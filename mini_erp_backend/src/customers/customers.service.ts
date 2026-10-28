import { Injectable, HttpStatus } from '@nestjs/common';
import { InjectConnection, InjectModel } from '@nestjs/mongoose';
import { Connection, Model, QueryFilter, ClientSession } from 'mongoose';
import { Customer, CustomerDocument } from '../database/schemas/customer.schema';
import { CreateCustomerDto } from './dto/create-customer.dto';
import { UpdateCustomerDto } from './dto/update-customer.dto';
import { PaginationQueryDto } from '../common/dto/pagination-query.dto';
import {
  buildPaginatedResponse,
  getPaginationSkip,
} from '../common/utils/pagination.util';
import { buildSearchRegex } from '../common/utils/search.util';
import { ErrorCode } from '../common/constants/error-codes';
import { BusinessException } from '../common/exceptions/business.exception';
import { UsersService } from '../users/users.service';
import { withTransaction } from '../common/utils/transaction.util';
import { AuditLogsService } from '../audit-logs/audit-logs.service';
import { Currency } from '../common/constants/currency';

@Injectable()
export class CustomersService {
  constructor(
    @InjectModel(Customer.name)
    private readonly customerModel: Model<CustomerDocument>,
    @InjectConnection() private readonly connection: Connection,
    private readonly usersService: UsersService,
    private readonly auditLogsService: AuditLogsService,
  ) {}

  async create(dto: CreateCustomerDto, adminUserId: string) {
    return withTransaction(this.connection, async (session) => {
      const [customer] = await this.customerModel.create(
        [
          {
            name: dto.name.trim(),
            phone: dto.phone.trim(),
            notes: dto.notes?.trim(),
            balances: { SYP: 0, USD: 0 },
          },
        ],
        { session },
      );

      const user = await this.usersService.createCustomerAccount(
        {
          customerId: customer._id.toString(),
          username: dto.account.username,
          password: dto.account.password,
        },
        session,
      );

      await this.auditLogsService.logInTransaction(session, {
        userId: adminUserId,
        action: 'CREATE_CUSTOMER',
        entity: 'Customer',
        entityId: customer._id.toString(),
        newData: {
          name: customer.name,
          phone: customer.phone,
          username: user.username,
        },
      });

      return {
        customer,
        user: {
          uid: user.uid,
          username: user.username,
          role: user.role,
          customerId: customer._id.toString(),
        },
      };
    });
  }

  async findAll(query: PaginationQueryDto) {
    const filter: QueryFilter<CustomerDocument> = {};
    const searchRegex = buildSearchRegex(query.search);

    if (searchRegex) {
      filter.$or = [{ name: searchRegex }, { phone: searchRegex }];
    }

    const skip = getPaginationSkip(query.page, query.limit);
    const [data, total] = await Promise.all([
      this.customerModel
        .find(filter)
        .sort({ createdAt: -1 })
        .skip(skip)
        .limit(query.limit),
      this.customerModel.countDocuments(filter),
    ]);

    return buildPaginatedResponse(data, total, query.page, query.limit);
  }

  async findById(id: string): Promise<CustomerDocument> {
    const customer = await this.customerModel.findById(id);
    if (!customer) {
      throw new BusinessException(
        ErrorCode.CUSTOMER_NOT_FOUND,
        'Customer not found',
        HttpStatus.NOT_FOUND,
      );
    }
    return customer;
  }

  async update(id: string, dto: UpdateCustomerDto, adminUserId: string) {
    const customer = await this.findById(id);
    const oldData = {
      name: customer.name,
      phone: customer.phone,
      notes: customer.notes,
    };

    if (dto.name !== undefined) customer.name = dto.name.trim();
    if (dto.phone !== undefined) customer.phone = dto.phone.trim();
    if (dto.notes !== undefined) customer.notes = dto.notes?.trim();

    await customer.save();

    await this.auditLogsService.log({
      userId: adminUserId,
      action: 'UPDATE_CUSTOMER',
      entity: 'Customer',
      entityId: id,
      oldData,
      newData: {
        name: customer.name,
        phone: customer.phone,
        notes: customer.notes,
      },
    });

    return customer;
  }

  async softDelete(id: string, adminUserId: string) {
    const customer = await this.findById(id);
    customer.deletedAt = new Date();
    await customer.save();
    await this.usersService.softDeleteByCustomerId(id);

    await this.auditLogsService.log({
      userId: adminUserId,
      action: 'DELETE_CUSTOMER',
      entity: 'Customer',
      entityId: id,
      oldData: {
        name: customer.name,
        phone: customer.phone,
      },
    });

    return { success: true };
  }

  async resetPassword(
    customerId: string,
    newPassword: string,
    adminUserId: string,
  ) {
    const customer = await this.findById(customerId);
    const user = await this.usersService.findByCustomerId(customerId);

    if (!user) {
      throw new BusinessException(
        ErrorCode.USER_NOT_FOUND,
        'Customer account not found',
        HttpStatus.NOT_FOUND,
      );
    }

    await this.usersService.resetPassword(user._id.toString(), newPassword);

    await this.auditLogsService.log({
      userId: adminUserId,
      action: 'RESET_CUSTOMER_PASSWORD',
      entity: 'Customer',
      entityId: customerId,
      newData: { customerName: customer.name, username: user.username },
    });

    return { success: true };
  }

  async ensureBalances(
    customerId: string,
    session?: ClientSession,
  ): Promise<{ SYP: number; USD: number }> {
    const customer = await this.customerModel
      .findById(customerId)
      .session(session ?? null);

    if (!customer) {
      throw new BusinessException(
        ErrorCode.CUSTOMER_NOT_FOUND,
        'Customer not found',
        HttpStatus.NOT_FOUND,
      );
    }

    const raw = await this.customerModel.collection.findOne(
      { _id: customer._id },
      { projection: { balances: 1, balance: 1 } },
    );
    const existing = raw?.balances as { SYP?: number; USD?: number } | undefined;
    const legacy = typeof raw?.balance === 'number' ? raw.balance : 0;
    const balances = {
      SYP: typeof existing?.SYP === 'number' ? existing.SYP : legacy,
      USD: typeof existing?.USD === 'number' ? existing.USD : 0,
    };

    const missing =
      !existing ||
      typeof existing.SYP !== 'number' ||
      typeof existing.USD !== 'number';

    if (missing) {
      customer.set('balances', balances);
      await customer.save(session ? { session } : {});
    }

    return balances;
  }

  async adjustBalance(
    customerId: string,
    delta: number,
    currency: Currency,
    session?: ClientSession,
  ): Promise<void> {
    await this.ensureBalances(customerId, session);

    const result = await this.customerModel.updateOne(
      { _id: customerId, deletedAt: null },
      { $inc: { [`balances.${currency}`]: delta } },
      session ? { session } : {},
    );

    if (result.matchedCount === 0) {
      throw new BusinessException(
        ErrorCode.CUSTOMER_NOT_FOUND,
        'Customer not found',
        HttpStatus.NOT_FOUND,
      );
    }
  }
}
