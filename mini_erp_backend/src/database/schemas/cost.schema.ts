import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { HydratedDocument } from 'mongoose';
import { softDeletePlugin } from '../../common/plugins/soft-delete.plugin';

export type CostDocument = HydratedDocument<Cost>;

@Schema({ _id: false })
export class AdditionalCost {
  @Prop({ required: true, trim: true })
  name: string;

  @Prop({ required: true, min: 0 })
  price: number;
}

export const AdditionalCostSchema = SchemaFactory.createForClass(AdditionalCost);

@Schema({ timestamps: true, collection: 'costs' })
export class Cost {
  @Prop({ required: true, trim: true })
  name: string;

  @Prop({ required: true, min: 0 })
  runtime: number;

  @Prop({ required: true, min: 0 })
  hourlyRate: number;

  @Prop({ required: true, min: 0 })
  boardPrice: number;

  @Prop({ required: true, min: 1 })
  quantity: number;

  @Prop({ required: true, min: 0 })
  wastePercentage: number;

  @Prop({ required: true, min: 0 })
  profitPercentage: number;

  @Prop({ type: [AdditionalCostSchema], default: [] })
  additionalCosts: AdditionalCost[];

  @Prop({ required: true, default: 0, min: 0 })
  woodCostPerUnit: number;

  @Prop({ required: true, default: 0, min: 0 })
  laserCostPerUnit: number;

  @Prop({ required: true, min: 0 })
  additionalCostsTotal: number;

  @Prop({ required: true, default: 0, min: 0 })
  baseCostPerUnit: number;

  @Prop({ required: true, default: 0, min: 0 })
  wasteCostPerUnit: number;

  @Prop({ required: true, min: 0 })
  costPerUnit: number;

  @Prop({ required: true, default: 0, min: 0 })
  profitPerUnit: number;

  @Prop({ required: true, min: 0 })
  sellingPricePerUnit: number;

  @Prop({ required: true, min: 0 })
  operatingCost: number;

  @Prop({ required: true, min: 0 })
  wasteCost: number;

  @Prop({ required: true, min: 0 })
  totalCost: number;

  @Prop({ required: true, min: 0 })
  profit: number;

  @Prop({ required: true, min: 0 })
  sellingPrice: number;

  @Prop()
  deletedAt?: Date;

  createdAt: Date;
  updatedAt: Date;
}

export const CostSchema = SchemaFactory.createForClass(Cost);
CostSchema.plugin(softDeletePlugin);
CostSchema.index({ name: 'text' });
