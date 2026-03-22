import { ConflictException, Injectable } from '@nestjs/common';
import {
  InvoiceStatus,
  Prisma,
  TransactionStatus,
  TransactionType,
  AssetType,
} from '@prisma/client';
import { PrismaService } from '../../../../prisma/prisma.service';
import { CreateBankAccountDto } from '../../interface/dto/create-bank-account.dto';
import { CreateCategoryDto } from '../../interface/dto/create-category.dto';
import { CreateCreditCardDto } from '../../interface/dto/create-credit-card.dto';
import { UpdateBankAccountDto } from '../../interface/dto/update-bank-account.dto';
import { UpdateCategoryDto } from '../../interface/dto/update-category.dto';
import { UpdateCreditCardDto } from '../../interface/dto/update-credit-card.dto';
import {
  BankAccountRecord,
  BankAccountFinancialSnapshot,
  CategoryRecord,
  CreditCardFinancialSnapshot,
  CreditCardInvoiceDetails,
  CreditCardInvoiceListDetails,
  CreditCardInvoiceRecord,
  CreditCardInvoiceWithPaymentOwner,
  CreditCardRecord,
  FinanceRepository,
  FinanceTransactionContext,
  InvoicePaymentWithRelations,
  TransactionWithRelations,
} from '../../domain/repositories/finance.repository';

function isPrismaKnownError(error: unknown): error is { code: string } {
  return typeof error === 'object' && error !== null && 'code' in error;
}

class PrismaFinanceTransactionContext implements FinanceTransactionContext {
  constructor(private readonly tx: Prisma.TransactionClient) {}

  private readonly transactionInclude = {
    category: true,
    bankAccount: true,
    creditCard: true,
    invoice: true,
  } satisfies Prisma.TransactionInclude;

  findActiveBankAccount(userId: number, id: number) {
    return this.tx.bankAccount.findFirst({
      where: { id, userId, isActive: true },
    });
  }

  async updateBankAccountBalance(id: number, currentBalanceCents: number) {
    await this.tx.bankAccount.update({
      where: { id },
      data: { currentBalanceCents },
    });
  }

  findActiveCreditCard(userId: number, id: number) {
    return this.tx.creditCard.findFirst({
      where: { id, userId, isActive: true },
    });
  }

  async updateCreditCard(id: number, data: { availableLimitCents: number }) {
    await this.tx.creditCard.update({
      where: { id },
      data,
    });
  }

  findInvoiceByReference(
    creditCardId: number,
    referenceMonth: number,
    referenceYear: number,
  ) {
    return this.tx.creditCardInvoice.findUnique({
      where: {
        creditCardId_referenceMonth_referenceYear: {
          creditCardId,
          referenceMonth,
          referenceYear,
        },
      },
    });
  }

  findInvoiceById(id: number) {
    return this.tx.creditCardInvoice.findUnique({
      where: { id },
    });
  }

  async getInvoiceClearedTotal(invoiceId: number): Promise<number> {
    const aggregate = await this.tx.transaction.aggregate({
      where: {
        invoiceId,
        status: TransactionStatus.CLEARED,
      },
      _sum: { amountCents: true },
    });

    return aggregate._sum.amountCents ?? 0;
  }

  createInvoice(data: {
    creditCardId: number;
    referenceMonth: number;
    referenceYear: number;
    closingDate: Date;
    dueDate: Date;
    totalCents: number;
    paidCents: number;
    status: InvoiceStatus;
  }): Promise<CreditCardInvoiceRecord> {
    return this.tx.creditCardInvoice.create({ data });
  }

  async updateInvoice(
    id: number,
    data: Partial<{
      totalCents: number;
      paidCents: number;
      status: InvoiceStatus;
    }>,
  ) {
    await this.tx.creditCardInvoice.update({
      where: { id },
      data,
    });
  }

  createTransaction(data: {
    userId: number;
    type: TransactionType;
    assetType: AssetType;
    bankAccountId?: number;
    creditCardId?: number;
    categoryId: number;
    invoiceId?: number;
    description: string;
    amountCents: number;
    transactionDate: Date;
    competencyDate: Date | null;
    status: TransactionStatus;
    notes?: string;
    installmentGroupId?: string;
    installmentNumber?: number;
    installmentCount?: number;
  }): Promise<TransactionWithRelations> {
    return this.tx.transaction.create({
      data,
      include: this.transactionInclude,
    });
  }

  findTransactionById(
    userId: number,
    id: number,
  ): Promise<TransactionWithRelations | null> {
    return this.tx.transaction.findFirst({
      where: { id, userId },
      include: this.transactionInclude,
    });
  }

  listTransactionsByIds(
    userId: number,
    ids: number[],
  ): Promise<TransactionWithRelations[]> {
    return this.tx.transaction.findMany({
      where: { userId, id: { in: ids } },
      include: this.transactionInclude,
      orderBy: [{ transactionDate: 'asc' }, { id: 'asc' }],
    });
  }

  listTransactionsByInstallmentGroup(
    userId: number,
    installmentGroupId: string,
  ): Promise<TransactionWithRelations[]> {
    return this.tx.transaction.findMany({
      where: { userId, installmentGroupId },
      include: this.transactionInclude,
      orderBy: [
        { installmentNumber: 'asc' },
        { transactionDate: 'asc' },
        { id: 'asc' },
      ],
    });
  }

  updateTransaction(
    id: number,
    data: Partial<{
      categoryId: number;
      description: string;
      amountCents: number;
      transactionDate: Date;
      competencyDate: Date | null;
      status: TransactionStatus;
      notes: string | null;
      invoiceId: number | null;
    }>,
  ): Promise<TransactionWithRelations> {
    return this.tx.transaction.update({
      where: { id },
      data,
      include: this.transactionInclude,
    });
  }

  async deleteTransactions(ids: number[]): Promise<number> {
    if (ids.length === 0) {
      return 0;
    }

    const result = await this.tx.transaction.deleteMany({
      where: { id: { in: ids } },
    });

    return result.count;
  }

  async getBankAccountFinancialSnapshot(
    id: number,
  ): Promise<BankAccountFinancialSnapshot> {
    const account = await this.tx.bankAccount.findUnique({
      where: { id },
      select: { initialBalanceCents: true },
    });

    if (!account) {
      throw new ConflictException(
        'Conta bancaria nao encontrada para recalculo.',
      );
    }

    const incomeAggregate = await this.tx.transaction.aggregate({
      where: {
        bankAccountId: id,
        status: TransactionStatus.CLEARED,
        type: TransactionType.INCOME,
      },
      _sum: { amountCents: true },
    });

    const expenseAggregate = await this.tx.transaction.aggregate({
      where: {
        bankAccountId: id,
        status: TransactionStatus.CLEARED,
        type: TransactionType.EXPENSE,
      },
      _sum: { amountCents: true },
    });

    const paymentAggregate = await this.tx.invoicePayment.aggregate({
      where: { bankAccountId: id },
      _sum: { amountCents: true },
    });

    return {
      initialBalanceCents: account.initialBalanceCents,
      clearedIncomeCents: incomeAggregate._sum.amountCents ?? 0,
      clearedExpenseCents: expenseAggregate._sum.amountCents ?? 0,
      invoicePaymentsCents: paymentAggregate._sum.amountCents ?? 0,
    };
  }

  async getCreditCardFinancialSnapshot(
    id: number,
  ): Promise<CreditCardFinancialSnapshot> {
    const card = await this.tx.creditCard.findUnique({
      where: { id },
      select: { limitCents: true },
    });

    if (!card) {
      throw new ConflictException(
        'Cartao de credito nao encontrado para recalculo.',
      );
    }

    const spentAggregate = await this.tx.transaction.aggregate({
      where: {
        creditCardId: id,
        status: TransactionStatus.CLEARED,
      },
      _sum: { amountCents: true },
    });

    const paidAggregate = await this.tx.invoicePayment.aggregate({
      where: {
        invoice: { creditCardId: id },
      },
      _sum: { amountCents: true },
    });

    return {
      limitCents: card.limitCents,
      clearedSpentCents: spentAggregate._sum.amountCents ?? 0,
      paidCents: paidAggregate._sum.amountCents ?? 0,
    };
  }

  findInvoiceForPayment(
    userId: number,
    invoiceId: number,
  ): Promise<CreditCardInvoiceWithPaymentOwner | null> {
    return this.tx.creditCardInvoice.findFirst({
      where: {
        id: invoiceId,
        creditCard: { userId },
      },
      include: { creditCard: true },
    });
  }

  createInvoicePayment(data: {
    invoiceId: number;
    bankAccountId: number;
    amountCents: number;
    paymentDate: Date;
  }): Promise<InvoicePaymentWithRelations> {
    return this.tx.invoicePayment.create({
      data,
      include: {
        bankAccount: true,
        invoice: true,
      },
    });
  }
}

@Injectable()
export class PrismaFinanceRepository implements FinanceRepository {
  constructor(private readonly prisma: PrismaService) {}

  private readonly transactionInclude = {
    category: true,
    bankAccount: true,
    creditCard: true,
    invoice: true,
  } satisfies Prisma.TransactionInclude;

  createBankAccount(
    userId: number,
    dto: CreateBankAccountDto,
  ): Promise<BankAccountRecord> {
    return this.prisma.client.bankAccount.create({
      data: {
        userId,
        ...dto,
        currentBalanceCents: dto.initialBalanceCents,
      },
    });
  }

  listBankAccounts(userId: number): Promise<BankAccountRecord[]> {
    return this.prisma.client.bankAccount.findMany({
      where: { userId },
      orderBy: { createdAt: 'desc' },
    });
  }

  findBankAccount(
    userId: number,
    id: number,
    onlyActive = true,
  ): Promise<BankAccountRecord | null> {
    return this.prisma.client.bankAccount.findFirst({
      where: {
        id,
        userId,
        ...(onlyActive ? { isActive: true } : {}),
      },
    });
  }

  updateBankAccount(
    id: number,
    dto: UpdateBankAccountDto | { isActive: boolean },
  ): Promise<BankAccountRecord> {
    return this.prisma.client.bankAccount.update({
      where: { id },
      data: dto,
    });
  }

  createCreditCard(
    userId: number,
    dto: CreateCreditCardDto,
  ): Promise<CreditCardRecord> {
    return this.prisma.client.creditCard.create({
      data: {
        userId,
        ...dto,
        availableLimitCents: dto.limitCents,
      },
    });
  }

  listCreditCards(userId: number): Promise<CreditCardRecord[]> {
    return this.prisma.client.creditCard.findMany({
      where: { userId },
      orderBy: { createdAt: 'desc' },
    });
  }

  findCreditCard(
    userId: number,
    id: number,
    onlyActive = true,
  ): Promise<CreditCardRecord | null> {
    return this.prisma.client.creditCard.findFirst({
      where: {
        id,
        userId,
        ...(onlyActive ? { isActive: true } : {}),
      },
    });
  }

  updateCreditCard(
    id: number,
    dto: UpdateCreditCardDto & {
      availableLimitCents?: number;
      isActive?: boolean;
    },
  ): Promise<CreditCardRecord> {
    return this.prisma.client.creditCard.update({
      where: { id },
      data: dto,
    });
  }

  async createCategory(
    userId: number,
    dto: CreateCategoryDto,
  ): Promise<CategoryRecord> {
    try {
      return await this.prisma.client.category.create({
        data: { userId, ...dto },
      });
    } catch (error: unknown) {
      if (isPrismaKnownError(error) && error.code === 'P2002') {
        throw new ConflictException(
          'Ja existe uma categoria com este nome e tipo para este usuario.',
        );
      }
      throw error;
    }
  }

  listCategories(userId: number): Promise<CategoryRecord[]> {
    return this.prisma.client.category.findMany({
      where: { userId },
      orderBy: [{ type: 'asc' }, { name: 'asc' }],
    });
  }

  findCategory(
    userId: number,
    id: number,
    onlyActive = true,
  ): Promise<CategoryRecord | null> {
    return this.prisma.client.category.findFirst({
      where: {
        id,
        userId,
        ...(onlyActive ? { isActive: true } : {}),
      },
    });
  }

  async updateCategory(
    id: number,
    dto: UpdateCategoryDto | { isActive: boolean },
  ): Promise<CategoryRecord> {
    try {
      return await this.prisma.client.category.update({
        where: { id },
        data: dto,
      });
    } catch (error: unknown) {
      if (isPrismaKnownError(error) && error.code === 'P2002') {
        throw new ConflictException(
          'Ja existe uma categoria com este nome e tipo para este usuario.',
        );
      }
      throw error;
    }
  }

  listTransactions(userId: number): Promise<TransactionWithRelations[]> {
    return this.prisma.client.transaction.findMany({
      where: { userId },
      include: this.transactionInclude,
      orderBy: [{ transactionDate: 'desc' }, { createdAt: 'desc' }],
    });
  }

  findTransaction(
    userId: number,
    id: number,
  ): Promise<TransactionWithRelations | null> {
    return this.prisma.client.transaction.findFirst({
      where: { id, userId },
      include: this.transactionInclude,
    });
  }

  listCardInvoices(
    userId: number,
    creditCardId: number,
  ): Promise<CreditCardInvoiceListDetails[]> {
    return this.prisma.client.creditCardInvoice.findMany({
      where: {
        creditCardId,
        creditCard: { userId },
      },
      include: {
        transactions: true,
        payments: true,
      },
      orderBy: [{ referenceYear: 'desc' }, { referenceMonth: 'desc' }],
    });
  }

  findCardInvoice(
    userId: number,
    creditCardId: number,
    invoiceId: number,
  ): Promise<CreditCardInvoiceDetails | null> {
    return this.prisma.client.creditCardInvoice.findFirst({
      where: {
        id: invoiceId,
        creditCardId,
        creditCard: { userId },
      },
      include: {
        transactions: true,
        payments: { include: { bankAccount: true } },
      },
    });
  }

  runInTransaction<T>(callback: (tx: FinanceTransactionContext) => Promise<T>) {
    return this.prisma.client.$transaction((tx) => {
      const context = new PrismaFinanceTransactionContext(tx);
      return callback(context);
    });
  }
}
