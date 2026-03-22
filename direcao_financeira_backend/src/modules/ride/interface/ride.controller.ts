import {
  Body,
  Controller,
  Get,
  Param,
  Patch,
  Post,
  Query,
  UseGuards,
} from '@nestjs/common';
import { JwtAuthGuard } from '../../auth/interface/guards/jwt-auth.guard';
import { CurrentUser } from '../../auth/interface/decorators/current-user.decorator';
import { RideService } from './ride.service';
import { CreateRideDto } from './dto/create-ride.dto';
import { FilterRideDto } from './dto/filter-ride.dto';
import { RideStatus } from '@prisma/client';
import type { AuthenticatedUser } from '../../auth/interface/types/authenticated-user.type';

@Controller('rides')
@UseGuards(JwtAuthGuard)
export class RideController {
  constructor(private readonly rideService: RideService) {}

  @Post()
  async create(
    @CurrentUser() user: AuthenticatedUser,
    @Body() dto: CreateRideDto,
  ) {
    const ride = await this.rideService.create(user.userId, dto);
    return { message: 'Corrida registrada com sucesso.', ride };
  }

  @Get()
  findAll(
    @CurrentUser() user: AuthenticatedUser,
    @Query() filters: FilterRideDto,
  ) {
    return this.rideService.findAll(user.userId, filters);
  }

  @Patch(':id/status')
  async updateStatus(
    @CurrentUser() user: AuthenticatedUser,
    @Param('id') id: string,
    @Body('status') status: RideStatus,
  ) {
    const ride = await this.rideService.updateStatus(user.userId, +id, status);
    return { message: 'Status da corrida atualizado com sucesso.', ride };
  }
}
