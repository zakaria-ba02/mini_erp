import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { ClientSession, Model, QueryFilter, Types } from 'mongoose';
import { AuditLog, AuditLogDocument } from '../database/schemas/audit-log.schema';
import { AuditLogQueryDto } from './dto/audit-log-query.dto';
import {
  buildPaginatedResponse,
  getPaginationSkip,
} from '../common/utils/pagination.util';

export interface CreateAuditLogDto {
  userId: string;
  action: string;
  entity: string;
  entityId: string;
  oldData?: Record<string, unknown>;
  newData?: Record<string, unknown>;
}

@Injectable()
export class AuditLogsService {
  constructor(
    @InjectModel(AuditLog.name)
    private readonly auditLogModel: Model<AuditLogDocument>,
  ) {}

  async logInTransaction(
    session: ClientSession,
    dto: CreateAuditLogDto,
  ): Promise<void> {
    await this.auditLogModel.create(
      [
        {
          userId: new Types.ObjectId(dto.userId),
          action: dto.action,
          entity: dto.entity,
          entityId: dto.entityId,
          oldData: dto.oldData,
          newData: dto.newData,
        },
      ],
      { session },
    );
  }

  async log(dto: CreateAuditLogDto): Promise<void> {
    await this.auditLogModel.create({
      userId: new Types.ObjectId(dto.userId),
      action: dto.action,
      entity: dto.entity,
      entityId: dto.entityId,
      oldData: dto.oldData,
      newData: dto.newData,
    });
  }

  async findAll(query: AuditLogQueryDto) {
    const page = query.page ?? 1;
    const limit = query.limit ?? 20;
    const filter: QueryFilter<AuditLogDocument> = {};

    if (query.entity) {
      filter.entity = query.entity;
    }

    if (query.userId) {
      filter.userId = new Types.ObjectId(query.userId);
    }

    if (query.fromDate || query.toDate) {
      filter.createdAt = {};
      if (query.fromDate) {
        filter.createdAt.$gte = query.fromDate;
      }
      if (query.toDate) {
        filter.createdAt.$lte = query.toDate;
      }
    }

    const skip = getPaginationSkip(page, limit);
    const [data, total] = await Promise.all([
      this.auditLogModel
        .find(filter)
        .sort({ createdAt: -1 })
        .skip(skip)
        .limit(limit)
        .populate('userId', 'username uid role'),
      this.auditLogModel.countDocuments(filter),
    ]);

    return buildPaginatedResponse(data, total, page, limit);
  }
}
