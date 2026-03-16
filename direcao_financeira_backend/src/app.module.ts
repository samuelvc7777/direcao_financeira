import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { PrismaModule } from './prisma/prisma.module';
import { UserModule } from './user/user.module';
import { AuthModule } from './auth/auth.module';
import { PlanModule } from './plan/plan.module';
import { AdminModule } from './admin/admin.module';
import { SubscriptionModule } from './subscription/subscription.module';
import { FinanceModule } from './finance/finance.module';

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
