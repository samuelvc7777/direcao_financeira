import { Inject, Injectable, NotFoundException } from '@nestjs/common';
import { CreatePlanDto } from '../../interface/dto/create-plan.dto';
import { UpdatePlanDto } from '../../interface/dto/update-plan.dto';
import {
  PLAN_REPOSITORY,
} from '../../domain/repositories/plan.repository';
import type { PlanRepository } from '../../domain/repositories/plan.repository';

@Injectable()
export class CreatePlanUseCase {
  constructor(
    @Inject(PLAN_REPOSITORY)
    private readonly planRepository: PlanRepository,
  ) {}

  execute(data: CreatePlanDto) {
    return this.planRepository.create(data);
  }
}

@Injectable()
export class ListPlansUseCase {
  constructor(
    @Inject(PLAN_REPOSITORY)
    private readonly planRepository: PlanRepository,
  ) {}

  execute() {
    return this.planRepository.findAll();
  }
}

@Injectable()
export class GetPlanUseCase {
  constructor(
    @Inject(PLAN_REPOSITORY)
    private readonly planRepository: PlanRepository,
  ) {}

  async execute(id: number) {
    const plan = await this.planRepository.findById(id);

    if (!plan) {
      throw new NotFoundException(`Plano com ID ${id} nao encontrado.`);
    }

    return plan;
  }
}

@Injectable()
export class UpdatePlanUseCase {
  constructor(
    @Inject(PLAN_REPOSITORY)
    private readonly planRepository: PlanRepository,
  ) {}

  execute(id: number, data: UpdatePlanDto) {
    return this.planRepository.update(id, data);
  }
}

@Injectable()
export class DeletePlanUseCase {
  constructor(
    @Inject(PLAN_REPOSITORY)
    private readonly planRepository: PlanRepository,
  ) {}

  async execute(id: number) {
    await this.planRepository.remove(id);

    return { message: `Plano com ID ${id} removido com sucesso.` };
  }
}
