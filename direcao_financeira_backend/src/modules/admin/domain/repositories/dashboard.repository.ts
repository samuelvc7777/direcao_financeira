export const DASHBOARD_REPOSITORY = 'DASHBOARD_REPOSITORY';

export interface DashboardPlanMetric {
  name: string;
  code: string;
  count: number;
  revenue: number;
  revenueCents: number;
}

export interface DashboardStats {
  metrics: {
    totalUsers: number;
    activeUsers: number;
    newUsers24h: number;
    activeSubscriptions: number;
    estimatedRevenue: number;
    estimatedRevenueCents: number;
  };
  plans: DashboardPlanMetric[];
  recentActivity: unknown[];
}

export interface DashboardRepository {
  getDashboardStats(): Promise<DashboardStats>;
}
