import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:direcao_financeira_mobile/app/core/app_bubble/app_bubble_service.dart';
import 'package:direcao_financeira_mobile/app/core/accessibility/accessibility_service.dart';
import 'package:direcao_financeira_mobile/app/core/dashboard/dashboard_refresh_notifier.dart';
import 'package:direcao_financeira_mobile/app/core/errors/failures.dart';
import 'package:direcao_financeira_mobile/app/core/network/journey_realtime_bridge.dart';
import 'package:direcao_financeira_mobile/app/core/network/realtime_client.dart';
import 'package:direcao_financeira_mobile/app/domain/entities/finish_shift_result_entity.dart';
import 'package:direcao_financeira_mobile/app/domain/entities/journey_statistics_entity.dart';
import 'package:direcao_financeira_mobile/app/domain/entities/location_tracking_status_entity.dart';
import 'package:direcao_financeira_mobile/app/domain/entities/manual_shift_draft_entity.dart';
import 'package:direcao_financeira_mobile/app/domain/entities/paged_result_entity.dart';
import 'package:direcao_financeira_mobile/app/domain/entities/active_shift_entity.dart';
import 'package:direcao_financeira_mobile/app/domain/entities/bank_account_entity.dart';
import 'package:direcao_financeira_mobile/app/domain/entities/category_entity.dart';
import 'package:direcao_financeira_mobile/app/domain/entities/credit_card_entity.dart';
import 'package:direcao_financeira_mobile/app/domain/entities/costs_gains_settings_entity.dart';
import 'package:direcao_financeira_mobile/app/domain/entities/detected_ride_draft_entity.dart';
import 'package:direcao_financeira_mobile/app/domain/entities/plan_entity.dart';
import 'package:direcao_financeira_mobile/app/domain/entities/ride_import_entity.dart';
import 'package:direcao_financeira_mobile/app/domain/entities/ride_entity.dart';
import 'package:direcao_financeira_mobile/app/domain/entities/shift_entity.dart';
import 'package:direcao_financeira_mobile/app/domain/entities/shift_route_entity.dart';
import 'package:direcao_financeira_mobile/app/domain/entities/store_product_entity.dart';
import 'package:direcao_financeira_mobile/app/domain/entities/store_purchase_event_entity.dart';
import 'package:direcao_financeira_mobile/app/domain/entities/subscription_entity.dart';
import 'package:direcao_financeira_mobile/app/domain/entities/transaction_draft_entity.dart';
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
import 'package:direcao_financeira_mobile/app/presentation/modules/journey/journey_runtime_coordinator.dart';
import 'package:direcao_financeira_mobile/app/presentation/modules/journey/shift_lifecycle_coordinator.dart';
import 'package:direcao_financeira_mobile/app/presentation/modules/subscription/subscription_controller.dart';
import 'package:direcao_financeira_mobile/app/presentation/modules/transactions/transactions_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../../support/test_entities.dart';
import 'support/journey_controller_test_builders.dart';

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
  Future<Either<Failure, void>> sendPasswordResetEmail(String email) async =>
      const Right(null);

  @override
  Future<Either<Failure, void>> updatePassword(String password) async =>
      const Right(null);

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
  final List<DateTime> requestedMonths = [];

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
  }) async {
    final created = buildTransaction(id: 99, type: type, date: transactionDate);
    transactions = [created, ...transactions];
    return Right(created);
  }

  @override
  Future<Either<Failure, List<TransactionEntity>>> createImportedTransactions({
    required List<TransactionDraftEntity> transactions,
  }) async {
    final created = <TransactionEntity>[];
    for (var i = 0; i < transactions.length; i++) {
      created.add(
        buildTransaction(
          id: 200 + i,
          type: transactions[i].type,
          date: transactions[i].transactionDate,
          description: transactions[i].description,
        ),
      );
    }
    return Right(created);
  }

  @override
  Future<Either<Failure, void>> deleteTransaction(
    int id, {
    TransactionMutationScope? scope,
  }) async => const Right(null);

  @override
  Future<Either<Failure, TransactionEntity>> getTransaction(int id) async =>
      Right(transactions.first);

  @override
  Future<Either<Failure, List<TransactionEntity>>> getTransactions({
    required DateTime referenceMonth,
  }) async {
    requestedMonths.add(referenceMonth);
    return Right(transactions);
  }

  @override
  Future<Either<Failure, void>> createInvoicePayment({
    required int bankAccountId,
    required int creditCardId,
    required int amountCents,
    required int expenseCategoryId,
    required int incomeCategoryId,
    required String description,
    required DateTime transactionDate,
  }) async => const Right(null);

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
  final StreamController<LocationTrackingStatusEntity> trackingController =
      StreamController<LocationTrackingStatusEntity>.broadcast();
  Either<Failure, ActiveShiftEntity?>? activeShiftResult;
  Either<Failure, JourneyStatisticsEntity>? statisticsResult;
  Either<Failure, LocationTrackingStatusEntity>? trackingStatusResult;
  Either<Failure, PagedResultEntity<ShiftEntity>>? shiftHistoryResult;
  Either<Failure, int>? syncPendingShiftsResult;
  Either<Failure, FinishShiftResultEntity>? addManualShiftResult;
  ManualShiftDraftEntity? lastManualShift;
  ShiftEntity? deletedShift;

  @override
  Future<Either<Failure, LocationTrackingStatusEntity>>
  ensureReadyForShiftStart() async => Right(trackingStatus);

  @override
  Future<Either<Failure, FinishShiftResultEntity>> finishShift() async =>
      const Right(FinishShiftResultEntity(synced: true, pendingSyncCount: 0));

  @override
  Future<Either<Failure, FinishShiftResultEntity>> addManualShift(
    ManualShiftDraftEntity shift,
  ) async {
    lastManualShift = shift;
    return addManualShiftResult ??
        const Right(FinishShiftResultEntity(synced: true, pendingSyncCount: 0));
  }

  @override
  Future<Either<Failure, void>> deleteShift(ShiftEntity shift) async {
    deletedShift = shift;
    return const Right(null);
  }

  @override
  Future<Either<Failure, ActiveShiftEntity?>> getActiveShift() async =>
      activeShiftResult ?? Right(activeShift);

  @override
  Future<Either<Failure, JourneyStatisticsEntity>> getDailyStatistics({
    String filter = 'day',
    String? date,
    String? endDate,
  }) async => statisticsResult ?? Right(buildJourneyStatistics());

  @override
  Future<Either<Failure, LocationTrackingStatusEntity>>
  getLocationTrackingStatus() async =>
      trackingStatusResult ?? Right(trackingStatus);

  @override
  Future<Either<Failure, ShiftRouteEntity>> getShiftRoute({
    int? localShiftId,
    int? remoteShiftId,
  }) async => throw UnimplementedError();

  @override
  Future<Either<Failure, PagedResultEntity<ShiftEntity>>> getShiftHistory({
    String filter = 'day',
    String? date,
    String? endDate,
    int offset = 0,
    int limit = 20,
  }) async =>
      shiftHistoryResult ??
      Right(
        PagedResultEntity(
          items: [buildShift()],
          totalCount: 1,
          offset: offset,
          limit: limit,
        ),
      );

  @override
  Future<Either<Failure, void>> pauseShift() async => const Right(null);

  @override
  Future<Either<Failure, void>> resumeShift() async => const Right(null);

  @override
  Future<Either<Failure, int>> syncPendingShifts() async =>
      syncPendingShiftsResult ?? const Right(0);

  @override
  Future<Either<Failure, void>> startShift() async => const Right(null);

  @override
  Stream<LocationTrackingStatusEntity> watchLocationTrackingStatus() =>
      trackingController.stream;

  Future<void> dispose() async {
    await trackingController.close();
  }
}

class _FakeRideRepository implements IRideRepository {
  Either<Failure, PagedResultEntity<RideEntity>> ridesResult = Right(
    PagedResultEntity(
      items: [buildRide()],
      totalCount: 1,
      offset: 0,
      limit: 20,
    ),
  );

  @override
  Future<Either<Failure, Unit>> createDetectedRide(
    DetectedRideDraftEntity ride,
  ) async => const Right(unit);

  @override
  Future<Either<Failure, Unit>> createFinishedRide(
    DetectedRideDraftEntity ride,
  ) async => const Right(unit);

  @override
  Future<Either<Failure, PagedResultEntity<RideEntity>>> getRides({
    String period = 'day',
    String? date,
    String? endDate,
    String? status,
    int offset = 0,
    int limit = 20,
  }) async => ridesResult;

  @override
  Future<Either<Failure, PagedResultEntity<RideImportEntity>>>
  getImportableRides({
    String period = 'month',
    String? date,
    String? endDate,
    String? status = 'FINISHED',
    int offset = 0,
    int limit = 100,
  }) async {
    final items = ridesResult
        .getOrElse(
          () => PagedResultEntity<RideEntity>(
            items: [],
            totalCount: 0,
            offset: 0,
            limit: 0,
          ),
        )
        .items
        .map(
          (ride) => RideImportEntity(
            rideId: ride.id,
            status: ride.status,
            appName: ride.appName,
            paymentMethod: ride.paymentMethod,
            grossValueCents: ride.grossValueCents,
            date: ride.date,
            time: ride.time,
            isAlreadyImported: false,
          ),
        )
        .toList();

    return Right(
      PagedResultEntity(
        items: items,
        totalCount: items.length,
        offset: offset,
        limit: limit,
      ),
    );
  }

  @override
  Future<Either<Failure, Unit>> finishRide({
    required int rideId,
    required String paymentMethod,
  }) async => const Right(unit);

  @override
  Future<Either<Failure, Unit>> cancelRide({
    required int rideId,
    required String cancelReason,
  }) async => const Right(unit);
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

  VoidCallback? boundOnRideChanged;
  var bindCalls = 0;
  var unbindCalls = 0;

  @override
  void bind({required VoidCallback onRideChanged}) {
    bindCalls++;
    boundOnRideChanged = onRideChanged;
  }

  @override
  void unbind() {
    unbindCalls++;
  }
}

class _FakeAppBubbleService implements AppBubbleService {
  @override
  Future<bool> isBubbleRunning() async => false;

  @override
  Future<bool> isOverlayPermissionGranted() async => true;

  @override
  Future<void> openOverlayPermissionSettings() async {}

  @override
  Future<void> startBubble() async {}

  @override
  Future<void> stopBubble() async {}
}

JourneyController _buildJourneyController({
  required _FakeJourneyRepository journeyRepository,
  required _FakeRideRepository rideRepository,
  required _FakeAccessibilityService accessibilityService,
  required _FakeJourneyRealtimeBridge journeyRealtimeBridge,
  required _FakeAppBubbleService appBubbleService,
}) {
  return JourneyController(
    getActiveShift: GetActiveShiftUseCase(journeyRepository),
    getDailyStatistics: GetDailyStatisticsUseCase(journeyRepository),
    getShiftHistory: GetShiftHistoryUseCase(journeyRepository),
    createManualShift: CreateManualShiftUseCase(journeyRepository),
    deleteShiftUseCase: DeleteShiftUseCase(journeyRepository),
    getRidesUseCase: GetRidesUseCase(rideRepository),
    getCostsGainsSettings: null,
    shiftLifecycleCoordinator: ShiftLifecycleCoordinator(
      startShiftUseCase: StartShiftUseCase(journeyRepository),
      pauseShiftUseCase: PauseShiftUseCase(journeyRepository),
      resumeShiftUseCase: ResumeShiftUseCase(journeyRepository),
      finishShiftUseCase: FinishShiftUseCase(journeyRepository),
      ensureReadyForShiftStartUseCase: EnsureReadyForShiftStartUseCase(
        journeyRepository,
      ),
    ),
    runtimeCoordinator: JourneyRuntimeCoordinator(
      journeyRealtimeBridge: journeyRealtimeBridge,
      getLocationTrackingStatusUseCase: GetLocationTrackingStatusUseCase(
        journeyRepository,
      ),
      watchLocationTrackingStatusUseCase: WatchLocationTrackingStatusUseCase(
        journeyRepository,
      ),
      syncPendingJourneyUseCase: SyncPendingJourneyUseCase(journeyRepository),
      accessibilityService: accessibilityService,
      appBubbleService: appBubbleService,
    ),
  );
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
    final categoryRepository = _FakeCategoryRepository();
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
      loadCategoriesUseCase: LoadCategoriesUseCase(categoryRepository),
      createCategoryUseCase: CreateCategoryUseCase(categoryRepository),
      getTransactionsUseCase: GetTransactionsUseCase(transactionRepository),
      createInvoicePaymentUseCase: CreateInvoicePaymentUseCase(
        transactionRepository,
      ),
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

    controller.isLoading.value = true;
    await controller.loadDashboardData(silent: true);
    expect(controller.isLoading.value, isFalse);

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
    final notifier = DefaultDashboardRefreshNotifier();
    final controller = CreditCardsController(
      loadCreditCardsUseCase: LoadCreditCardsUseCase(repository),
      createCreditCardUseCase: CreateCreditCardUseCase(repository),
      updateCreditCardUseCase: UpdateCreditCardUseCase(repository),
      deactivateCreditCardUseCase: DeactivateCreditCardUseCase(repository),
      reactivateCreditCardUseCase: ReactivateCreditCardUseCase(repository),
      dashboardRefreshNotifier: notifier,
    );

    await controller.loadCreditCards();

    expect(controller.creditCards.length, 2);
    expect(controller.activeCards.length, 1);
    expect(controller.inactiveCards.length, 1);

    final before = notifier.refreshTick.value;
    await controller.updateCreditCard(
      id: 1,
      name: 'Visa',
      brand: 'visa',
      color: '#8B5CF6',
      limitCents: 500000,
      closingDay: 14,
      dueDay: 19,
      lastFourDigits: '1234',
    );
    expect(notifier.refreshTick.value, before + 1);
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
    'TransactionsController recarrega o mes ao navegar entre periodos',
    () async {
      final transactionRepository = _FakeTransactionRepository();
      final categoryRepository = _FakeCategoryRepository();
      final bankRepository = _FakeBankAccountRepository();
      final cardRepository = _FakeCreditCardRepository();
      final notifier = DefaultDashboardRefreshNotifier();
      final controller = TransactionsController(
        createTransactionUseCase: CreateTransactionUseCase(
          transactionRepository,
        ),
        updateTransactionUseCase: UpdateTransactionUseCase(
          transactionRepository,
        ),
        deleteTransactionUseCase: DeleteTransactionUseCase(
          transactionRepository,
        ),
        getTransactionsUseCase: GetTransactionsUseCase(transactionRepository),
        getCategoriesUseCase: GetCategoriesUseCase(categoryRepository),
        getBankAccountsUseCase: GetBankAccountsUseCase(bankRepository),
        getCreditCardsUseCase: GetCreditCardsUseCase(cardRepository),
        dashboardRefreshNotifier: notifier,
      );

      controller.selectedMonth.value = DateTime(2026, 3, 1);
      await controller.loadData();
      transactionRepository.requestedMonths.clear();

      await controller.goToPreviousMonth();
      expect(controller.selectedMonth.value, DateTime(2026, 2, 1));
      expect(transactionRepository.requestedMonths, [DateTime(2026, 2, 1)]);

      transactionRepository.requestedMonths.clear();

      await controller.goToNextMonth();
      expect(controller.selectedMonth.value, DateTime(2026, 3, 1));
      expect(transactionRepository.requestedMonths, [DateTime(2026, 3, 1)]);
    },
  );

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
      final appBubbleService = _FakeAppBubbleService();
      final controller = _buildJourneyController(
        journeyRepository: journeyRepository,
        rideRepository: rideRepository,
        accessibilityService: accessibilityService,
        journeyRealtimeBridge: journeyRealtimeBridge,
        appBubbleService: appBubbleService,
      );

      controller.onInit();
      await Future<void>.delayed(Duration.zero);
      await controller.toggleTrafficLight();

      expect(controller.isAccessibilityServiceEnabled, isTrue);
      expect(controller.isTrafficLightActive.value, isTrue);
      expect(accessibilityService.lastTrafficLightValue, isTrue);

      controller.onClose();
      await journeyRepository.dispose();
    },
  );

  test(
    'CreateManualShiftUseCase envia dados do turno manual ao repositorio',
    () async {
      final journeyRepository = _FakeJourneyRepository();
      final useCase = CreateManualShiftUseCase(journeyRepository);

      final result = await useCase(
        ManualShiftDraftEntity(
          totalDrivenKm: 124.5,
          startTime: DateTime(2026, 5, 12, 8),
          endTime: DateTime(2026, 5, 12, 16, 30),
        ),
      );

      expect(result.isRight(), isTrue);
      expect(journeyRepository.lastManualShift?.totalDrivenKm, 124.5);
      expect(
        journeyRepository.lastManualShift?.startTime,
        DateTime(2026, 5, 12, 8),
      );
      expect(
        journeyRepository.lastManualShift?.endTime,
        DateTime(2026, 5, 12, 16, 30),
      );

      await journeyRepository.dispose();
    },
  );

  test(
    'JourneyController atualiza Km Rodados com km local em blocos de 1 km',
    () async {
      final journeyRepository = _FakeJourneyRepository()
        ..activeShift = buildActiveShift().copyWith(currentDrivenKm: 0)
        ..trackingStatus = buildTrackingStatus(totalDistanceMeters: 0);
      final rideRepository = _FakeRideRepository();
      final accessibilityService = _FakeAccessibilityService();
      final journeyRealtimeBridge = _FakeJourneyRealtimeBridge();
      final appBubbleService = _FakeAppBubbleService();
      final controller = _buildJourneyController(
        journeyRepository: journeyRepository,
        rideRepository: rideRepository,
        accessibilityService: accessibilityService,
        journeyRealtimeBridge: journeyRealtimeBridge,
        appBubbleService: appBubbleService,
      );

      controller.onInit();
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      expect(controller.drivenKm.value, '10.0 km');

      journeyRepository.trackingController.add(
        buildTrackingStatus(isTrackingActive: true, totalDistanceMeters: 400),
      );
      await Future<void>.delayed(Duration.zero);
      expect(controller.drivenKm.value, '10.0 km');

      journeyRepository.trackingController.add(
        buildTrackingStatus(isTrackingActive: true, totalDistanceMeters: 1100),
      );
      await Future<void>.delayed(Duration.zero);
      expect(controller.drivenKm.value, '11.0 km');

      journeyRepository.trackingController.add(
        buildTrackingStatus(isTrackingActive: true, totalDistanceMeters: 1900),
      );
      await Future<void>.delayed(Duration.zero);
      expect(controller.drivenKm.value, '11.0 km');

      journeyRepository.trackingController.add(
        buildTrackingStatus(isTrackingActive: true, totalDistanceMeters: 2000),
      );
      await Future<void>.delayed(Duration.zero);
      expect(controller.drivenKm.value, '12.0 km');

      controller.onClose();
      await journeyRepository.dispose();
    },
  );

  test(
    'JourneyController atualiza Tempo Total e Velocidade Media com turno ativo local',
    () async {
      final now = DateTime.now();
      final journeyRepository = _FakeJourneyRepository()
        ..activeShift = buildActiveShift().copyWith(
          startTime: now.subtract(const Duration(hours: 2)),
          createdAt: now.subtract(const Duration(hours: 2)),
          currentDrivenKm: 0,
          idleTimeSeconds: 3600,
        )
        ..trackingStatus = buildTrackingStatus(
          isTrackingActive: true,
          totalDistanceMeters: 1100,
          idleTimeSeconds: 3600,
        );
      final rideRepository = _FakeRideRepository();
      final accessibilityService = _FakeAccessibilityService();
      final journeyRealtimeBridge = _FakeJourneyRealtimeBridge();
      final appBubbleService = _FakeAppBubbleService();
      final controller = _buildJourneyController(
        journeyRepository: journeyRepository,
        rideRepository: rideRepository,
        accessibilityService: accessibilityService,
        journeyRealtimeBridge: journeyRealtimeBridge,
        appBubbleService: appBubbleService,
      );

      controller.onInit();
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      expect(controller.totalTime.value, '02:00:00');
      expect(controller.drivenKm.value, '11.0 km');
      expect(controller.averageKmh.value, '5.5 km/h');

      journeyRepository.trackingController.add(
        buildTrackingStatus(
          isTrackingActive: true,
          totalDistanceMeters: 1900,
          idleTimeSeconds: 3600,
        ),
      );
      await Future<void>.delayed(Duration.zero);
      expect(controller.totalTime.value, '02:00:00');
      expect(controller.drivenKm.value, '11.0 km');
      expect(controller.averageKmh.value, '5.5 km/h');

      journeyRepository.trackingController.add(
        buildTrackingStatus(
          isTrackingActive: true,
          totalDistanceMeters: 2000,
          idleTimeSeconds: 3600,
        ),
      );
      await Future<void>.delayed(Duration.zero);
      expect(controller.totalTime.value, '02:00:00');
      expect(controller.drivenKm.value, '12.0 km');
      expect(controller.averageKmh.value, '6.0 km/h');

      controller.onClose();
      await journeyRepository.dispose();
    },
  );

  test(
    'JourneyController atualiza Tempo Total e Tempo Medio em blocos de 30s nas estatisticas',
    () async {
      final now = DateTime.now();
      final journeyRepository = _FakeJourneyRepository()
        ..activeShift = buildActiveShift().copyWith(
          startTime: now.subtract(const Duration(hours: 2)),
          createdAt: now.subtract(const Duration(hours: 2)),
          currentDrivenKm: 0,
          idleTimeSeconds: 3600,
          pausedAt: now,
        )
        ..trackingStatus = buildTrackingStatus(
          isTrackingActive: false,
          isPaused: true,
          totalDistanceMeters: 0,
          idleTimeSeconds: 3600,
        );
      final rideRepository = _FakeRideRepository();
      final accessibilityService = _FakeAccessibilityService();
      final journeyRealtimeBridge = _FakeJourneyRealtimeBridge();
      final appBubbleService = _FakeAppBubbleService();
      final controller = _buildJourneyController(
        journeyRepository: journeyRepository,
        rideRepository: rideRepository,
        accessibilityService: accessibilityService,
        journeyRealtimeBridge: journeyRealtimeBridge,
        appBubbleService: appBubbleService,
      );

      controller.onInit();
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      controller.totalShifts.value = '2';
      controller.elapsedSeconds.value = 89;
      await Future<void>.delayed(Duration.zero);

      expect(controller.totalTime.value, '01:01:00');
      expect(controller.averageTime.value, '00:30:30');

      controller.elapsedSeconds.value = 119;
      await Future<void>.delayed(Duration.zero);

      expect(controller.totalTime.value, '01:01:30');
      expect(controller.averageTime.value, '00:30:45');

      controller.onClose();
      await journeyRepository.dispose();
    },
  );

  test(
    'JourneyController expoe blocos de presentation para historico e corridas',
    () async {
      final journeyRepository = _FakeJourneyRepository();
      final rideRepository = _FakeRideRepository();
      final accessibilityService = _FakeAccessibilityService();
      final journeyRealtimeBridge = _FakeJourneyRealtimeBridge();
      final appBubbleService = _FakeAppBubbleService();
      final controller = _buildJourneyController(
        journeyRepository: journeyRepository,
        rideRepository: rideRepository,
        accessibilityService: accessibilityService,
        journeyRealtimeBridge: journeyRealtimeBridge,
        appBubbleService: appBubbleService,
      );

      controller.onInit();
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      final historyState = controller.historySectionState;
      final ridesState = controller.ridesSectionState;
      final summary = controller.operationalSummaryData;
      final paymentMethods = controller.paymentMethodsSectionState;

      expect(historyState.totalCount, 1);
      expect(historyState.loadedCount, 1);
      expect(ridesState.totalVisibleCount, 1);
      expect(ridesState.visibleCount, 1);
      expect(summary.totalRides, 1);
      expect(paymentMethods.totalFinishedRides, 1);

      controller.onClose();
      await journeyRepository.dispose();
    },
  );

  test(
    'JourneyController sincroniza pendencias na reconexao e preserva banner derivado',
    () async {
      final journeyRepository = _FakeJourneyRepository()
        ..shiftHistoryResult = Right(
          PagedResultEntity(
            items: [
              buildJourneyShiftVariant(index: 1, isPendingSync: true),
              buildJourneyShiftVariant(index: 2, isPendingSync: true),
            ],
            totalCount: 2,
            offset: 0,
            limit: 20,
          ),
        )
        ..syncPendingShiftsResult = const Right(0)
        ..trackingStatusResult = Right(buildTrackingStatus());
      final rideRepository = _FakeRideRepository();
      final accessibilityService = _FakeAccessibilityService();
      final journeyRealtimeBridge = _FakeJourneyRealtimeBridge();
      final appBubbleService = _FakeAppBubbleService();
      final controller = _buildJourneyController(
        journeyRepository: journeyRepository,
        rideRepository: rideRepository,
        accessibilityService: accessibilityService,
        journeyRealtimeBridge: journeyRealtimeBridge,
        appBubbleService: appBubbleService,
      );

      controller.onInit();
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      expect(controller.pendingShiftSyncCount.value, 2);
      expect(
        controller.bannerMessage,
        'Existem 2 turnos pendentes de sincronizacao com o servidor.',
      );

      journeyRealtimeBridge.isOnline.value = false;
      await Future<void>.delayed(Duration.zero);
      expect(
        controller.bannerMessage,
        'Voce esta offline. O turno continua funcionando no aparelho e sera sincronizado quando a internet voltar.',
      );

      journeyRepository.shiftHistoryResult = Right(
        PagedResultEntity(
          items: [buildJourneyShiftVariant(index: 3, isPendingSync: false)],
          totalCount: 1,
          offset: 0,
          limit: 20,
        ),
      );
      journeyRealtimeBridge.isOnline.value = true;
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      expect(controller.pendingShiftSyncCount.value, 0);
      expect(controller.bannerMessage, isNull);

      controller.onClose();
      await journeyRepository.dispose();
    },
  );

  test(
    'JourneyController expone banner de tracking e erro normalizado dos blocos de carga',
    () async {
      final journeyRepository = _FakeJourneyRepository()
        ..activeShift = buildActiveShift()
        ..activeShiftResult = Right(buildActiveShift())
        ..trackingStatus = buildJourneyTrackingIssue(
          issueMessage: 'Permita localizacao em segundo plano.',
        )
        ..trackingStatusResult = Right(
          buildJourneyTrackingIssue(
            issueMessage: 'Permita localizacao em segundo plano.',
          ),
        );
      final rideRepository = _FakeRideRepository();
      final accessibilityService = _FakeAccessibilityService();
      final journeyRealtimeBridge = _FakeJourneyRealtimeBridge();
      final appBubbleService = _FakeAppBubbleService();
      final controller = _buildJourneyController(
        journeyRepository: journeyRepository,
        rideRepository: rideRepository,
        accessibilityService: accessibilityService,
        journeyRealtimeBridge: journeyRealtimeBridge,
        appBubbleService: appBubbleService,
      );

      controller.onInit();
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      expect(controller.canOpenTrackingSettings, isTrue);
      expect(controller.bannerMessage, 'Permita localizacao em segundo plano.');

      journeyRepository.shiftHistoryResult = Left(
        ServerFailure('socketexception'),
      );
      await controller.refreshJourneyData(showErrors: false);
      await Future<void>.delayed(Duration.zero);

      expect(
        controller.historyError.value,
        'Nao foi possivel carregar o historico de turnos. Verifique sua conexao e tente novamente.',
      );
      expect(controller.bannerMessage, 'Permita localizacao em segundo plano.');

      controller.onClose();
      await journeyRepository.dispose();
    },
  );

  test(
    'JourneyController preserva filtros de corridas e metricas derivadas usadas na presentation',
    () async {
      final journeyRepository = _FakeJourneyRepository()
        ..statisticsResult = Right(
          buildJourneyStatisticsVariant(
            totalRides: 3,
            grossEarningsCents: 15000,
            totalCostsCents: 4500,
          ),
        );
      final rideRepository = _FakeRideRepository()
        ..ridesResult = Right(
          PagedResultEntity(
            items: [
              buildJourneyRideVariant(
                id: 1,
                status: 'FINISHED',
                paymentMethod: 'pix',
                grossValueCents: 5000,
              ),
              buildJourneyRideVariant(
                id: 2,
                status: 'FINISHED',
                paymentMethod: 'dinheiro',
                grossValueCents: 4500,
              ),
              buildJourneyRideVariant(
                id: 3,
                status: 'PENDING',
                paymentMethod: null,
                grossValueCents: 0,
              ),
            ],
            totalCount: 3,
            offset: 0,
            limit: 100,
          ),
        );
      final accessibilityService = _FakeAccessibilityService();
      final journeyRealtimeBridge = _FakeJourneyRealtimeBridge();
      final appBubbleService = _FakeAppBubbleService();
      final controller = _buildJourneyController(
        journeyRepository: journeyRepository,
        rideRepository: rideRepository,
        accessibilityService: accessibilityService,
        journeyRealtimeBridge: journeyRealtimeBridge,
        appBubbleService: appBubbleService,
      );

      controller.onInit();
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      final summary = controller.operationalSummaryData;
      final paymentMethods = controller.paymentMethodsSectionState;
      final initialRidesState = controller.ridesSectionState;

      expect(summary.grossEarningsCents, 15000);
      expect(summary.totalCostsCents, 4500);
      expect(summary.netEarningsCents, 10500);
      expect(summary.totalRides, 3);
      expect(paymentMethods.totalFinishedRides, 2);
      expect(paymentMethods.mappedCount, 2);
      expect(paymentMethods.hasUnmappedRides, isFalse);
      expect(
        initialRidesState.visibleRides.map((ride) => ride.id),
        orderedEquals([3, 2, 1]),
      );

      controller.changeRideStatusFilter('Pendentes');
      final ridesState = controller.ridesSectionState;
      expect(ridesState.selectedStatusFilter, 'Pendentes');
      expect(ridesState.totalVisibleCount, 1);
      expect(ridesState.visibleCount, 1);
      expect(ridesState.visibleRides.single.status, 'PENDING');

      controller.changeRideStatusFilter('Finalizados');
      final finishedRidesState = controller.ridesSectionState;
      expect(
        finishedRidesState.visibleRides.map((ride) => ride.id),
        orderedEquals([2, 1]),
      );

      controller.onClose();
      await journeyRepository.dispose();
    },
  );

  test(
    'JourneyController calcula analise por corrida com turnos ativo e finalizados',
    () async {
      final activeShift = buildActiveShift().copyWith(
        startTime: DateTime.now().subtract(const Duration(minutes: 30)),
        createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
        currentDrivenKm: 2,
        idleTimeSeconds: 0,
      );
      final journeyRepository = _FakeJourneyRepository()
        ..activeShift = activeShift
        ..activeShiftResult = Right(activeShift)
        ..statisticsResult = const Right(
          JourneyStatisticsEntity(
            totalShifts: 1,
            totalTime: '01:00:00',
            averageTime: '01:00:00',
            idleTime: '00:00:00',
            drivenKm: '10.0 km',
            totalDrivenKmValue: 10,
            averageKmh: '10.0 km/h',
            rideStats: RideStatisticsEntity(
              totalRides: 1,
              grossEarningsCents: 1373,
              netEarningsCents: 1373,
              totalCostsCents: 0,
              ridesTotalKm: 4,
              ridesTotalTime: 9 * 60,
            ),
          ),
        );
      final rideRepository = _FakeRideRepository();
      final accessibilityService = _FakeAccessibilityService();
      final journeyRealtimeBridge = _FakeJourneyRealtimeBridge();
      final appBubbleService = _FakeAppBubbleService();
      final controller = _buildJourneyController(
        journeyRepository: journeyRepository,
        rideRepository: rideRepository,
        accessibilityService: accessibilityService,
        journeyRealtimeBridge: journeyRealtimeBridge,
        appBubbleService: appBubbleService,
      );

      controller.onInit();
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);
      controller.elapsedSeconds.value = 30 * 60;
      controller.currentKm.value = 2;
      controller.costsGainsSettings.value = const CostsGainsSettingsEntity(
        userId: 1,
        desiredMonthlyProfitCents: 0,
        workDaysPerWeek: 6,
        workHoursPerDay: 8,
        kmPerDay: 0,
        financeOrRentMonthlyCents: 0,
        insuranceMonthlyCents: 0,
        maintenanceMonthlyCents: 0,
        annualTaxesCents: 0,
        fuelPricePerLiterCents: 580,
        kmPerLiter: 10,
        platformFeeType: PlatformFeeType.fixed,
        platformFeeValue: 500,
      );

      final analysis = controller.rideAnalysisData;

      expect(controller.isRideAnalysisAvailable, isTrue);
      expect(analysis.totalRides, 1);
      expect(analysis.totalTimeSeconds, 90 * 60);
      expect(analysis.totalKm, 12);
      expect(controller.rideAnalysisFuelCostsCents, 696);
      expect(controller.rideAnalysisPlatformFeeCents, 1925);
      expect(analysis.costsPerRide, closeTo(26.21, 0.01));
      expect(analysis.grossPerHour, closeTo(9.15, 0.01));
      expect(analysis.costsPerHour, closeTo(17.47, 0.01));
      expect(
        analysis.profitPerHour,
        closeTo(analysis.grossPerHour! - analysis.costsPerHour!, 0.01),
      );

      controller.onClose();
      await journeyRepository.dispose();
    },
  );

  test(
    'JourneyController mostra analise por corrida com turno finalizado sem ativo',
    () async {
      final controller = _buildJourneyController(
        journeyRepository: _FakeJourneyRepository(),
        rideRepository: _FakeRideRepository(),
        accessibilityService: _FakeAccessibilityService(),
        journeyRealtimeBridge: _FakeJourneyRealtimeBridge(),
        appBubbleService: _FakeAppBubbleService(),
      );

      controller.activeShift.value = null;
      controller.totalShifts.value = '1';
      controller.totalShiftDrivenKm.value = 10;
      controller.totalRides.value = 1;
      controller.grossEarningsCents.value = 5000;
      controller.costsGainsSettings.value = const CostsGainsSettingsEntity(
        userId: 1,
        desiredMonthlyProfitCents: 0,
        workDaysPerWeek: 6,
        workHoursPerDay: 8,
        kmPerDay: 0,
        financeOrRentMonthlyCents: 0,
        insuranceMonthlyCents: 0,
        maintenanceMonthlyCents: 0,
        annualTaxesCents: 0,
        fuelPricePerLiterCents: 580,
        kmPerLiter: 10,
        platformFeeType: PlatformFeeType.percentage,
        platformFeeValue: 10,
      );

      expect(controller.isRideAnalysisAvailable, isTrue);
      expect(controller.rideAnalysisTotalKm, 10);
      expect(controller.rideAnalysisFuelCostsCents, 580);
    },
  );
}
