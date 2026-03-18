import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';

import '../../domain/entities/subscription_entity.dart';
import '../models/plan_model.dart';
import '../models/subscription_model.dart';

abstract class ISubscriptionRemoteDataSource {
  Future<SubscriptionModel?> getMySubscription();
  Future<List<SubscriptionModel>> getSubscriptionHistory();
  Future<List<PlanModel>> getAvailablePlans();
  Future<SubscriptionModel?> changePlan(int planId);
  Future<SubscriptionModel?> cancelSubscription();
  Future<SubscriptionModel?> renewSubscription({required bool autoRenew});
}

abstract class ISubscriptionLocalDataSource {
  Future<void> syncStoredUser({
    SubscriptionEntity? activeSubscription,
    List<SubscriptionEntity>? subscriptions,
  });
}

class SubscriptionRemoteDataSource implements ISubscriptionRemoteDataSource {
  SubscriptionRemoteDataSource({required this.dio});

  final Dio dio;

  @override
  Future<SubscriptionModel?> getMySubscription() async {
    final response = await dio.get('/subscriptions/me');
    return _extractActiveSubscription(response.data);
  }

  @override
  Future<List<SubscriptionModel>> getSubscriptionHistory() async {
    final response = await dio.get('/subscriptions/me/history');
    final data = response.data;
    final rawList = data is List
        ? data
        : data is Map<String, dynamic>
            ? (data['subscriptions'] ?? data['history'] ?? data['data'] ?? [])
            : [];

    if (rawList is! List) {
      return [];
    }

    return rawList
        .whereType<Map<String, dynamic>>()
        .map(SubscriptionModel.fromJson)
        .toList();
  }

  @override
  Future<List<PlanModel>> getAvailablePlans() async {
    final response = await dio.get('/admin/plans');
    final data = response.data;
    final rawList = data is List
        ? data
        : data is Map<String, dynamic>
            ? (data['plans'] ?? data['data'] ?? [])
            : [];

    if (rawList is! List) {
      return [];
    }

    return rawList
        .whereType<Map<String, dynamic>>()
        .map(PlanModel.fromJson)
        .where((plan) => plan.isActive)
        .toList();
  }

  @override
  Future<SubscriptionModel?> changePlan(int planId) async {
    final response = await dio.post(
      '/subscriptions/me/change-plan',
      data: {'planId': planId},
    );
    return _extractActiveSubscription(response.data);
  }

  @override
  Future<SubscriptionModel?> cancelSubscription() async {
    final response = await dio.post('/subscriptions/me/cancel');
    return _extractActiveSubscription(response.data);
  }

  @override
  Future<SubscriptionModel?> renewSubscription({required bool autoRenew}) async {
    final response = await dio.post(
      '/subscriptions/me/renew',
      data: {'autoRenew': autoRenew},
    );
    return _extractActiveSubscription(response.data);
  }

  SubscriptionModel? _extractActiveSubscription(dynamic data) {
    if (data is Map<String, dynamic>) {
      if (data['activeSubscription'] is Map<String, dynamic>) {
        return SubscriptionModel.fromJson(
          data['activeSubscription'] as Map<String, dynamic>,
        );
      }
      if (data['subscription'] is Map<String, dynamic>) {
        return SubscriptionModel.fromJson(
          data['subscription'] as Map<String, dynamic>,
        );
      }
      if (data['data'] is Map<String, dynamic>) {
        return _extractActiveSubscription(data['data']);
      }
      if (data['id'] != null && data['status'] != null) {
        return SubscriptionModel.fromJson(data);
      }
    }

    return null;
  }
}

class SubscriptionLocalDataSource implements ISubscriptionLocalDataSource {
  SubscriptionLocalDataSource({required this.storage});

  final GetStorage storage;

  @override
  Future<void> syncStoredUser({
    SubscriptionEntity? activeSubscription,
    List<SubscriptionEntity>? subscriptions,
  }) async {
    final stored = storage.read('user');
    if (stored is! Map) {
      return;
    }

    final updated = Map<String, dynamic>.from(stored);
    if (activeSubscription != null || updated.containsKey('activeSubscription')) {
      updated['activeSubscription'] = activeSubscription == null
          ? null
          : _toSubscriptionJson(activeSubscription);
    }
    if (subscriptions != null) {
      updated['subscriptions'] = subscriptions
          .map(_toSubscriptionJson)
          .toList();
    }

    await storage.write('user', updated);
  }

  Map<String, dynamic> _toSubscriptionJson(SubscriptionEntity subscription) {
    if (subscription is SubscriptionModel) {
      return subscription.toJson();
    }

    return SubscriptionModel(
      id: subscription.id,
      status: subscription.status,
      startDate: subscription.startDate,
      endDate: subscription.endDate,
      canceledAt: subscription.canceledAt,
      autoRenew: subscription.autoRenew,
      createdAt: subscription.createdAt,
      updatedAt: subscription.updatedAt,
      plan: subscription.plan,
    ).toJson();
  }
}
