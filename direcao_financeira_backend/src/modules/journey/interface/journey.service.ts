import {
  Injectable,
  NotFoundException,
  BadRequestException,
  Inject,
} from '@nestjs/common';
import { AppGateway } from '../../websocket/interface/app.gateway';
import { JOURNEY_REPOSITORY } from '../domain/repositories/journey.repository';
import type {
  JourneyRepository,
  ShiftRoutePointData,
} from '../domain/repositories/journey.repository';
import { SyncFinishedShiftDto } from './dto/sync-finished-shift.dto';
import { TrackedRouteDto } from './dto/tracked-route.dto';

@Injectable()
export class JourneyService {
  constructor(
    @Inject(JOURNEY_REPOSITORY)
    private readonly journeyRepository: JourneyRepository,
    private readonly appGateway: AppGateway,
  ) {}

  async getActiveShift(userId: number) {
    const activeShift = await this.journeyRepository.findActiveShift(userId);

    if (!activeShift) {
      return null;
    }

    const rides = await this.journeyRepository.findRidesByShift(activeShift.id);
    const currentDrivenKm = rides.reduce((acc, ride) => acc + ride.totalKm, 0);

    return {
      id: activeShift.id,
      remoteShiftId: activeShift.id,
      startTime: activeShift.startTime,
      createdAt: activeShift.createdAt,
      currentDrivenKm,
      idleTime: activeShift.idleTime,
    };
  }

  async syncFinishedShift(userId: number, dto: SyncFinishedShiftDto) {
    const remoteShiftId =
      dto.remoteShiftId != null && dto.remoteShiftId <= 2147483647
        ? dto.remoteShiftId
        : undefined;
    const startTime = new Date(dto.startTime);
    const endTime = new Date(dto.endTime);

    if (Number.isNaN(startTime.getTime()) || Number.isNaN(endTime.getTime())) {
      throw new BadRequestException('Datas do turno sao invalidas.');
    }

    if (endTime <= startTime) {
      throw new BadRequestException(
        'O horario final precisa ser maior que o horario inicial.',
      );
    }

    const totalTime = Math.floor(
      (endTime.getTime() - startTime.getTime()) / 1000,
    );
    const idleTime = Math.max(0, Math.floor(dto.idleTime || 0));
    const totalDrivenKm = Math.max(0, dto.totalDrivenKm || 0);
    const averageKmh =
      totalDrivenKm > 0 && totalTime > 0
        ? totalDrivenKm / (totalTime / 3600)
        : 0;

    let shift;

    if (remoteShiftId != null) {
      const existingShift = await this.journeyRepository.findShiftByIdForUser(
        remoteShiftId,
        userId,
      );

      if (!existingShift) {
        throw new NotFoundException(
          'Turno remoto nao encontrado para sincronizar.',
        );
      }

      shift = await this.journeyRepository.updateCompletedShift(
        existingShift.id,
        {
          startTime,
          endTime,
          totalTime,
          idleTime,
          totalDrivenKm,
          averageKmh,
          averageTime: existingShift.averageTime ?? 0,
        },
      );
    } else {
      shift = await this.journeyRepository.createCompletedShift(userId, {
        startTime,
        endTime,
        totalTime,
        idleTime,
        totalDrivenKm,
        averageKmh,
        averageTime: 0,
      });
    }

    if (dto.trackedRoute != null) {
      await this.journeyRepository.upsertShiftRoute(
        shift.id,
        this.parseTrackedRoute(dto.trackedRoute),
      );
    }

    this.appGateway.emitToUser(userId, 'journey.shift.finished', {
      shiftId: shift.id,
      endedAt: shift.endTime,
      syncedFromMobile: true,
    });

    return shift;
  }

  private getRangeByFilter(
    filter: 'day' | 'week' | 'month' | 'year' | 'custom',
    baseDate?: string,
    endDateParam?: string,
  ): { start: Date; end: Date } {
    const now = baseDate ? new Date(baseDate) : new Date();
    let start: Date;
    let end: Date;

    switch (filter) {
      case 'custom':
        start = new Date(now.setHours(0, 0, 0, 0));
        end = endDateParam
          ? new Date(new Date(endDateParam).setHours(23, 59, 59, 999))
          : new Date(now.setHours(23, 59, 59, 999));
        break;
      case 'day':
        start = new Date(now.setHours(0, 0, 0, 0));
        end = new Date(now.setHours(23, 59, 59, 999));
        break;
      case 'week':
        const day = now.getDay();
        const diff = now.getDate() - day + (day === 0 ? -6 : 1);
        start = new Date(now.setDate(diff));
        start.setHours(0, 0, 0, 0);
        end = new Date(start);
        end.setDate(start.getDate() + 6);
        end.setHours(23, 59, 59, 999);
        break;
      case 'month':
        start = new Date(now.getFullYear(), now.getMonth(), 1);
        end = new Date(
          now.getFullYear(),
          now.getMonth() + 1,
          0,
          23,
          59,
          59,
          999,
        );
        break;
      case 'year':
        start = new Date(now.getFullYear(), 0, 1);
        end = new Date(now.getFullYear(), 11, 31, 23, 59, 59, 999);
        break;
      default:
        start = new Date(now.setHours(0, 0, 0, 0));
        end = new Date(now.setHours(23, 59, 59, 999));
    }
    return { start, end };
  }

  async getStats(
    userId: number,
    filter: 'day' | 'week' | 'month' | 'year' | 'custom',
    date?: string,
    endDate?: string,
  ) {
    const { start, end } = this.getRangeByFilter(filter, date, endDate);

    const shifts = await this.journeyRepository.findShiftsByPeriod(
      userId,
      start,
      end,
    );
    const rides = await this.journeyRepository.findRidesByPeriod(
      userId,
      start,
      end,
    );

    // Shift Stats
    const totalShifts = shifts.length;
    const totalTime = shifts.reduce((acc, s) => acc + s.totalTime, 0);
    const totalIdleTime = shifts.reduce((acc, s) => acc + s.idleTime, 0);
    const totalKm = shifts.reduce((acc, s) => acc + s.totalDrivenKm, 0);

    const avgKmh =
      totalKm > 0 && totalTime > 0 ? totalKm / (totalTime / 3600) : 0;

    const avgShiftTime =
      totalShifts > 0 ? Math.floor(totalTime / totalShifts) : 0;

    // Ride Stats
    const totalRides = rides.length;
    const grossEarningsCents = rides.reduce(
      (acc, r) => acc + r.grossValueCents,
      0,
    );
    const netEarningsCents = rides.reduce(
      (acc, r) => acc + r.netProfitCents,
      0,
    );
    const totalCostsCents = grossEarningsCents - netEarningsCents;
    const ridesTotalKm = rides.reduce((acc, r) => acc + r.totalKm, 0);
    const ridesTotalTime = rides.reduce((acc, r) => acc + r.totalTime, 0); // seconds

    return {
      totalShifts,
      totalTime,
      totalIdleTime,
      totalKm,
      avgKmh,
      avgShiftTime,
      rideStats: {
        totalRides,
        grossEarningsCents,
        netEarningsCents,
        totalCostsCents,
        ridesTotalKm,
        ridesTotalTime,
      },
    };
  }

  async getHistory(
    userId: number,
    filter?: 'day' | 'week' | 'month' | 'year' | 'custom',
    date?: string,
    endDate?: string,
  ) {
    const range = filter
      ? this.getRangeByFilter(filter, date, endDate)
      : undefined;
    const history = await this.journeyRepository.findShiftHistory(
      userId,
      range?.start,
      range?.end,
    );

    return history.map((shift) => ({
      id: shift.id,
      remoteShiftId: shift.id,
      startTime: shift.startTime,
      endTime: shift.endTime,
      totalTime: shift.totalTime,
      totalDrivenKm: shift.totalDrivenKm,
      ridesCount: shift._count.rides,
      hasRoute: shift.route != null,
      trackedDistanceKm: shift.route
        ? shift.route.totalDistanceMeters / 1000
        : 0,
      routePointCount: shift.route?.pointCount ?? 0,
    }));
  }

  async getShiftRoute(userId: number, shiftId: number) {
    const route = await this.journeyRepository.findShiftRouteForUser(
      shiftId,
      userId,
    );

    if (!route) {
      throw new NotFoundException('Rota do turno nao encontrada.');
    }

    return {
      shiftId: route.shiftId,
      shiftStartTime: route.shift.startTime,
      shiftEndTime: route.shift.endTime,
      startedAt: route.startedAt,
      endedAt: route.endedAt,
      totalDistanceMeters: route.totalDistanceMeters,
      pointCount: route.pointCount,
      points: this.serializeRoutePoints(route.points),
    };
  }

  private parseTrackedRoute(trackedRoute: TrackedRouteDto) {
    const startedAt = new Date(trackedRoute.startedAt);
    const endedAt = new Date(trackedRoute.endedAt);

    if (
      Number.isNaN(startedAt.getTime()) ||
      Number.isNaN(endedAt.getTime()) ||
      endedAt < startedAt
    ) {
      throw new BadRequestException('A rota informada e invalida.');
    }

    const points = trackedRoute.points
      .map<ShiftRoutePointData>((point) => {
        const recordedAt = new Date(point.recordedAt);

        if (Number.isNaN(recordedAt.getTime())) {
          throw new BadRequestException(
            'A rota informada possui pontos com data invalida.',
          );
        }

        return {
          latitude: point.latitude,
          longitude: point.longitude,
          accuracyMeters: point.accuracyMeters,
          recordedAt,
        };
      })
      .sort(
        (first, second) =>
          first.recordedAt.getTime() - second.recordedAt.getTime(),
      );

    return {
      points,
      pointCount: points.length,
      totalDistanceMeters: Math.max(0, trackedRoute.totalDistanceMeters),
      startedAt,
      endedAt,
    };
  }

  private serializeRoutePoints(pointsValue: unknown) {
    if (!Array.isArray(pointsValue)) {
      return [];
    }

    return pointsValue
      .map((point) => {
        if (point == null || typeof point !== 'object') {
          return null;
        }

        const data = point as Record<string, unknown>;
        const latitude = Number(data.latitude);
        const longitude = Number(data.longitude);
        const accuracyMeters = Number(data.accuracyMeters);
        const recordedAt = data.recordedAt;

        if (
          Number.isNaN(latitude) ||
          Number.isNaN(longitude) ||
          Number.isNaN(accuracyMeters) ||
          typeof recordedAt !== 'string'
        ) {
          return null;
        }

        return {
          latitude,
          longitude,
          accuracyMeters,
          recordedAt,
        };
      })
      .filter((point) => point != null);
  }
}
