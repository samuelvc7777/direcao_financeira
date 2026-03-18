import { Injectable } from '@nestjs/common';
import { CreatePlanDto } from './dto/create-plan.dto';
import { UpdatePlanDto } from './dto/update-plan.dto';
import {
  CreatePlanUseCase,
  DeletePlanUseCase,
  GetPlanUseCase,
  ListPlansUseCase,
  UpdatePlanUseCase,
} from '../application/use-cases/create-plan.use-case';

@Injectable()
export class PlanService {
  constructor(
    private readonly createPlanUseCase: CreatePlanUseCase,
    private readonly listPlansUseCase: ListPlansUseCase,
    private readonly getPlanUseCase: GetPlanUseCase,
    private readonly updatePlanUseCase: UpdatePlanUseCase,
    private readonly deletePlanUseCase: DeletePlanUseCase,
  ) {}

  create(createPlanDto: CreatePlanDto) {
    return this.createPlanUseCase.execute(createPlanDto);
  }

  findAll() {
    return this.listPlansUseCase.execute();
  }

  findOne(id: number) {
    return this.getPlanUseCase.execute(id);
  }

  update(id: number, updatePlanDto: UpdatePlanDto) {
    return this.updatePlanUseCase.execute(id, updatePlanDto);
  }

  remove(id: number) {
    return this.deletePlanUseCase.execute(id);
  }
}
