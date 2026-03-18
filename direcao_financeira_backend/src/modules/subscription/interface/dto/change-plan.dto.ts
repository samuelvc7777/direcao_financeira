import { IsInt, Min } from 'class-validator';

export class ChangePlanDto {
  @IsInt({ message: 'O ID do plano deve ser um numero inteiro.' })
  @Min(1, { message: 'O ID do plano deve ser maior que zero.' })
  planId: number;
}
