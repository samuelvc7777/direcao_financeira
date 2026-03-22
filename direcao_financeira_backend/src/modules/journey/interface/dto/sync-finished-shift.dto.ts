import {
  IsDateString,
  IsNumber,
  IsOptional,
  IsPositive,
  Min,
  ValidateNested,
} from 'class-validator';
import { Type } from 'class-transformer';
import { TrackedRouteDto } from './tracked-route.dto';

export class SyncFinishedShiftDto {
  @IsOptional()
  @IsPositive()
  remoteShiftId?: number;

  @IsDateString()
  startTime!: string;

  @IsDateString()
  endTime!: string;

  @IsNumber()
  @Min(0)
  idleTime!: number;

  @IsNumber()
  @Min(0)
  totalDrivenKm!: number;

  @IsOptional()
  @ValidateNested()
  @Type(() => TrackedRouteDto)
  trackedRoute?: TrackedRouteDto;
}
