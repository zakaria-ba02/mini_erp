import {
  Body,
  Controller,
  Delete,
  Get,
  HttpStatus,
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
import { BusinessException } from '../common/exceptions/business.exception';
import { ErrorCode } from '../common/constants/error-codes';
import { CustomersService } from './customers.service';
import { CreateCustomerDto } from './dto/create-customer.dto';
import { UpdateCustomerDto } from './dto/update-customer.dto';
import { ResetCustomerPasswordDto } from './dto/reset-customer-password.dto';
import { PaginationQueryDto } from '../common/dto/pagination-query.dto';
import { UsersService } from '../users/users.service';
import { SuccessResponseDto } from '../common/dto/swagger-response.dto';

@ApiTags('Customers')
@ApiBearerAuth('access-token')
@Controller('customers')
@Roles(UserRole.Admin)
export class CustomersController {
  constructor(
    private readonly customersService: CustomersService,
    private readonly usersService: UsersService,
  ) {}

  @Post()
  @ApiOperation({ summary: 'Create customer with login account' })
  create(
    @Body() dto: CreateCustomerDto,
    @CurrentUser() user: { uid: string },
  ) {
    return this.resolveAdminUserId(user.uid).then((adminUserId) =>
      this.customersService.create(dto, adminUserId),
    );
  }

  @Get()
  @ApiOperation({ summary: 'List customers with pagination and search' })
  findAll(@Query() query: PaginationQueryDto) {
    return this.customersService.findAll(query);
  }

  // Must be declared before ':id' so 'me' is not treated as an ID.
  @Get('me')
  @Roles(UserRole.Customer)
  @ApiOperation({ summary: 'Get own customer profile (customer role)' })
  getOwnProfile(@CurrentUser() user: JwtPayload) {
    if (!user.customerId) {
      throw new BusinessException(
        ErrorCode.CUSTOMER_NOT_FOUND,
        'Customer not found',
        HttpStatus.NOT_FOUND,
      );
    }
    return this.customersService.findById(user.customerId);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get customer by ID' })
  @ApiParam({ name: 'id', description: 'Customer MongoDB ID' })
  findOne(@Param('id') id: string) {
    return this.customersService.findById(id);
  }

  @Patch(':id')
  @ApiOperation({ summary: 'Update customer' })
  @ApiParam({ name: 'id', description: 'Customer MongoDB ID' })
  update(
    @Param('id') id: string,
    @Body() dto: UpdateCustomerDto,
    @CurrentUser() user: { uid: string },
  ) {
    return this.resolveAdminUserId(user.uid).then((adminUserId) =>
      this.customersService.update(id, dto, adminUserId),
    );
  }

  @Delete(':id')
  @ApiOperation({ summary: 'Soft delete customer' })
  @ApiParam({ name: 'id', description: 'Customer MongoDB ID' })
  @ApiResponse({ status: 200, type: SuccessResponseDto })
  remove(@Param('id') id: string, @CurrentUser() user: { uid: string }) {
    return this.resolveAdminUserId(user.uid).then((adminUserId) =>
      this.customersService.softDelete(id, adminUserId),
    );
  }

  @Post(':id/reset-password')
  @ApiOperation({ summary: 'Reset customer login password' })
  @ApiParam({ name: 'id', description: 'Customer MongoDB ID' })
  @ApiResponse({ status: 201, type: SuccessResponseDto })
  resetPassword(
    @Param('id') id: string,
    @Body() dto: ResetCustomerPasswordDto,
    @CurrentUser() user: { uid: string },
  ) {
    return this.resolveAdminUserId(user.uid).then((adminUserId) =>
      this.customersService.resetPassword(id, dto.newPassword, adminUserId),
    );
  }

  private async resolveAdminUserId(uid: string): Promise<string> {
    const admin = await this.usersService.findByUid(uid);
    return admin!._id.toString();
  }
}
