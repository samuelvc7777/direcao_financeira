import { Module } from '@nestjs/common';
import { UserService } from './user.service';
import { UserController } from './user.controller';
import { PrismaModule } from '../../../prisma/prisma.module';
import {
  CreateUserUseCase,
  FindAllUsersUseCase,
  FindUserByEmailUseCase,
  FindUserByIdUseCase,
  RemoveUserUseCase,
  UpdateUserUseCase,
} from '../application/use-cases/user.use-cases';
import { USER_REPOSITORY } from '../domain/repositories/user.repository';
import { PrismaUserRepository } from '../infrastructure/repositories/prisma-user.repository';
import { PASSWORD_HASHER } from '../../auth/domain/services/password-hasher';
import { BcryptPasswordHasherService } from '../../auth/infrastructure/services/bcrypt-password-hasher.service';

@Module({
  imports: [PrismaModule],
  controllers: [UserController],
  providers: [
    UserService,
    CreateUserUseCase,
    FindAllUsersUseCase,
    FindUserByIdUseCase,
    FindUserByEmailUseCase,
    UpdateUserUseCase,
    RemoveUserUseCase,
    PrismaUserRepository,
    BcryptPasswordHasherService,
    {
      provide: USER_REPOSITORY,
      useExisting: PrismaUserRepository,
    },
    {
      provide: PASSWORD_HASHER,
      useExisting: BcryptPasswordHasherService,
    },
  ],
  exports: [
    UserService,
    CreateUserUseCase,
    FindAllUsersUseCase,
    FindUserByIdUseCase,
    FindUserByEmailUseCase,
    UpdateUserUseCase,
    RemoveUserUseCase,
  ],
})
export class UserModule {}
