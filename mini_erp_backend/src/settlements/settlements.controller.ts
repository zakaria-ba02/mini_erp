import { Controller, Get, Param, Post, Query, Body } from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiOperation,
  ApiParam,
  ApiTags,
} from '@nestjs/swagger';
import { Roles } from '../common/decorators/roles.decorator';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { UserRole } from '../auth/interfaces/jwt-payload.interface';
import type { JwtPayload } from '../auth/interfaces/jwt-payload.interface';
import { PaginationQueryDto } from '../common/dto/pagination-query.dto';
import { UsersService } from '../users/users.service';
import { SettlementsService } from './settlements.service';
import { SettleCustomerDto } from './dto/settle-customer.dto';

@ApiTags('Customers')
@ApiBearerAuth('access-token')
@Controller('customers')
@Roles(UserRole.Admin)
export class SettlementsController {
  constructor(
    private readonly settlementsService: SettlementsService,
    private readonly usersService: UsersService,
  ) {}

  @Post(':id/settle')
  @ApiOperation({
    summary:
      'Settle the current account period for one currency (Admin only)',
  })
  @ApiParam({ name: 'id', description: 'Customer MongoDB ID' })
  settle(
    @Param('id') id: string,
    @Body() dto: SettleCustomerDto,
    @CurrentUser() user: JwtPayload,
  ) {
    return this.resolveAdmin(user.uid).then((admin) =>
      this.settlementsService.settle(id, dto.currency, {
        adminUserId: admin._id.toString(),
        adminUid: user.uid,
      }),
    );
  }

  @Get(':id/settlements')
  @ApiOperation({
    summary: 'List previous account settlements for a customer',
  })
  @ApiParam({ name: 'id', description: 'Customer MongoDB ID' })
  findAll(@Param('id') id: string, @Query() query: PaginationQueryDto) {
    return this.settlementsService.findByCustomer(id, query);
  }

  private async resolveAdmin(uid: string) {
    const admin = await this.usersService.findByUid(uid);
    return admin!;
  }
}
