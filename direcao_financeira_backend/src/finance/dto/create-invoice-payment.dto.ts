import { IsDateString, IsInt, Min } from 'class-validator';

export class CreateInvoicePaymentDto {
  @IsInt({ message: 'bankAccountId deve ser inteiro.' })
  @Min(1, { message: 'bankAccountId invalido.' })
  bankAccountId: number;

  @IsInt({ message: 'O valor deve ser inteiro em centavos.' })
  @Min(1, { message: 'O valor deve ser maior que zero.' })
  amountCents: number;

  @IsDateString({}, { message: 'A data de pagamento e invalida.' })
  paymentDate: string;
}
