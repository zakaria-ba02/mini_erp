import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
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

export class AdditionalCostDto {
  @ApiProperty({ example: 'Glue' })
  @IsString()
  @IsNotEmpty()
  name: string;

  @ApiProperty({ example: 30, minimum: 0 })
  @IsNumber()
  @Min(0)
  price: number;
}

export class CreateCostDto {
  @ApiProperty({ example: 'Board A' })
  @IsString()
  @IsNotEmpty()
  name: string;

  @ApiProperty({ example: 2, minimum: 0 })
  @IsNumber()
  @Min(0)
  runtime: number;

  @ApiProperty({ example: 50, minimum: 0 })
  @IsNumber()
  @Min(0)
  hourlyRate: number;

  @ApiProperty({ example: 100, minimum: 0 })
  @IsNumber()
  @Min(0)
  boardPrice: number;

  @ApiProperty({ example: 10, minimum: 1 })
  @IsNumber()
  @Min(1)
  quantity: number;

  @ApiProperty({ example: 10, minimum: 0 })
  @IsNumber()
  @Min(0)
  wastePercentage: number;

  @ApiProperty({ example: 20, minimum: 0 })
  @IsNumber()
  @Min(0)
  profitPercentage: number;

  @ApiPropertyOptional({ type: [AdditionalCostDto] })
  @IsOptional()
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => AdditionalCostDto)
  additionalCosts?: AdditionalCostDto[];
}
