import {
  Body,
  Controller,
  Get,
  Param,
  ParseIntPipe,
  Post,
  Query,
  UseGuards,
} from '@nestjs/common';
import { JwtAuthGuard } from '../../auth/interface/guards/jwt-auth.guard';
import { CurrentUser } from '../../auth/interface/decorators/current-user.decorator';
import { JourneyService } from './journey.service';
import { SyncFinishedShiftDto } from './dto/sync-finished-shift.dto';
import type { AuthenticatedUser } from '../../auth/interface/types/authenticated-user.type';

@Controller('journey')
@UseGuards(JwtAuthGuard)
export class JourneyController {
  constructor(private readonly journeyService: JourneyService) {}

  @Get('active')
  getActiveShift(@CurrentUser() user: AuthenticatedUser) {
    return this.journeyService.getActiveShift(user.userId);
  }

  @Post('sync-finished')
  syncFinishedShift(
    @CurrentUser() user: AuthenticatedUser,
    @Body() dto: SyncFinishedShiftDto,
  ) {
    return this.journeyService.syncFinishedShift(user.userId, dto);
  }

  @Get('stats')
  getStats(
    @CurrentUser() user: AuthenticatedUser,
    @Query('filter')
    filter: 'day' | 'week' | 'month' | 'year' | 'custom' = 'day',
    @Query('date') date?: string,
    @Query('endDate') endDate?: string,
  ) {
    return this.journeyService.getStats(user.userId, filter, date, endDate);
  }

  @Get('history')
  getHistory(
    @CurrentUser() user: AuthenticatedUser,
    @Query('filter') filter?: 'day' | 'week' | 'month' | 'year' | 'custom',
    @Query('date') date?: string,
    @Query('endDate') endDate?: string,
  ) {
    return this.journeyService.getHistory(user.userId, filter, date, endDate);
  }

  @Get(':shiftId/route')
  getShiftRoute(
    @CurrentUser() user: AuthenticatedUser,
    @Param('shiftId', ParseIntPipe) shiftId: number,
  ) {
    return this.journeyService.getShiftRoute(user.userId, shiftId);
  }
}
