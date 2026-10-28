import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { Invoice, InvoiceSchema } from '../database/schemas/invoice.schema';
import { Cost, CostSchema } from '../database/schemas/cost.schema';
import { InvoicesService } from './invoices.service';
import { InvoicesController } from './invoices.controller';
import { CustomersModule } from '../customers/customers.module';
import { AuditLogsModule } from '../audit-logs/audit-logs.module';
import { NotificationsModule } from '../notifications/notifications.module';
import { UsersModule } from '../users/users.module';

@Module({
  imports: [
    MongooseModule.forFeature([
      { name: Invoice.name, schema: InvoiceSchema },
      { name: Cost.name, schema: CostSchema },
    ]),
    CustomersModule,
    AuditLogsModule,
    NotificationsModule,
    UsersModule,
  ],
  controllers: [InvoicesController],
  providers: [InvoicesService],
  exports: [InvoicesService],
})
export class InvoicesModule {}
