import { Module } from '@nestjs/common';
import { SubscriptionController } from './subscription.controller';
import { SubscriptionService } from './subscription.service';
import { PrismaModule } from '../../../prisma/prisma.module';
import {
  CancelCurrentSubscriptionUseCase,
  ChangePlanUseCase,
  GetActiveSubscriptionUseCase,
  GetSubscriptionHistoryUseCase,
  RenewSubscriptionUseCase,
} from '../application/use-cases/subscription.use-cases';
import { SUBSCRIPTION_REPOSITORY } from '../domain/repositories/subscription.repository';
import { PrismaSubscriptionRepository } from '../infrastructure/repositories/prisma-subscription.repository';

@Module({
  imports: [PrismaModule],
  controllers: [SubscriptionController],
  providers: [
    SubscriptionService,
    GetActiveSubscriptionUseCase,
    GetSubscriptionHistoryUseCase,
    ChangePlanUseCase,
    CancelCurrentSubscriptionUseCase,
    RenewSubscriptionUseCase,
    PrismaSubscriptionRepository,
    {
      provide: SUBSCRIPTION_REPOSITORY,
      useExisting: PrismaSubscriptionRepository,
    },
  ],
  exports: [SubscriptionService],
})
export class SubscriptionModule {}
