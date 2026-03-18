import { Test, TestingModule } from '@nestjs/testing';
import { UserController } from '../user.controller';
import { UserService } from '../user.service';
import { createMockProvider } from '../../../../test-utils/mock-provider';
import {
  CreateUserUseCase,
  FindAllUsersUseCase,
  FindUserByEmailUseCase,
  FindUserByIdUseCase,
  RemoveUserUseCase,
  UpdateUserUseCase,
} from '../../application/use-cases/user.use-cases';

describe('UserController', () => {
  let controller: UserController;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [UserController],
      providers: [
        UserService,
        createMockProvider(CreateUserUseCase),
        createMockProvider(FindAllUsersUseCase),
        createMockProvider(FindUserByIdUseCase),
        createMockProvider(FindUserByEmailUseCase),
        createMockProvider(UpdateUserUseCase),
        createMockProvider(RemoveUserUseCase),
      ],
    }).compile();

    controller = module.get<UserController>(UserController);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });
});
