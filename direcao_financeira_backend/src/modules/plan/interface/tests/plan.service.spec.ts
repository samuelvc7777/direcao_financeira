import { Test, TestingModule } from '@nestjs/testing';
import { PlanService } from '../plan.service';
import { createMockProvider } from '../../../../test-utils/mock-provider';
import {
  CreatePlanUseCase,
  DeletePlanUseCase,
  GetPlanUseCase,
  ListPlansUseCase,
  UpdatePlanUseCase,
} from '../../application/use-cases/create-plan.use-case';

describe('PlanService', () => {
  let service: PlanService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        PlanService,
        createMockProvider(CreatePlanUseCase),
        createMockProvider(ListPlansUseCase),
        createMockProvider(GetPlanUseCase),
        createMockProvider(UpdatePlanUseCase),
        createMockProvider(DeletePlanUseCase),
      ],
    }).compile();

    service = module.get<PlanService>(PlanService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });
});
