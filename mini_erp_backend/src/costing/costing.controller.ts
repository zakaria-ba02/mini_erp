import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Patch,
  Post,
  Query,
} from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiOperation,
  ApiParam,
  ApiResponse,
  ApiTags,
} from '@nestjs/swagger';
import { Roles } from '../common/decorators/roles.decorator';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { UserRole } from '../auth/interfaces/jwt-payload.interface';
import { CostingService } from './costing.service';
import { CreateCostDto } from './dto/create-cost.dto';
import { UpdateCostDto } from './dto/update-cost.dto';
import { PaginationQueryDto } from '../common/dto/pagination-query.dto';
import { UsersService } from '../users/users.service';
import { SuccessResponseDto } from '../common/dto/swagger-response.dto';

@ApiTags('Costing')
@ApiBearerAuth('access-token')
@Controller('costing')
@Roles(UserRole.Admin)
export class CostingController {
  constructor(
    private readonly costingService: CostingService,
    private readonly usersService: UsersService,
  ) {}

  @Post()
  @ApiOperation({ summary: 'Create and calculate a cost catalog entry' })
  create(@Body() dto: CreateCostDto, @CurrentUser() user: { uid: string }) {
    return this.resolveAdminUserId(user.uid).then((adminUserId) =>
      this.costingService.create(dto, adminUserId),
    );
  }

  @Get()
  @ApiOperation({ summary: 'List cost catalog with pagination and search' })
  findAll(@Query() query: PaginationQueryDto) {
    return this.costingService.findAll(query);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get cost catalog entry by ID' })
  @ApiParam({ name: 'id', description: 'Cost MongoDB ID' })
  findOne(@Param('id') id: string) {
    return this.costingService.findById(id);
  }

  @Patch(':id')
  @ApiOperation({ summary: 'Update and recalculate cost catalog entry' })
  @ApiParam({ name: 'id', description: 'Cost MongoDB ID' })
  update(
    @Param('id') id: string,
    @Body() dto: UpdateCostDto,
    @CurrentUser() user: { uid: string },
  ) {
    return this.resolveAdminUserId(user.uid).then((adminUserId) =>
      this.costingService.update(id, dto, adminUserId),
    );
  }

  @Delete(':id')
  @ApiOperation({ summary: 'Soft delete cost catalog entry' })
  @ApiParam({ name: 'id', description: 'Cost MongoDB ID' })
  @ApiResponse({ status: 200, type: SuccessResponseDto })
  remove(@Param('id') id: string, @CurrentUser() user: { uid: string }) {
    return this.resolveAdminUserId(user.uid).then((adminUserId) =>
      this.costingService.softDelete(id, adminUserId),
    );
  }

  private async resolveAdminUserId(uid: string): Promise<string> {
    const admin = await this.usersService.findByUid(uid);
    return admin!._id.toString();
  }
}
