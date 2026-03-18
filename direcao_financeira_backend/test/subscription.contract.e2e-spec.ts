import { INestApplication } from '@nestjs/common';
import { Test, TestingModule } from '@nestjs/testing';
import request from 'supertest';
import { SubscriptionController } from '../src/modules/subscription/interface/subscription.controller';
import { SubscriptionService } from '../src/modules/subscription/interface/subscription.service';
import { JwtAuthGuard } from '../src/modules/auth/interface/guards/jwt-auth.guard';

describe('Subscription contract (e2e)', () => {
  let app: INestApplication;

  const subscriptionServiceMock = {
    getActiveSubscription: jest.fn(),
    getSubscriptionHistory: jest.fn(),
    changePlan: jest.fn(),
    cancelCurrentSubscription: jest.fn(),
    renewSubscription: jest.fn(),
  };

  const jwtAuthGuardMock = {
    canActivate: (context: any) => {
      context.switchToHttp().getRequest().user = {
        userId: 7,
        email: 'user@teste.com',
        role: 'USER',
        name: 'User Teste',
      };
      return true;
    },
  };

  beforeEach(async () => {
    jest.clearAllMocks();

    const moduleFixture: TestingModule = await Test.createTestingModule({
      controllers: [SubscriptionController],
      providers: [
        {
          provide: SubscriptionService,
          useValue: subscriptionServiceMock,
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

  it('POST /subscriptions/me/change-plan preserva payload de resposta', async () => {
    subscriptionServiceMock.changePlan.mockResolvedValue({
      id: 99,
      status: 'ACTIVE',
      autoRenew: false,
      plan: {
        id: 2,
        code: 'PRO',
        name: 'Pro',
      },
      payments: [],
    });

    const response = await request(app.getHttpServer())
      .post('/subscriptions/me/change-plan')
      .send({ planId: 2 })
      .expect(201);

    expect(subscriptionServiceMock.changePlan).toHaveBeenCalledWith(7, { planId: 2 });
    expect(response.body).toEqual({
      message: 'Plano alterado com sucesso.',
      subscription: {
        id: 99,
        status: 'ACTIVE',
        autoRenew: false,
        plan: {
          id: 2,
          code: 'PRO',
          name: 'Pro',
        },
        payments: [],
      },
    });
  });
});
