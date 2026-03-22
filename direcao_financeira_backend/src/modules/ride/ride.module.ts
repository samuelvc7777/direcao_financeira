import { Module } from '@nestjs/common';
import { JourneyModule } from '../journey/journey.module';
import { PrismaModule } from '../../prisma/prisma.module';
import { RideController } from './interface/ride.controller';
import { RideService } from './interface/ride.service';
import { RIDE_REPOSITORY } from './domain/repositories/ride.repository';
import { PrismaRideRepository } from './infrastructure/repositories/prisma-ride.repository';
import { RideRulesService } from './domain/services/ride-rules.service';

@Module({
  imports: [PrismaModule, JourneyModule],
  controllers: [RideController],
  providers: [
    RideService,
    RideRulesService,
    PrismaRideRepository,
    {
      provide: RIDE_REPOSITORY,
      useExisting: PrismaRideRepository,
    },
  ],
  exports: [RideService],
})
export class RideModule {}
