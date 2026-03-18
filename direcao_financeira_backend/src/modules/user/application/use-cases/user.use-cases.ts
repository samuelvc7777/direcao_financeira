import { Inject, Injectable } from '@nestjs/common';
import { CreateUserDto } from '../../interface/dto/create-user.dto';
import { UpdateUserDto } from '../../interface/dto/update-user.dto';
import { PASSWORD_HASHER } from '../../../auth/domain/services/password-hasher';
import { toUserProfileOutput } from '../../domain/services/user-output.mapper';
import {
  USER_REPOSITORY,
} from '../../domain/repositories/user.repository';
import type { PasswordHasher } from '../../../auth/domain/services/password-hasher';
import type { UserRepository } from '../../domain/repositories/user.repository';

@Injectable()
export class CreateUserUseCase {
  constructor(
    @Inject(USER_REPOSITORY)
    private readonly userRepository: UserRepository,
    @Inject(PASSWORD_HASHER)
    private readonly passwordHasher: PasswordHasher,
  ) {}

  async execute(createUserDto: CreateUserDto) {
    let planId: number | undefined = createUserDto.planId;

    if (!planId && (!createUserDto.role || createUserDto.role === 'USER')) {
      planId = (await this.userRepository.findDefaultActivePlanId()) ?? undefined;
    }

    const hashedPassword = await this.passwordHasher.hash(createUserDto.password);

    const user = await this.userRepository.create({
      ...createUserDto,
      planId: planId ?? undefined,
      password: hashedPassword,
    });

    return toUserProfileOutput(user);
  }
}

@Injectable()
export class FindAllUsersUseCase {
  constructor(
    @Inject(USER_REPOSITORY)
    private readonly userRepository: UserRepository,
  ) {}

  async execute() {
    const users = await this.userRepository.findAll();
    return users.map((user) => toUserProfileOutput(user));
  }
}

@Injectable()
export class FindUserByIdUseCase {
  constructor(
    @Inject(USER_REPOSITORY)
    private readonly userRepository: UserRepository,
  ) {}

  async execute(id: number) {
    const user = await this.userRepository.findById(id);
    return user ? toUserProfileOutput(user) : null;
  }
}

@Injectable()
export class FindUserByEmailUseCase {
  constructor(
    @Inject(USER_REPOSITORY)
    private readonly userRepository: UserRepository,
  ) {}

  execute(email: string) {
    return this.userRepository.findByEmail(email);
  }
}

@Injectable()
export class UpdateUserUseCase {
  constructor(
    @Inject(USER_REPOSITORY)
    private readonly userRepository: UserRepository,
  ) {}

  async execute(id: number, updateUserDto: UpdateUserDto) {
    const { planId, ...userData } = updateUserDto;
    void planId;

    const user = await this.userRepository.update(id, userData);
    return toUserProfileOutput(user);
  }
}

@Injectable()
export class RemoveUserUseCase {
  constructor(
    @Inject(USER_REPOSITORY)
    private readonly userRepository: UserRepository,
  ) {}

  execute(id: number) {
    return this.userRepository.remove(id);
  }
}
