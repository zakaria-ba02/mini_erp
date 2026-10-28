import { Injectable, HttpStatus } from '@nestjs/common';
import { InjectConnection, InjectModel } from '@nestjs/mongoose';
import {
  Connection,
  Model,
  QueryFilter,
  Types,
} from 'mongoose';
import {
  Invoice,
  InvoiceDocument,
  InvoiceItem,
  InvoiceStatus,
} from '../database/schemas/invoice.schema';
import { Cost, CostDocument } from '../database/schemas/cost.schema';
import {
  CreateInvoiceDto,
  CreateInvoiceItemDto,
  UpdateInvoiceDto,
} from './dto/create-invoice.dto';
import { InvoiceQueryDto } from './dto/invoice-query.dto';
import {
  buildPaginatedResponse,
  getPaginationSkip,
} from '../common/utils/pagination.util';
import { ErrorCode } from '../common/constants/error-codes';
import { BusinessException } from '../common/exceptions/business.exception';
import { CustomersService } from '../customers/customers.service';
import { withTransaction } from '../common/utils/transaction.util';
import { AuditLogsService } from '../audit-logs/audit-logs.service';
import { NotificationsService } from '../notifications/notifications.service';
import { JwtPayload, UserRole } from '../auth/interfaces/jwt-payload.interface';
import { UsersService } from '../users/users.service';
import {
  settlementIdQuery,
  assertDocumentUnsettled,
} from '../common/utils/settlement-filter.util';
import { resolveCurrency } from '../common/constants/currency';

@Injectable()
export class InvoicesService {
  constructor(
    @InjectModel(Invoice.name)
    private readonly invoiceModel: Model<InvoiceDocument>,
    @InjectModel(Cost.name) private readonly costModel: Model<CostDocument>,
    @InjectConnection() private readonly connection: Connection,
    private readonly customersService: CustomersService,
    private readonly auditLogsService: AuditLogsService,
    private readonly notificationsService: NotificationsService,
    private readonly usersService: UsersService,
  ) {}

  async create(dto: CreateInvoiceDto, adminUserId: string) {
    const items = await this.resolveItems(dto.items);
    const total = this.calculateTotal(items);

    const invoice = await withTransaction(this.connection, async (session) => {
      await this.customersService.adjustBalance(
        dto.customerId,
        total,
        dto.currency,
        session,
      );

      const [created] = await this.invoiceModel.create(
        [
          {
            customerId: new Types.ObjectId(dto.customerId),
            date: dto.date,
            items,
            total,
            status: InvoiceStatus.Unpaid,
            currency: dto.currency,
            settlementId: null,
          },
        ],
        { session },
      );

      await this.auditLogsService.logInTransaction(session, {
        userId: adminUserId,
        action: 'CREATE_INVOICE',
        entity: 'Invoice',
        entityId: created._id.toString(),
        newData: { customerId: dto.customerId, total, currency: dto.currency },
      });

      return created;
    });

    await this.notificationsService.sendToCustomer(
      dto.customerId,
      'فاتورة جديدة',
      `تم إنشاء فاتورة بقيمة ${total}`,
      { invoiceId: invoice._id.toString(), type: 'invoice_created' },
    );

    return invoice;
  }

  async findAll(query: InvoiceQueryDto, currentUser: JwtPayload) {
    const filter: QueryFilter<InvoiceDocument> = {};

    if (currentUser.role === UserRole.Customer) {
      filter.customerId = new Types.ObjectId(currentUser.customerId);
    } else if (query.customerId) {
      filter.customerId = new Types.ObjectId(query.customerId);
    }

    filter.settlementId = settlementIdQuery(query.settlementId);

    if (query.currency) {
      filter.currency = query.currency;
    }

    if (query.status) {
      filter.status = query.status;
    }

    if (query.fromDate || query.toDate) {
      filter.date = {};
      if (query.fromDate) filter.date.$gte = query.fromDate;
      if (query.toDate) filter.date.$lte = query.toDate;
    }

    const skip = getPaginationSkip(query.page, query.limit);
    const [data, total] = await Promise.all([
      this.invoiceModel
        .find(filter)
        .sort({ date: -1 })
        .skip(skip)
        .limit(query.limit),
      this.invoiceModel.countDocuments(filter),
    ]);

    return buildPaginatedResponse(data, total, query.page, query.limit);
  }

  async findById(id: string, currentUser: JwtPayload): Promise<InvoiceDocument> {
    const invoice = await this.invoiceModel.findById(id);
    if (!invoice) {
      throw new BusinessException(
        ErrorCode.INVOICE_NOT_FOUND,
        'Invoice not found',
        HttpStatus.NOT_FOUND,
      );
    }

    this.assertCustomerAccess(invoice.customerId.toString(), currentUser);
    return invoice;
  }

  async update(id: string, dto: UpdateInvoiceDto, adminUserId: string) {
    const invoice = await this.invoiceModel.findById(id);
    if (!invoice) {
      throw new BusinessException(
        ErrorCode.INVOICE_NOT_FOUND,
        'Invoice not found',
        HttpStatus.NOT_FOUND,
      );
    }

    assertDocumentUnsettled(invoice.settlementId);

    const oldTotal = invoice.total;
    const oldCustomerId = invoice.customerId.toString();
    const oldCurrency = resolveCurrency(invoice.currency);
    const oldData = invoice.toObject();

    if (dto.items) {
      invoice.items = await this.resolveItems(dto.items);
      invoice.total = this.calculateTotal(invoice.items);
    }

    if (dto.customerId !== undefined) {
      invoice.customerId = new Types.ObjectId(dto.customerId);
    }
    if (dto.date !== undefined) invoice.date = dto.date;
    if (dto.status !== undefined) invoice.status = dto.status;
    if (dto.currency !== undefined) invoice.currency = dto.currency;

    const newCustomerId = invoice.customerId.toString();
    const newCurrency = resolveCurrency(invoice.currency);

    await withTransaction(this.connection, async (session) => {
      if (oldCustomerId === newCustomerId && oldCurrency === newCurrency) {
        const balanceDelta = invoice.total - oldTotal;
        if (balanceDelta !== 0) {
          await this.customersService.adjustBalance(
            newCustomerId,
            balanceDelta,
            newCurrency,
            session,
          );
        }
      } else {
        await this.customersService.adjustBalance(
          oldCustomerId,
          -oldTotal,
          oldCurrency,
          session,
        );
        await this.customersService.adjustBalance(
          newCustomerId,
          invoice.total,
          newCurrency,
          session,
        );
      }

      await invoice.save({ session });

      await this.auditLogsService.logInTransaction(session, {
        userId: adminUserId,
        action: 'UPDATE_INVOICE',
        entity: 'Invoice',
        entityId: id,
        oldData: {
          total: oldData.total,
          status: oldData.status,
          currency: oldCurrency,
        },
        newData: {
          total: invoice.total,
          status: invoice.status,
          currency: newCurrency,
        },
      });
    });

    return invoice;
  }

  async softDelete(id: string, adminUserId: string) {
    const invoice = await this.invoiceModel.findById(id);
    if (!invoice) {
      throw new BusinessException(
        ErrorCode.INVOICE_NOT_FOUND,
        'Invoice not found',
        HttpStatus.NOT_FOUND,
      );
    }

    assertDocumentUnsettled(invoice.settlementId);

    const oldTotal = invoice.total;
    const customerId = invoice.customerId.toString();
    const currency = resolveCurrency(invoice.currency);

    await withTransaction(this.connection, async (session) => {
      await this.customersService.adjustBalance(
        customerId,
        -oldTotal,
        currency,
        session,
      );

      invoice.deletedAt = new Date();
      await invoice.save({ session });

      await this.auditLogsService.logInTransaction(session, {
        userId: adminUserId,
        action: 'DELETE_INVOICE',
        entity: 'Invoice',
        entityId: id,
        oldData: { total: oldTotal },
      });
    });

    return { success: true };
  }

  private async resolveItems(
    items: CreateInvoiceItemDto[],
  ): Promise<InvoiceItem[]> {
    const resolved: InvoiceItem[] = [];

    for (const item of items) {
      let name = item.name?.trim();

      if (item.costId) {
        const cost = await this.costModel.findById(item.costId);
        if (!cost) {
          throw new BusinessException(
            ErrorCode.COST_NOT_FOUND,
            `Cost ${item.costId} not found`,
            HttpStatus.BAD_REQUEST,
          );
        }
        name = cost.name;
      }

      if (!name) {
        throw new BusinessException(
          ErrorCode.VALIDATION_ERROR,
          'Manual invoice items require a name',
          HttpStatus.BAD_REQUEST,
        );
      }

      const lineTotal = item.quantity * item.unitPrice;
      resolved.push({
        costId: item.costId ? new Types.ObjectId(item.costId) : undefined,
        name,
        quantity: item.quantity,
        unitPrice: item.unitPrice,
        lineTotal,
      });
    }

    return resolved;
  }

  private calculateTotal(items: InvoiceItem[]): number {
    return items.reduce((sum, item) => sum + item.lineTotal, 0);
  }

  private assertCustomerAccess(
    invoiceCustomerId: string,
    currentUser: JwtPayload,
  ): void {
    if (
      currentUser.role === UserRole.Customer &&
      currentUser.customerId !== invoiceCustomerId
    ) {
      throw new BusinessException(
        ErrorCode.FORBIDDEN,
        'Forbidden',
        HttpStatus.FORBIDDEN,
      );
    }
  }

  async resolveAdminUserId(uid: string): Promise<string> {
    const admin = await this.usersService.findByUid(uid);
    return admin!._id.toString();
  }
}
