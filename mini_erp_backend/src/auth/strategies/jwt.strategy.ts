import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { PassportStrategy } from '@nestjs/passport';
import { ExtractJwt, Strategy } from 'passport-jwt';
import { UsersService } from '../../users/users.service';
import { JwtPayload } from '../interfaces/jwt-payload.interface';
import { ErrorCode } from '../../common/constants/error-codes';
import { BusinessException } from '../../common/exceptions/business.exception';
import { HttpStatus } from '@nestjs/common';

@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy) {
  constructor(
    configService: ConfigService,
    private readonly usersService: UsersService,
  ) {
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      ignoreExpiration: false,
      secretOrKey: configService.getOrThrow<string>('jwt.accessSecret'),
    });
  }

  async validate(payload: JwtPayload): Promise<JwtPayload> {
    if (typeof payload?.uid !== 'string' || payload.uid.trim() === '') {
      throw new BusinessException(
        ErrorCode.UNAUTHORIZED,
        'Unauthorized',
        HttpStatus.UNAUTHORIZED,
      );
    }

    const user = await this.usersService.findByUid(payload.uid);

    if (!user || !user.isActive) {
      throw new BusinessException(
        ErrorCode.UNAUTHORIZED,
        'Unauthorized',
        HttpStatus.UNAUTHORIZED,
      );
    }

    return {
      uid: user.uid,
      role: user.role,
      ...(user.customerId
        ? { customerId: user.customerId.toString() }
        : {}),
    };
  }
}
