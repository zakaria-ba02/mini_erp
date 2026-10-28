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
import { InvoicesService } from './invoices.service';
import { CreateInvoiceDto, UpdateInvoiceDto } from './dto/create-invoice.dto';
import { InvoiceQueryDto } from './dto/invoice-query.dto';
import { SuccessResponseDto } from '../common/dto/swagger-response.dto';

@ApiTags('Invoices')
@ApiBearerAuth('access-token')
@Controller('invoices')
export class InvoicesController {
  constructor(private readonly invoicesService: InvoicesService) {}

  @Post()
  @Roles(UserRole.Admin)
  @ApiOperation({ summary: 'Create invoice (Admin only)' })
  create(
    @Body() dto: CreateInvoiceDto,
    @CurrentUser() user: JwtPayload,
  ) {
    return this.invoicesService
      .resolveAdminUserId(user.uid)
      .then((adminUserId) => this.invoicesService.create(dto, adminUserId));
  }

  @Get()
  @ApiOperation({
    summary:
      'List invoices (Admin: all, Customer: own only). Defaults to the current unsettled period.',
  })
  findAll(@Query() query: InvoiceQueryDto, @CurrentUser() user: JwtPayload) {
    return this.invoicesService.findAll(query, user);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get invoice by ID' })
  @ApiParam({ name: 'id', description: 'Invoice MongoDB ID' })
  findOne(@Param('id') id: string, @CurrentUser() user: JwtPayload) {
    return this.invoicesService.findById(id, user);
  }

  @Patch(':id')
  @Roles(UserRole.Admin)
  @ApiOperation({ summary: 'Update invoice (Admin only)' })
  @ApiParam({ name: 'id', description: 'Invoice MongoDB ID' })
  update(
    @Param('id') id: string,
    @Body() dto: UpdateInvoiceDto,
    @CurrentUser() user: JwtPayload,
  ) {
    return this.invoicesService
      .resolveAdminUserId(user.uid)
      .then((adminUserId) => this.invoicesService.update(id, dto, adminUserId));
  }

  @Delete(':id')
  @Roles(UserRole.Admin)
  @ApiOperation({ summary: 'Soft delete invoice (Admin only)' })
  @ApiParam({ name: 'id', description: 'Invoice MongoDB ID' })
  @ApiResponse({ status: 200, type: SuccessResponseDto })
  remove(@Param('id') id: string, @CurrentUser() user: JwtPayload) {
    return this.invoicesService
      .resolveAdminUserId(user.uid)
      .then((adminUserId) => this.invoicesService.softDelete(id, adminUserId));
  }
}
