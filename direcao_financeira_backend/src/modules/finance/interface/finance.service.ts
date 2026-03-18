import {
  AssetType,
  TransactionStatus,
} from '@prisma/client';
import {
  ConflictException,
  Inject,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { CreateBankAccountDto } from './dto/create-bank-account.dto';
import { UpdateBankAccountDto } from './dto/update-bank-account.dto';
import { CreateCreditCardDto } from './dto/create-credit-card.dto';
import { UpdateCreditCardDto } from './dto/update-credit-card.dto';
import { CreateCategoryDto } from './dto/create-category.dto';
import { UpdateCategoryDto } from './dto/update-category.dto';
import { CreateTransactionDto } from './dto/create-transaction.dto';
import { CreateInvoicePaymentDto } from './dto/create-invoice-payment.dto';
import {
  FINANCE_REPOSITORY,
  FinanceTransactionContext,
} from '../domain/repositories/finance.repository';
import type { FinanceRepository } from '../domain/repositories/finance.repository';
import { FinanceRulesService } from '../domain/services/finance-rules.service';

@Injectable()
export class FinanceService {
  constructor(
    @Inject(FINANCE_REPOSITORY)
    private readonly financeRepository: FinanceRepository,
    private readonly financeRulesService: FinanceRulesService,
  ) {}

  createBankAccount(userId: number, dto: CreateBankAccountDto) {
    return this.financeRepository.createBankAccount(userId, dto);
  }

  listBankAccounts(userId: number) {
    return this.financeRepository.listBankAccounts(userId);
  }

  async updateBankAccount(userId: number, id: number, dto: UpdateBankAccountDto) {
    await this.getBankAccountOrThrow(userId, id, false);
    return this.financeRepository.updateBankAccount(id, dto);
  }

  async deactivateBankAccount(userId: number, id: number) {
    await this.getBankAccountOrThrow(userId, id);
    return this.financeRepository.updateBankAccount(id, { isActive: false });
  }

  createCreditCard(userId: number, dto: CreateCreditCardDto) {
    return this.financeRepository.createCreditCard(userId, dto);
  }

  listCreditCards(userId: number) {
    return this.financeRepository.listCreditCards(userId);
  }

  async updateCreditCard(userId: number, id: number, dto: UpdateCreditCardDto) {
    const card = await this.getCreditCardOrThrow(userId, id, false);
    let nextAvailableLimit = card.availableLimitCents;

    if (dto.limitCents !== undefined) {
      const usedLimit = card.limitCents - card.availableLimitCents;
      if (dto.limitCents < usedLimit) {
        throw new ConflictException(
          'O novo limite nao pode ser menor que o valor ja utilizado.',
        );
      }

      nextAvailableLimit = dto.limitCents - usedLimit;
    }

    return this.financeRepository.updateCreditCard(id, {
      ...dto,
      availableLimitCents: nextAvailableLimit,
    });
  }

  async deactivateCreditCard(userId: number, id: number) {
    await this.getCreditCardOrThrow(userId, id);
    return this.financeRepository.updateCreditCard(id, { isActive: false });
  }

  createCategory(userId: number, dto: CreateCategoryDto) {
    return this.financeRepository.createCategory(userId, dto);
  }

  listCategories(userId: number) {
    return this.financeRepository.listCategories(userId);
  }

  async updateCategory(userId: number, id: number, dto: UpdateCategoryDto) {
    await this.getCategoryOrThrow(userId, id, false);
    return this.financeRepository.updateCategory(id, dto);
  }

  async deactivateCategory(userId: number, id: number) {
    await this.getCategoryOrThrow(userId, id);
    return this.financeRepository.updateCategory(id, { isActive: false });
  }

  listTransactions(userId: number) {
    return this.financeRepository.listTransactions(userId);
  }

  async findTransaction(userId: number, id: number) {
    const transaction = await this.financeRepository.findTransaction(userId, id);

    if (!transaction) {
      throw new NotFoundException('Transacao nao encontrada.');
    }

    return transaction;
  }

  async createTransaction(userId: number, dto: CreateTransactionDto) {
    const category = await this.getCategoryOrThrow(userId, dto.categoryId);

    this.financeRulesService.assertCategoryMatchesTransaction(dto.type, category.type);
    const { bankAccountId, creditCardId } =
      this.financeRulesService.resolveAssetIds(dto);
    this.financeRulesService.assertCreditCardExpenseOnly(dto.assetType, dto.type);

    const status = dto.status ?? TransactionStatus.CLEARED;
    const transactionDate = new Date(dto.transactionDate);
    const competencyDate = dto.competencyDate ? new Date(dto.competencyDate) : null;

    return this.financeRepository.runInTransaction(async (tx) => {
      if (dto.assetType === AssetType.BANK_ACCOUNT && bankAccountId) {
        return this.createBankAccountTransaction({
          tx,
          userId,
          bankAccountId,
          dto,
          status,
          transactionDate,
          competencyDate,
        });
      }

      if (!creditCardId) {
        throw new NotFoundException('Cartao de credito ativo nao encontrado.');
      }

      return this.createCreditCardTransaction({
        tx,
        userId,
        creditCardId,
        dto,
        status,
        transactionDate,
        competencyDate,
      });
    });
  }

  listCardInvoices(userId: number, creditCardId: number) {
    return this.financeRepository.listCardInvoices(userId, creditCardId);
  }

  async findCardInvoice(userId: number, creditCardId: number, invoiceId: number) {
    const invoice = await this.financeRepository.findCardInvoice(
      userId,
      creditCardId,
      invoiceId,
    );

    if (!invoice) {
      throw new NotFoundException('Fatura nao encontrada.');
    }

    return invoice;
  }

  payInvoice(userId: number, invoiceId: number, dto: CreateInvoicePaymentDto) {
    return this.financeRepository.runInTransaction(async (tx) => {
      const invoice = await tx.findInvoiceForPayment(userId, invoiceId);

      if (!invoice) {
        throw new NotFoundException('Fatura nao encontrada.');
      }

      const bankAccount = await tx.findActiveBankAccount(userId, dto.bankAccountId);

      if (!bankAccount) {
        throw new NotFoundException('Conta bancaria ativa nao encontrada.');
      }

      const remainingAmount = invoice.totalCents - invoice.paidCents;
      this.financeRulesService.ensureInvoicePaymentAmount(
        remainingAmount,
        dto.amountCents,
      );
      this.financeRulesService.ensureBankBalanceForInvoicePayment(
        bankAccount.currentBalanceCents,
        dto.amountCents,
      );

      const paymentDate = new Date(dto.paymentDate);
      const nextPaidCents = invoice.paidCents + dto.amountCents;
      const payment = await tx.createInvoicePayment({
        invoiceId,
        bankAccountId: dto.bankAccountId,
        amountCents: dto.amountCents,
        paymentDate,
      });

      await tx.updateBankAccountBalance(
        bankAccount.id,
        bankAccount.currentBalanceCents - dto.amountCents,
      );
      await tx.updateCreditCard(invoice.creditCardId, {
        availableLimitCents:
          invoice.creditCard.availableLimitCents + dto.amountCents,
      });
      await tx.updateInvoice(invoice.id, {
        paidCents: nextPaidCents,
        status: this.financeRulesService.resolveInvoiceStatus(
          invoice.closingDate,
          invoice.dueDate,
          invoice.totalCents,
          nextPaidCents,
        ),
      });

      return payment;
    });
  }

  private async getBankAccountOrThrow(userId: number, id: number, onlyActive = true) {
    const account = await this.financeRepository.findBankAccount(
      userId,
      id,
      onlyActive,
    );

    if (!account) {
      throw new NotFoundException(
        onlyActive
          ? 'Conta bancaria ativa nao encontrada.'
          : 'Conta bancaria nao encontrada.',
      );
    }

    return account;
  }

  private async getCreditCardOrThrow(userId: number, id: number, onlyActive = true) {
    const card = await this.financeRepository.findCreditCard(userId, id, onlyActive);

    if (!card) {
      throw new NotFoundException(
        onlyActive
          ? 'Cartao de credito ativo nao encontrado.'
          : 'Cartao de credito nao encontrado.',
      );
    }

    return card;
  }

  private async getCategoryOrThrow(userId: number, id: number, onlyActive = true) {
    const category = await this.financeRepository.findCategory(userId, id, onlyActive);

    if (!category) {
      throw new NotFoundException(
        onlyActive ? 'Categoria ativa nao encontrada.' : 'Categoria nao encontrada.',
      );
    }

    return category;
  }

  private async createBankAccountTransaction(params: {
    tx: FinanceTransactionContext;
    userId: number;
    bankAccountId: number;
    dto: CreateTransactionDto;
    status: TransactionStatus;
    transactionDate: Date;
    competencyDate: Date | null;
  }) {
    const bankAccount = await params.tx.findActiveBankAccount(
      params.userId,
      params.bankAccountId,
    );

    if (!bankAccount) {
      throw new NotFoundException('Conta bancaria ativa nao encontrada.');
    }

    const balanceDelta = this.financeRulesService.calculateBankBalanceDelta(
      params.status,
      params.dto.type,
      params.dto.amountCents,
    );
    const nextBalance = bankAccount.currentBalanceCents + balanceDelta;
    this.financeRulesService.ensureNonNegativeBalance(nextBalance);

    const transaction = await params.tx.createTransaction({
      userId: params.userId,
      type: params.dto.type,
      assetType: params.dto.assetType,
      bankAccountId: params.bankAccountId,
      categoryId: params.dto.categoryId,
      description: params.dto.description,
      amountCents: params.dto.amountCents,
      transactionDate: params.transactionDate,
      competencyDate: params.competencyDate,
      status: params.status,
      notes: params.dto.notes,
    });

    if (balanceDelta !== 0) {
      await params.tx.updateBankAccountBalance(bankAccount.id, nextBalance);
    }

    return transaction;
  }

  private async createCreditCardTransaction(params: {
    tx: FinanceTransactionContext;
    userId: number;
    creditCardId: number;
    dto: CreateTransactionDto;
    status: TransactionStatus;
    transactionDate: Date;
    competencyDate: Date | null;
  }) {
    const creditCard = await params.tx.findActiveCreditCard(
      params.userId,
      params.creditCardId,
    );

    if (!creditCard) {
      throw new NotFoundException('Cartao de credito ativo nao encontrado.');
    }

    if (params.status === TransactionStatus.CLEARED) {
      this.financeRulesService.ensureCreditLimit(
        creditCard.availableLimitCents,
        params.dto.amountCents,
      );
    }

    const invoice =
      params.status === TransactionStatus.CLEARED
        ? await this.findOrCreateInvoice(
            params.tx,
            creditCard.id,
            params.transactionDate,
            creditCard.closingDay,
            creditCard.dueDay,
          )
        : null;

    const transaction = await params.tx.createTransaction({
      userId: params.userId,
      type: params.dto.type,
      assetType: params.dto.assetType,
      creditCardId: params.creditCardId,
      categoryId: params.dto.categoryId,
      invoiceId: invoice?.id,
      description: params.dto.description,
      amountCents: params.dto.amountCents,
      transactionDate: params.transactionDate,
      competencyDate: params.competencyDate,
      status: params.status,
      notes: params.dto.notes,
    });

    if (params.status === TransactionStatus.CLEARED && invoice) {
      await params.tx.updateCreditCard(creditCard.id, {
        availableLimitCents: creditCard.availableLimitCents - params.dto.amountCents,
      });
      await params.tx.updateInvoice(invoice.id, {
        totalCents: invoice.totalCents + params.dto.amountCents,
        status: this.financeRulesService.resolveInvoiceStatus(
          invoice.closingDate,
          invoice.dueDate,
          invoice.totalCents + params.dto.amountCents,
          invoice.paidCents,
        ),
      });
    }

    return transaction;
  }

  private async findOrCreateInvoice(
    tx: FinanceTransactionContext,
    creditCardId: number,
    transactionDate: Date,
    closingDay: number,
    dueDay: number,
  ) {
    const { referenceMonth, referenceYear } =
      this.financeRulesService.resolveInvoiceReference(transactionDate, closingDay);
    const existing = await tx.findInvoiceByReference(
      creditCardId,
      referenceMonth,
      referenceYear,
    );

    if (existing) {
      return existing;
    }

    const { closingDate, dueDate } = this.financeRulesService.buildInvoiceDates(
      referenceYear,
      referenceMonth,
      closingDay,
      dueDay,
    );

    return tx.createInvoice({
      creditCardId,
      referenceMonth,
      referenceYear,
      closingDate,
      dueDate,
      totalCents: 0,
      paidCents: 0,
      status: this.financeRulesService.resolveInvoiceStatus(
        closingDate,
        dueDate,
        0,
        0,
      ),
    });
  }
}
