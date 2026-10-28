import { Injectable, HttpStatus } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { JwtService, JwtSignOptions } from '@nestjs/jwt';
import { UsersService } from '../users/users.service';
import { UserDocument } from '../database/schemas/user.schema';
import { JwtPayload } from './interfaces/jwt-payload.interface';
import { LoginDto } from './dto/login.dto';
import { RefreshTokenDto } from './dto/refresh-token.dto';
import { ErrorCode } from '../common/constants/error-codes';
import { BusinessException } from '../common/exceptions/business.exception';

export interface AuthTokensResponse {
  accessToken: string;
  refreshToken: string;
}

@Injectable()
export class AuthService {
  constructor(
    private readonly usersService: UsersService,
    private readonly jwtService: JwtService,
    private readonly configService: ConfigService,
  ) {}

  async login(dto: LoginDto): Promise<AuthTokensResponse> {
    const user = await this.usersService.findByUsername(dto.username);

    if (!user) {
      this.throwInvalidCredentials();
    }

    if (!user!.isActive) {
      this.throwInvalidCredentials();
    }

    const isPasswordValid = await this.usersService.comparePassword(
      dto.password,
      user!.passwordHash,
    );

    if (!isPasswordValid) {
      this.throwInvalidCredentials();
    }

    await this.usersService.ensurePersistedUid(user!);
    return this.issueTokenPair(user!);
  }

  async refresh(dto: RefreshTokenDto): Promise<AuthTokensResponse> {
    let payload: JwtPayload;

    try {
      payload = await this.jwtService.verifyAsync<JwtPayload>(dto.refreshToken, {
        secret: this.configService.getOrThrow<string>('jwt.refreshSecret'),
      });
    } catch {
      throw new BusinessException(
        ErrorCode.UNAUTHORIZED,
        'Invalid refresh token',
        HttpStatus.UNAUTHORIZED,
      );
    }

    const user = await this.usersService.findByUid(payload.uid);

    if (!user || !user.isActive || !user.refreshTokenHash) {
      throw new BusinessException(
        ErrorCode.UNAUTHORIZED,
        'Invalid refresh token',
        HttpStatus.UNAUTHORIZED,
      );
    }

    const isRefreshValid = await this.usersService.comparePassword(
      dto.refreshToken,
      user.refreshTokenHash,
    );

    if (!isRefreshValid) {
      throw new BusinessException(
        ErrorCode.UNAUTHORIZED,
        'Invalid refresh token',
        HttpStatus.UNAUTHORIZED,
      );
    }

    await this.usersService.ensurePersistedUid(user);
    return this.issueTokenPair(user);
  }

  async logout(uid: string): Promise<{ success: boolean }> {
    const user = await this.usersService.findByUid(uid);
    if (user) {
      await this.usersService.updateRefreshTokenHash(user._id.toString(), null);
    }
    return { success: true };
  }

  private async issueTokenPair(
    user: UserDocument,
  ): Promise<AuthTokensResponse> {
    const payload = this.createJwtPayload(user);

    const accessToken = await this.jwtService.signAsync(payload, {
      secret: this.configService.getOrThrow<string>('jwt.accessSecret'),
      expiresIn: this.configService.getOrThrow<string>(
        'jwt.accessExpiresIn',
      ) as JwtSignOptions['expiresIn'],
    });

    const refreshToken = await this.jwtService.signAsync(payload, {
      secret: this.configService.getOrThrow<string>('jwt.refreshSecret'),
      expiresIn: this.configService.getOrThrow<string>(
        'jwt.refreshExpiresIn',
      ) as JwtSignOptions['expiresIn'],
    });

    const refreshTokenHash = await this.usersService.hashPassword(refreshToken);

    await Promise.all([
      this.usersService.updateLastLogin(user._id.toString()),
      this.usersService.updateRefreshTokenHash(
        user._id.toString(),
        refreshTokenHash,
      ),
    ]);

    return { accessToken, refreshToken };
  }

  private createJwtPayload(user: UserDocument): JwtPayload {
    if (typeof user.uid !== 'string' || user.uid.trim() === '') {
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

  private throwInvalidCredentials(): never {
    throw new BusinessException(
      ErrorCode.INVALID_CREDENTIALS,
      'Invalid credentials',
      HttpStatus.UNAUTHORIZED,
    );
  }
}
