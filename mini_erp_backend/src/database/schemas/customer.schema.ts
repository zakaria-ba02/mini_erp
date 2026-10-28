import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { HydratedDocument } from 'mongoose';
import { softDeletePlugin } from '../../common/plugins/soft-delete.plugin';

export type CustomerDocument = HydratedDocument<Customer>;

@Schema({ _id: false })
export class CustomerBalances {
  @Prop({ required: true, default: 0 })
  SYP: number;

  @Prop({ required: true, default: 0 })
  USD: number;
}

export const CustomerBalancesSchema =
  SchemaFactory.createForClass(CustomerBalances);

@Schema({ timestamps: true, collection: 'customers' })
export class Customer {
  @Prop({ required: true, trim: true })
  name: string;

  @Prop({ required: true, trim: true })
  phone: string;

  @Prop({ trim: true })
  notes?: string;

  @Prop({ type: CustomerBalancesSchema })
  balances?: CustomerBalances;

  @Prop()
  deletedAt?: Date;

  createdAt: Date;
  updatedAt: Date;
}

export const CustomerSchema = SchemaFactory.createForClass(Customer);
CustomerSchema.plugin(softDeletePlugin);
CustomerSchema.index({ name: 'text', phone: 'text' });
CustomerSchema.set('toJSON', {
  transform(_doc, ret) {
    const row = ret as unknown as {
      balances?: { SYP?: number; USD?: number };
      balance?: number;
    };
    const legacy = typeof row.balance === 'number' ? row.balance : 0;
    row.balances = {
      SYP: row.balances?.SYP ?? legacy,
      USD: row.balances?.USD ?? 0,
    };
    delete row.balance;
    return row;
  },
});
