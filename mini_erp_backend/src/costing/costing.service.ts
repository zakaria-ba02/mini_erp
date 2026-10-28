import { Injectable, HttpStatus } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, QueryFilter } from 'mongoose';
import { Cost, CostDocument } from '../database/schemas/cost.schema';
import { CreateCostDto } from './dto/create-cost.dto';
import { UpdateCostDto } from './dto/update-cost.dto';
import { PaginationQueryDto } from '../common/dto/pagination-query.dto';
import {
  buildPaginatedResponse,
  getPaginationSkip,
} from '../common/utils/pagination.util';
import { buildSearchRegex } from '../common/utils/search.util';
import { calculateCostFields } from './utils/cost-calculator.util';
import { ErrorCode } from '../common/constants/error-codes';
import { BusinessException } from '../common/exceptions/business.exception';
import { AuditLogsService } from '../audit-logs/audit-logs.service';

@Injectable()
export class CostingService {
  constructor(
    @InjectModel(Cost.name) private readonly costModel: Model<CostDocument>,
    private readonly auditLogsService: AuditLogsService,
  ) {}

  async create(dto: CreateCostDto, adminUserId: string) {
    const calculated = calculateCostFields(dto);
    const cost = await this.costModel.create({
      name: dto.name.trim(),
      runtime: dto.runtime,
      hourlyRate: dto.hourlyRate,
      boardPrice: dto.boardPrice,
      quantity: dto.quantity,
      wastePercentage: dto.wastePercentage,
      profitPercentage: dto.profitPercentage,
      additionalCosts: dto.additionalCosts ?? [],
      ...calculated,
    });

    await this.auditLogsService.log({
      userId: adminUserId,
      action: 'CREATE_COST',
      entity: 'Cost',
      entityId: cost._id.toString(),
      newData: { name: cost.name, totalCost: cost.totalCost },
    });

    return cost;
  }

  async findAll(query: PaginationQueryDto) {
    const filter: QueryFilter<CostDocument> = {};
    const searchRegex = buildSearchRegex(query.search);

    if (searchRegex) {
      filter.name = searchRegex;
    }

    const skip = getPaginationSkip(query.page, query.limit);
    const [data, total] = await Promise.all([
      this.costModel
        .find(filter)
        .sort({ createdAt: -1 })
        .skip(skip)
        .limit(query.limit),
      this.costModel.countDocuments(filter),
    ]);

    return buildPaginatedResponse(data, total, query.page, query.limit);
  }

  async findById(id: string): Promise<CostDocument> {
    const cost = await this.costModel.findById(id);
    if (!cost) {
      throw new BusinessException(
        ErrorCode.COST_NOT_FOUND,
        'Cost not found',
        HttpStatus.NOT_FOUND,
      );
    }
    return cost;
  }

  async update(id: string, dto: UpdateCostDto, adminUserId: string) {
    const cost = await this.findById(id);
    const oldData = cost.toObject();

    const merged = {
      runtime: dto.runtime ?? cost.runtime,
      hourlyRate: dto.hourlyRate ?? cost.hourlyRate,
      boardPrice: dto.boardPrice ?? cost.boardPrice,
      quantity: dto.quantity ?? cost.quantity,
      wastePercentage: dto.wastePercentage ?? cost.wastePercentage,
      profitPercentage: dto.profitPercentage ?? cost.profitPercentage,
      additionalCosts: dto.additionalCosts ?? cost.additionalCosts,
    };

    const calculated = calculateCostFields(merged);

    if (dto.name !== undefined) cost.name = dto.name.trim();
    cost.runtime = merged.runtime;
    cost.hourlyRate = merged.hourlyRate;
    cost.boardPrice = merged.boardPrice;
    cost.quantity = merged.quantity;
    cost.wastePercentage = merged.wastePercentage;
    cost.profitPercentage = merged.profitPercentage;
    cost.additionalCosts = merged.additionalCosts;
    Object.assign(cost, calculated);

    await cost.save();

    await this.auditLogsService.log({
      userId: adminUserId,
      action: 'UPDATE_COST',
      entity: 'Cost',
      entityId: id,
      oldData: { name: oldData.name, totalCost: oldData.totalCost },
      newData: { name: cost.name, totalCost: cost.totalCost },
    });

    return cost;
  }

  async softDelete(id: string, adminUserId: string) {
    const cost = await this.findById(id);
    cost.deletedAt = new Date();
    await cost.save();

    await this.auditLogsService.log({
      userId: adminUserId,
      action: 'DELETE_COST',
      entity: 'Cost',
      entityId: id,
      oldData: { name: cost.name },
    });

    return { success: true };
  }
}
