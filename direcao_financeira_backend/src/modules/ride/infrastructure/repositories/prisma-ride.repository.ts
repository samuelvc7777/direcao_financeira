import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../../../prisma/prisma.service';
import { Ride, RideStatus } from '@prisma/client';
import { RideRepository } from '../../domain/repositories/ride.repository';

@Injectable()
export class PrismaRideRepository implements RideRepository {
  constructor(private readonly prisma: PrismaService) {}

  async createRide(userId: number, data: any): Promise<Ride> {
    return this.prisma.client.ride.create({
      data: {
        ...data,
        userId,
      },
    });
  }

  async findAllRides(userId: number, filters: any): Promise<Ride[]> {
    return this.prisma.client.ride.findMany({
      where: {
        userId,
        ...filters,
      },
      orderBy: { createdAt: 'desc' },
      include: {
        shift: {
          select: { startTime: true, endTime: true },
        },
      },
    });
  }

  async findRideById(userId: number, id: number): Promise<Ride | null> {
    return this.prisma.client.ride.findFirst({
      where: { id, userId },
    });
  }

  async updateRideStatus(id: number, status: RideStatus): Promise<Ride> {
    return this.prisma.client.ride.update({
      where: { id },
      data: { status },
    });
  }
}
