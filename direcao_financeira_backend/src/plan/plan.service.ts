import { ConflictException, Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreatePlanDto } from './dto/create-plan.dto';
import { UpdatePlanDto } from './dto/update-plan.dto';

@Injectable()
export class PlanService {
  constructor(private prisma: PrismaService) {}

  async create(createPlanDto: CreatePlanDto) {
    try {
      return await this.prisma.client.plan.create({
        data: createPlanDto,
      });
    } catch (error) {
      if (error.code === 'P2002') {
        throw new ConflictException('Ja existe um plano com este nome ou codigo.');
      }
      throw error;
    }
  }

  async findAll() {
    return await this.prisma.client.plan.findMany({
      orderBy: { priceCents: 'asc' },
    });
  }

  async findOne(id: number) {
    const plan = await this.prisma.client.plan.findUnique({
      where: { id },
    });

    if (!plan) {
      throw new NotFoundException(`Plano com ID ${id} nao encontrado.`);
    }

    return plan;
  }

  async update(id: number, updatePlanDto: UpdatePlanDto) {
    try {
      return await this.prisma.client.plan.update({
        where: { id },
        data: updatePlanDto,
      });
    } catch (error) {
      if (error.code === 'P2025') {
        throw new NotFoundException(`Plano com ID ${id} nao encontrado.`);
      }
      if (error.code === 'P2002') {
        throw new ConflictException('Ja existe um plano com este nome ou codigo.');
      }
      throw error;
    }
  }

  async remove(id: number) {
    try {
      await this.prisma.client.plan.delete({
        where: { id },
      });
      return { message: `Plano com ID ${id} removido com sucesso.` };
    } catch (error) {
      if (error.code === 'P2025') {
        throw new NotFoundException(`Plano com ID ${id} nao encontrado.`);
      }
      throw error;
    }
  }
}
