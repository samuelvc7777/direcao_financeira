import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../../../prisma/prisma.service';
import { Shift, Ride, ShiftRoute } from '@prisma/client';
import {
  JourneyRepository,
  ShiftHistoryRecord,
  ShiftRouteRecord,
  ShiftRouteWriteData,
  SyncedShiftWriteData,
} from '../../domain/repositories/journey.repository';

@Injectable()
export class PrismaJourneyRepository implements JourneyRepository {
  constructor(private readonly prisma: PrismaService) {}

  async findActiveShift(userId: number): Promise<Shift | null> {
    return this.prisma.client.shift.findFirst({
      where: { userId, endTime: null },
    });
  }

  async findShiftByIdForUser(
    shiftId: number,
    userId: number,
  ): Promise<Shift | null> {
    return this.prisma.client.shift.findFirst({
      where: { id: shiftId, userId },
    });
  }

  async createCompletedShift(
    userId: number,
    data: SyncedShiftWriteData,
  ): Promise<Shift> {
    return this.prisma.client.shift.create({
      data: {
        userId,
        ...data,
      },
    });
  }

  async updateCompletedShift(
    id: number,
    data: SyncedShiftWriteData,
  ): Promise<Shift> {
    return this.prisma.client.shift.update({
      where: { id },
      data,
    });
  }

  async findShiftsByPeriod(
    userId: number,
    startDate: Date,
    endDate?: Date,
  ): Promise<Shift[]> {
    return this.prisma.client.shift.findMany({
      where: {
        userId,
        startTime: {
          gte: startDate,
          ...(endDate ? { lte: endDate } : {}),
        },
        endTime: { not: null },
      },
    });
  }

  async findShiftHistory(
    userId: number,
    startDate?: Date,
    endDate?: Date,
  ): Promise<ShiftHistoryRecord[]> {
    return this.prisma.client.shift.findMany({
      where: {
        userId,
        endTime: { not: null },
        ...(startDate || endDate
          ? {
              startTime: {
                ...(startDate ? { gte: startDate } : {}),
                ...(endDate ? { lte: endDate } : {}),
              },
            }
          : {}),
      },
      orderBy: { startTime: 'desc' },
      include: {
        route: {
          select: {
            pointCount: true,
            totalDistanceMeters: true,
          },
        },
        _count: {
          select: { rides: true },
        },
      },
    });
  }

  async upsertShiftRoute(
    shiftId: number,
    data: ShiftRouteWriteData,
  ): Promise<ShiftRoute> {
    const serializedPoints = data.points.map((point) => ({
      latitude: point.latitude,
      longitude: point.longitude,
      accuracyMeters: point.accuracyMeters,
      recordedAt: point.recordedAt.toISOString(),
    }));

    return this.prisma.client.shiftRoute.upsert({
      where: { shiftId },
      create: {
        shiftId,
        points: serializedPoints,
        pointCount: data.pointCount,
        totalDistanceMeters: data.totalDistanceMeters,
        startedAt: data.startedAt,
        endedAt: data.endedAt,
      },
      update: {
        points: serializedPoints,
        pointCount: data.pointCount,
        totalDistanceMeters: data.totalDistanceMeters,
        startedAt: data.startedAt,
        endedAt: data.endedAt,
      },
    });
  }

  async findShiftRouteForUser(
    shiftId: number,
    userId: number,
  ): Promise<ShiftRouteRecord | null> {
    return this.prisma.client.shiftRoute.findFirst({
      where: {
        shiftId,
        shift: {
          userId,
        },
      },
      include: {
        shift: {
          select: {
            id: true,
            userId: true,
            startTime: true,
            endTime: true,
          },
        },
      },
    });
  }

  async findRidesByShift(shiftId: number): Promise<Ride[]> {
    return this.prisma.client.ride.findMany({
      where: { shiftId, status: 'FINISHED' },
    });
  }

  async findRidesByPeriod(
    userId: number,
    startDate: Date,
    endDate?: Date,
  ): Promise<Ride[]> {
    return this.prisma.client.ride.findMany({
      where: {
        userId,
        createdAt: {
          gte: startDate,
          ...(endDate ? { lte: endDate } : {}),
        },
      },
    });
  }
}
