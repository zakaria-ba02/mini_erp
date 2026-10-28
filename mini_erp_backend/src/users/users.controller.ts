import { Body, Controller, HttpStatus, Patch } from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiOperation,
  ApiResponse,
  ApiTags,
} from '@nestjs/swagger';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import type { JwtPayload } from '../auth/interfaces/jwt-payload.interface';
import { UsersService } from './users.service';
import { UpdateFcmTokenDto } from './dto/update-fcm-token.dto';
import { ChangeMyPasswordDto } from './dto/change-my-password.dto';
import { SuccessResponseDto } from '../common/dto/swagger-response.dto';
import { BusinessException } from '../common/exceptions/business.exception';
import { ErrorCode } from '../common/constants/error-codes';

@ApiTags('Users')
@ApiBearerAuth('access-token')
@Controller('users')
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @Patch('me/fcm-token')
  @ApiOperation({ summary: 'Update FCM token for current user device' })
  @ApiResponse({ status: 200, type: SuccessResponseDto })
  async updateFcmToken(
    @CurrentUser() user: JwtPayload,
    @Body() dto: UpdateFcmTokenDto,
  ) {
    const dbUser = await this.usersService.findByUid(user.uid);
    if (!dbUser) {
      return { success: true };
    }
    await this.usersService.updateFcmToken(dbUser._id.toString(), dto.fcmToken);
    return { success: true };
  }

  @Patch('me/password')
  @ApiOperation({ summary: 'Change own password (any authenticated user)' })
  @ApiResponse({ status: 200, type: SuccessResponseDto })
  async changeMyPassword(
    @CurrentUser() user: JwtPayload,
    @Body() dto: ChangeMyPasswordDto,
  ) {
    const dbUser = await this.usersService.findByUid(user.uid);
    if (!dbUser) {
      throw new BusinessException(
        ErrorCode.USER_NOT_FOUND,
        'User not found',
        HttpStatus.NOT_FOUND,
      );
    }

    const oldPasswordMatches = await this.usersService.comparePassword(
      dto.oldPassword,
      dbUser.passwordHash,
    );
    if (!oldPasswordMatches) {
      throw new BusinessException(
        ErrorCode.INVALID_CREDENTIALS,
        'Old password is incorrect',
        HttpStatus.BAD_REQUEST,
      );
    }

    await this.usersService.resetPassword(
      dbUser._id.toString(),
      dto.newPassword,
    );
    return { success: true };
  }
}
