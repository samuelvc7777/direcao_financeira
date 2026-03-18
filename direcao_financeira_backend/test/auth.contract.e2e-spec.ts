import { INestApplication } from '@nestjs/common';
import { Test, TestingModule } from '@nestjs/testing';
import request from 'supertest';
import { AuthController } from '../src/modules/auth/interface/auth.controller';
import { AuthService } from '../src/modules/auth/interface/auth.service';
import { JwtAuthGuard } from '../src/modules/auth/interface/guards/jwt-auth.guard';

describe('Auth contract (e2e)', () => {
  let app: INestApplication;

  const authServiceMock = {
    register: jest.fn(),
    login: jest.fn(),
    me: jest.fn(),
  };

  const jwtAuthGuardMock = {
    canActivate: (context: any) => {
      context.switchToHttp().getRequest().user = {
        userId: 42,
        email: 'samuel@teste.com',
        role: 'USER',
        name: 'Samuel',
      };
      return true;
    },
  };

  beforeEach(async () => {
    jest.clearAllMocks();

    const moduleFixture: TestingModule = await Test.createTestingModule({
      controllers: [AuthController],
      providers: [
        {
          provide: AuthService,
          useValue: authServiceMock,
        },
      ],
    })
      .overrideGuard(JwtAuthGuard)
      .useValue(jwtAuthGuardMock)
      .compile();

    app = moduleFixture.createNestApplication();
    await app.init();
  });

  afterEach(async () => {
    await app.close();
  });

  it('POST /auth/register preserva o contrato de sucesso', async () => {
    authServiceMock.register.mockResolvedValue({
      access_token: 'token-register',
      user: {
        id: 1,
        name: 'Samuel',
        email: 'samuel@teste.com',
        role: 'USER',
      },
    });

    const response = await request(app.getHttpServer())
      .post('/auth/register')
      .send({
        name: 'Samuel',
        email: 'samuel@teste.com',
        password: 'Senha@123',
      })
      .expect(201);

    expect(response.body).toEqual({
      message: 'Usuario cadastrado com sucesso! Bem-vindo(a) ao sistema.',
      access_token: 'token-register',
      user: {
        id: 1,
        name: 'Samuel',
        email: 'samuel@teste.com',
        role: 'USER',
      },
    });
  });

  it('POST /auth/login preserva o contrato de sucesso', async () => {
    authServiceMock.login.mockResolvedValue({
      access_token: 'token-login',
      user: {
        id: 1,
        name: 'Samuel',
        email: 'samuel@teste.com',
        role: 'USER',
      },
    });

    const response = await request(app.getHttpServer())
      .post('/auth/login')
      .send({
        email: 'samuel@teste.com',
        password: 'Senha@123',
      })
      .expect(200);

    expect(response.body).toEqual({
      access_token: 'token-login',
      user: {
        id: 1,
        name: 'Samuel',
        email: 'samuel@teste.com',
        role: 'USER',
      },
    });
  });

  it('GET /auth/me preserva o contrato do perfil autenticado', async () => {
    authServiceMock.me.mockResolvedValue({
      id: 42,
      name: 'Samuel',
      email: 'samuel@teste.com',
      role: 'USER',
      activeSubscription: null,
      subscriptions: [],
    });

    const response = await request(app.getHttpServer())
      .get('/auth/me')
      .expect(200);

    expect(authServiceMock.me).toHaveBeenCalledWith(42);
    expect(response.body).toEqual({
      id: 42,
      name: 'Samuel',
      email: 'samuel@teste.com',
      role: 'USER',
      activeSubscription: null,
      subscriptions: [],
    });
  });
});
