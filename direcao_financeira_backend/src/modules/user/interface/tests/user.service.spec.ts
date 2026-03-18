import { Test, TestingModule } from '@nestjs/testing';
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

describe('UserService', () => {
  let service: UserService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
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

    service = module.get<UserService>(UserService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });
});
