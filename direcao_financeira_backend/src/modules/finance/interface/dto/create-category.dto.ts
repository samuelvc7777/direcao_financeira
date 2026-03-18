import { CategoryType } from '@prisma/client';
import { IsEnum, IsNotEmpty, IsString } from 'class-validator';

export class CreateCategoryDto {
  @IsString()
  @IsNotEmpty({ message: 'O nome da categoria e obrigatorio.' })
  name: string;

  @IsEnum(CategoryType, { message: 'Tipo de categoria invalido.' })
  type: CategoryType;

  @IsString()
  @IsNotEmpty({ message: 'A cor da categoria e obrigatoria.' })
  color: string;

  @IsString()
  @IsNotEmpty({ message: 'O icone da categoria e obrigatorio.' })
  icon: string;
}
