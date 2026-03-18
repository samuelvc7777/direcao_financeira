import { Test, TestingModule } from '@nestjs/testing';
import { AdminController } from './admin.controller';
import { AdminService } from './admin.service';
import { SubscriptionService } from '../../subscription/interface/subscription.service';
import { createMockProvider } from '../../../test-utils/mock-provider';
import { GetDashboardStatsUseCase } from '../application/use-cases/get-dashboard-stats.use-case';
import {
  CancelCurrentSubscriptionUseCase,
  ChangePlanUseCase,
  GetActiveSubscriptionUseCase,
  GetSubscriptionHistoryUseCase,
  RenewSubscriptionUseCase,
} from '../../subscription/application/use-cases/subscription.use-cases';

describe('AdminController', () => {
  let controller: AdminController;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [AdminController],
      providers: [
        AdminService,
        SubscriptionService,
        createMockProvider(GetDashboardStatsUseCase),
        createMockProvider(GetActiveSubscriptionUseCase),
        createMockProvider(GetSubscriptionHistoryUseCase),
        createMockProvider(ChangePlanUseCase),
        createMockProvider(CancelCurrentSubscriptionUseCase),
        createMockProvider(RenewSubscriptionUseCase),
      ],
    }).compile();

    controller = module.get<AdminController>(AdminController);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });
});
