import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { HydratedDocument, Types } from 'mongoose';
import { Currency } from '../../common/constants/currency';

export type SettlementDocument = HydratedDocument<Settlement>;

@Schema({ timestamps: { createdAt: true, updatedAt: false }, collection: 'settlements' })
export class Settlement {
  @Prop({ type: Types.ObjectId, ref: 'Customer', required: true, index: true })
  customerId: Types.ObjectId;

  @Prop({ required: true, enum: Currency, type: String, default: Currency.SYP })
  currency: Currency;

  @Prop({ required: true, min: 0 })
  totalInvoices: number;

  @Prop({ required: true, min: 0 })
  totalPayments: number;

  @Prop({ required: true })
  balanceAtSettlement: number;

  @Prop({ required: true, trim: true })
  settledBy: string;

  createdAt: Date;
}

export const SettlementSchema = SchemaFactory.createForClass(Settlement);
SettlementSchema.index({ customerId: 1, createdAt: -1 });
SettlementSchema.index({ customerId: 1, currency: 1, createdAt: -1 });
