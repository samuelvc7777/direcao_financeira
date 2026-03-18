import { IsBoolean, IsOptional } from 'class-validator';

export class RenewSubscriptionDto {
  @IsOptional()
  @IsBoolean({ message: 'autoRenew deve ser um valor booleano.' })
  autoRenew?: boolean;
}
