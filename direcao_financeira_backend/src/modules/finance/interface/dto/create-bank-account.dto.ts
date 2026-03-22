import { AccountType } from '@prisma/client';
import {
  IsEnum,
  IsInt,
  IsNotEmpty,
  IsOptional,
  IsString,
  Min,
} from 'class-validator';

export class CreateBankAccountDto {
  @IsString()
  @IsNotEmpty({ message: 'O nome da conta e obrigatorio.' })
  name: string;

  @IsString()
  @IsNotEmpty({ message: 'O nome do banco e obrigatorio.' })
  bankName: string;

  @IsString()
  @IsOptional()
  color?: string;

  @IsEnum(AccountType, { message: 'Tipo de conta invalido.' })
  accountType: AccountType;

  @IsInt({ message: 'O saldo inicial deve ser um numero inteiro em centavos.' })
  @Min(0, { message: 'O saldo inicial nao pode ser negativo.' })
  initialBalanceCents: number;
}
