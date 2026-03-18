import { Test, TestingModule } from '@nestjs/testing';
import { AdminService } from './admin.service';
import { createMockProvider } from '../../../test-utils/mock-provider';
import { GetDashboardStatsUseCase } from '../application/use-cases/get-dashboard-stats.use-case';

describe('AdminService', () => {
  let service: AdminService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [AdminService, createMockProvider(GetDashboardStatsUseCase)],
    }).compile();

    service = module.get<AdminService>(AdminService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });
});
