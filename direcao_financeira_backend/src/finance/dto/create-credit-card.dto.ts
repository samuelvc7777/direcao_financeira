import { IsInt, IsNotEmpty, IsString, Length, Max, Min } from 'class-validator';

export class CreateCreditCardDto {
  @IsString()
  @IsNotEmpty({ message: 'O nome do cartao e obrigatorio.' })
  name: string;

  @IsString()
  @IsNotEmpty({ message: 'A bandeira do cartao e obrigatoria.' })
  brand: string;

  @IsString()
  @Length(4, 4, { message: 'Os ultimos quatro digitos devem ter 4 caracteres.' })
  lastFourDigits: string;

  @IsInt({ message: 'O limite deve ser um numero inteiro em centavos.' })
  @Min(0, { message: 'O limite nao pode ser negativo.' })
  limitCents: number;

  @IsInt({ message: 'O dia de fechamento deve ser inteiro.' })
  @Min(1, { message: 'O dia de fechamento deve ser entre 1 e 31.' })
  @Max(31, { message: 'O dia de fechamento deve ser entre 1 e 31.' })
  closingDay: number;

  @IsInt({ message: 'O dia de vencimento deve ser inteiro.' })
  @Min(1, { message: 'O dia de vencimento deve ser entre 1 e 31.' })
  @Max(31, { message: 'O dia de vencimento deve ser entre 1 e 31.' })
  dueDay: number;
}
