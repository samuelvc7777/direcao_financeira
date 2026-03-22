import { Type } from 'class-transformer';
import {
  IsArray,
  IsDateString,
  IsLatitude,
  IsLongitude,
  IsNumber,
  Min,
  ValidateNested,
} from 'class-validator';

export class TrackedRoutePointDto {
  @IsLatitude()
  latitude!: number;

  @IsLongitude()
  longitude!: number;

  @IsNumber()
  @Min(0)
  accuracyMeters!: number;

  @IsDateString()
  recordedAt!: string;
}

export class TrackedRouteDto {
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => TrackedRoutePointDto)
  points!: TrackedRoutePointDto[];

  @IsNumber()
  @Min(0)
  totalDistanceMeters!: number;

  @IsDateString()
  startedAt!: string;

  @IsDateString()
  endedAt!: string;
}
