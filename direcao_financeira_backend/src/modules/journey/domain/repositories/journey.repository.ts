import { Shift, Ride, ShiftRoute } from '@prisma/client';

export const JOURNEY_REPOSITORY = 'JOURNEY_REPOSITORY';

export type SyncedShiftWriteData = Pick<
  Shift,
  | 'startTime'
  | 'endTime'
  | 'totalTime'
  | 'idleTime'
  | 'totalDrivenKm'
  | 'averageKmh'
  | 'averageTime'
>;

export type ShiftRoutePointData = {
  latitude: number;
  longitude: number;
  accuracyMeters: number;
  recordedAt: Date;
};

export type ShiftRouteWriteData = {
  points: ShiftRoutePointData[];
  pointCount: number;
  totalDistanceMeters: number;
  startedAt: Date;
  endedAt: Date;
};

export type ShiftHistoryRecord = Shift & {
  _count: { rides: number };
  route: Pick<ShiftRoute, 'pointCount' | 'totalDistanceMeters'> | null;
};

export type ShiftRouteRecord = ShiftRoute & {
  shift: Pick<Shift, 'id' | 'userId' | 'startTime' | 'endTime'>;
};

export interface JourneyRepository {
  findActiveShift(userId: number): Promise<Shift | null>;
  findShiftByIdForUser(shiftId: number, userId: number): Promise<Shift | null>;
  createCompletedShift(
    userId: number,
    data: SyncedShiftWriteData,
  ): Promise<Shift>;
  updateCompletedShift(id: number, data: SyncedShiftWriteData): Promise<Shift>;
  findShiftsByPeriod(
    userId: number,
    startDate: Date,
    endDate?: Date,
  ): Promise<Shift[]>;
  findShiftHistory(
    userId: number,
    startDate?: Date,
    endDate?: Date,
  ): Promise<ShiftHistoryRecord[]>;
  upsertShiftRoute(
    shiftId: number,
    data: ShiftRouteWriteData,
  ): Promise<ShiftRoute>;
  findShiftRouteForUser(
    shiftId: number,
    userId: number,
  ): Promise<ShiftRouteRecord | null>;
  findRidesByShift(shiftId: number): Promise<Ride[]>;
  findRidesByPeriod(
    userId: number,
    startDate: Date,
    endDate?: Date,
  ): Promise<Ride[]>;
}
