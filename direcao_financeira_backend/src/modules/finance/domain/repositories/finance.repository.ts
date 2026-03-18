import {
  AssetType,
  InvoiceStatus,
  Prisma,
  TransactionStatus,
  TransactionType,
} from '@prisma/client';
import { CreateBankAccountDto } from '../../interface/dto/create-bank-account.dto';
import { CreateCategoryDto } from '../../interface/dto/create-category.dto';
import { CreateCreditCardDto } from '../../interface/dto/create-credit-card.dto';
import { UpdateBankAccountDto } from '../../interface/dto/update-bank-account.dto';
import { UpdateCategoryDto } from '../../interface/dto/update-category.dto';
import { UpdateCreditCardDto } from '../../interface/dto/update-credit-card.dto';

export const FINANCE_REPOSITORY = 'FINANCE_REPOSITORY';

export type BankAccountRecord = Prisma.BankAccountGetPayload<Record<string, never>>;
export type CreditCardRecord = Prisma.CreditCardGetPayload<Record<string, never>>;
export type CategoryRecord = Prisma.CategoryGetPayload<Record<string, never>>;
export type CreditCardInvoiceRecord = Prisma.CreditCardInvoiceGetPayload<Record<string, never>>;
export type InvoicePaymentRecord = Prisma.InvoicePaymentGetPayload<Record<string, never>>;

export type TransactionWithRelations = Prisma.TransactionGetPayload<{
  include: {
    category: true;
    bankAccount: true;
    creditCard: true;
    invoice: true;
  };
}>;

export type CreditCardInvoiceWithPaymentOwner = Prisma.CreditCardInvoiceGetPayload<{
  include: {
    creditCard: true;
  };
}>;

export type CreditCardInvoiceListDetails = Prisma.CreditCardInvoiceGetPayload<{
  include: {
    transactions: true;
    payments: true;
  };
}>;

export type CreditCardInvoiceDetails = Prisma.CreditCardInvoiceGetPayload<{
  include: {
    transactions: true;
    payments: {
      include: {
        bankAccount: true;
      };
    };
  };
}>;

export type InvoicePaymentWithRelations = Prisma.InvoicePaymentGetPayload<{
  include: {
    bankAccount: true;
    invoice: true;
  };
}>;

export interface FinanceTransactionContext {
  findActiveBankAccount(userId: number, id: number): Promise<BankAccountRecord | null>;
  updateBankAccountBalance(id: number, currentBalanceCents: number): Promise<void>;
  findActiveCreditCard(userId: number, id: number): Promise<CreditCardRecord | null>;
  updateCreditCard(id: number, data: { availableLimitCents: number }): Promise<void>;
  findInvoiceByReference(
    creditCardId: number,
    referenceMonth: number,
    referenceYear: number,
  ): Promise<CreditCardInvoiceRecord | null>;
  createInvoice(data: {
    creditCardId: number;
    referenceMonth: number;
    referenceYear: number;
    closingDate: Date;
    dueDate: Date;
    totalCents: number;
    paidCents: number;
    status: InvoiceStatus;
  }): Promise<CreditCardInvoiceRecord>;
  updateInvoice(
    id: number,
    data: Partial<{ totalCents: number; paidCents: number; status: InvoiceStatus }>,
  ): Promise<void>;
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
  }): Promise<TransactionWithRelations>;
  findInvoiceForPayment(
    userId: number,
    invoiceId: number,
  ): Promise<CreditCardInvoiceWithPaymentOwner | null>;
  createInvoicePayment(data: {
    invoiceId: number;
    bankAccountId: number;
    amountCents: number;
    paymentDate: Date;
  }): Promise<InvoicePaymentWithRelations>;
}

export interface FinanceRepository {
  createBankAccount(userId: number, dto: CreateBankAccountDto): Promise<BankAccountRecord>;
  listBankAccounts(userId: number): Promise<BankAccountRecord[]>;
  findBankAccount(
    userId: number,
    id: number,
    onlyActive?: boolean,
  ): Promise<BankAccountRecord | null>;
  updateBankAccount(
    id: number,
    dto: UpdateBankAccountDto | { isActive: boolean },
  ): Promise<BankAccountRecord>;
  createCreditCard(userId: number, dto: CreateCreditCardDto): Promise<CreditCardRecord>;
  listCreditCards(userId: number): Promise<CreditCardRecord[]>;
  findCreditCard(
    userId: number,
    id: number,
    onlyActive?: boolean,
  ): Promise<CreditCardRecord | null>;
  updateCreditCard(
    id: number,
    dto: UpdateCreditCardDto & { availableLimitCents?: number; isActive?: boolean },
  ): Promise<CreditCardRecord>;
  createCategory(userId: number, dto: CreateCategoryDto): Promise<CategoryRecord>;
  listCategories(userId: number): Promise<CategoryRecord[]>;
  findCategory(userId: number, id: number, onlyActive?: boolean): Promise<CategoryRecord | null>;
  updateCategory(
    id: number,
    dto: UpdateCategoryDto | { isActive: boolean },
  ): Promise<CategoryRecord>;
  listTransactions(userId: number): Promise<TransactionWithRelations[]>;
  findTransaction(userId: number, id: number): Promise<TransactionWithRelations | null>;
  listCardInvoices(
    userId: number,
    creditCardId: number,
  ): Promise<CreditCardInvoiceListDetails[]>;
  findCardInvoice(
    userId: number,
    creditCardId: number,
    invoiceId: number,
  ): Promise<CreditCardInvoiceDetails | null>;
  runInTransaction<T>(callback: (tx: FinanceTransactionContext) => Promise<T>): Promise<T>;
}
