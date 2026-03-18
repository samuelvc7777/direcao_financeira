export interface PlanEntity {
  id: number;
  code: string;
  name: string;
  description: string;
  priceCents: number;
  durationDays: number;
  color: string;
  isActive: boolean;
  createdAt: Date;
  updatedAt: Date;
}
