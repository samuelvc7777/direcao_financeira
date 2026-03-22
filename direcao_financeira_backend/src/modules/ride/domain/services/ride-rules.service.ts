import { Injectable } from '@nestjs/common';

@Injectable()
export class RideRulesService {
  calculateGainPerKm(netProfitCents: number, totalKm: number): number {
    return totalKm > 0 ? Math.round(netProfitCents / totalKm) : 0;
  }

  calculateGainPerHour(
    netProfitCents: number,
    totalTimeSeconds: number,
  ): number {
    return totalTimeSeconds > 0
      ? Math.round(netProfitCents / (totalTimeSeconds / 3600))
      : 0;
  }
}
