import { IsEnum, IsOptional, IsString } from 'class-validator';
import { RideStatus } from '@prisma/client';

export class FilterRideDto {
  @IsEnum(RideStatus)
  @IsOptional()
  status?: RideStatus;

  @IsString()
  @IsOptional()
  period?: 'day' | 'week' | 'month' | 'year' | 'custom' | 'all';

  @IsString()
  @IsOptional()
  date?: string;

  @IsString()
  @IsOptional()
  endDate?: string;
}
