import { Inject, Injectable, UnauthorizedException } from '@nestjs/common';
import { LoginDto } from '../../interface/dto/login.dto';
import { CreateUserDto } from '../../../user/interface/dto/create-user.dto';
import {
  CreateUserUseCase,
  FindUserByEmailUseCase,
  FindUserByIdUseCase,
} from '../../../user/application/use-cases/user.use-cases';
import { PASSWORD_HASHER } from '../../domain/services/password-hasher';
import { TOKEN_SERVICE } from '../../domain/services/token-service';
import type { PasswordHasher } from '../../domain/services/password-hasher';
import type { TokenService } from '../../domain/services/token-service';

@Injectable()
export class RegisterUseCase {
  constructor(
    private readonly createUserUseCase: CreateUserUseCase,
    @Inject(TOKEN_SERVICE)
    private readonly tokenService: TokenService,
  ) {}

  async execute(createUserDto: CreateUserDto) {
    const user = await this.createUserUseCase.execute(createUserDto);
    const payload = {
      sub: user.id,
      email: user.email,
      role: user.role,
      name: user.name,
    };

    return {
      access_token: this.tokenService.sign(payload),
      user,
    };
  }
}

@Injectable()
export class LoginUseCase {
  constructor(
    private readonly findUserByEmailUseCase: FindUserByEmailUseCase,
    private readonly findUserByIdUseCase: FindUserByIdUseCase,
    @Inject(PASSWORD_HASHER)
    private readonly passwordHasher: PasswordHasher,
    @Inject(TOKEN_SERVICE)
    private readonly tokenService: TokenService,
  ) {}

  async execute(loginDto: LoginDto) {
    const user = await this.findUserByEmailUseCase.execute(loginDto.email);

    if (!user?.password) {
      throw new UnauthorizedException('Credenciais invalidas');
    }

    const isPasswordValid = await this.passwordHasher.compare(
      loginDto.password,
      user.password,
    );

    if (!isPasswordValid) {
      throw new UnauthorizedException('Credenciais invalidas');
    }

    const profile = await this.findUserByIdUseCase.execute(user.id);
    const payload = {
      sub: user.id,
      email: user.email,
      role: user.role,
      name: user.name,
    };

    return {
      access_token: this.tokenService.sign(payload),
      user: profile,
    };
  }
}

@Injectable()
export class GetAuthenticatedProfileUseCase {
  constructor(private readonly findUserByIdUseCase: FindUserByIdUseCase) {}

  async execute(userId: number) {
    const profile = await this.findUserByIdUseCase.execute(userId);

    if (!profile) {
      throw new UnauthorizedException('Usuario nao encontrado');
    }

    return profile;
  }
}
