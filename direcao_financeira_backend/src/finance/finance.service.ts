import {
  AssetType,
  CategoryType,
  InvoiceStatus,
  TransactionStatus,
  TransactionType,
} from '@prisma/client';
import {
  ConflictException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateBankAccountDto } from './dto/create-bank-account.dto';
import { UpdateBankAccountDto } from './dto/update-bank-account.dto';
import { CreateCreditCardDto } from './dto/create-credit-card.dto';
import { UpdateCreditCardDto } from './dto/update-credit-card.dto';
import { CreateCategoryDto } from './dto/create-category.dto';
import { UpdateCategoryDto } from './dto/update-category.dto';
import { CreateTransactionDto } from './dto/create-transaction.dto';
import { CreateInvoicePaymentDto } from './dto/create-invoice-payment.dto';

@Injectable()
export class FinanceService {
  constructor(private prisma: PrismaService) {}

  async createBankAccount(userId: number, dto: CreateBankAccountDto) {
    return this.prisma.client.bankAccount.create({
      data: {
        userId,
        ...dto,
        currentBalanceCents: dto.initialBalanceCents,
      },
    });
  }

  listBankAccounts(userId: number) {
    return this.prisma.client.bankAccount.findMany({
      where: { userId },
      orderBy: { createdAt: 'desc' },
    });
  }

  async updateBankAccount(userId: number, id: number, dto: UpdateBankAccountDto) {
    await this.getBankAccountOrThrow(userId, id);

    return this.prisma.client.bankAccount.update({
      where: { id },
      data: dto,
    });
  }

  async deactivateBankAccount(userId: number, id: number) {
    await this.getBankAccountOrThrow(userId, id);

    return this.prisma.client.bankAccount.update({
      where: { id },
      data: { isActive: false },
    });
  }

  async createCreditCard(userId: number, dto: CreateCreditCardDto) {
    return this.prisma.client.creditCard.create({
      data: {
        userId,
        ...dto,
        availableLimitCents: dto.limitCents,
      },
    });
  }

  listCreditCards(userId: number) {
    return this.prisma.client.creditCard.findMany({
      where: { userId },
      orderBy: { createdAt: 'desc' },
    });
  }

  async updateCreditCard(userId: number, id: number, dto: UpdateCreditCardDto) {
    const card = await this.getCreditCardOrThrow(userId, id);
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

    return this.prisma.client.creditCard.update({
      where: { id },
      data: {
        ...dto,
        availableLimitCents: nextAvailableLimit,
      },
    });
  }

  async deactivateCreditCard(userId: number, id: number) {
    await this.getCreditCardOrThrow(userId, id);

    return this.prisma.client.creditCard.update({
      where: { id },
      data: { isActive: false },
    });
  }

  async createCategory(userId: number, dto: CreateCategoryDto) {
    try {
      return await this.prisma.client.category.create({
        data: {
          userId,
          ...dto,
        },
      });
    } catch (error) {
      if (error.code === 'P2002') {
        throw new ConflictException(
          'Ja existe uma categoria com este nome e tipo para este usuario.',
        );
      }
      throw error;
    }
  }

  listCategories(userId: number) {
    return this.prisma.client.category.findMany({
      where: { userId },
      orderBy: [{ type: 'asc' }, { name: 'asc' }],
    });
  }

  async updateCategory(userId: number, id: number, dto: UpdateCategoryDto) {
    await this.getCategoryOrThrow(userId, id);

    try {
      return await this.prisma.client.category.update({
        where: { id },
        data: dto,
      });
    } catch (error) {
      if (error.code === 'P2002') {
        throw new ConflictException(
          'Ja existe uma categoria com este nome e tipo para este usuario.',
        );
      }
      throw error;
    }
  }

  async deactivateCategory(userId: number, id: number) {
    await this.getCategoryOrThrow(userId, id);

    return this.prisma.client.category.update({
      where: { id },
      data: { isActive: false },
    });
  }

  listTransactions(userId: number) {
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

  async findTransaction(userId: number, id: number) {
    const transaction = await this.prisma.client.transaction.findFirst({
      where: { id, userId },
      include: {
        category: true,
        bankAccount: true,
        creditCard: true,
        invoice: true,
      },
    });

    if (!transaction) {
      throw new NotFoundException('Transacao nao encontrada.');
    }

    return transaction;
  }

  async createTransaction(userId: number, dto: CreateTransactionDto) {
    const category = await this.getCategoryOrThrow(userId, dto.categoryId);

    if (
      (dto.type === TransactionType.INCOME && category.type !== CategoryType.INCOME) ||
      (dto.type === TransactionType.EXPENSE && category.type !== CategoryType.EXPENSE)
    ) {
      throw new ConflictException(
        'A categoria precisa ter o mesmo tipo da transacao.',
      );
    }

    const hasBankAccount = dto.bankAccountId !== undefined;
    const hasCreditCard = dto.creditCardId !== undefined;

    if (hasBankAccount === hasCreditCard) {
      throw new ConflictException(
        'A transacao deve apontar para conta bancaria ou cartao, nunca ambos.',
      );
    }

    if (
      (dto.assetType === AssetType.BANK_ACCOUNT && !hasBankAccount) ||
      (dto.assetType === AssetType.CREDIT_CARD && !hasCreditCard)
    ) {
      throw new ConflictException(
        'Os identificadores informados nao correspondem ao tipo de origem da transacao.',
      );
    }

    if (dto.assetType === AssetType.CREDIT_CARD && dto.type !== TransactionType.EXPENSE) {
      throw new ConflictException(
        'Cartao de credito aceita apenas transacoes de despesa nesta fase.',
      );
    }

    const status = dto.status ?? TransactionStatus.CLEARED;
    const transactionDate = new Date(dto.transactionDate);
    const competencyDate = dto.competencyDate ? new Date(dto.competencyDate) : null;

    return this.prisma.client.$transaction(async (tx) => {
      if (dto.assetType === AssetType.BANK_ACCOUNT && dto.bankAccountId) {
        const bankAccount = await tx.bankAccount.findFirst({
          where: { id: dto.bankAccountId, userId, isActive: true },
        });

        if (!bankAccount) {
          throw new NotFoundException('Conta bancaria ativa nao encontrada.');
        }

        const balanceDelta =
          status === TransactionStatus.CLEARED
            ? dto.type === TransactionType.INCOME
              ? dto.amountCents
              : -dto.amountCents
            : 0;

        const nextBalance = bankAccount.currentBalanceCents + balanceDelta;
        if (nextBalance < 0) {
          throw new ConflictException('Saldo insuficiente para esta transacao.');
        }

        const transaction = await tx.transaction.create({
          data: {
            userId,
            type: dto.type,
            assetType: dto.assetType,
            bankAccountId: dto.bankAccountId,
            categoryId: dto.categoryId,
            description: dto.description,
            amountCents: dto.amountCents,
            transactionDate,
            competencyDate,
            status,
            notes: dto.notes,
          },
          include: {
            category: true,
            bankAccount: true,
            creditCard: true,
            invoice: true,
          },
        });

        if (balanceDelta !== 0) {
          await tx.bankAccount.update({
            where: { id: bankAccount.id },
            data: { currentBalanceCents: nextBalance },
          });
        }

        return transaction;
      }

      const creditCard = await tx.creditCard.findFirst({
        where: { id: dto.creditCardId, userId, isActive: true },
      });

      if (!creditCard) {
        throw new NotFoundException('Cartao de credito ativo nao encontrado.');
      }

      if (status === TransactionStatus.CLEARED && creditCard.availableLimitCents < dto.amountCents) {
        throw new ConflictException('Limite disponivel insuficiente para esta compra.');
      }

      const invoice =
        status === TransactionStatus.CLEARED
          ? await this.findOrCreateInvoice(tx, creditCard.id, transactionDate, creditCard.closingDay, creditCard.dueDay)
          : null;

      const transaction = await tx.transaction.create({
        data: {
          userId,
          type: dto.type,
          assetType: dto.assetType,
          creditCardId: dto.creditCardId,
          categoryId: dto.categoryId,
          invoiceId: invoice?.id,
          description: dto.description,
          amountCents: dto.amountCents,
          transactionDate,
          competencyDate,
          status,
          notes: dto.notes,
        },
        include: {
          category: true,
          bankAccount: true,
          creditCard: true,
          invoice: true,
        },
      });

      if (status === TransactionStatus.CLEARED && invoice) {
        await tx.creditCard.update({
          where: { id: creditCard.id },
          data: {
            availableLimitCents: creditCard.availableLimitCents - dto.amountCents,
          },
        });

        await tx.creditCardInvoice.update({
          where: { id: invoice.id },
          data: {
            totalCents: invoice.totalCents + dto.amountCents,
            status: this.resolveInvoiceStatus(
              invoice.closingDate,
              invoice.dueDate,
              invoice.totalCents + dto.amountCents,
              invoice.paidCents,
            ),
          },
        });
      }

      return transaction;
    });
  }

  listCardInvoices(userId: number, creditCardId: number) {
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

  async findCardInvoice(userId: number, creditCardId: number, invoiceId: number) {
    const invoice = await this.prisma.client.creditCardInvoice.findFirst({
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

    if (!invoice) {
      throw new NotFoundException('Fatura nao encontrada.');
    }

    return invoice;
  }

  async payInvoice(userId: number, invoiceId: number, dto: CreateInvoicePaymentDto) {
    return this.prisma.client.$transaction(async (tx) => {
      const invoice = await tx.creditCardInvoice.findFirst({
        where: {
          id: invoiceId,
          creditCard: { userId },
        },
        include: { creditCard: true },
      });

      if (!invoice) {
        throw new NotFoundException('Fatura nao encontrada.');
      }

      const bankAccount = await tx.bankAccount.findFirst({
        where: {
          id: dto.bankAccountId,
          userId,
          isActive: true,
        },
      });

      if (!bankAccount) {
        throw new NotFoundException('Conta bancaria ativa nao encontrada.');
      }

      const remainingAmount = invoice.totalCents - invoice.paidCents;
      if (remainingAmount <= 0) {
        throw new ConflictException('Esta fatura ja esta quitada.');
      }

      if (dto.amountCents > remainingAmount) {
        throw new ConflictException(
          'O valor do pagamento nao pode ser maior que o saldo restante da fatura.',
        );
      }

      if (bankAccount.currentBalanceCents < dto.amountCents) {
        throw new ConflictException('Saldo insuficiente para pagar a fatura.');
      }

      const paymentDate = new Date(dto.paymentDate);
      const nextPaidCents = invoice.paidCents + dto.amountCents;
      const nextStatus = this.resolveInvoiceStatus(
        invoice.closingDate,
        invoice.dueDate,
        invoice.totalCents,
        nextPaidCents,
      );

      const payment = await tx.invoicePayment.create({
        data: {
          invoiceId,
          bankAccountId: dto.bankAccountId,
          amountCents: dto.amountCents,
          paymentDate,
        },
        include: {
          bankAccount: true,
          invoice: true,
        },
      });

      await tx.bankAccount.update({
        where: { id: bankAccount.id },
        data: {
          currentBalanceCents: bankAccount.currentBalanceCents - dto.amountCents,
        },
      });

      await tx.creditCard.update({
        where: { id: invoice.creditCardId },
        data: {
          availableLimitCents:
            invoice.creditCard.availableLimitCents + dto.amountCents,
        },
      });

      await tx.creditCardInvoice.update({
        where: { id: invoice.id },
        data: {
          paidCents: nextPaidCents,
          status: nextStatus,
        },
      });

      return payment;
    });
  }

  private async getBankAccountOrThrow(userId: number, id: number) {
    const account = await this.prisma.client.bankAccount.findFirst({
      where: { id, userId },
    });

    if (!account) {
      throw new NotFoundException('Conta bancaria nao encontrada.');
    }

    return account;
  }

  private async getCreditCardOrThrow(userId: number, id: number) {
    const card = await this.prisma.client.creditCard.findFirst({
      where: { id, userId },
    });

    if (!card) {
      throw new NotFoundException('Cartao de credito nao encontrado.');
    }

    return card;
  }

  private async getCategoryOrThrow(userId: number, id: number) {
    const category = await this.prisma.client.category.findFirst({
      where: { id, userId, isActive: true },
    });

    if (!category) {
      throw new NotFoundException('Categoria ativa nao encontrada.');
    }

    return category;
  }

  private getMonthDate(year: number, monthIndex: number, day: number) {
    return new Date(year, monthIndex + 1, 0).getDate() < day
      ? new Date(year, monthIndex + 1, 0)
      : new Date(year, monthIndex, day);
  }

  private async findOrCreateInvoice(
    tx: any,
    creditCardId: number,
    transactionDate: Date,
    closingDay: number,
    dueDay: number,
  ) {
    let referenceMonth = transactionDate.getMonth() + 1;
    let referenceYear = transactionDate.getFullYear();

    if (transactionDate.getDate() > closingDay) {
      referenceMonth += 1;
      if (referenceMonth === 13) {
        referenceMonth = 1;
        referenceYear += 1;
      }
    }

    const existing = await tx.creditCardInvoice.findUnique({
      where: {
        creditCardId_referenceMonth_referenceYear: {
          creditCardId,
          referenceMonth,
          referenceYear,
        },
      },
    });

    if (existing) {
      return existing;
    }

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
    const initialStatus = this.resolveInvoiceStatus(closingDate, dueDate, 0, 0);

    return tx.creditCardInvoice.create({
      data: {
        creditCardId,
        referenceMonth,
        referenceYear,
        closingDate,
        dueDate,
        totalCents: 0,
        paidCents: 0,
        status: initialStatus,
      },
    });
  }

  private resolveInvoiceStatus(
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
}
