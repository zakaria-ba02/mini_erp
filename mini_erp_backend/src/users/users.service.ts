import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { randomUUID } from 'crypto';
import * as bcrypt from 'bcrypt';
import { User, UserDocument } from '../database/schemas/user.schema';
import { UserRole } from '../auth/interfaces/jwt-payload.interface';
import { ErrorCode } from '../common/constants/error-codes';
import { BusinessException } from '../common/exceptions/business.exception';
import { HttpStatus } from '@nestjs/common';

@Injectable()
export class UsersService {
  private readonly saltRounds = 12;

  constructor(
    @InjectModel(User.name) private readonly userModel: Model<UserDocument>,
  ) {}

  async findByUsername(username: string): Promise<UserDocument | null> {
    return this.userModel.findOne({ username: username.toLowerCase().trim() });
  }

  async findByUid(uid: string): Promise<UserDocument | null> {
    if (typeof uid !== 'string' || uid.trim() === '') {
      return null;
    }
    return this.userModel.findOne({ uid: uid.trim() });
  }

  /**
   * Returns a uid that is actually stored on the Mongo document.
   * Legacy users may have no uid field; Mongoose must not invent one
   * in memory and then sign a JWT that JwtStrategy cannot look up.
   */
  async ensurePersistedUid(user: UserDocument): Promise<string> {
    const raw = await this.userModel.collection.findOne(
      { _id: user._id },
      { projection: { uid: 1 } },
    );
    const existing =
      typeof raw?.uid === 'string' && raw.uid.trim() !== ''
        ? raw.uid.trim()
        : '';

    if (existing) {
      user.uid = existing;
      return existing;
    }

    let uid = randomUUID();
    for (let attempt = 0; attempt < 8; attempt += 1) {
      const clash = await this.userModel.collection.findOne({ uid });
      if (!clash) {
        break;
      }
      uid = randomUUID();
    }

    await this.userModel.collection.updateOne(
      {
        _id: user._id,
        $or: [
          { uid: { $exists: false } },
          { uid: null },
          { uid: '' },
        ],
      },
      { $set: { uid } },
    );

    const saved = await this.userModel.collection.findOne(
      { _id: user._id },
      { projection: { uid: 1 } },
    );
    const persisted =
      typeof saved?.uid === 'string' && saved.uid.trim() !== ''
        ? saved.uid.trim()
        : uid;

    user.uid = persisted;
    return persisted;
  }

  async findById(id: string): Promise<UserDocument | null> {
    return this.userModel.findById(id);
  }

  async findByCustomerId(customerId: string): Promise<UserDocument | null> {
    return this.userModel.findOne({ customerId, role: UserRole.Customer });
  }

  async hashPassword(password: string): Promise<string> {
    return bcrypt.hash(password, this.saltRounds);
  }

  async comparePassword(
    plainPassword: string,
    passwordHash: string,
  ): Promise<boolean> {
    return bcrypt.compare(plainPassword, passwordHash);
  }

  async updateLastLogin(userId: string): Promise<void> {
    await this.userModel.findByIdAndUpdate(userId, {
      lastLoginAt: new Date(),
    });
  }

  async updateRefreshTokenHash(
    userId: string,
    refreshTokenHash: string | null,
  ): Promise<void> {
    await this.userModel.findByIdAndUpdate(userId, { refreshTokenHash });
  }

  async updateFcmToken(userId: string, fcmToken: string): Promise<void> {
    await this.userModel.findByIdAndUpdate(userId, { fcmToken });
  }

  async createCustomerAccount(
    params: {
      customerId: string;
      username: string;
      password: string;
    },
    session?: import('mongoose').ClientSession,
  ): Promise<UserDocument> {
    const existing = await this.findByUsername(params.username);
    if (existing) {
      throw new BusinessException(
        ErrorCode.VALIDATION_ERROR,
        'Username already exists',
        HttpStatus.CONFLICT,
      );
    }

    const passwordHash = await this.hashPassword(params.password);
    const options = session ? { session } : undefined;
    const [user] = await this.userModel.create(
      [
        {
          uid: randomUUID(),
          username: params.username.toLowerCase().trim(),
          passwordHash,
          role: UserRole.Customer,
          customerId: params.customerId,
          isActive: true,
        },
      ],
      options,
    );
    return user;
  }

  async resetPassword(userId: string, newPassword: string): Promise<void> {
    const passwordHash = await this.hashPassword(newPassword);
    await this.userModel.findByIdAndUpdate(userId, {
      passwordHash,
      refreshTokenHash: null,
    });
  }

  async softDeleteByCustomerId(customerId: string): Promise<void> {
    const user = await this.findByCustomerId(customerId);
    if (user) {
      user.deletedAt = new Date();
      user.isActive = false;
      user.refreshTokenHash = undefined;
      await user.save();
    }
  }
}
