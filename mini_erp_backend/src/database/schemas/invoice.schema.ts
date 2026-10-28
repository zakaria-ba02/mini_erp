import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { HydratedDocument, Types } from 'mongoose';
import { softDeletePlugin } from '../../common/plugins/soft-delete.plugin';
import { Currency } from '../../common/constants/currency';

export type InvoiceDocument = HydratedDocument<Invoice>;

export enum InvoiceStatus {
  Unpaid = 'unpaid',
  Partial = 'partial',
  Paid = 'paid',
}

@Schema({ _id: false })
export class InvoiceItem {
  @Prop({ type: Types.ObjectId, ref: 'Cost' })
  costId?: Types.ObjectId;

  @Prop({ required: true, trim: true })
  name: string;

  @Prop({ required: true, min: 0 })
  quantity: number;

  @Prop({ required: true, min: 0 })
  unitPrice: number;

  @Prop({ required: true, min: 0 })
  lineTotal: number;
}

export const InvoiceItemSchema = SchemaFactory.createForClass(InvoiceItem);

@Schema({ timestamps: true, collection: 'invoices' })
export class Invoice {
  @Prop({ type: Types.ObjectId, ref: 'Customer', required: true })
  customerId: Types.ObjectId;

  @Prop({ required: true })
  date: Date;

  @Prop({ type: [InvoiceItemSchema], required: true, default: [] })
  items: InvoiceItem[];

  @Prop({ required: true, min: 0 })
  total: number;

  @Prop({
    required: true,
    enum: InvoiceStatus,
    type: String,
    default: InvoiceStatus.Unpaid,
  })
  status: InvoiceStatus;

  @Prop({
    required: true,
    enum: Currency,
    type: String,
    default: Currency.SYP,
    index: true,
  })
  currency: Currency;

  @Prop({ type: Types.ObjectId, ref: 'Settlement', default: null, index: true })
  settlementId?: Types.ObjectId | null;

  @Prop()
  deletedAt?: Date;

  createdAt: Date;
  updatedAt: Date;
}

export const InvoiceSchema = SchemaFactory.createForClass(Invoice);
InvoiceSchema.plugin(softDeletePlugin);
InvoiceSchema.index({ customerId: 1 });
InvoiceSchema.index({ customerId: 1, settlementId: 1 });
InvoiceSchema.index({ customerId: 1, currency: 1, settlementId: 1 });
InvoiceSchema.index({ date: -1 });
