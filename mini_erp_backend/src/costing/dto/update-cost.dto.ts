import { ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import {
  IsArray,
  IsNotEmpty,
  IsNumber,
  IsOptional,
  IsString,
  Min,
  ValidateNested,
} from 'class-validator';
import { AdditionalCostDto } from './create-cost.dto';

export class UpdateCostDto {
  @ApiPropertyOptional({ example: 'Board A' })
  @IsOptional()
  @IsString()
  @IsNotEmpty()
  name?: string;

  @ApiPropertyOptional({ example: 2, minimum: 0 })
  @IsOptional()
  @IsNumber()
  @Min(0)
  runtime?: number;

  @ApiPropertyOptional({ example: 50, minimum: 0 })
  @IsOptional()
  @IsNumber()
  @Min(0)
  hourlyRate?: number;

  @ApiPropertyOptional({ example: 100, minimum: 0 })
  @IsOptional()
  @IsNumber()
  @Min(0)
  boardPrice?: number;

  @ApiPropertyOptional({ example: 10, minimum: 1 })
  @IsOptional()
  @IsNumber()
  @Min(1)
  quantity?: number;

  @ApiPropertyOptional({ example: 10, minimum: 0 })
  @IsOptional()
  @IsNumber()
  @Min(0)
  wastePercentage?: number;

  @ApiPropertyOptional({ example: 20, minimum: 0 })
  @IsOptional()
  @IsNumber()
  @Min(0)
  profitPercentage?: number;

  @ApiPropertyOptional({ type: [AdditionalCostDto] })
  @IsOptional()
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => AdditionalCostDto)
  additionalCosts?: AdditionalCostDto[];
}
