import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { HydratedDocument, Types } from 'mongoose';
import { randomUUID } from 'crypto';
import { softDeletePlugin } from '../../common/plugins/soft-delete.plugin';
import { UserRole } from '../../auth/interfaces/jwt-payload.interface';

export type UserDocument = HydratedDocument<User>;

@Schema({ timestamps: true, collection: 'users' })
export class User {
  /// Persisted public id. New documents get a UUID in the validate hook.
  /// Do not rely on a schema default here — Mongoose would invent a
  /// memory-only uid when loading legacy rows that never stored one.
  @Prop({ required: true, unique: true })
  uid: string;

  @Prop({ required: true, trim: true, lowercase: true })
  username: string;

  @Prop({ required: true })
  passwordHash: string;

  @Prop({ required: true, enum: UserRole, type: String })
  role: UserRole;

  @Prop({ type: Types.ObjectId, ref: 'Customer' })
  customerId?: Types.ObjectId;

  @Prop()
  fcmToken?: string;

  @Prop({ default: true })
  isActive: boolean;

  @Prop()
  lastLoginAt?: Date;

  @Prop()
  refreshTokenHash?: string;

  @Prop()
  deletedAt?: Date;

  createdAt: Date;
  updatedAt: Date;
}

export const UserSchema = SchemaFactory.createForClass(User);
UserSchema.plugin(softDeletePlugin);
UserSchema.index({ username: 1 }, { unique: true });
UserSchema.index({ customerId: 1 });

UserSchema.pre('validate', function persistUidOnCreate() {
  if (this.isNew) {
    const current = this.get('uid');
    if (typeof current !== 'string' || current.trim() === '') {
      this.set('uid', randomUUID());
    }
  }
});
