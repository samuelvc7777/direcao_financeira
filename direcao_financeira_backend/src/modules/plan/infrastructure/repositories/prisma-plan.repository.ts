import {
  ConflictException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { PrismaService } from '../../../../prisma/prisma.service';
import { CreatePlanDto } from '../../interface/dto/create-plan.dto';
import { UpdatePlanDto } from '../../interface/dto/update-plan.dto';
import { PlanRepository } from '../../domain/repositories/plan.repository';

function isPrismaKnownError(error: unknown): error is { code: string } {
  return typeof error === 'object' && error !== null && 'code' in error;
}

@Injectable()
export class PrismaPlanRepository implements PlanRepository {
  constructor(private readonly prisma: PrismaService) {}

  async create(data: CreatePlanDto) {
    try {
      return await this.prisma.client.plan.create({ data });
    } catch (error: unknown) {
      if (isPrismaKnownError(error) && error.code === 'P2002') {
        throw new ConflictException(
          'Ja existe um plano com este nome ou codigo.',
        );
      }
      throw error;
    }
  }

  findAll() {
    return this.prisma.client.plan.findMany({
      orderBy: { priceCents: 'asc' },
    });
  }

  findById(id: number) {
    return this.prisma.client.plan.findUnique({
      where: { id },
    });
  }

  async update(id: number, data: UpdatePlanDto) {
    try {
      return await this.prisma.client.plan.update({
        where: { id },
        data,
      });
    } catch (error: unknown) {
      if (isPrismaKnownError(error) && error.code === 'P2025') {
        throw new NotFoundException(`Plano com ID ${id} nao encontrado.`);
      }
      if (isPrismaKnownError(error) && error.code === 'P2002') {
        throw new ConflictException(
          'Ja existe um plano com este nome ou codigo.',
        );
      }
      throw error;
    }
  }

  async remove(id: number) {
    try {
      await this.prisma.client.plan.delete({
        where: { id },
      });
    } catch (error: unknown) {
      if (isPrismaKnownError(error) && error.code === 'P2025') {
        throw new NotFoundException(`Plano com ID ${id} nao encontrado.`);
      }
      throw error;
    }
  }
}
