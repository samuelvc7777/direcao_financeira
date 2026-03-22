import 'package:direcao_financeira_mobile/app/data/models/bank_account_model.dart';
import 'package:direcao_financeira_mobile/app/data/models/category_model.dart';
import 'package:direcao_financeira_mobile/app/data/models/credit_card_model.dart';
import 'package:direcao_financeira_mobile/app/data/models/plan_model.dart';
import 'package:direcao_financeira_mobile/app/data/models/subscription_model.dart';
import 'package:direcao_financeira_mobile/app/data/models/transaction_model.dart';
import 'package:direcao_financeira_mobile/app/data/models/user_model.dart';
import 'package:direcao_financeira_mobile/app/domain/entities/active_shift_entity.dart';
import 'package:direcao_financeira_mobile/app/domain/entities/bank_account_entity.dart';
import 'package:direcao_financeira_mobile/app/domain/entities/category_entity.dart';
import 'package:direcao_financeira_mobile/app/domain/entities/journey_statistics_entity.dart';
import 'package:direcao_financeira_mobile/app/domain/entities/location_tracking_status_entity.dart';
import 'package:direcao_financeira_mobile/app/domain/entities/ride_entity.dart';
import 'package:direcao_financeira_mobile/app/domain/entities/shift_entity.dart';
import 'package:direcao_financeira_mobile/app/domain/entities/store_product_entity.dart';
import 'package:direcao_financeira_mobile/app/domain/entities/transaction_entity.dart';

UserModel buildUser({
  int id = 1,
  String email = 'samuel@example.com',
  String name = 'Samuel',
}) {
  return UserModel(
    id: id,
    email: email,
    name: name,
    role: 'user',
    isActive: true,
  );
}

BankAccountModel buildBankAccount({
  int id = 1,
  String name = 'Carteira',
  bool isActive = true,
}) {
  return BankAccountModel(
    id: id,
    name: name,
    bankName: 'Nubank',
    color: '#06B6D4',
    accountType: AccountType.wallet,
    initialBalanceCents: 10000,
    currentBalanceCents: 15000,
    isActive: isActive,
  );
}

CategoryModel buildCategory({
  int id = 1,
  String name = 'Combustivel',
  CategoryType type = CategoryType.expense,
  bool isActive = true,
}) {
  final now = DateTime(2026, 1, 1);
  return CategoryModel(
    id: id,
    userId: 1,
    name: name,
    type: type,
    color: '#038C8C',
    icon: 'fuel',
    isActive: isActive,
    createdAt: now,
    updatedAt: now,
  );
}

CreditCardModel buildCreditCard({
  int id = 1,
  String name = 'Visa',
  bool isActive = true,
}) {
  return CreditCardModel(
    id: id,
    name: name,
    brand: 'visa',
    color: '#8B5CF6',
    limitCents: 500000,
    availableLimitCents: 350000,
    closingDay: 10,
    dueDay: 20,
    lastFourDigits: '1234',
    isActive: isActive,
  );
}

TransactionModel buildTransaction({
  int id = 1,
  TransactionType type = TransactionType.expense,
  DateTime? date,
}) {
  return TransactionModel(
    id: id,
    type: type,
    status: TransactionStatus.cleared,
    assetType: AssetType.bankAccount,
    amountCents: 2500,
    categoryId: 1,
    description: 'Posto Shell',
    transactionDate: date ?? DateTime(2026, 1, 10),
    bankAccountId: 1,
    categoryName: 'Combustivel',
  );
}

PlanModel buildPlan({int id = 1, String code = 'premium_monthly'}) {
  return PlanModel(
    id: id,
    code: code,
    name: 'Premium',
    description: 'Plano premium',
    priceCents: 2500,
    durationDays: 30,
    color: '#038C8C',
    isActive: true,
  );
}

SubscriptionModel buildSubscription({
  int id = 1,
  String status = 'ACTIVE',
  PlanModel? plan,
}) {
  return SubscriptionModel(
    id: id,
    status: status,
    autoRenew: true,
    startDate: DateTime(2026, 1, 1),
    endDate: DateTime(2026, 2, 1),
    plan: plan ?? buildPlan(),
  );
}

StoreProductEntity buildStoreProduct({String productId = 'premium_monthly'}) {
  return const StoreProductEntity(
    productId: 'premium_monthly',
    title: 'Premium',
    description: 'Plano premium',
    priceLabel: 'R\$ 25,00',
    rawPrice: 25,
    currencyCode: 'BRL',
  );
}

ActiveShiftEntity buildActiveShift() {
  return ActiveShiftEntity(
    id: 1,
    startTime: DateTime(2026, 1, 10, 8),
    createdAt: DateTime(2026, 1, 10, 8),
    currentDrivenKm: 12.5,
    idleTimeSeconds: 300,
  );
}

LocationTrackingStatusEntity buildTrackingStatus({
  bool isTrackingActive = false,
  bool isLocationServiceEnabled = true,
  bool hasForegroundPermission = true,
  bool hasBackgroundPermission = true,
  bool isPreciseLocation = true,
  bool isPaused = false,
}) {
  return LocationTrackingStatusEntity(
    isTrackingActive: isTrackingActive,
    isLocationServiceEnabled: isLocationServiceEnabled,
    hasForegroundPermission: hasForegroundPermission,
    hasBackgroundPermission: hasBackgroundPermission,
    isPreciseLocation: isPreciseLocation,
    isPaused: isPaused,
    totalDistanceMeters: 1000,
  );
}

JourneyStatisticsEntity buildJourneyStatistics() {
  return const JourneyStatisticsEntity(
    totalShifts: 1,
    totalTime: '01:00:00',
    averageTime: '01:00:00',
    idleTime: '00:10:00',
    drivenKm: '10.0 km',
    averageKmh: '20.0 km/h',
    rideStats: RideStatisticsEntity(
      totalRides: 1,
      grossEarningsCents: 5000,
      netEarningsCents: 4000,
      totalCostsCents: 1000,
      ridesTotalKm: 5,
      ridesTotalTime: 900,
    ),
  );
}

ShiftEntity buildShift() {
  return const ShiftEntity(
    index: 1,
    localId: 1,
    remoteShiftId: 10,
    date: '10/01/2026',
    startTime: '08:00',
    endTime: '09:00',
    duration: '01:00:00',
    hasRoute: true,
  );
}

RideEntity buildRide() {
  return const RideEntity(
    id: 1,
    status: 'FINISHED',
    appName: 'Uber',
    grossValueCents: 3200,
    date: '10/01/2026',
    time: '08:30',
    origin: 'Centro',
    passenger: 'Joao',
    durationMinutes: 20,
  );
}
