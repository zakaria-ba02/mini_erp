import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import {
  IsDate,
  IsEnum,
  IsMongoId,
  IsNotEmpty,
  IsNumber,
  IsOptional,
  IsString,
  Min,
} from 'class-validator';
import { Currency } from '../../common/constants/currency';

export class CreatePaymentDto {
  @ApiProperty({ example: '507f1f77bcf86cd799439011' })
  @IsMongoId()
  customerId: string;

  @ApiProperty({ example: 100, minimum: 0.01 })
  @IsNumber()
  @Min(0.01)
  amount: number;

  @ApiProperty({ example: '2026-08-10T00:00:00.000Z' })
  @Type(() => Date)
  @IsDate()
  date: Date;

  @ApiProperty({ example: 'cash' })
  @IsString()
  @IsNotEmpty()
  method: string;

  @ApiPropertyOptional({ example: 'Partial payment' })
  @IsOptional()
  @IsString()
  notes?: string;

  @ApiProperty({ enum: Currency, example: Currency.SYP })
  @IsEnum(Currency)
  currency: Currency;
}

export class UpdatePaymentDto {
  @ApiPropertyOptional({ example: '507f1f77bcf86cd799439011' })
  @IsOptional()
  @IsMongoId()
  customerId?: string;

  @ApiPropertyOptional({ example: 100, minimum: 0.01 })
  @IsOptional()
  @IsNumber()
  @Min(0.01)
  amount?: number;

  @ApiPropertyOptional({ example: '2026-08-10T00:00:00.000Z' })
  @IsOptional()
  @Type(() => Date)
  @IsDate()
  date?: Date;

  @ApiPropertyOptional({ example: 'bank_transfer' })
  @IsOptional()
  @IsString()
  @IsNotEmpty()
  method?: string;

  @ApiPropertyOptional({ example: 'Updated note' })
  @IsOptional()
  @IsString()
  notes?: string;

  @ApiPropertyOptional({ enum: Currency, example: Currency.SYP })
  @IsOptional()
  @IsEnum(Currency)
  currency?: Currency;
}
