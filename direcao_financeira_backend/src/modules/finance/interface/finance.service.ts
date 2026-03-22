import { randomUUID } from 'crypto';
import { AssetType, CreditCard, TransactionStatus } from '@prisma/client';
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
import { DeleteTransactionDto } from './dto/delete-transaction.dto';
import { TransactionMutationScope } from './dto/transaction-mutation-scope.dto';
import { UpdateTransactionDto } from './dto/update-transaction.dto';
import {
  FINANCE_REPOSITORY,
  FinanceTransactionContext,
  TransactionWithRelations,
} from '../domain/repositories/finance.repository';
import type { FinanceRepository } from '../domain/repositories/finance.repository';
import { FinanceRulesService } from '../domain/services/finance-rules.service';
import { AppGateway } from '../../websocket/interface/app.gateway';

@Injectable()
export class FinanceService {
  constructor(
    @Inject(FINANCE_REPOSITORY)
    private readonly financeRepository: FinanceRepository,
    private readonly financeRulesService: FinanceRulesService,
    private readonly appGateway: AppGateway,
  ) {}

  createBankAccount(userId: number, dto: CreateBankAccountDto) {
    return this.financeRepository.createBankAccount(userId, dto);
  }

  listBankAccounts(userId: number) {
    return this.financeRepository.listBankAccounts(userId);
  }

  async updateBankAccount(
    userId: number,
    id: number,
    dto: UpdateBankAccountDto,
  ) {
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
    const transaction = await this.financeRepository.findTransaction(
      userId,
      id,
    );

    if (!transaction) {
      throw new NotFoundException('Transacao nao encontrada.');
    }

    return transaction;
  }

  async createTransaction(userId: number, dto: CreateTransactionDto) {
    const category = await this.getCategoryOrThrow(userId, dto.categoryId);

    this.financeRulesService.assertCategoryMatchesTransaction(
      dto.type,
      category.type,
    );
    const { bankAccountId, creditCardId } =
      this.financeRulesService.resolveAssetIds(dto);
    this.financeRulesService.assertCreditCardExpenseOnly(
      dto.assetType,
      dto.type,
    );

    const installmentCount = dto.installmentCount ?? 1;
    this.financeRulesService.assertInstallmentConfiguration(
      dto.assetType,
      installmentCount,
    );

    const status = dto.status ?? TransactionStatus.CLEARED;
    const transactionDate = new Date(dto.transactionDate);
    const competencyDate = dto.competencyDate
      ? new Date(dto.competencyDate)
      : null;

    const result = await this.financeRepository.runInTransaction(async (tx) => {
      if (dto.assetType === AssetType.BANK_ACCOUNT && bankAccountId) {
        const transaction = await this.createBankAccountTransaction({
          tx,
          userId,
          bankAccountId,
          dto,
          status,
          transactionDate,
          competencyDate,
        });

        return {
          transaction,
          transactions: [transaction],
          installmentGroupId: transaction.installmentGroupId,
        };
      }

      if (!creditCardId) {
        throw new NotFoundException('Cartao de credito ativo nao encontrado.');
      }

      const transactions = await this.createCreditCardTransactions({
        tx,
        userId,
        creditCardId,
        dto,
        status,
        transactionDate,
        competencyDate,
        installmentCount,
      });

      return {
        transaction: transactions[0],
        transactions,
        installmentGroupId: transactions[0]?.installmentGroupId ?? null,
      };
    });

    this.appGateway.emitToUser(userId, 'transaction.created', result);

    return result;
  }

  async updateTransaction(
    userId: number,
    id: number,
    dto: UpdateTransactionDto,
  ) {
    const category =
      dto.categoryId !== undefined
        ? await this.getCategoryOrThrow(userId, dto.categoryId)
        : null;
    const scope = dto.scope ?? TransactionMutationScope.CURRENT;

    return this.financeRepository.runInTransaction(async (tx) => {
      const baseTransaction = await this.getTransactionOrThrow(tx, userId, id);

      if (category) {
        this.financeRulesService.assertCategoryMatchesTransaction(
          baseTransaction.type,
          category.type,
        );
      }

      const targetTransactions = await this.resolveTransactionsForScope(
        tx,
        userId,
        baseTransaction,
        scope,
      );

      if (
        baseTransaction.assetType === AssetType.BANK_ACCOUNT &&
        targetTransactions.length > 1
      ) {
        throw new ConflictException(
          'Conta bancaria nao suporta alteracao em grupo de parcelas.',
        );
      }

      const invoiceIdsToSync = new Set<number>();
      const bankAccountIdsToSync = new Set<number>();
      const creditCardIdsToSync = new Set<number>();

      this.captureAffectedStates(
        targetTransactions,
        invoiceIdsToSync,
        bankAccountIdsToSync,
        creditCardIdsToSync,
      );
      this.ensureTransactionsCanMutate(targetTransactions);

      let amountMap = new Map<number, number>();
      if (dto.amountCents !== undefined) {
        amountMap = this.resolveUpdatedAmounts(
          targetTransactions,
          scope,
          dto.amountCents,
        );
      }

      const updatedTransactions: TransactionWithRelations[] = [];
      for (const transaction of targetTransactions) {
        const nextTransactionDate =
          dto.transactionDate !== undefined
            ? dto.transactionDate
              ? this.shiftInstallmentDate(
                  new Date(dto.transactionDate),
                  this.getInstallmentOffset(targetTransactions, transaction),
                )
              : transaction.transactionDate
            : transaction.transactionDate;
        const nextCompetencyDate =
          dto.competencyDate !== undefined
            ? dto.competencyDate
              ? this.shiftInstallmentDate(
                  new Date(dto.competencyDate),
                  this.getInstallmentOffset(targetTransactions, transaction),
                )
              : null
            : transaction.competencyDate;
        const nextStatus = dto.status ?? transaction.status;
        const nextAmount =
          amountMap.get(transaction.id) ?? transaction.amountCents;
        const nextInvoiceId =
          transaction.assetType === AssetType.CREDIT_CARD
            ? await this.resolveInvoiceIdForMutation(
                tx,
                transaction,
                nextTransactionDate,
                nextStatus,
              )
            : undefined;

        if (
          transaction.assetType === AssetType.CREDIT_CARD &&
          nextStatus === TransactionStatus.CLEARED &&
          transaction.creditCardId
        ) {
          const card = await tx.findActiveCreditCard(
            userId,
            transaction.creditCardId,
          );

          if (!card) {
            throw new NotFoundException(
              'Cartao de credito ativo nao encontrado.',
            );
          }

          const snapshot = await tx.getCreditCardFinancialSnapshot(card.id);
          const currentAvailableLimit =
            this.financeRulesService.calculateCreditCardAvailableLimit(
              snapshot,
            );
          const releasedAmount =
            transaction.status === TransactionStatus.CLEARED
              ? transaction.amountCents
              : 0;
          const availableForUpdate = currentAvailableLimit + releasedAmount;
          this.financeRulesService.ensureCreditLimit(
            availableForUpdate,
            nextAmount,
          );
        }

        const updated = await tx.updateTransaction(transaction.id, {
          categoryId: dto.categoryId,
          description: dto.description,
          amountCents: dto.amountCents !== undefined ? nextAmount : undefined,
          transactionDate:
            dto.transactionDate !== undefined ? nextTransactionDate : undefined,
          competencyDate:
            dto.competencyDate !== undefined ? nextCompetencyDate : undefined,
          status: dto.status,
          notes: dto.notes !== undefined ? dto.notes || null : undefined,
          invoiceId: nextInvoiceId,
        });

        updatedTransactions.push(updated);
        this.captureAffectedStates(
          [updated],
          invoiceIdsToSync,
          bankAccountIdsToSync,
          creditCardIdsToSync,
        );
      }

      await this.syncFinancialStates(
        tx,
        invoiceIdsToSync,
        bankAccountIdsToSync,
        creditCardIdsToSync,
      );

      return {
        transaction: updatedTransactions[0],
        transactions: updatedTransactions,
        scope,
      };
    });
  }

  async deleteTransaction(
    userId: number,
    id: number,
    dto: DeleteTransactionDto,
  ) {
    const scope = dto.scope ?? TransactionMutationScope.CURRENT;

    return this.financeRepository.runInTransaction(async (tx) => {
      const baseTransaction = await this.getTransactionOrThrow(tx, userId, id);
      const targetTransactions = await this.resolveTransactionsForScope(
        tx,
        userId,
        baseTransaction,
        scope,
      );

      this.ensureTransactionsCanMutate(targetTransactions);

      const invoiceIdsToSync = new Set<number>();
      const bankAccountIdsToSync = new Set<number>();
      const creditCardIdsToSync = new Set<number>();
      this.captureAffectedStates(
        targetTransactions,
        invoiceIdsToSync,
        bankAccountIdsToSync,
        creditCardIdsToSync,
      );

      const deletedCount = await tx.deleteTransactions(
        targetTransactions.map((item) => item.id),
      );
      await this.syncFinancialStates(
        tx,
        invoiceIdsToSync,
        bankAccountIdsToSync,
        creditCardIdsToSync,
      );

      return {
        deletedCount,
        scope,
        transactionIds: targetTransactions.map((item) => item.id),
      };
    });
  }

  listCardInvoices(userId: number, creditCardId: number) {
    return this.financeRepository.listCardInvoices(userId, creditCardId);
  }

  async findCardInvoice(
    userId: number,
    creditCardId: number,
    invoiceId: number,
  ) {
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

      const bankAccount = await tx.findActiveBankAccount(
        userId,
        dto.bankAccountId,
      );

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

  private async getBankAccountOrThrow(
    userId: number,
    id: number,
    onlyActive = true,
  ) {
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

  private async getCreditCardOrThrow(
    userId: number,
    id: number,
    onlyActive = true,
  ) {
    const card = await this.financeRepository.findCreditCard(
      userId,
      id,
      onlyActive,
    );

    if (!card) {
      throw new NotFoundException(
        onlyActive
          ? 'Cartao de credito ativo nao encontrado.'
          : 'Cartao de credito nao encontrado.',
      );
    }

    return card;
  }

  private async getCategoryOrThrow(
    userId: number,
    id: number,
    onlyActive = true,
  ) {
    const category = await this.financeRepository.findCategory(
      userId,
      id,
      onlyActive,
    );

    if (!category) {
      throw new NotFoundException(
        onlyActive
          ? 'Categoria ativa nao encontrada.'
          : 'Categoria nao encontrada.',
      );
    }

    return category;
  }

  private async getTransactionOrThrow(
    tx: FinanceTransactionContext,
    userId: number,
    id: number,
  ) {
    const transaction = await tx.findTransactionById(userId, id);

    if (!transaction) {
      throw new NotFoundException('Transacao nao encontrada.');
    }

    return transaction;
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

  private async createCreditCardTransactions(params: {
    tx: FinanceTransactionContext;
    userId: number;
    creditCardId: number;
    dto: CreateTransactionDto;
    status: TransactionStatus;
    transactionDate: Date;
    competencyDate: Date | null;
    installmentCount: number;
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

    const groupId = params.installmentCount > 1 ? randomUUID() : undefined;
    const amounts = this.financeRulesService.splitInstallmentAmounts(
      params.dto.amountCents,
      params.installmentCount,
    );
    const transactions: TransactionWithRelations[] = [];

    for (let index = 0; index < params.installmentCount; index += 1) {
      const installmentNumber = index + 1;
      const installmentDate = this.shiftInstallmentDate(
        params.transactionDate,
        index,
      );
      const installmentCompetencyDate = params.competencyDate
        ? this.shiftInstallmentDate(params.competencyDate, index)
        : null;
      const invoice =
        params.status === TransactionStatus.CLEARED
          ? await this.findOrCreateInvoice(
              params.tx,
              creditCard,
              installmentDate,
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
        amountCents: amounts[index],
        transactionDate: installmentDate,
        competencyDate: installmentCompetencyDate,
        status: params.status,
        notes: params.dto.notes,
        installmentGroupId: groupId,
        installmentNumber:
          params.installmentCount > 1 ? installmentNumber : undefined,
        installmentCount:
          params.installmentCount > 1 ? params.installmentCount : undefined,
      });

      transactions.push(transaction);
    }

    const invoiceIdsToSync = new Set<number>();
    this.captureAffectedStates(
      transactions,
      invoiceIdsToSync,
      new Set<number>(),
      new Set<number>(),
    );
    await this.syncFinancialStates(
      params.tx,
      invoiceIdsToSync,
      new Set<number>(),
      new Set<number>([creditCard.id]),
    );

    return transactions;
  }

  private async findOrCreateInvoice(
    tx: FinanceTransactionContext,
    creditCard: CreditCard,
    transactionDate: Date,
  ) {
    const { referenceMonth, referenceYear } =
      this.financeRulesService.resolveInvoiceReference(
        transactionDate,
        creditCard.closingDay,
      );
    const existing = await tx.findInvoiceByReference(
      creditCard.id,
      referenceMonth,
      referenceYear,
    );

    if (existing) {
      return existing;
    }

    const { closingDate, dueDate } = this.financeRulesService.buildInvoiceDates(
      referenceYear,
      referenceMonth,
      creditCard.closingDay,
      creditCard.dueDay,
    );

    return tx.createInvoice({
      creditCardId: creditCard.id,
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

  private async resolveTransactionsForScope(
    tx: FinanceTransactionContext,
    userId: number,
    baseTransaction: TransactionWithRelations,
    scope: TransactionMutationScope,
  ) {
    if (
      scope === TransactionMutationScope.ALL &&
      baseTransaction.installmentGroupId
    ) {
      return tx.listTransactionsByInstallmentGroup(
        userId,
        baseTransaction.installmentGroupId,
      );
    }

    return [baseTransaction];
  }

  private ensureTransactionsCanMutate(
    transactions: TransactionWithRelations[],
  ) {
    for (const transaction of transactions) {
      if (transaction.invoice && transaction.invoice.paidCents > 0) {
        throw new ConflictException(
          'Nao e possivel alterar ou excluir transacoes de faturas que ja receberam pagamento.',
        );
      }
    }
  }

  private resolveUpdatedAmounts(
    transactions: TransactionWithRelations[],
    scope: TransactionMutationScope,
    amountCents: number,
  ) {
    if (scope === TransactionMutationScope.ALL && transactions.length > 1) {
      const splitAmounts = this.financeRulesService.splitInstallmentAmounts(
        amountCents,
        transactions.length,
      );

      return new Map(
        transactions.map((transaction, index) => [
          transaction.id,
          splitAmounts[index],
        ]),
      );
    }

    return new Map(
      transactions.map((transaction) => [transaction.id, amountCents]),
    );
  }

  private getInstallmentOffset(
    transactions: TransactionWithRelations[],
    currentTransaction: TransactionWithRelations,
  ) {
    const baseNumber = transactions[0]?.installmentNumber ?? 1;
    const currentNumber = currentTransaction.installmentNumber ?? baseNumber;
    return currentNumber - baseNumber;
  }

  private shiftInstallmentDate(baseDate: Date, monthOffset: number) {
    const shiftedDate = new Date(baseDate);
    shiftedDate.setMonth(shiftedDate.getMonth() + monthOffset);
    return shiftedDate;
  }

  private captureAffectedStates(
    transactions: TransactionWithRelations[],
    invoiceIds: Set<number>,
    bankAccountIds: Set<number>,
    creditCardIds: Set<number>,
  ) {
    for (const transaction of transactions) {
      if (transaction.invoiceId) {
        invoiceIds.add(transaction.invoiceId);
      }
      if (transaction.bankAccountId) {
        bankAccountIds.add(transaction.bankAccountId);
      }
      if (transaction.creditCardId) {
        creditCardIds.add(transaction.creditCardId);
      }
    }
  }

  private async resolveInvoiceIdForMutation(
    tx: FinanceTransactionContext,
    transaction: TransactionWithRelations,
    transactionDate: Date,
    status: TransactionStatus,
  ) {
    if (transaction.assetType !== AssetType.CREDIT_CARD) {
      return undefined;
    }

    if (status !== TransactionStatus.CLEARED) {
      return null;
    }

    if (!transaction.creditCardId) {
      throw new NotFoundException('Cartao de credito ativo nao encontrado.');
    }

    const card = await tx.findActiveCreditCard(
      transaction.userId,
      transaction.creditCardId,
    );

    if (!card) {
      throw new NotFoundException('Cartao de credito ativo nao encontrado.');
    }

    const invoice = await this.findOrCreateInvoice(tx, card, transactionDate);
    return invoice.id;
  }

  private async syncFinancialStates(
    tx: FinanceTransactionContext,
    invoiceIds: Set<number>,
    bankAccountIds: Set<number>,
    creditCardIds: Set<number>,
  ) {
    for (const bankAccountId of bankAccountIds) {
      const snapshot = await tx.getBankAccountFinancialSnapshot(bankAccountId);
      const nextBalance =
        this.financeRulesService.calculateBankAccountCurrentBalance(snapshot);
      this.financeRulesService.ensureNonNegativeBalance(nextBalance);
      await tx.updateBankAccountBalance(bankAccountId, nextBalance);
    }

    for (const invoiceId of invoiceIds) {
      await this.syncInvoice(tx, invoiceId);
    }

    for (const creditCardId of creditCardIds) {
      const snapshot = await tx.getCreditCardFinancialSnapshot(creditCardId);
      const nextAvailableLimit =
        this.financeRulesService.calculateCreditCardAvailableLimit(snapshot);
      if (nextAvailableLimit < 0) {
        throw new ConflictException(
          'Limite disponivel insuficiente para esta compra.',
        );
      }
      await tx.updateCreditCard(creditCardId, {
        availableLimitCents: nextAvailableLimit,
      });
    }
  }

  private async syncInvoice(tx: FinanceTransactionContext, invoiceId: number) {
    const invoice = await tx.findInvoiceById(invoiceId);

    if (!invoice) {
      return;
    }

    const totalCents = await tx.getInvoiceClearedTotal(invoiceId);

    if (invoice.paidCents > totalCents) {
      throw new ConflictException(
        'Nao e possivel alterar a transacao porque a fatura ficaria menor que o valor ja pago.',
      );
    }

    await tx.updateInvoice(invoiceId, {
      totalCents,
      status: this.financeRulesService.resolveInvoiceStatus(
        invoice.closingDate,
        invoice.dueDate,
        totalCents,
        invoice.paidCents,
      ),
    });
  }
}
