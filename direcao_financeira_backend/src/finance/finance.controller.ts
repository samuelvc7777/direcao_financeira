import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Patch,
  Post,
  UseGuards,
} from '@nestjs/common';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { FinanceService } from './finance.service';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { CreateBankAccountDto } from './dto/create-bank-account.dto';
import { UpdateBankAccountDto } from './dto/update-bank-account.dto';
import { CreateCreditCardDto } from './dto/create-credit-card.dto';
import { UpdateCreditCardDto } from './dto/update-credit-card.dto';
import { CreateCategoryDto } from './dto/create-category.dto';
import { UpdateCategoryDto } from './dto/update-category.dto';
import { CreateTransactionDto } from './dto/create-transaction.dto';
import { CreateInvoicePaymentDto } from './dto/create-invoice-payment.dto';

@Controller('finance')
@UseGuards(JwtAuthGuard)
export class FinanceController {
  constructor(private readonly financeService: FinanceService) {}

  @Post('bank-accounts')
  async createBankAccount(@CurrentUser() user: any, @Body() dto: CreateBankAccountDto) {
    const account = await this.financeService.createBankAccount(user.userId, dto);
    return { message: 'Conta bancaria criada com sucesso.', account };
  }

  @Get('bank-accounts')
  listBankAccounts(@CurrentUser() user: any) {
    return this.financeService.listBankAccounts(user.userId);
  }

  @Patch('bank-accounts/:id')
  async updateBankAccount(
    @CurrentUser() user: any,
    @Param('id') id: string,
    @Body() dto: UpdateBankAccountDto,
  ) {
    const account = await this.financeService.updateBankAccount(user.userId, +id, dto);
    return { message: 'Conta bancaria atualizada com sucesso.', account };
  }

  @Delete('bank-accounts/:id')
  async deactivateBankAccount(@CurrentUser() user: any, @Param('id') id: string) {
    const account = await this.financeService.deactivateBankAccount(user.userId, +id);
    return { message: 'Conta bancaria desativada com sucesso.', account };
  }

  @Post('credit-cards')
  async createCreditCard(@CurrentUser() user: any, @Body() dto: CreateCreditCardDto) {
    const card = await this.financeService.createCreditCard(user.userId, dto);
    return { message: 'Cartao de credito criado com sucesso.', card };
  }

  @Get('credit-cards')
  listCreditCards(@CurrentUser() user: any) {
    return this.financeService.listCreditCards(user.userId);
  }

  @Patch('credit-cards/:id')
  async updateCreditCard(
    @CurrentUser() user: any,
    @Param('id') id: string,
    @Body() dto: UpdateCreditCardDto,
  ) {
    const card = await this.financeService.updateCreditCard(user.userId, +id, dto);
    return { message: 'Cartao de credito atualizado com sucesso.', card };
  }

  @Delete('credit-cards/:id')
  async deactivateCreditCard(@CurrentUser() user: any, @Param('id') id: string) {
    const card = await this.financeService.deactivateCreditCard(user.userId, +id);
    return { message: 'Cartao de credito desativado com sucesso.', card };
  }

  @Post('categories')
  async createCategory(@CurrentUser() user: any, @Body() dto: CreateCategoryDto) {
    const category = await this.financeService.createCategory(user.userId, dto);
    return { message: 'Categoria criada com sucesso.', category };
  }

  @Get('categories')
  listCategories(@CurrentUser() user: any) {
    return this.financeService.listCategories(user.userId);
  }

  @Patch('categories/:id')
  async updateCategory(
    @CurrentUser() user: any,
    @Param('id') id: string,
    @Body() dto: UpdateCategoryDto,
  ) {
    const category = await this.financeService.updateCategory(user.userId, +id, dto);
    return { message: 'Categoria atualizada com sucesso.', category };
  }

  @Delete('categories/:id')
  async deactivateCategory(@CurrentUser() user: any, @Param('id') id: string) {
    const category = await this.financeService.deactivateCategory(user.userId, +id);
    return { message: 'Categoria desativada com sucesso.', category };
  }

  @Post('transactions')
  async createTransaction(@CurrentUser() user: any, @Body() dto: CreateTransactionDto) {
    const transaction = await this.financeService.createTransaction(user.userId, dto);
    return { message: 'Transacao criada com sucesso.', transaction };
  }

  @Get('transactions')
  listTransactions(@CurrentUser() user: any) {
    return this.financeService.listTransactions(user.userId);
  }

  @Get('transactions/:id')
  findTransaction(@CurrentUser() user: any, @Param('id') id: string) {
    return this.financeService.findTransaction(user.userId, +id);
  }

  @Get('credit-cards/:id/invoices')
  listCardInvoices(@CurrentUser() user: any, @Param('id') id: string) {
    return this.financeService.listCardInvoices(user.userId, +id);
  }

  @Get('credit-cards/:cardId/invoices/:invoiceId')
  findCardInvoice(
    @CurrentUser() user: any,
    @Param('cardId') cardId: string,
    @Param('invoiceId') invoiceId: string,
  ) {
    return this.financeService.findCardInvoice(user.userId, +cardId, +invoiceId);
  }

  @Post('invoices/:invoiceId/payments')
  async payInvoice(
    @CurrentUser() user: any,
    @Param('invoiceId') invoiceId: string,
    @Body() dto: CreateInvoicePaymentDto,
  ) {
    const payment = await this.financeService.payInvoice(user.userId, +invoiceId, dto);
    return { message: 'Pagamento de fatura registrado com sucesso.', payment };
  }
}
