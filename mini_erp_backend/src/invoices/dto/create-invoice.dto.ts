import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import {
  ArrayMinSize,
  IsArray,
  IsDate,
  IsEnum,
  IsMongoId,
  IsNotEmpty,
  IsNumber,
  IsOptional,
  IsString,
  Min,
  ValidateIf,
  ValidateNested,
} from 'class-validator';
import { InvoiceStatus } from '../../database/schemas/invoice.schema';
import { Currency } from '../../common/constants/currency';

export class CreateInvoiceItemDto {
  @ApiPropertyOptional({ example: '507f1f77bcf86cd799439011' })
  @IsOptional()
  @IsMongoId()
  costId?: string;

  @ApiPropertyOptional({ example: 'Manual item name' })
  @ValidateIf((item: CreateInvoiceItemDto) => !item.costId)
  @IsString()
  @IsNotEmpty()
  name?: string;

  @ApiProperty({ example: 2, minimum: 0.01 })
  @IsNumber()
  @Min(0.01)
  quantity: number;

  @ApiProperty({ example: 50, minimum: 0 })
  @IsNumber()
  @Min(0)
  unitPrice: number;
}

export class CreateInvoiceDto {
  @ApiProperty({ example: '507f1f77bcf86cd799439011' })
  @IsMongoId()
  customerId: string;

  @ApiProperty({ example: '2026-08-10T00:00:00.000Z' })
  @Type(() => Date)
  @IsDate()
  date: Date;

  @ApiProperty({ type: [CreateInvoiceItemDto] })
  @IsArray()
  @ArrayMinSize(1)
  @ValidateNested({ each: true })
  @Type(() => CreateInvoiceItemDto)
  items: CreateInvoiceItemDto[];

  @ApiProperty({ enum: Currency, example: Currency.SYP })
  @IsEnum(Currency)
  currency: Currency;
}

export class UpdateInvoiceItemDto extends CreateInvoiceItemDto {}

export class UpdateInvoiceDto {
  @ApiPropertyOptional({ example: '507f1f77bcf86cd799439011' })
  @IsOptional()
  @IsMongoId()
  customerId?: string;

  @ApiPropertyOptional({ example: '2026-08-10T00:00:00.000Z' })
  @IsOptional()
  @Type(() => Date)
  @IsDate()
  date?: Date;

  @ApiPropertyOptional({ type: [UpdateInvoiceItemDto] })
  @IsOptional()
  @IsArray()
  @ArrayMinSize(1)
  @ValidateNested({ each: true })
  @Type(() => UpdateInvoiceItemDto)
  items?: UpdateInvoiceItemDto[];

  @ApiPropertyOptional({ enum: InvoiceStatus, example: InvoiceStatus.Unpaid })
  @IsOptional()
  @IsEnum(InvoiceStatus)
  status?: InvoiceStatus;

  @ApiPropertyOptional({ enum: Currency, example: Currency.SYP })
  @IsOptional()
  @IsEnum(Currency)
  currency?: Currency;
}
