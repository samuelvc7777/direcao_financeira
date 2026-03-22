import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:direcao_financeira_mobile/app/core/accessibility/accessibility_service.dart';
import 'package:direcao_financeira_mobile/app/core/dashboard/dashboard_refresh_notifier.dart';
import 'package:direcao_financeira_mobile/app/core/errors/failures.dart';
import 'package:direcao_financeira_mobile/app/core/network/journey_realtime_bridge.dart';
import 'package:direcao_financeira_mobile/app/core/network/realtime_client.dart';
import 'package:direcao_financeira_mobile/app/domain/entities/finish_shift_result_entity.dart';
import 'package:direcao_financeira_mobile/app/domain/entities/journey_statistics_entity.dart';
import 'package:direcao_financeira_mobile/app/domain/entities/location_tracking_status_entity.dart';
import 'package:direcao_financeira_mobile/app/domain/entities/active_shift_entity.dart';
import 'package:direcao_financeira_mobile/app/domain/entities/bank_account_entity.dart';
import 'package:direcao_financeira_mobile/app/domain/entities/category_entity.dart';
import 'package:direcao_financeira_mobile/app/domain/entities/credit_card_entity.dart';
import 'package:direcao_financeira_mobile/app/domain/entities/plan_entity.dart';
import 'package:direcao_financeira_mobile/app/domain/entities/ride_entity.dart';
import 'package:direcao_financeira_mobile/app/domain/entities/shift_entity.dart';
import 'package:direcao_financeira_mobile/app/domain/entities/shift_route_entity.dart';
import 'package:direcao_financeira_mobile/app/domain/entities/store_product_entity.dart';
import 'package:direcao_financeira_mobile/app/domain/entities/store_purchase_event_entity.dart';
import 'package:direcao_financeira_mobile/app/domain/entities/subscription_entity.dart';
import 'package:direcao_financeira_mobile/app/domain/entities/transaction_entity.dart';
import 'package:direcao_financeira_mobile/app/domain/entities/user_entity.dart';
import 'package:direcao_financeira_mobile/app/domain/repositories/i_auth_repository.dart';
import 'package:direcao_financeira_mobile/app/domain/repositories/i_bank_account_repository.dart';
import 'package:direcao_financeira_mobile/app/domain/repositories/i_category_repository.dart';
import 'package:direcao_financeira_mobile/app/domain/repositories/i_credit_card_repository.dart';
import 'package:direcao_financeira_mobile/app/domain/repositories/i_journey_repository.dart';
import 'package:direcao_financeira_mobile/app/domain/repositories/i_ride_repository.dart';
import 'package:direcao_financeira_mobile/app/domain/repositories/i_subscription_repository.dart';
import 'package:direcao_financeira_mobile/app/domain/repositories/i_transaction_repository.dart';
import 'package:direcao_financeira_mobile/app/domain/usecases/auth_session_use_cases.dart';
import 'package:direcao_financeira_mobile/app/domain/usecases/bank_account_use_cases.dart';
import 'package:direcao_financeira_mobile/app/domain/usecases/category_use_cases.dart';
import 'package:direcao_financeira_mobile/app/domain/usecases/credit_card_use_cases.dart';
import 'package:direcao_financeira_mobile/app/domain/usecases/get_rides_usecase.dart';
import 'package:direcao_financeira_mobile/app/domain/usecases/journey_use_cases.dart';
import 'package:direcao_financeira_mobile/app/domain/usecases/subscription_use_cases.dart';
import 'package:direcao_financeira_mobile/app/domain/usecases/transaction_use_cases.dart';
import 'package:direcao_financeira_mobile/app/presentation/modules/bank_accounts/bank_accounts_controller.dart';
import 'package:direcao_financeira_mobile/app/presentation/modules/categories/categories_controller.dart';
import 'package:direcao_financeira_mobile/app/presentation/modules/credit_cards/credit_cards_controller.dart';
import 'package:direcao_financeira_mobile/app/presentation/modules/home/home_controller.dart';
import 'package:direcao_financeira_mobile/app/presentation/modules/home/home_tab_navigation.dart';
import 'package:direcao_financeira_mobile/app/presentation/modules/journey/journey_controller.dart';
import 'package:direcao_financeira_mobile/app/presentation/modules/subscription/subscription_controller.dart';
import 'package:direcao_financeira_mobile/app/presentation/modules/transactions/transactions_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../../support/test_entities.dart';

class _FakeAuthRepository implements IAuthRepository {
  UserEntity? storedUser;

  @override
  Either<Failure, UserEntity?> getStoredUser() => Right(storedUser);

  @override
  Future<Either<Failure, String?>> getToken() async => const Right(null);

  @override
  Future<Either<Failure, UserEntity>> login(
    String email,
    String password,
  ) async => Right(buildUser());

  @override
  Future<Either<Failure, void>> logout() async => const Right(null);

  @override
  Future<Either<Failure, UserEntity>> register(
    String name,
    String email,
    String password,
  ) async => Right(buildUser());

  @override
  Future<Either<Failure, void>> saveToken(String token) async =>
      const Right(null);

  @override
  Future<Either<Failure, void>> saveUser(UserEntity user) async =>
      const Right(null);
}

class _FakeBankAccountRepository implements IBankAccountRepository {
  List<BankAccountEntity> accounts = [];

  @override
  Future<Either<Failure, BankAccountEntity>> createBankAccount({
    required String name,
    required String bankName,
    required String color,
    required AccountType accountType,
    required int initialBalanceCents,
  }) async => Right(buildBankAccount(name: name));

  @override
  Future<Either<Failure, void>> deactivateBankAccount(int id) async =>
      const Right(null);

  @override
  Future<Either<Failure, List<BankAccountEntity>>> getBankAccounts() async =>
      Right(accounts);

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
  }) async =>
      Right(buildBankAccount(id: id, name: name, isActive: isActive ?? true));
}

class _FakeCategoryRepository implements ICategoryRepository {
  List categories = [];

  @override
  Future<Either<Failure, CategoryEntity>> createCategory({
    required String name,
    required CategoryType type,
    required String color,
    required String icon,
  }) async => Right(buildCategory(name: name, type: type));

  @override
  Future<Either<Failure, void>> deactivateCategory(int id) async =>
      const Right(null);

  @override
  Future<Either<Failure, List<CategoryEntity>>> getCategories() async =>
      Right(List<CategoryEntity>.from(categories));

  @override
  Future<Either<Failure, void>> reactivateCategory(int id) async =>
      const Right(null);

  @override
  Future<Either<Failure, CategoryEntity>> updateCategory({
    required int id,
    required String name,
    required CategoryType type,
    required String color,
    required String icon,
  }) async => Right(buildCategory(id: id, name: name, type: type));
}

class _FakeCreditCardRepository implements ICreditCardRepository {
  List<CreditCardEntity> cards = [];

  @override
  Future<Either<Failure, CreditCardEntity>> createCreditCard({
    required String name,
    required String brand,
    required String color,
    required int limitCents,
    required int closingDay,
    required int dueDay,
    required String lastFourDigits,
  }) async => Right(buildCreditCard(name: name));

  @override
  Future<Either<Failure, void>> deactivateCreditCard(int id) async =>
      const Right(null);

  @override
  Future<Either<Failure, List<CreditCardEntity>>> getCreditCards() async =>
      Right(cards);

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
  }) async =>
      Right(buildCreditCard(id: id, name: name, isActive: isActive ?? true));
}

class _FakeTransactionRepository implements ITransactionRepository {
  List<TransactionEntity> transactions = [];

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
  }) async =>
      Right(buildTransaction(id: 99, type: type, date: transactionDate));

  @override
  Future<Either<Failure, void>> deleteTransaction(
    int id, {
    TransactionMutationScope? scope,
  }) async => const Right(null);

  @override
  Future<Either<Failure, TransactionEntity>> getTransaction(int id) async =>
      Right(transactions.first);

  @override
  Future<Either<Failure, List<TransactionEntity>>> getTransactions() async =>
      Right(transactions);

  @override
  Future<Either<Failure, TransactionEntity>> updateTransaction(
    int id, {
    int? categoryId,
    String? description,
    int? amountCents,
    DateTime? transactionDate,
    TransactionMutationScope? scope,
  }) async => Right(buildTransaction(id: id, date: transactionDate));
}

class _FakeSubscriptionRepository implements ISubscriptionRepository {
  SubscriptionEntity? activeSubscription;
  List<SubscriptionEntity> history = [];
  List plans = [];
  bool storeAvailable = true;
  List<StoreProductEntity> products = [];

  @override
  Future<Either<Failure, void>> buyProduct({
    required String productId,
    String? applicationUserName,
  }) async => const Right(null);

  @override
  Future<Either<Failure, SubscriptionEntity?>> cancelSubscription() async =>
      Right(activeSubscription);

  @override
  Future<Either<Failure, SubscriptionEntity?>> changePlan(int planId) async =>
      Right(activeSubscription);

  @override
  Future<Either<Failure, void>> completePurchase(String productId) async =>
      const Right(null);

  @override
  Future<Either<Failure, List<PlanEntity>>> getAvailablePlans() async =>
      Right(List<PlanEntity>.from(plans));

  @override
  Future<Either<Failure, SubscriptionEntity?>> getMySubscription() async =>
      Right(activeSubscription);

  @override
  Future<Either<Failure, List<StoreProductEntity>>> getStoreProducts(
    Set<String> productIds,
  ) async =>
      Right(products.where((p) => productIds.contains(p.productId)).toList());

  @override
  Future<Either<Failure, List<SubscriptionEntity>>>
  getSubscriptionHistory() async => Right(history);

  @override
  Future<Either<Failure, bool>> isStoreAvailable() async =>
      Right(storeAvailable);

  @override
  Stream<StorePurchaseEventEntity> get purchaseUpdates =>
      const Stream<StorePurchaseEventEntity>.empty();

  @override
  Future<Either<Failure, SubscriptionEntity?>> renewSubscription({
    required bool autoRenew,
  }) async => Right(activeSubscription);

  @override
  Future<Either<Failure, void>> restorePurchases({
    String? applicationUserName,
  }) async => const Right(null);

  @override
  Future<Either<Failure, void>> syncStoredUser({
    SubscriptionEntity? activeSubscription,
    List<SubscriptionEntity>? subscriptions,
  }) async => const Right(null);
}

class _FakeJourneyRepository implements IJourneyRepository {
  ActiveShiftEntity? activeShift;
  LocationTrackingStatusEntity trackingStatus = buildTrackingStatus();

  @override
  Future<Either<Failure, LocationTrackingStatusEntity>>
  ensureReadyForShiftStart() async => Right(trackingStatus);

  @override
  Future<Either<Failure, FinishShiftResultEntity>> finishShift() async =>
      const Right(FinishShiftResultEntity(synced: true, pendingSyncCount: 0));

  @override
  Future<Either<Failure, ActiveShiftEntity?>> getActiveShift() async =>
      Right(activeShift);

  @override
  Future<Either<Failure, JourneyStatisticsEntity>> getDailyStatistics({
    String filter = 'day',
    String? date,
    String? endDate,
  }) async => Right(buildJourneyStatistics());

  @override
  Future<Either<Failure, LocationTrackingStatusEntity>>
  getLocationTrackingStatus() async => Right(trackingStatus);

  @override
  Future<Either<Failure, ShiftRouteEntity>> getShiftRoute({
    int? localShiftId,
    int? remoteShiftId,
  }) async => throw UnimplementedError();

  @override
  Future<Either<Failure, List<ShiftEntity>>> getShiftHistory({
    String filter = 'day',
    String? date,
    String? endDate,
  }) async => Right([buildShift()]);

  @override
  Future<Either<Failure, void>> pauseShift() async => const Right(null);

  @override
  Future<Either<Failure, void>> resumeShift() async => const Right(null);

  @override
  Future<Either<Failure, int>> syncPendingShifts() async => const Right(0);

  @override
  Future<Either<Failure, void>> startShift() async => const Right(null);

  @override
  Stream<LocationTrackingStatusEntity> watchLocationTrackingStatus() =>
      Stream<LocationTrackingStatusEntity>.empty();
}

class _FakeRideRepository implements IRideRepository {
  @override
  Future<Either<Failure, List<RideEntity>>> getRides({
    String period = 'day',
    String? date,
    String? endDate,
  }) async => Right([buildRide()]);
}

class _FakeHomeTabNavigation implements HomeTabNavigation {
  bool openedTransactionsTab = false;

  @override
  void openTransactionsTab() {
    openedTransactionsTab = true;
  }
}

class _FakeRealtimeClient implements RealtimeClient {
  @override
  final RxBool isOnline = true.obs;

  final Map<String, void Function(dynamic payload)> handlers = {};

  @override
  void connect({required String token}) {}

  @override
  void disconnect() {}

  @override
  Future<void> dispose() async {}

  @override
  void off(String event) {
    handlers.remove(event);
  }

  @override
  void on(String event, void Function(dynamic payload) handler) {
    handlers[event] = handler;
  }
}

class _FakeAccessibilityService implements AccessibilityService {
  @override
  final RxBool isServiceEnabled = true.obs;

  @override
  bool persistedTrafficLightActive = false;

  bool? lastTrafficLightValue;

  @override
  Future<void> requestAccessibilityPermission() async {}

  @override
  Future<void> setJourneyActive(bool isActive) async {}

  @override
  Future<void> setTrafficLightActive(bool isActive) async {
    lastTrafficLightValue = isActive;
    persistedTrafficLightActive = isActive;
  }

  @override
  Future<void> syncSettingsWithNative() async {}
}

class _FakeJourneyRealtimeBridge implements JourneyRealtimeBridge {
  @override
  final RxBool isOnline = true.obs;

  @override
  void bind({
    required VoidCallback onShiftChanged,
    required VoidCallback onRideChanged,
  }) {}

  @override
  void unbind() {}
}

void main() {
  setUpAll(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await initializeDateFormatting('pt_BR');
    Get.testMode = true;
  });

  tearDown(() {
    Get.reset();
  });

  test('HomeController carrega dashboard e reage ao notifier', () async {
    final authRepository = _FakeAuthRepository()
      ..storedUser = buildUser(name: 'Samuel');
    final bankRepository = _FakeBankAccountRepository()
      ..accounts = [
        buildBankAccount(isActive: true),
        buildBankAccount(id: 2, isActive: false),
      ];
    final cardRepository = _FakeCreditCardRepository()
      ..cards = [
        buildCreditCard(isActive: true),
        buildCreditCard(id: 2, isActive: false),
      ];
    final transactionRepository = _FakeTransactionRepository()
      ..transactions = [
        buildTransaction(id: 1, date: DateTime(2026, 1, 12)),
        buildTransaction(id: 2, date: DateTime(2026, 1, 10)),
      ];
    final notifier = DefaultDashboardRefreshNotifier();
    final navigation = _FakeHomeTabNavigation();
    final realtimeClient = _FakeRealtimeClient();
    final controller = HomeController(
      getStoredUserUseCase: GetStoredUserUseCase(authRepository),
      logoutUseCase: LogoutUseCase(authRepository),
      loadBankAccountsUseCase: LoadBankAccountsUseCase(bankRepository),
      loadCreditCardsUseCase: LoadCreditCardsUseCase(cardRepository),
      getTransactionsUseCase: GetTransactionsUseCase(transactionRepository),
      dashboardRefreshNotifier: notifier,
      homeTabNavigation: navigation,
      realtimeClient: realtimeClient,
    );

    controller.onInit();
    await Future<void>.delayed(Duration.zero);

    expect(controller.userName.value, 'Samuel');
    expect(controller.contas.length, 1);
    expect(controller.cartoes.length, 1);
    expect(controller.ultimasTransacoes.first.id, 1);

    bankRepository.accounts = [buildBankAccount(id: 99, name: 'Nova conta')];
    notifier.requestRefresh();
    await Future<void>.delayed(Duration.zero);

    expect(controller.contas.single.id, 99);

    controller.openTransactionsTab();
    expect(navigation.openedTransactionsTab, isTrue);

    controller.onClose();
  });

  test('BankAccountsController carrega contas e separa ativas', () async {
    final repository = _FakeBankAccountRepository()
      ..accounts = [
        buildBankAccount(isActive: true),
        buildBankAccount(id: 2, isActive: false),
      ];
    final controller = BankAccountsController(
      loadBankAccountsUseCase: LoadBankAccountsUseCase(repository),
      createBankAccountUseCase: CreateBankAccountUseCase(repository),
      updateBankAccountUseCase: UpdateBankAccountUseCase(repository),
      deactivateBankAccountUseCase: DeactivateBankAccountUseCase(repository),
      reactivateBankAccountUseCase: ReactivateBankAccountUseCase(repository),
    );

    await controller.loadBankAccounts();

    expect(controller.bankAccounts.length, 2);
    expect(controller.activeAccounts.length, 1);
    expect(controller.inactiveAccounts.length, 1);
  });

  test('CategoriesController carrega categorias e separa por tipo', () async {
    final repository = _FakeCategoryRepository()
      ..categories = [
        buildCategory(type: CategoryType.income, name: 'Receitas'),
        buildCategory(id: 2, type: CategoryType.expense, name: 'Combustivel'),
      ];
    final controller = CategoriesController(
      loadCategoriesUseCase: LoadCategoriesUseCase(repository),
      createCategoryUseCase: CreateCategoryUseCase(repository),
      updateCategoryUseCase: UpdateCategoryUseCase(repository),
      deactivateCategoryUseCase: DeactivateCategoryUseCase(repository),
      reactivateCategoryUseCase: ReactivateCategoryUseCase(repository),
    );

    await controller.loadCategories();

    expect(controller.categories.length, 2);
    expect(controller.incomeCategories.single.name, 'Receitas');
    expect(controller.expenseCategories.single.name, 'Combustivel');
  });

  test('CreditCardsController carrega cartoes e separa ativos', () async {
    final repository = _FakeCreditCardRepository()
      ..cards = [
        buildCreditCard(isActive: true),
        buildCreditCard(id: 2, isActive: false),
      ];
    final controller = CreditCardsController(
      loadCreditCardsUseCase: LoadCreditCardsUseCase(repository),
      createCreditCardUseCase: CreateCreditCardUseCase(repository),
      updateCreditCardUseCase: UpdateCreditCardUseCase(repository),
      deactivateCreditCardUseCase: DeactivateCreditCardUseCase(repository),
      reactivateCreditCardUseCase: ReactivateCreditCardUseCase(repository),
    );

    await controller.loadCreditCards();

    expect(controller.creditCards.length, 2);
    expect(controller.activeCards.length, 1);
    expect(controller.inactiveCards.length, 1);
  });

  testWidgets('TransactionsController publica refresh ao criar transacao', (
    tester,
  ) async {
    final transactionRepository = _FakeTransactionRepository()
      ..transactions = [buildTransaction()];
    final categoryRepository = _FakeCategoryRepository()
      ..categories = [buildCategory()];
    final bankRepository = _FakeBankAccountRepository()
      ..accounts = [buildBankAccount()];
    final cardRepository = _FakeCreditCardRepository()
      ..cards = [buildCreditCard()];
    final notifier = DefaultDashboardRefreshNotifier();

    await tester.pumpWidget(
      GetMaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () =>
                    Get.to(() => const Scaffold(body: Text('Formulario'))),
                child: const Text('Abrir'),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Abrir'));
    await tester.pumpAndSettle();

    final controller = TransactionsController(
      createTransactionUseCase: CreateTransactionUseCase(transactionRepository),
      updateTransactionUseCase: UpdateTransactionUseCase(transactionRepository),
      deleteTransactionUseCase: DeleteTransactionUseCase(transactionRepository),
      getTransactionsUseCase: GetTransactionsUseCase(transactionRepository),
      getCategoriesUseCase: GetCategoriesUseCase(categoryRepository),
      getBankAccountsUseCase: GetBankAccountsUseCase(bankRepository),
      getCreditCardsUseCase: GetCreditCardsUseCase(cardRepository),
      dashboardRefreshNotifier: notifier,
    );

    await controller.loadData();
    final result = await controller.createTransaction(
      type: TransactionType.expense,
      assetType: AssetType.bankAccount,
      amountCents: 2500,
      categoryId: 1,
      description: 'Posto Shell',
      transactionDate: DateTime(2026, 1, 15),
      bankAccountId: 1,
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();

    expect(result, isTrue);
    expect(notifier.refreshTick.value, 1);
    expect(
      controller.transactions.any((transaction) => transaction.id == 99),
      isTrue,
    );
  });

  test(
    'SubscriptionController carrega assinatura, planos e catalogo da loja',
    () async {
      final repository = _FakeSubscriptionRepository()
        ..activeSubscription = buildSubscription()
        ..history = [buildSubscription()]
        ..plans = [buildPlan()]
        ..products = [buildStoreProduct()];
      final controller = SubscriptionController(
        getMySubscriptionUseCase: GetMySubscriptionUseCase(repository),
        getSubscriptionHistoryUseCase: GetSubscriptionHistoryUseCase(
          repository,
        ),
        getAvailablePlansUseCase: GetAvailablePlansUseCase(repository),
        changePlanUseCase: ChangePlanUseCase(repository),
        cancelSubscriptionUseCase: CancelSubscriptionUseCase(repository),
        renewSubscriptionUseCase: RenewSubscriptionUseCase(repository),
        syncStoredUserSubscriptionUseCase: SyncStoredUserSubscriptionUseCase(
          repository,
        ),
        isStoreAvailableUseCase: IsStoreAvailableUseCase(repository),
        getStoreProductsUseCase: GetStoreProductsUseCase(repository),
        buyStoreProductUseCase: BuyStoreProductUseCase(repository),
        restorePurchasesUseCase: RestorePurchasesUseCase(repository),
        completePurchaseUseCase: CompletePurchaseUseCase(repository),
        watchStorePurchaseUpdatesUseCase: WatchStorePurchaseUpdatesUseCase(
          repository,
        ),
      );

      await controller.loadData();

      expect(controller.activeSubscription.value?.id, 1);
      expect(controller.selectedPlanId.value, 1);
      expect(controller.isStoreAvailable.value, isTrue);
      expect(
        controller.storeProductsById.containsKey('premium_monthly'),
        isTrue,
      );
    },
  );

  test(
    'JourneyController usa contratos de acessibilidade e realtime',
    () async {
      final journeyRepository = _FakeJourneyRepository();
      final rideRepository = _FakeRideRepository();
      final accessibilityService = _FakeAccessibilityService();
      final journeyRealtimeBridge = _FakeJourneyRealtimeBridge();
      final controller = JourneyController(
        getActiveShift: GetActiveShiftUseCase(journeyRepository),
        getDailyStatistics: GetDailyStatisticsUseCase(journeyRepository),
        getShiftHistory: GetShiftHistoryUseCase(journeyRepository),
        startShiftUseCase: StartShiftUseCase(journeyRepository),
        pauseShiftUseCase: PauseShiftUseCase(journeyRepository),
        resumeShiftUseCase: ResumeShiftUseCase(journeyRepository),
        finishShiftUseCase: FinishShiftUseCase(journeyRepository),
        syncPendingJourneyUseCase: SyncPendingJourneyUseCase(journeyRepository),
        ensureReadyForShiftStartUseCase: EnsureReadyForShiftStartUseCase(
          journeyRepository,
        ),
        getLocationTrackingStatusUseCase: GetLocationTrackingStatusUseCase(
          journeyRepository,
        ),
        watchLocationTrackingStatusUseCase: WatchLocationTrackingStatusUseCase(
          journeyRepository,
        ),
        getRidesUseCase: GetRidesUseCase(rideRepository),
        journeyRealtimeBridge: journeyRealtimeBridge,
        accessibilityService: accessibilityService,
      );

      controller.onInit();
      await Future<void>.delayed(Duration.zero);
      await controller.toggleTrafficLight();

      expect(controller.isAccessibilityServiceEnabled, isTrue);
      expect(controller.isTrafficLightActive.value, isTrue);
      expect(accessibilityService.lastTrafficLightValue, isTrue);

      controller.onClose();
    },
  );
}
