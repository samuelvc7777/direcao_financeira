import { Test, TestingModule } from '@nestjs/testing';
import { PlanController } from '../plan.controller';
import { PlanService } from '../plan.service';
import { createMockProvider } from '../../../../test-utils/mock-provider';
import {
  CreatePlanUseCase,
  DeletePlanUseCase,
  GetPlanUseCase,
  ListPlansUseCase,
  UpdatePlanUseCase,
} from '../../application/use-cases/create-plan.use-case';

describe('PlanController', () => {
  let controller: PlanController;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [PlanController],
      providers: [
        PlanService,
        createMockProvider(CreatePlanUseCase),
        createMockProvider(ListPlansUseCase),
        createMockProvider(GetPlanUseCase),
        createMockProvider(UpdatePlanUseCase),
        createMockProvider(DeletePlanUseCase),
      ],
    }).compile();

    controller = module.get<PlanController>(PlanController);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });
});
