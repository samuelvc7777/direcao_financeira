import { Ride, RideStatus } from '@prisma/client';

export const RIDE_REPOSITORY = 'RIDE_REPOSITORY';

export interface RideRepository {
  createRide(userId: number, data: any): Promise<Ride>;
  findAllRides(userId: number, filters: any): Promise<Ride[]>;
  findRideById(userId: number, id: number): Promise<Ride | null>;
  updateRideStatus(id: number, status: RideStatus): Promise<Ride>;
}
