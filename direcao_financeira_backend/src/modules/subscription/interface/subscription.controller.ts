import {
  Body,
  Controller,
  Get,
  Post,
  UseGuards,
} from '@nestjs/common';
import { SubscriptionService } from './subscription.service';
import { JwtAuthGuard } from '../../auth/interface/guards/jwt-auth.guard';
import { CurrentUser } from '../../auth/interface/decorators/current-user.decorator';
import { ChangePlanDto } from './dto/change-plan.dto';
import { RenewSubscriptionDto } from './dto/renew-subscription.dto';
import type { AuthenticatedUser } from '../../auth/interface/types/authenticated-user.type';

@Controller('subscriptions')
@UseGuards(JwtAuthGuard)
export class SubscriptionController {
  constructor(private readonly subscriptionService: SubscriptionService) {}

  @Get('me')
  async getMyActiveSubscription(@CurrentUser() user: AuthenticatedUser) {
    return this.subscriptionService.getActiveSubscription(user.userId);
  }

  @Get('me/history')
  async getMySubscriptionHistory(@CurrentUser() user: AuthenticatedUser) {
    return this.subscriptionService.getSubscriptionHistory(user.userId);
  }

  @Post('me/change-plan')
  async changeMyPlan(
    @CurrentUser() user: AuthenticatedUser,
    @Body() changePlanDto: ChangePlanDto,
  ) {
    const subscription = await this.subscriptionService.changePlan(
      user.userId,
      changePlanDto,
    );

    return {
      message: 'Plano alterado com sucesso.',
      subscription,
    };
  }

  @Post('me/cancel')
  async cancelMySubscription(@CurrentUser() user: AuthenticatedUser) {
    const subscription = await this.subscriptionService.cancelCurrentSubscription(
      user.userId,
    );

    return {
      message: 'Assinatura cancelada com sucesso.',
      subscription,
    };
  }

  @Post('me/renew')
  async renewMySubscription(
    @CurrentUser() user: AuthenticatedUser,
    @Body() renewDto: RenewSubscriptionDto,
  ) {
    const subscription = await this.subscriptionService.renewSubscription(
      user.userId,
      renewDto,
    );

    return {
      message: 'Assinatura renovada com sucesso.',
      subscription,
    };
  }
}
