import { ConflictException, NotFoundException } from '@nestjs/common';
import {
  ChangePlanUseCase,
  RenewSubscriptionUseCase,
} from './subscription.use-cases';
import {
  SubscriptionDetails,
  SubscriptionRepository,
} from '../../domain/repositories/subscription.repository';

describe('Subscription use cases', () => {
  const makeSubscription = (
    overrides: Partial<SubscriptionDetails> = {},
  ): SubscriptionDetails => ({
    id: 10,
    userId: 1,
    planId: 2,
    status: 'CANCELED',
    startDate: new Date('2026-01-01T00:00:00.000Z'),
    endDate: new Date('2026-02-01T00:00:00.000Z'),
    canceledAt: new Date('2026-02-01T00:00:00.000Z'),
    autoRenew: false,
    createdAt: new Date('2026-01-01T00:00:00.000Z'),
    updatedAt: new Date('2026-02-01T00:00:00.000Z'),
    plan: basePlan,
    payments: [],
    ...overrides,
  });

  const basePlan = {
    id: 2,
    code: 'PRO',
    name: 'Pro',
    description: 'Plano Pro',
    priceCents: 2990,
    durationDays: 30,
    color: '#000',
    isActive: true,
    createdAt: new Date('2026-03-01T00:00:00.000Z'),
    updatedAt: new Date('2026-03-01T00:00:00.000Z'),
  };

  const subscriptionRepositoryMock: jest.Mocked<SubscriptionRepository> = {
    findActiveByUserId: jest.fn(),
    findHistoryByUserId: jest.fn(),
    findActivePlanById: jest.fn(),
    cancelActiveSubscription: jest.fn(),
    changePlan: jest.fn(),
    renewActiveSubscription: jest.fn(),
    findLatestByUserId: jest.fn(),
    createSubscription: jest.fn(),
  };

  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('change plan falha quando o plano nao existe ou esta inativo', async () => {
    subscriptionRepositoryMock.findActivePlanById.mockResolvedValue(null);

    const useCase = new ChangePlanUseCase(subscriptionRepositoryMock);

    await expect(useCase.execute(1, { planId: 99 })).rejects.toThrow(
      NotFoundException,
    );
  });

  it('renew cria nova assinatura quando nao existe uma ativa e o ultimo plano segue ativo', async () => {
    subscriptionRepositoryMock.findActiveByUserId.mockResolvedValue(null);
    subscriptionRepositoryMock.findLatestByUserId.mockResolvedValue(
      makeSubscription(),
    );
    subscriptionRepositoryMock.createSubscription.mockImplementation(
      async (data) =>
        makeSubscription({
          id: 11,
          userId: data.userId,
          planId: data.planId,
          status: 'ACTIVE',
          startDate: data.startDate,
          endDate: data.endDate,
          canceledAt: null,
          autoRenew: data.autoRenew,
          createdAt: data.startDate,
          updatedAt: data.startDate,
        }),
    );

    const useCase = new RenewSubscriptionUseCase(subscriptionRepositoryMock);
    const result = await useCase.execute(1, { autoRenew: true });

    expect(subscriptionRepositoryMock.createSubscription).toHaveBeenCalled();
    expect(result.status).toBe('ACTIVE');
    expect(result.autoRenew).toBe(true);
    expect(result.plan.id).toBe(2);
  });

  it('renew falha quando o ultimo plano nao esta mais disponivel', async () => {
    subscriptionRepositoryMock.findActiveByUserId.mockResolvedValue(null);
    subscriptionRepositoryMock.findLatestByUserId.mockResolvedValue(
      makeSubscription({
        plan: {
          ...basePlan,
          isActive: false,
        },
      }),
    );

    const useCase = new RenewSubscriptionUseCase(subscriptionRepositoryMock);

    await expect(useCase.execute(1, {})).rejects.toThrow(ConflictException);
  });
});
