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
import type { JwtPayload } from '../auth/interfaces/jwt-payload.interface';
import { PaymentsService } from './payments.service';
import { CreatePaymentDto, UpdatePaymentDto } from './dto/create-payment.dto';
import { PaymentQueryDto } from './dto/payment-query.dto';
import { SuccessResponseDto } from '../common/dto/swagger-response.dto';

@ApiTags('Payments')
@ApiBearerAuth('access-token')
@Controller('payments')
export class PaymentsController {
  constructor(private readonly paymentsService: PaymentsService) {}

  @Post()
  @Roles(UserRole.Admin)
  @ApiOperation({ summary: 'Create payment (Admin only)' })
  create(
    @Body() dto: CreatePaymentDto,
    @CurrentUser() user: JwtPayload,
  ) {
    return this.paymentsService
      .resolveAdminUserId(user.uid)
      .then((adminUserId) => this.paymentsService.create(dto, adminUserId));
  }

  @Get()
  @ApiOperation({
    summary:
      'List payments (Admin: all, Customer: own only). Defaults to the current unsettled period.',
  })
  findAll(@Query() query: PaymentQueryDto, @CurrentUser() user: JwtPayload) {
    return this.paymentsService.findAll(query, user);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get payment by ID' })
  @ApiParam({ name: 'id', description: 'Payment MongoDB ID' })
  findOne(@Param('id') id: string, @CurrentUser() user: JwtPayload) {
    return this.paymentsService.findById(id, user);
  }

  @Patch(':id')
  @Roles(UserRole.Admin)
  @ApiOperation({ summary: 'Update payment (Admin only)' })
  @ApiParam({ name: 'id', description: 'Payment MongoDB ID' })
  update(
    @Param('id') id: string,
    @Body() dto: UpdatePaymentDto,
    @CurrentUser() user: JwtPayload,
  ) {
    return this.paymentsService
      .resolveAdminUserId(user.uid)
      .then((adminUserId) => this.paymentsService.update(id, dto, adminUserId));
  }

  @Delete(':id')
  @Roles(UserRole.Admin)
  @ApiOperation({ summary: 'Soft delete payment (Admin only)' })
  @ApiParam({ name: 'id', description: 'Payment MongoDB ID' })
  @ApiResponse({ status: 200, type: SuccessResponseDto })
  remove(@Param('id') id: string, @CurrentUser() user: JwtPayload) {
    return this.paymentsService
      .resolveAdminUserId(user.uid)
      .then((adminUserId) => this.paymentsService.softDelete(id, adminUserId));
  }
}
