import { Module } from '@nestjs/common';
import { PrismaModule } from '../../../prisma/prisma.module';
import { FinanceController } from './finance.controller';
import { FinanceService } from './finance.service';
import { FINANCE_REPOSITORY } from '../domain/repositories/finance.repository';
import { FinanceRulesService } from '../domain/services/finance-rules.service';
import { PrismaFinanceRepository } from '../infrastructure/repositories/prisma-finance.repository';

@Module({
  imports: [PrismaModule],
  controllers: [FinanceController],
  providers: [
    FinanceService,
    FinanceRulesService,
    PrismaFinanceRepository,
    {
      provide: FINANCE_REPOSITORY,
      useExisting: PrismaFinanceRepository,
    },
  ],
  exports: [FinanceService],
})
export class FinanceModule {}
