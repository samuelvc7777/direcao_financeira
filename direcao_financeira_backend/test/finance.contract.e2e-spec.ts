import { INestApplication } from '@nestjs/common';
import { Test, TestingModule } from '@nestjs/testing';
import request from 'supertest';
import { FinanceController } from '../src/modules/finance/interface/finance.controller';
import { FinanceService } from '../src/modules/finance/interface/finance.service';
import { JwtAuthGuard } from '../src/modules/auth/interface/guards/jwt-auth.guard';

describe('Finance contract (e2e)', () => {
  let app: INestApplication;

  const financeServiceMock = {
    createBankAccount: jest.fn(),
    listBankAccounts: jest.fn(),
    updateBankAccount: jest.fn(),
    deactivateBankAccount: jest.fn(),
    createCreditCard: jest.fn(),
    listCreditCards: jest.fn(),
    updateCreditCard: jest.fn(),
    deactivateCreditCard: jest.fn(),
    createCategory: jest.fn(),
    listCategories: jest.fn(),
    updateCategory: jest.fn(),
    deactivateCategory: jest.fn(),
    createTransaction: jest.fn(),
    updateTransaction: jest.fn(),
    deleteTransaction: jest.fn(),
    listTransactions: jest.fn(),
    findTransaction: jest.fn(),
    listCardInvoices: jest.fn(),
    findCardInvoice: jest.fn(),
    payInvoice: jest.fn(),
  };

  const jwtAuthGuardMock = {
    canActivate: (context: any) => {
      context.switchToHttp().getRequest().user = {
        userId: 11,
        email: 'finance@teste.com',
        role: 'USER',
        name: 'Finance User',
      };
      return true;
    },
  };

  beforeEach(async () => {
    jest.clearAllMocks();

    const moduleFixture: TestingModule = await Test.createTestingModule({
      controllers: [FinanceController],
      providers: [
        {
          provide: FinanceService,
          useValue: financeServiceMock,
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

  it('POST /finance/transactions preserva mensagem e payload', async () => {
    financeServiceMock.createTransaction.mockResolvedValue({
      transaction: {
        id: 123,
        description: 'Mercado',
        amountCents: 2590,
        status: 'CLEARED',
      },
      transactions: [
        {
          id: 123,
          description: 'Mercado',
          amountCents: 2590,
          status: 'CLEARED',
        },
      ],
      installmentGroupId: null,
    });

    const payload = {
      type: 'EXPENSE',
      assetType: 'BANK_ACCOUNT',
      accountId: 1,
      categoryId: 3,
      description: 'Mercado',
      amountCents: 2590,
      transactionDate: '2026-03-18T10:00:00.000Z',
    };

    const response = await request(app.getHttpServer())
      .post('/finance/transactions')
      .send(payload)
      .expect(201);

    expect(financeServiceMock.createTransaction).toHaveBeenCalledWith(
      11,
      payload,
    );
    expect(response.body).toEqual({
      message: 'Transacao criada com sucesso.',
      transaction: {
        id: 123,
        description: 'Mercado',
        amountCents: 2590,
        status: 'CLEARED',
      },
      transactions: [
        {
          id: 123,
          description: 'Mercado',
          amountCents: 2590,
          status: 'CLEARED',
        },
      ],
      installmentGroupId: null,
    });
  });

  it('PATCH /finance/transactions/:id preserva mensagem, escopo e payload', async () => {
    financeServiceMock.updateTransaction.mockResolvedValue({
      transaction: {
        id: 123,
        description: 'Mercado atualizado',
        amountCents: 3000,
      },
      transactions: [
        {
          id: 123,
          description: 'Mercado atualizado',
          amountCents: 3000,
        },
      ],
      scope: 'CURRENT',
    });

    const payload = {
      description: 'Mercado atualizado',
      amountCents: 3000,
      scope: 'CURRENT',
    };

    const response = await request(app.getHttpServer())
      .patch('/finance/transactions/123')
      .send(payload)
      .expect(200);

    expect(financeServiceMock.updateTransaction).toHaveBeenCalledWith(
      11,
      123,
      payload,
    );
    expect(response.body).toEqual({
      message: 'Transacao atualizada com sucesso.',
      transaction: {
        id: 123,
        description: 'Mercado atualizado',
        amountCents: 3000,
      },
      transactions: [
        {
          id: 123,
          description: 'Mercado atualizado',
          amountCents: 3000,
        },
      ],
      scope: 'CURRENT',
    });
  });

  it('DELETE /finance/transactions/:id preserva mensagem, escopo e ids removidos', async () => {
    financeServiceMock.deleteTransaction.mockResolvedValue({
      deletedCount: 3,
      scope: 'ALL',
      transactionIds: [123, 124, 125],
    });

    const payload = {
      scope: 'ALL',
    };

    const response = await request(app.getHttpServer())
      .delete('/finance/transactions/123')
      .send(payload)
      .expect(200);

    expect(financeServiceMock.deleteTransaction).toHaveBeenCalledWith(
      11,
      123,
      payload,
    );
    expect(response.body).toEqual({
      message: 'Transacao excluida com sucesso.',
      deletedCount: 3,
      scope: 'ALL',
      transactionIds: [123, 124, 125],
    });
  });

  it('POST /finance/invoices/:invoiceId/payments preserva mensagem e payload', async () => {
    financeServiceMock.payInvoice.mockResolvedValue({
      id: 88,
      amountCents: 5000,
      bankAccountId: 2,
    });

    const payload = {
      bankAccountId: 2,
      amountCents: 5000,
      paymentDate: '2026-03-18T10:00:00.000Z',
    };

    const response = await request(app.getHttpServer())
      .post('/finance/invoices/44/payments')
      .send(payload)
      .expect(201);

    expect(financeServiceMock.payInvoice).toHaveBeenCalledWith(11, 44, payload);
    expect(response.body).toEqual({
      message: 'Pagamento de fatura registrado com sucesso.',
      payment: {
        id: 88,
        amountCents: 5000,
        bankAccountId: 2,
      },
    });
  });
});
