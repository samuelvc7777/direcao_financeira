import 'package:dartz/dartz.dart';
import 'package:direcao_financeira_mobile/app/core/dashboard/dashboard_refresh_notifier.dart';
import 'package:direcao_financeira_mobile/app/core/errors/failures.dart';
import 'package:direcao_financeira_mobile/app/core/network/realtime_client.dart';
import 'package:direcao_financeira_mobile/app/domain/entities/bank_account_entity.dart';
import 'package:direcao_financeira_mobile/app/domain/entities/credit_card_entity.dart';
import 'package:direcao_financeira_mobile/app/domain/entities/transaction_entity.dart';
import 'package:direcao_financeira_mobile/app/domain/entities/user_entity.dart';
import 'package:direcao_financeira_mobile/app/domain/repositories/i_auth_repository.dart';
import 'package:direcao_financeira_mobile/app/domain/repositories/i_bank_account_repository.dart';
import 'package:direcao_financeira_mobile/app/domain/repositories/i_credit_card_repository.dart';
import 'package:direcao_financeira_mobile/app/domain/repositories/i_transaction_repository.dart';
import 'package:direcao_financeira_mobile/app/domain/usecases/auth_session_use_cases.dart';
import 'package:direcao_financeira_mobile/app/domain/usecases/bank_account_use_cases.dart';
import 'package:direcao_financeira_mobile/app/domain/usecases/credit_card_use_cases.dart';
import 'package:direcao_financeira_mobile/app/domain/usecases/transaction_use_cases.dart';
import 'package:direcao_financeira_mobile/app/presentation/modules/home/home_controller.dart';
import 'package:direcao_financeira_mobile/app/presentation/modules/home/home_tab_navigation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

class _FakeAuthRepository implements IAuthRepository {
  @override
  Either<Failure, UserEntity?> getStoredUser() =>
      Right(
        UserEntity(
          id: 1,
          name: 'Samuel',
          email: 'samuel@test.com',
          role: 'user',
          isActive: true,
        ),
      );

  @override
  Future<Either<Failure, String?>> getToken() async => const Right(null);

  @override
  Future<Either<Failure, UserEntity>> login(String email, String password) async =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, void>> logout() async => const Right(null);

  @override
  Future<Either<Failure, UserEntity>> register(
    String name,
    String email,
    String password,
  ) async => throw UnimplementedError();

  @override
  Future<Either<Failure, void>> saveToken(String token) async => const Right(null);

  @override
  Future<Either<Failure, void>> saveUser(UserEntity user) async => const Right(null);
}

class _FakeBankAccountRepository implements IBankAccountRepository {
  @override
  Future<Either<Failure, List<BankAccountEntity>>> getBankAccounts() async =>
      const Right([]);

  @override
  Future<Either<Failure, BankAccountEntity>> createBankAccount({
    required String name,
    required String bankName,
    required String color,
    required AccountType accountType,
    required int initialBalanceCents,
  }) async => throw UnimplementedError();

  @override
  Future<Either<Failure, void>> deactivateBankAccount(int id) async =>
      const Right(null);

  @override
  Future<Either<Failure, void>> reactivateBankAccount(int id) async =>
      const Right(null);

  @override
  Future<Either<Failure, BankAccountEntity>> updateBankAccount({
    required int id,
    required String name,
    required String bankName,
    required String color,
    required AccountType accountType,
    required int initialBalanceCents,
    bool? isActive,
  }) async => throw UnimplementedError();
}

class _FakeCreditCardRepository implements ICreditCardRepository {
  @override
  Future<Either<Failure, List<CreditCardEntity>>> getCreditCards() async =>
      const Right([]);

  @override
  Future<Either<Failure, CreditCardEntity>> createCreditCard({
    required String name,
    required String brand,
    required String color,
    required int limitCents,
    required int closingDay,
    required int dueDay,
    required String lastFourDigits,
  }) async => throw UnimplementedError();

  @override
  Future<Either<Failure, void>> deactivateCreditCard(int id) async =>
      const Right(null);

  @override
  Future<Either<Failure, void>> reactivateCreditCard(int id) async =>
      const Right(null);

  @override
  Future<Either<Failure, CreditCardEntity>> updateCreditCard({
    required int id,
    required String name,
    required String brand,
    required String color,
    required int limitCents,
    required int closingDay,
    required int dueDay,
    required String lastFourDigits,
    bool? isActive,
  }) async => throw UnimplementedError();
}

class _FakeTransactionRepository implements ITransactionRepository {
  final List<DateTime> requestedMonths = [];
  List<TransactionEntity> response = [];

  @override
  Future<Either<Failure, List<TransactionEntity>>> getTransactions({
    required DateTime referenceMonth,
  }) async {
    requestedMonths.add(referenceMonth);
    return Right(response);
  }

  @override
  Future<Either<Failure, TransactionEntity>> createTransaction({
    required TransactionType type,
    required AssetType assetType,
    required int amountCents,
    required int categoryId,
    required String description,
    required DateTime transactionDate,
    int? bankAccountId,
    int? creditCardId,
    int? installmentCount,
  }) async => throw UnimplementedError();

  @override
  Future<Either<Failure, void>> deleteTransaction(
    int id, {
    TransactionMutationScope? scope,
  }) async => const Right(null);

  @override
  Future<Either<Failure, TransactionEntity>> getTransaction(int id) async =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, TransactionEntity>> updateTransaction(
    int id, {
    int? categoryId,
    String? description,
    int? amountCents,
    DateTime? transactionDate,
    TransactionMutationScope? scope,
  }) async => throw UnimplementedError();
}

class _FakeHomeTabNavigation implements HomeTabNavigation {
  @override
  void openTransactionsTab() {}
}

class _FakeRealtimeClient implements RealtimeClient {
  @override
  final RxBool isOnline = true.obs;

  @override
  void connect({required String token}) {}

  @override
  Future<void> dispose() async {}

  @override
  void disconnect() {}

  @override
  void off(String event) {}

  @override
  void on(String event, void Function(dynamic payload) handler) {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('HomeController', () {
    late _FakeTransactionRepository transactionRepository;
    late HomeController controller;

    setUp(() {
      Get.testMode = true;
      transactionRepository = _FakeTransactionRepository()
        ..response = [
          TransactionEntity(
            id: 1,
            type: TransactionType.expense,
            status: TransactionStatus.cleared,
            assetType: AssetType.bankAccount,
            amountCents: 5000,
            categoryId: 7,
            description: 'Combustivel',
            transactionDate: DateTime(2026, 3, 10),
            categoryName: 'Combustivel',
            categoryColor: '#FFAA00',
          ),
        ];
      controller = HomeController(
        getStoredUserUseCase: GetStoredUserUseCase(_FakeAuthRepository()),
        logoutUseCase: LogoutUseCase(_FakeAuthRepository()),
        loadBankAccountsUseCase: LoadBankAccountsUseCase(_FakeBankAccountRepository()),
        loadCreditCardsUseCase: LoadCreditCardsUseCase(_FakeCreditCardRepository()),
        getTransactionsUseCase: GetTransactionsUseCase(transactionRepository),
        dashboardRefreshNotifier: DefaultDashboardRefreshNotifier(),
        homeTabNavigation: _FakeHomeTabNavigation(),
        realtimeClient: _FakeRealtimeClient(),
      );
    });

    test('carrega transacoes usando o mes selecionado', () async {
      final selectedMonth = DateTime(2026, 3, 1);
      controller.selectedMonth.value = selectedMonth;

      await controller.loadDashboardData();

      expect(transactionRepository.requestedMonths, [selectedMonth]);
    });

    test('previousMonth e nextMonth mudam o mes e fazem nova carga remota', () async {
      controller.selectedMonth.value = DateTime(2026, 3, 1);

      controller.previousMonth();
      controller.nextMonth();

      expect(transactionRepository.requestedMonths, [
        DateTime(2026, 2, 1),
        DateTime(2026, 3, 1),
      ]);
    });

    test('gera o grafico a partir das despesas do retorno mensal sem placeholder', () async {
      await controller.loadDashboardData();

      expect(controller.gastosPorCategoria, isNotEmpty);
      expect(controller.gastosPorCategoria.single.categoryLabel, 'Combustivel');
      expect(controller.gastosPorCategoria.single.amountCents, 5000);
    });
  });
}
