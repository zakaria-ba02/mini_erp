import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import {
  IsNotEmpty,
  IsOptional,
  IsString,
  MinLength,
  ValidateNested,
} from 'class-validator';

export class CreateCustomerAccountDto {
  @ApiProperty({ example: 'customer1' })
  @IsString()
  @IsNotEmpty()
  username: string;

  @ApiProperty({ example: 'secure-password', minLength: 6 })
  @IsString()
  @IsNotEmpty()
  @MinLength(6)
  password: string;
}

export class CreateCustomerDto {
  @ApiProperty({ example: 'Acme Corp' })
  @IsString()
  @IsNotEmpty()
  name: string;

  @ApiProperty({ example: '0500000000' })
  @IsString()
  @IsNotEmpty()
  phone: string;

  @ApiPropertyOptional({ example: 'VIP customer' })
  @IsOptional()
  @IsString()
  notes?: string;

  @ApiProperty({ type: CreateCustomerAccountDto })
  @ValidateNested()
  @Type(() => CreateCustomerAccountDto)
  account: CreateCustomerAccountDto;
}
