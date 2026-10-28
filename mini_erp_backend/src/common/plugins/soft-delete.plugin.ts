import { Schema } from 'mongoose';

const appliedSchemas = new WeakSet<Schema>();

export function softDeletePlugin(schema: Schema): void {
  if (appliedSchemas.has(schema)) {
    return;
  }
  appliedSchemas.add(schema);

  if (!schema.path('deletedAt')) {
    schema.add({
      deletedAt: { type: Date, default: null, index: true },
    });
  }

  const excludeDeleted = function (this: { where: (criteria: object) => void }) {
    this.where({ deletedAt: null });
  };

  schema.pre('find' as never, excludeDeleted as never);
  schema.pre('findOne' as never, excludeDeleted as never);
  schema.pre('countDocuments' as never, excludeDeleted as never);
  schema.pre('findOneAndUpdate' as never, excludeDeleted as never);
  schema.pre('updateOne' as never, excludeDeleted as never);
  schema.pre('updateMany' as never, excludeDeleted as never);

  schema.methods.softDelete = async function softDelete(): Promise<void> {
    this.deletedAt = new Date();
    await this.save();
  };
}

export interface SoftDeleteDocument {
  deletedAt?: Date | null;
  softDelete(): Promise<void>;
}
