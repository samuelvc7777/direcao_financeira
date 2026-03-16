import {
  AssetType,
  TransactionStatus,
  TransactionType,
} from '@prisma/client';
import {
  IsDateString,
  IsEnum,
  IsInt,
  IsNotEmpty,
  IsOptional,
  IsString,
  Min,
} from 'class-validator';

export class CreateTransactionDto {
  @IsEnum(TransactionType, { message: 'Tipo de transacao invalido.' })
  type: TransactionType;

  @IsEnum(AssetType, { message: 'Tipo de origem invalido.' })
  assetType: AssetType;

  @IsOptional()
  @IsInt({ message: 'bankAccountId deve ser inteiro.' })
  @Min(1, { message: 'bankAccountId invalido.' })
  bankAccountId?: number;

  @IsOptional()
  @IsInt({ message: 'creditCardId deve ser inteiro.' })
  @Min(1, { message: 'creditCardId invalido.' })
  creditCardId?: number;

  @IsInt({ message: 'categoryId deve ser inteiro.' })
  @Min(1, { message: 'categoryId invalido.' })
  categoryId: number;

  @IsString()
  @IsNotEmpty({ message: 'A descricao e obrigatoria.' })
  description: string;

  @IsInt({ message: 'O valor deve ser inteiro em centavos.' })
  @Min(1, { message: 'O valor deve ser maior que zero.' })
  amountCents: number;

  @IsDateString({}, { message: 'A data da transacao e invalida.' })
  transactionDate: string;

  @IsOptional()
  @IsDateString({}, { message: 'A data de competencia e invalida.' })
  competencyDate?: string;

  @IsOptional()
  @IsEnum(TransactionStatus, { message: 'Status da transacao invalido.' })
  status?: TransactionStatus;

  @IsOptional()
  @IsString()
  notes?: string;
}
