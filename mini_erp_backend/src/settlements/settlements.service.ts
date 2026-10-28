import { Injectable, HttpStatus } from '@nestjs/common';
import { InjectConnection, InjectModel } from '@nestjs/mongoose';
import { Connection, Model, Types, ClientSession } from 'mongoose';
import {
  Settlement,
  SettlementDocument,
} from '../database/schemas/settlement.schema';
import {
  Customer,
  CustomerDocument,
} from '../database/schemas/customer.schema';
import { Invoice, InvoiceDocument } from '../database/schemas/invoice.schema';
import { Payment, PaymentDocument } from '../database/schemas/payment.schema';
import { PaginationQueryDto } from '../common/dto/pagination-query.dto';
import {
  buildPaginatedResponse,
  getPaginationSkip,
} from '../common/utils/pagination.util';
import { withTransaction } from '../common/utils/transaction.util';
import { ErrorCode } from '../common/constants/error-codes';
import { BusinessException } from '../common/exceptions/business.exception';
import { AuditLogsService } from '../audit-logs/audit-logs.service';
import {
  balancesMatch,
  computeSettlementTotals,
} from './utils/settlement-totals.util';
import { Currency } from '../common/constants/currency';
import { unsettledDocumentsFilter } from '../common/utils/currency-filter.util';

@Injectable()
export class SettlementsService {
  constructor(
    @InjectModel(Settlement.name)
    private readonly settlementModel: Model<SettlementDocument>,
    @InjectModel(Customer.name)
    private readonly customerModel: Model<CustomerDocument>,
    @InjectModel(Invoice.name)
    private readonly invoiceModel: Model<InvoiceDocument>,
    @InjectModel(Payment.name)
    private readonly paymentModel: Model<PaymentDocument>,
    @InjectConnection() private readonly connection: Connection,
    private readonly auditLogsService: AuditLogsService,
  ) {}

  async settle(
    customerId: string,
    currency: Currency,
    actor: { adminUserId: string; adminUid: string },
  ) {
    return withTransaction(this.connection, async (session) => {
      const customer = await this.customerModel
        .findById(customerId)
        .session(session);

      if (!customer) {
        throw new BusinessException(
          ErrorCode.CUSTOMER_NOT_FOUND,
          'Customer not found',
          HttpStatus.NOT_FOUND,
        );
      }

      const balances = await this.ensureCustomerBalances(customer, session);
      const customerObjectId = customer._id;
      const unsettledFilter = unsettledDocumentsFilter(
        customerObjectId,
        currency,
      );

      const [invoices, payments] = await Promise.all([
        this.invoiceModel.find(unsettledFilter).session(session),
        this.paymentModel.find(unsettledFilter).session(session),
      ]);

      const totals = computeSettlementTotals({ invoices, payments });

      if (!balancesMatch(totals.balanceAtSettlement, balances[currency])) {
        throw new BusinessException(
          ErrorCode.SETTLEMENT_BALANCE_MISMATCH,
          'Settlement totals do not match the current customer balance',
          HttpStatus.CONFLICT,
        );
      }

      const [settlement] = await this.settlementModel.create(
        [
          {
            customerId: customerObjectId,
            currency,
            totalInvoices: totals.totalInvoices,
            totalPayments: totals.totalPayments,
            balanceAtSettlement: totals.balanceAtSettlement,
            settledBy: actor.adminUid,
          },
        ],
        { session },
      );

      await this.invoiceModel.updateMany(
        unsettledFilter,
        { $set: { settlementId: settlement._id } },
        { session },
      );
      await this.paymentModel.updateMany(
        unsettledFilter,
        { $set: { settlementId: settlement._id } },
        { session },
      );

      customer.set('balances', {
        SYP: currency === Currency.SYP ? 0 : balances.SYP,
        USD: currency === Currency.USD ? 0 : balances.USD,
      });
      await customer.save({ session });

      await this.auditLogsService.logInTransaction(session, {
        userId: actor.adminUserId,
        action: 'SETTLE_CUSTOMER_ACCOUNT',
        entity: 'Customer',
        entityId: customerId,
        oldData: { currency, balance: totals.balanceAtSettlement },
        newData: {
          settlementId: settlement._id.toString(),
          currency,
          totalInvoices: totals.totalInvoices,
          totalPayments: totals.totalPayments,
          balanceAtSettlement: totals.balanceAtSettlement,
          invoiceCount: invoices.length,
          paymentCount: payments.length,
        },
      });

      return settlement;
    });
  }

  private async ensureCustomerBalances(
    customer: CustomerDocument,
    session: ClientSession,
  ): Promise<{ SYP: number; USD: number }> {
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
      await customer.save({ session });
    }
    return balances;
  }

  async findByCustomer(customerId: string, query: PaginationQueryDto) {
    const customer = await this.customerModel.findById(customerId);
    if (!customer) {
      throw new BusinessException(
        ErrorCode.CUSTOMER_NOT_FOUND,
        'Customer not found',
        HttpStatus.NOT_FOUND,
      );
    }

    const filter = { customerId: new Types.ObjectId(customerId) };
    const skip = getPaginationSkip(query.page, query.limit);
    const [data, total] = await Promise.all([
      this.settlementModel
        .find(filter)
        .sort({ createdAt: -1 })
        .skip(skip)
        .limit(query.limit),
      this.settlementModel.countDocuments(filter),
    ]);

    return buildPaginatedResponse(data, total, query.page, query.limit);
  }
}
