import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { PrismaModule } from './prisma/prisma.module';
import { UserModule } from './modules/user/interface/user.module';
import { AuthModule } from './modules/auth/interface/auth.module';
import { PlanModule } from './modules/plan/interface/plan.module';
import { AdminModule } from './modules/admin/interface/admin.module';
import { SubscriptionModule } from './modules/subscription/interface/subscription.module';
import { FinanceModule } from './modules/finance/interface/finance.module';

@Module({
  imports: [
    PrismaModule,
    UserModule,
    AuthModule,
    PlanModule,
    AdminModule,
    SubscriptionModule,
    FinanceModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
