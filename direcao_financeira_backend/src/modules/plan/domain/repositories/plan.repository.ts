import { CreatePlanDto } from '../../interface/dto/create-plan.dto';
import { UpdatePlanDto } from '../../interface/dto/update-plan.dto';
import { PlanEntity } from '../entities/plan.entity';

export const PLAN_REPOSITORY = 'PLAN_REPOSITORY';

export interface PlanRepository {
  create(data: CreatePlanDto): Promise<PlanEntity>;
  findAll(): Promise<PlanEntity[]>;
  findById(id: number): Promise<PlanEntity | null>;
  update(id: number, data: UpdatePlanDto): Promise<PlanEntity>;
  remove(id: number): Promise<void>;
}
