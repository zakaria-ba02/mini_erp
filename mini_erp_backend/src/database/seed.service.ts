import { Injectable, Logger, OnModuleInit } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { randomUUID } from 'crypto';
import * as bcrypt from 'bcrypt';
import { User, UserDocument } from './schemas/user.schema';
import { UserRole } from '../auth/interfaces/jwt-payload.interface';

@Injectable()
export class SeedService implements OnModuleInit {
  private readonly logger = new Logger(SeedService.name);
  private readonly saltRounds = 12;

  constructor(
    @InjectModel(User.name) private readonly userModel: Model<UserDocument>,
    private readonly configService: ConfigService,
  ) {}

  async onModuleInit(): Promise<void> {
    try {
      await this.seedAdminIfNeeded();
    } catch (error) {
      this.logger.error(
        'Admin seed failed; continuing startup',
        error instanceof Error ? error.stack : String(error),
      );
    }
  }

  private async seedAdminIfNeeded(): Promise<void> {
    const adminUsername = this.configService.get<string>(
      'ADMIN_SEED_USERNAME',
    );
    const adminPassword = this.configService.get<string>(
      'ADMIN_SEED_PASSWORD',
    );

    if (!adminUsername?.trim() || !adminPassword?.trim()) {
      return;
    }

    const existingAdmin = await this.userModel
      .findOne({ role: UserRole.Admin })
      .exec();

    if (existingAdmin) {
      return;
    }

    const passwordHash = await bcrypt.hash(adminPassword, this.saltRounds);
    await this.userModel.create({
      uid: randomUUID(),
      username: adminUsername.toLowerCase().trim(),
      passwordHash,
      role: UserRole.Admin,
      isActive: true,
    });

    this.logger.log(`Seed admin user "${adminUsername}" created`);
  }
}
