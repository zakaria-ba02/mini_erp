import { Injectable, HttpStatus } from '@nestjs/common';
import { InjectConnection, InjectModel } from '@nestjs/mongoose';
import { Connection, Model, QueryFilter, Types } from 'mongoose';
import { Payment, PaymentDocument } from '../database/schemas/payment.schema';
import { CreatePaymentDto, UpdatePaymentDto } from './dto/create-payment.dto';
import { PaymentQueryDto } from './dto/payment-query.dto';
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
export class PaymentsService {
  constructor(
    @InjectModel(Payment.name)
    private readonly paymentModel: Model<PaymentDocument>,
    @InjectConnection() private readonly connection: Connection,
    private readonly customersService: CustomersService,
    private readonly auditLogsService: AuditLogsService,
    private readonly notificationsService: NotificationsService,
    private readonly usersService: UsersService,
  ) {}

  async create(dto: CreatePaymentDto, adminUserId: string) {
    await this.customersService.findById(dto.customerId);

    const payment = await withTransaction(this.connection, async (session) => {
      await this.customersService.adjustBalance(
        dto.customerId,
        -dto.amount,
        dto.currency,
        session,
      );

      const [created] = await this.paymentModel.create(
        [
          {
            customerId: new Types.ObjectId(dto.customerId),
            amount: dto.amount,
            date: dto.date,
            method: dto.method.trim(),
            notes: dto.notes?.trim(),
            currency: dto.currency,
            settlementId: null,
          },
        ],
        { session },
      );

      await this.auditLogsService.logInTransaction(session, {
        userId: adminUserId,
        action: 'CREATE_PAYMENT',
        entity: 'Payment',
        entityId: created._id.toString(),
        newData: {
          customerId: dto.customerId,
          amount: dto.amount,
          currency: dto.currency,
        },
      });

      return created;
    });

    await this.notificationsService.sendToCustomer(
      dto.customerId,
      'دفعة جديدة',
      `تم تسجيل دفعة بقيمة ${dto.amount}`,
      { paymentId: payment._id.toString(), type: 'payment_created' },
    );

    return payment;
  }

  async findAll(query: PaymentQueryDto, currentUser: JwtPayload) {
    const filter: QueryFilter<PaymentDocument> = {};

    if (currentUser.role === UserRole.Customer) {
      filter.customerId = new Types.ObjectId(currentUser.customerId);
    } else if (query.customerId) {
      filter.customerId = new Types.ObjectId(query.customerId);
    }

    filter.settlementId = settlementIdQuery(query.settlementId);

    if (query.currency) {
      filter.currency = query.currency;
    }

    if (query.fromDate || query.toDate) {
      filter.date = {};
      if (query.fromDate) filter.date.$gte = query.fromDate;
      if (query.toDate) filter.date.$lte = query.toDate;
    }

    const skip = getPaginationSkip(query.page, query.limit);
    const [data, total] = await Promise.all([
      this.paymentModel
        .find(filter)
        .sort({ date: -1 })
        .skip(skip)
        .limit(query.limit),
      this.paymentModel.countDocuments(filter),
    ]);

    return buildPaginatedResponse(data, total, query.page, query.limit);
  }

  async findById(id: string, currentUser: JwtPayload): Promise<PaymentDocument> {
    const payment = await this.paymentModel.findById(id);
    if (!payment) {
      throw new BusinessException(
        ErrorCode.PAYMENT_NOT_FOUND,
        'Payment not found',
        HttpStatus.NOT_FOUND,
      );
    }

    this.assertCustomerAccess(payment.customerId.toString(), currentUser);
    return payment;
  }

  async update(id: string, dto: UpdatePaymentDto, adminUserId: string) {
    const payment = await this.paymentModel.findById(id);
    if (!payment) {
      throw new BusinessException(
        ErrorCode.PAYMENT_NOT_FOUND,
        'Payment not found',
        HttpStatus.NOT_FOUND,
      );
    }

    assertDocumentUnsettled(payment.settlementId);

    const oldAmount = payment.amount;
    const oldCustomerId = payment.customerId.toString();
    const oldCurrency = resolveCurrency(payment.currency);
    const oldData = payment.toObject();

    if (dto.customerId !== undefined) {
      await this.customersService.findById(dto.customerId);
      payment.customerId = new Types.ObjectId(dto.customerId);
    }
    if (dto.amount !== undefined) payment.amount = dto.amount;
    if (dto.date !== undefined) payment.date = dto.date;
    if (dto.method !== undefined) payment.method = dto.method.trim();
    if (dto.notes !== undefined) payment.notes = dto.notes?.trim();
    if (dto.currency !== undefined) payment.currency = dto.currency;

    const newCustomerId = payment.customerId.toString();
    const newCurrency = resolveCurrency(payment.currency);

    await withTransaction(this.connection, async (session) => {
      if (oldCustomerId === newCustomerId && oldCurrency === newCurrency) {
        const balanceDelta = oldAmount - payment.amount;
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
          oldAmount,
          oldCurrency,
          session,
        );
        await this.customersService.adjustBalance(
          newCustomerId,
          -payment.amount,
          newCurrency,
          session,
        );
      }

      await payment.save({ session });

      await this.auditLogsService.logInTransaction(session, {
        userId: adminUserId,
        action: 'UPDATE_PAYMENT',
        entity: 'Payment',
        entityId: id,
        oldData: {
          amount: oldData.amount,
          customerId: oldCustomerId,
          currency: oldCurrency,
        },
        newData: {
          amount: payment.amount,
          customerId: newCustomerId,
          currency: newCurrency,
        },
      });
    });

    return payment;
  }

  async softDelete(id: string, adminUserId: string) {
    const payment = await this.paymentModel.findById(id);
    if (!payment) {
      throw new BusinessException(
        ErrorCode.PAYMENT_NOT_FOUND,
        'Payment not found',
        HttpStatus.NOT_FOUND,
      );
    }

    assertDocumentUnsettled(payment.settlementId);

    const oldAmount = payment.amount;
    const customerId = payment.customerId.toString();
    const currency = resolveCurrency(payment.currency);

    await withTransaction(this.connection, async (session) => {
      await this.customersService.adjustBalance(
        customerId,
        oldAmount,
        currency,
        session,
      );

      payment.deletedAt = new Date();
      await payment.save({ session });

      await this.auditLogsService.logInTransaction(session, {
        userId: adminUserId,
        action: 'DELETE_PAYMENT',
        entity: 'Payment',
        entityId: id,
        oldData: { amount: oldAmount },
      });
    });

    return { success: true };
  }

  private assertCustomerAccess(
    paymentCustomerId: string,
    currentUser: JwtPayload,
  ): void {
    if (
      currentUser.role === UserRole.Customer &&
      currentUser.customerId !== paymentCustomerId
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
