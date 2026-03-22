import { AssetType, CategoryType, TransactionType } from '@prisma/client';
import { ConflictException } from '@nestjs/common';
import { FinanceRulesService } from './finance-rules.service';

describe('FinanceRulesService', () => {
  let service: FinanceRulesService;

  beforeEach(() => {
    service = new FinanceRulesService();
  });

  it('bloqueia categoria com tipo diferente da transacao', () => {
    expect(() =>
      service.assertCategoryMatchesTransaction(
        TransactionType.EXPENSE,
        CategoryType.INCOME,
      ),
    ).toThrow(ConflictException);
  });

  it('resolve accountId para conta bancaria quando assetType for BANK_ACCOUNT', () => {
    expect(
      service.resolveAssetIds({
        assetType: AssetType.BANK_ACCOUNT,
        accountId: 10,
      }),
    ).toEqual({
      bankAccountId: 10,
      creditCardId: undefined,
    });
  });

  it('bloqueia quando nenhum ativo financeiro e informado', () => {
    expect(() =>
      service.resolveAssetIds({
        assetType: AssetType.CREDIT_CARD,
      }),
    ).toThrow(ConflictException);
  });

  it('divide o valor total em parcelas preservando o total', () => {
    expect(service.splitInstallmentAmounts(1000, 3)).toEqual([334, 333, 333]);
  });

  it('bloqueia parcelamento fora de cartao de credito', () => {
    expect(() =>
      service.assertInstallmentConfiguration(AssetType.BANK_ACCOUNT, 2),
    ).toThrow(ConflictException);
  });
});
