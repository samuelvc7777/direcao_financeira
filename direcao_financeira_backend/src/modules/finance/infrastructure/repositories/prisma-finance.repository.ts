import { ConflictException, Injectable } from '@nestjs/common';
import { InvoiceStatus, Prisma, TransactionStatus, TransactionType, AssetType } from '@prisma/client';
import { PrismaService } from '../../../../prisma/prisma.service';
import { CreateBankAccountDto } from '../../interface/dto/create-bank-account.dto';
import { CreateCategoryDto } from '../../interface/dto/create-category.dto';
import { CreateCreditCardDto } from '../../interface/dto/create-credit-card.dto';
import { UpdateBankAccountDto } from '../../interface/dto/update-bank-account.dto';
import { UpdateCategoryDto } from '../../interface/dto/update-category.dto';
import { UpdateCreditCardDto } from '../../interface/dto/update-credit-card.dto';
import {
  BankAccountRecord,
  CategoryRecord,
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
    data: Partial<{ totalCents: number; paidCents: number; status: InvoiceStatus }>,
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
  }): Promise<TransactionWithRelations> {
    return this.tx.transaction.create({
      data,
      include: {
        category: true,
        bankAccount: true,
        creditCard: true,
        invoice: true,
      },
    });
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

  createBankAccount(userId: number, dto: CreateBankAccountDto): Promise<BankAccountRecord> {
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

  createCreditCard(userId: number, dto: CreateCreditCardDto): Promise<CreditCardRecord> {
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
    dto: UpdateCreditCardDto & { availableLimitCents?: number; isActive?: boolean },
  ): Promise<CreditCardRecord> {
    return this.prisma.client.creditCard.update({
      where: { id },
      data: dto,
    });
  }

  async createCategory(userId: number, dto: CreateCategoryDto): Promise<CategoryRecord> {
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
      include: {
        category: true,
        bankAccount: true,
        creditCard: true,
        invoice: true,
      },
      orderBy: [{ transactionDate: 'desc' }, { createdAt: 'desc' }],
    });
  }

  findTransaction(userId: number, id: number): Promise<TransactionWithRelations | null> {
    return this.prisma.client.transaction.findFirst({
      where: { id, userId },
      include: {
        category: true,
        bankAccount: true,
        creditCard: true,
        invoice: true,
      },
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
