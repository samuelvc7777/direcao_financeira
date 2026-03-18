import {
  Controller,
  Get,
  Post,
  Body,
  Patch,
  Param,
  Delete,
  UseGuards,
} from '@nestjs/common';
import { PlanService } from './plan.service';
import { CreatePlanDto } from './dto/create-plan.dto';
import { UpdatePlanDto } from './dto/update-plan.dto';
import { JwtAuthGuard } from '../../auth/interface/guards/jwt-auth.guard';
import { RolesGuard } from '../../auth/interface/guards/roles.guard';
import { Roles } from '../../auth/interface/decorators/roles.decorator';
import { Role } from '@prisma/client';

@Controller('admin/plans')
@UseGuards(JwtAuthGuard, RolesGuard)
export class PlanController {
  constructor(private readonly planService: PlanService) {}

  @Post()
  @Roles(Role.ADMIN)
  async create(@Body() createPlanDto: CreatePlanDto) {
    const plan = await this.planService.create(createPlanDto);
    return {
      message: 'Plano criado com sucesso!',
      plan,
    };
  }

  @Get()
  async findAll() {
    return await this.planService.findAll();
  }

  @Get(':id')
  async findOne(@Param('id') id: string) {
    return await this.planService.findOne(+id);
  }

  @Patch(':id')
  @Roles(Role.ADMIN)
  async update(@Param('id') id: string, @Body() updatePlanDto: UpdatePlanDto) {
    const plan = await this.planService.update(+id, updatePlanDto);
    return {
      message: 'Plano atualizado com sucesso!',
      plan,
    };
  }

  @Delete(':id')
  @Roles(Role.ADMIN)
  async remove(@Param('id') id: string) {
    return await this.planService.remove(+id);
  }
}
