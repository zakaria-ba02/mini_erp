import { ApiProperty } from '@nestjs/swagger';
import { IsEnum } from 'class-validator';
import { Currency } from '../../common/constants/currency';

export class SettleCustomerDto {
  @ApiProperty({ enum: Currency, example: Currency.SYP })
  @IsEnum(Currency)
  currency: Currency;
}
