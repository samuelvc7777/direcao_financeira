import { Module } from '@nestjs/common';
import { AdminController } from './admin.controller';
import { AdminService } from './admin.service';
import { PrismaModule } from '../../../prisma/prisma.module';
import { SubscriptionModule } from '../../subscription/interface/subscription.module';
import { GetDashboardStatsUseCase } from '../application/use-cases/get-dashboard-stats.use-case';
import { DASHBOARD_REPOSITORY } from '../domain/repositories/dashboard.repository';
import { PrismaDashboardRepository } from '../infrastructure/repositories/prisma-dashboard.repository';

@Module({
  imports: [PrismaModule, SubscriptionModule],
  controllers: [AdminController],
  providers: [
    AdminService,
    GetDashboardStatsUseCase,
    PrismaDashboardRepository,
    {
      provide: DASHBOARD_REPOSITORY,
      useExisting: PrismaDashboardRepository,
    },
  ],
})
export class AdminModule {}
