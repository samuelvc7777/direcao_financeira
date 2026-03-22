import { TransactionStatus } from '@prisma/client';
import { IsEnum, IsInt, IsOptional, IsString, Min } from 'class-validator';
import {
  IsOptionalDateString,
  TransactionMutationScope,
} from './transaction-mutation-scope.dto';

export class UpdateTransactionDto {
  @IsOptional()
  @IsInt({ message: 'categoryId deve ser inteiro.' })
  @Min(1, { message: 'categoryId invalido.' })
  categoryId?: number;

  @IsOptional()
  @IsString()
  description?: string;

  @IsOptional()
  @IsInt({ message: 'O valor deve ser inteiro em centavos.' })
  @Min(1, { message: 'O valor deve ser maior que zero.' })
  amountCents?: number;

  @IsOptional()
  @IsEnum(TransactionStatus, { message: 'Status da transacao invalido.' })
  status?: TransactionStatus;

  @IsOptional()
  @IsString()
  notes?: string;

  @IsOptional()
  @IsEnum(TransactionMutationScope, {
    message: 'Escopo de alteracao invalido.',
  })
  scope?: TransactionMutationScope;

  @IsOptionalDateString({ message: 'A data da transacao e invalida.' })
  transactionDate?: string | null;

  @IsOptionalDateString({ message: 'A data de competencia e invalida.' })
  competencyDate?: string | null;
}
