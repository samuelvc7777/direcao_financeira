import { Injectable } from '@nestjs/common';
import { GetDashboardStatsUseCase } from '../application/use-cases/get-dashboard-stats.use-case';

@Injectable()
export class AdminService {
  constructor(
    private readonly getDashboardStatsUseCase: GetDashboardStatsUseCase,
  ) {}

  getDashboardStats() {
    return this.getDashboardStatsUseCase.execute();
  }
}
