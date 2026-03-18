import {
  AssetType,
  CategoryType,
  InvoiceStatus,
  TransactionStatus,
  TransactionType,
} from '@prisma/client';
import { ConflictException, Injectable } from '@nestjs/common';

@Injectable()
export class FinanceRulesService {
  assertCategoryMatchesTransaction(
    transactionType: TransactionType,
    categoryType: CategoryType,
  ) {
    if (
      (transactionType === TransactionType.INCOME &&
        categoryType !== CategoryType.INCOME) ||
      (transactionType === TransactionType.EXPENSE &&
        categoryType !== CategoryType.EXPENSE)
    ) {
      throw new ConflictException(
        'A categoria precisa ter o mesmo tipo da transacao.',
      );
    }
  }

  resolveAssetIds(params: {
    assetType: AssetType;
    accountId?: number;
    bankAccountId?: number;
    creditCardId?: number;
  }) {
    const bankAccountId =
      params.bankAccountId ??
      (params.assetType === AssetType.BANK_ACCOUNT ? params.accountId : undefined);
    const creditCardId =
      params.creditCardId ??
      (params.assetType === AssetType.CREDIT_CARD ? params.accountId : undefined);
    const hasBankAccount = bankAccountId !== undefined;
    const hasCreditCard = creditCardId !== undefined;

    if (hasBankAccount === hasCreditCard) {
      throw new ConflictException(
        'A transacao deve apontar para uma conta bancaria ou cartao, nunca ambos ou nenhum.',
      );
    }

    if (
      (params.assetType === AssetType.BANK_ACCOUNT && !hasBankAccount) ||
      (params.assetType === AssetType.CREDIT_CARD && !hasCreditCard)
    ) {
      throw new ConflictException(
        'Os identificadores informados nao correspondem ao tipo de origem da transacao.',
      );
    }

    return { bankAccountId, creditCardId };
  }

  assertCreditCardExpenseOnly(assetType: AssetType, type: TransactionType) {
    if (assetType === AssetType.CREDIT_CARD && type !== TransactionType.EXPENSE) {
      throw new ConflictException(
        'Cartao de credito aceita apenas transacoes de despesa nesta fase.',
      );
    }
  }

  calculateBankBalanceDelta(
    status: TransactionStatus,
    type: TransactionType,
    amountCents: number,
  ) {
    if (status !== TransactionStatus.CLEARED) {
      return 0;
    }

    return type === TransactionType.INCOME ? amountCents : -amountCents;
  }

  ensureNonNegativeBalance(nextBalance: number) {
    if (nextBalance < 0) {
      throw new ConflictException('Saldo insuficiente para esta transacao.');
    }
  }

  ensureCreditLimit(availableLimitCents: number, amountCents: number) {
    if (availableLimitCents < amountCents) {
      throw new ConflictException('Limite disponivel insuficiente para esta compra.');
    }
  }

  ensureInvoicePaymentAmount(remainingAmount: number, paymentAmount: number) {
    if (remainingAmount <= 0) {
      throw new ConflictException('Esta fatura ja esta quitada.');
    }

    if (paymentAmount > remainingAmount) {
      throw new ConflictException(
        'O valor do pagamento nao pode ser maior que o saldo restante da fatura.',
      );
    }
  }

  ensureBankBalanceForInvoicePayment(balanceCents: number, paymentAmount: number) {
    if (balanceCents < paymentAmount) {
      throw new ConflictException('Saldo insuficiente para pagar a fatura.');
    }
  }

  resolveInvoiceReference(transactionDate: Date, closingDay: number) {
    let referenceMonth = transactionDate.getMonth() + 1;
    let referenceYear = transactionDate.getFullYear();

    if (transactionDate.getDate() > closingDay) {
      referenceMonth += 1;
      if (referenceMonth === 13) {
        referenceMonth = 1;
        referenceYear += 1;
      }
    }

    return { referenceMonth, referenceYear };
  }

  buildInvoiceDates(
    referenceYear: number,
    referenceMonth: number,
    closingDay: number,
    dueDay: number,
  ) {
    const closingDate = this.getMonthDate(referenceYear, referenceMonth - 1, closingDay);
    let dueMonth = referenceMonth;
    let dueYear = referenceYear;

    if (dueDay <= closingDay) {
      dueMonth += 1;
      if (dueMonth === 13) {
        dueMonth = 1;
        dueYear += 1;
      }
    }

    const dueDate = this.getMonthDate(dueYear, dueMonth - 1, dueDay);
    return { closingDate, dueDate };
  }

  resolveInvoiceStatus(
    closingDate: Date,
    dueDate: Date,
    totalCents: number,
    paidCents: number,
  ) {
    const now = new Date();

    if (paidCents >= totalCents && totalCents > 0) {
      return InvoiceStatus.PAID;
    }

    if (dueDate < now && paidCents < totalCents) {
      return InvoiceStatus.OVERDUE;
    }

    if (closingDate < now) {
      return InvoiceStatus.CLOSED;
    }

    return InvoiceStatus.OPEN;
  }

  private getMonthDate(year: number, monthIndex: number, day: number) {
    return new Date(year, monthIndex + 1, 0).getDate() < day
      ? new Date(year, monthIndex + 1, 0)
      : new Date(year, monthIndex, day);
  }
}
