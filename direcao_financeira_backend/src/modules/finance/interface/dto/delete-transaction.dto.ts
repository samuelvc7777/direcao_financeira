import { IsEnum, IsOptional } from 'class-validator';
import { TransactionMutationScope } from './transaction-mutation-scope.dto';

export class DeleteTransactionDto {
  @IsOptional()
  @IsEnum(TransactionMutationScope, { message: 'Escopo de exclusao invalido.' })
  scope?: TransactionMutationScope;
}
