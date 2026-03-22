import { Module } from '@nestjs/common';
import { PrismaModule } from '../../prisma/prisma.module';
import { JourneyController } from './interface/journey.controller';
import { JourneyService } from './interface/journey.service';
import { JOURNEY_REPOSITORY } from './domain/repositories/journey.repository';
import { PrismaJourneyRepository } from './infrastructure/repositories/prisma-journey.repository';

@Module({
  imports: [PrismaModule],
  controllers: [JourneyController],
  providers: [
    JourneyService,
    PrismaJourneyRepository,
    {
      provide: JOURNEY_REPOSITORY,
      useExisting: PrismaJourneyRepository,
    },
  ],
  exports: [JourneyService, JOURNEY_REPOSITORY],
})
export class JourneyModule {}
