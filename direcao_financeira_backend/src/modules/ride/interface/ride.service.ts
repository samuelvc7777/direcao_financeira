import { Injectable, NotFoundException, Inject } from '@nestjs/common';
import { AppGateway } from '../../websocket/interface/app.gateway';
import { JOURNEY_REPOSITORY } from '../../journey/domain/repositories/journey.repository';
import type { JourneyRepository } from '../../journey/domain/repositories/journey.repository';
import { RIDE_REPOSITORY } from '../domain/repositories/ride.repository';
import type { RideRepository } from '../domain/repositories/ride.repository';
import { CreateRideDto } from './dto/create-ride.dto';
import { FilterRideDto } from './dto/filter-ride.dto';
import { RideStatus } from '@prisma/client';
import { RideRulesService } from '../domain/services/ride-rules.service';

@Injectable()
export class RideService {
  constructor(
    @Inject(RIDE_REPOSITORY)
    private readonly rideRepository: RideRepository,
    @Inject(JOURNEY_REPOSITORY)
    private readonly journeyRepository: JourneyRepository,
    private readonly rideRulesService: RideRulesService,
    private readonly appGateway: AppGateway,
  ) {}

  async create(userId: number, dto: CreateRideDto) {
    const gainPerKmCents = this.rideRulesService.calculateGainPerKm(
      dto.netProfitCents,
      dto.totalKm,
    );

    const gainPerHourCents = this.rideRulesService.calculateGainPerHour(
      dto.netProfitCents,
      dto.totalTime,
    );

    const activeShift = dto.shiftId == null
      ? await this.journeyRepository.findActiveShift(userId)
      : null;

    const ride = await this.rideRepository.createRide(userId, {
      ...dto,
      shiftId: dto.shiftId ?? activeShift?.id,
      gainPerKmCents,
      gainPerHourCents,
      status: 'FINISHED',
    });

    this.appGateway.emitToUser(userId, 'journey.ride.created', {
      rideId: ride.id,
      shiftId: ride.shiftId,
      status: ride.status,
    });

    return ride;
  }

  async findAll(userId: number, filters: FilterRideDto) {
    const { status, period, date, endDate } = filters;
    const prismaFilters: any = {};

    if (status) {
      prismaFilters.status = status;
    }

    if (period && period !== 'all') {
      const now = date ? new Date(date) : new Date();
      let start: Date;
      let end: Date;

      switch (period) {
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

      if (period === 'custom') {
        start = new Date(now.setHours(0, 0, 0, 0));
        end = endDate
          ? new Date(new Date(endDate).setHours(23, 59, 59, 999))
          : new Date(now.setHours(23, 59, 59, 999));
      }

      prismaFilters.createdAt = {
        gte: start,
        lte: end,
      };
    }

    return this.rideRepository.findAllRides(userId, prismaFilters);
  }

  async updateStatus(userId: number, id: number, status: RideStatus) {
    const ride = await this.rideRepository.findRideById(userId, id);

    if (!ride) {
      throw new NotFoundException('Corrida nao encontrada.');
    }

    const updatedRide = await this.rideRepository.updateRideStatus(id, status);

    this.appGateway.emitToUser(userId, 'journey.ride.updated', {
      rideId: updatedRide.id,
      shiftId: updatedRide.shiftId,
      status: updatedRide.status,
    });

    return updatedRide;
  }
}
