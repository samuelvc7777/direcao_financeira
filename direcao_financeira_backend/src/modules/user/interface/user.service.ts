import { Injectable } from '@nestjs/common';
import { CreateUserDto } from './dto/create-user.dto';
import { UpdateUserDto } from './dto/update-user.dto';
import {
  CreateUserUseCase,
  FindAllUsersUseCase,
  FindUserByEmailUseCase,
  FindUserByIdUseCase,
  RemoveUserUseCase,
  UpdateUserUseCase,
} from '../application/use-cases/user.use-cases';

@Injectable()
export class UserService {
  constructor(
    private readonly createUserUseCase: CreateUserUseCase,
    private readonly findAllUsersUseCase: FindAllUsersUseCase,
    private readonly findUserByIdUseCase: FindUserByIdUseCase,
    private readonly findUserByEmailUseCase: FindUserByEmailUseCase,
    private readonly updateUserUseCase: UpdateUserUseCase,
    private readonly removeUserUseCase: RemoveUserUseCase,
  ) {}

  create(createUserDto: CreateUserDto) {
    return this.createUserUseCase.execute(createUserDto);
  }

  findAll() {
    return this.findAllUsersUseCase.execute();
  }

  findByEmail(email: string) {
    return this.findUserByEmailUseCase.execute(email);
  }

  findOne(id: number) {
    return this.findUserByIdUseCase.execute(id);
  }

  update(id: number, updateUserDto: UpdateUserDto) {
    return this.updateUserUseCase.execute(id, updateUserDto);
  }

  remove(id: number) {
    return this.removeUserUseCase.execute(id);
  }

  getProfileById(id: number) {
    return this.findOne(id);
  }
}
