import {
  IsBoolean,
  IsEmail,
  IsEnum,
  IsNotEmpty,
  IsNumber,
  IsOptional,
  IsString,
  Matches,
  MinLength,
} from 'class-validator';

export class CreateUserDto {
  @IsString()
  @IsNotEmpty({ message: 'O nome é obrigatório' })
  name: string;

  @IsEmail({}, { message: 'O e-mail informado é inválido' })
  email: string;

  @IsString()
  @MinLength(8, { message: 'A senha deve ter no mínimo 8 caracteres' })
  @Matches(/(?=.*\W+)(?![.\n])(?=.*[A-Z])(?=.*[a-z]).*$/, {
    message:
      'A senha é muito fraca. Ela deve conter pelo menos uma letra maiúscula, uma letra minúscula e um caractere especial (símbolo).',
  })
  password: string;

  @IsOptional()
  @IsEnum(['USER', 'ADMIN', 'ATTENDANT'], { message: 'Cargo inválido' })
  role?: 'USER' | 'ADMIN' | 'ATTENDANT';

  @IsOptional()
  @IsNumber({}, { message: 'ID do plano inválido' })
  planId?: number;

  @IsOptional()
  @IsBoolean({ message: 'O status de atividade deve ser um valor booleano' })
  isActive?: boolean;
}
