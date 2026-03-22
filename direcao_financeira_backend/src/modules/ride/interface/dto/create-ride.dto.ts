import {
  IsEnum,
  IsNumber,
  IsOptional,
  IsString,
  Min,
  Max,
} from 'class-validator';
import { RideStatus, RidePaymentMethod } from '@prisma/client';

export class CreateRideDto {
  @IsNumber()
  @IsOptional()
  shiftId?: number;

  @IsEnum(RidePaymentMethod)
  paymentMethod: RidePaymentMethod;

  @IsNumber()
  grossValueCents: number;

  @IsNumber()
  netProfitCents: number;

  @IsNumber()
  totalKm: number;

  @IsNumber()
  totalTime: number; // em segundos

  @IsNumber()
  @IsOptional()
  @Min(0)
  @Max(5)
  customerRating?: number;

  @IsString()
  @IsOptional()
  originAddress?: string;

  @IsString()
  @IsOptional()
  destinationAddress?: string;

  @IsOptional()
  stops?: any;

  @IsString()
  @IsOptional()
  passengerName?: string;
}
