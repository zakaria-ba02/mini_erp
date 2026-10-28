import { ApiPropertyOptional } from '@nestjs/swagger';
import { Transform, Type } from 'class-transformer';
import { IsEnum, IsMongoId, IsOptional, ValidateIf } from 'class-validator';
import { PaginationQueryDto } from '../../common/dto/pagination-query.dto';
import { Currency } from '../../common/constants/currency';

export class PaymentQueryDto extends PaginationQueryDto {
  @ApiPropertyOptional({ example: '507f1f77bcf86cd799439011' })
  @IsOptional()
  @IsMongoId()
  customerId?: string;

  @ApiPropertyOptional({
    description:
      'Defaults to the current unsettled period. Pass a settlement ObjectId to view a closed period.',
    example: '507f1f77bcf86cd799439011',
  })
  @IsOptional()
  @Transform(({ value }) =>
    value === '' || value === 'null' || value === null ? undefined : value,
  )
  @ValidateIf((_, value) => value !== undefined)
  @IsMongoId()
  settlementId?: string;

  @ApiPropertyOptional({ enum: Currency, example: Currency.SYP })
  @IsOptional()
  @IsEnum(Currency)
  currency?: Currency;

  @ApiPropertyOptional({ example: '2026-01-01T00:00:00.000Z' })
  @IsOptional()
  @Type(() => Date)
  fromDate?: Date;

  @ApiPropertyOptional({ example: '2026-12-31T23:59:59.999Z' })
  @IsOptional()
  @Type(() => Date)
  toDate?: Date;
}
