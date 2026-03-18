import { Body, Controller, Get, Param, Post, UseGuards } from '@nestjs/common';
import { AdminService } from './admin.service';
import { JwtAuthGuard } from '../../auth/interface/guards/jwt-auth.guard';
import { RolesGuard } from '../../auth/interface/guards/roles.guard';
import { Roles } from '../../auth/interface/decorators/roles.decorator';
import { Role } from '@prisma/client';
import { SubscriptionService } from '../../subscription/interface/subscription.service';
import { ChangePlanDto } from '../../subscription/interface/dto/change-plan.dto';
import { RenewSubscriptionDto } from '../../subscription/interface/dto/renew-subscription.dto';

@Controller('admin')
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles(Role.ADMIN)
export class AdminController {
  constructor(
    private readonly adminService: AdminService,
    private readonly subscriptionService: SubscriptionService,
  ) {}

  @Get('dashboard')
  async getDashboard() {
    return await this.adminService.getDashboardStats();
  }

  @Post('users/:id/subscription/change-plan')
  async changeUserPlan(
    @Param('id') id: string,
    @Body() changePlanDto: ChangePlanDto,
  ) {
    const subscription = await this.subscriptionService.changePlan(
      +id,
      changePlanDto,
    );

    return {
      message: 'Plano do usuario alterado com sucesso.',
      subscription,
    };
  }

  @Post('users/:id/subscription/cancel')
  async cancelUserSubscription(@Param('id') id: string) {
    const subscription = await this.subscriptionService.cancelCurrentSubscription(
      +id,
    );

    return {
      message: 'Assinatura do usuario cancelada com sucesso.',
      subscription,
    };
  }

  @Post('users/:id/subscription/renew')
  async renewUserSubscription(
    @Param('id') id: string,
    @Body() renewDto: RenewSubscriptionDto,
  ) {
    const subscription = await this.subscriptionService.renewSubscription(
      +id,
      renewDto,
    );

    return {
      message: 'Assinatura do usuario renovada com sucesso.',
      subscription,
    };
  }
}
