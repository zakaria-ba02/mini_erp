import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import {
  Settlement,
  SettlementSchema,
} from '../database/schemas/settlement.schema';
import {
  Customer,
  CustomerSchema,
} from '../database/schemas/customer.schema';
import { Invoice, InvoiceSchema } from '../database/schemas/invoice.schema';
import { Payment, PaymentSchema } from '../database/schemas/payment.schema';
import { SettlementsService } from './settlements.service';
import { SettlementsController } from './settlements.controller';
import { AuditLogsModule } from '../audit-logs/audit-logs.module';
import { UsersModule } from '../users/users.module';

@Module({
  imports: [
    MongooseModule.forFeature([
      { name: Settlement.name, schema: SettlementSchema },
      { name: Customer.name, schema: CustomerSchema },
      { name: Invoice.name, schema: InvoiceSchema },
      { name: Payment.name, schema: PaymentSchema },
    ]),
    AuditLogsModule,
    UsersModule,
  ],
  controllers: [SettlementsController],
  providers: [SettlementsService],
  exports: [SettlementsService],
})
export class SettlementsModule {}
