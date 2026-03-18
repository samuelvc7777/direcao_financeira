import { Module } from '@nestjs/common';
import { PlanController } from './plan.controller';
import { PlanService } from './plan.service';
import { PrismaModule } from '../../../prisma/prisma.module';
import {
  CreatePlanUseCase,
  DeletePlanUseCase,
  GetPlanUseCase,
  ListPlansUseCase,
  UpdatePlanUseCase,
} from '../application/use-cases/create-plan.use-case';
import { PLAN_REPOSITORY } from '../domain/repositories/plan.repository';
import { PrismaPlanRepository } from '../infrastructure/repositories/prisma-plan.repository';

@Module({
  imports: [PrismaModule],
  controllers: [PlanController],
  providers: [
    PlanService,
    CreatePlanUseCase,
    ListPlansUseCase,
    GetPlanUseCase,
    UpdatePlanUseCase,
    DeletePlanUseCase,
    PrismaPlanRepository,
    {
      provide: PLAN_REPOSITORY,
      useExisting: PrismaPlanRepository,
    },
  ],
  exports: [PlanService],
})
export class PlanModule {}
