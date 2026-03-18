import { Injectable } from '@nestjs/common';
import { CreateUserDto } from '../../user/interface/dto/create-user.dto';
import { LoginDto } from './dto/login.dto';
import {
  GetAuthenticatedProfileUseCase,
  LoginUseCase,
  RegisterUseCase,
} from '../application/use-cases/auth.use-cases';

@Injectable()
export class AuthService {
  constructor(
    private readonly registerUseCase: RegisterUseCase,
    private readonly loginUseCase: LoginUseCase,
    private readonly getAuthenticatedProfileUseCase: GetAuthenticatedProfileUseCase,
  ) {}

  register(createUserDto: CreateUserDto) {
    return this.registerUseCase.execute(createUserDto);
  }

  login(loginDto: LoginDto) {
    return this.loginUseCase.execute(loginDto);
  }

  me(userId: number) {
    return this.getAuthenticatedProfileUseCase.execute(userId);
  }
}
