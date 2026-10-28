import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { HydratedDocument, Types } from 'mongoose';
import { softDeletePlugin } from '../../common/plugins/soft-delete.plugin';
import { Currency } from '../../common/constants/currency';

export type PaymentDocument = HydratedDocument<Payment>;

@Schema({ timestamps: true, collection: 'payments' })
export class Payment {
  @Prop({ type: Types.ObjectId, ref: 'Customer', required: true })
  customerId: Types.ObjectId;

  @Prop({ required: true, min: 0.01 })
  amount: number;

  @Prop({ required: true })
  date: Date;

  @Prop({ required: true, trim: true })
  method: string;

  @Prop({ trim: true })
  notes?: string;

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

export const PaymentSchema = SchemaFactory.createForClass(Payment);
PaymentSchema.plugin(softDeletePlugin);
PaymentSchema.index({ customerId: 1 });
PaymentSchema.index({ customerId: 1, settlementId: 1 });
PaymentSchema.index({ customerId: 1, currency: 1, settlementId: 1 });
PaymentSchema.index({ date: -1 });
