import { IsBoolean, IsNotEmpty, IsNumber, IsString } from 'class-validator';

export class CreatePlanDto {
  @IsString()
  @IsNotEmpty({ message: 'O codigo do plano e obrigatorio' })
  code: string;

  @IsString()
  @IsNotEmpty({ message: 'O nome do plano e obrigatorio' })
  name: string;

  @IsString()
  @IsNotEmpty({ message: 'A descricao do plano e obrigatoria' })
  description: string;

  @IsNumber()
  @IsNotEmpty({ message: 'O preco do plano em centavos e obrigatorio' })
  priceCents: number;

  @IsNumber()
  @IsNotEmpty({ message: 'A duracao em dias e obrigatoria' })
  durationDays: number;

  @IsString()
  @IsNotEmpty({ message: 'A cor do plano e obrigatoria' })
  color: string;

  @IsBoolean()
  @IsNotEmpty({ message: 'O status de atividade e obrigatorio' })
  isActive: boolean;
}
