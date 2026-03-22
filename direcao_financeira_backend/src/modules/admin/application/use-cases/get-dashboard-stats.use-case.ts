import { Inject, Injectable } from '@nestjs/common';
import { DASHBOARD_REPOSITORY } from '../../domain/repositories/dashboard.repository';
import type { DashboardRepository } from '../../domain/repositories/dashboard.repository';

@Injectable()
export class GetDashboardStatsUseCase {
  constructor(
    @Inject(DASHBOARD_REPOSITORY)
    private readonly dashboardRepository: DashboardRepository,
  ) {}

  execute() {
    return this.dashboardRepository.getDashboardStats();
  }
}
