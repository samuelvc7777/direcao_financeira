import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get_storage/get_storage.dart';

import '../../domain/entities/plan_entity.dart';
import '../../domain/entities/subscription_entity.dart';
import '../../domain/repositories/i_subscription_repository.dart';
import '../models/plan_model.dart';
import '../models/subscription_model.dart';

class SubscriptionRepository implements ISubscriptionRepository {
  final Dio dio;
  final GetStorage storage;

  SubscriptionRepository({required this.dio, required this.storage});

  @override
  Future<SubscriptionEntity?> getMySubscription() async {
    try {
      final response = await dio.get('/subscriptions/me');
      debugPrint('[SubscriptionRepository] GET /subscriptions/me -> ${response.data}');
      return _extractActiveSubscription(response.data);
    } on DioException catch (e) {
      debugPrint(
        '[SubscriptionRepository] GET /subscriptions/me ERROR -> status=${e.response?.statusCode} data=${e.response?.data}',
      );
      throw Exception(_extractMessage(e, 'Erro ao carregar assinatura.'));
    }
  }

  @override
  Future<List<SubscriptionEntity>> getSubscriptionHistory() async {
    try {
      final response = await dio.get('/subscriptions/me/history');
      debugPrint('[SubscriptionRepository] GET /subscriptions/me/history -> ${response.data}');
      final data = response.data;
      final rawList = data is List
          ? data
          : data is Map<String, dynamic>
              ? (data['subscriptions'] ?? data['history'] ?? data['data'] ?? [])
              : [];

      return rawList is List
          ? rawList
              .whereType<Map<String, dynamic>>()
              .map(SubscriptionModel.fromJson)
              .toList()
          : [];
    } on DioException catch (e) {
      debugPrint(
        '[SubscriptionRepository] GET /subscriptions/me/history ERROR -> status=${e.response?.statusCode} data=${e.response?.data}',
      );
      throw Exception(_extractMessage(e, 'Erro ao carregar historico.'));
    }
  }

  @override
  Future<List<PlanEntity>> getAvailablePlans() async {
    try {
      final response = await dio.get('/admin/plans');
      debugPrint('[SubscriptionRepository] GET /admin/plans -> ${response.data}');
      final data = response.data;
      final rawList = data is List
          ? data
          : data is Map<String, dynamic>
              ? (data['plans'] ?? data['data'] ?? [])
              : [];

      return rawList is List
          ? rawList
              .whereType<Map<String, dynamic>>()
              .map(PlanModel.fromJson)
              .where((plan) => plan.isActive)
              .toList()
          : [];
    } on DioException catch (e) {
      debugPrint(
        '[SubscriptionRepository] GET /admin/plans ERROR -> status=${e.response?.statusCode} data=${e.response?.data}',
      );
      if (e.response?.statusCode == 404) {
        return [];
      }
      throw Exception(_extractMessage(e, 'Erro ao carregar planos.'));
    }
  }

  @override
  Future<SubscriptionEntity?> changePlan(int planId) async {
    try {
      final response = await dio.post(
        '/subscriptions/me/change-plan',
        data: {'planId': planId},
      );
      return _extractActiveSubscription(response.data);
    } on DioException catch (e) {
      throw Exception(_extractMessage(e, 'Erro ao trocar o plano.'));
    }
  }

  @override
  Future<SubscriptionEntity?> cancelSubscription() async {
    try {
      final response = await dio.post('/subscriptions/me/cancel');
      return _extractActiveSubscription(response.data);
    } on DioException catch (e) {
      throw Exception(_extractMessage(e, 'Erro ao cancelar assinatura.'));
    }
  }

  @override
  Future<SubscriptionEntity?> renewSubscription({required bool autoRenew}) async {
    try {
      final response = await dio.post(
        '/subscriptions/me/renew',
        data: {'autoRenew': autoRenew},
      );
      return _extractActiveSubscription(response.data);
    } on DioException catch (e) {
      throw Exception(_extractMessage(e, 'Erro ao renovar assinatura.'));
    }
  }

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
      updated['activeSubscription'] = activeSubscription is SubscriptionModel
          ? activeSubscription.toJson()
          : activeSubscription == null
              ? null
              : SubscriptionModel(
                  id: activeSubscription.id,
                  status: activeSubscription.status,
                  startDate: activeSubscription.startDate,
                  endDate: activeSubscription.endDate,
                  canceledAt: activeSubscription.canceledAt,
                  autoRenew: activeSubscription.autoRenew,
                  createdAt: activeSubscription.createdAt,
                  updatedAt: activeSubscription.updatedAt,
                  plan: activeSubscription.plan,
                ).toJson();
    }
    if (subscriptions != null) {
      updated['subscriptions'] = subscriptions
          .map(
            (subscription) => subscription is SubscriptionModel
                ? subscription.toJson()
                : SubscriptionModel(
                    id: subscription.id,
                    status: subscription.status,
                    startDate: subscription.startDate,
                    endDate: subscription.endDate,
                    canceledAt: subscription.canceledAt,
                    autoRenew: subscription.autoRenew,
                    createdAt: subscription.createdAt,
                    updatedAt: subscription.updatedAt,
                    plan: subscription.plan,
                  ).toJson(),
          )
          .toList();
    }

    await storage.write('user', updated);
  }

  SubscriptionEntity? _extractActiveSubscription(dynamic data) {
    if (data is Map<String, dynamic>) {
      if (data['activeSubscription'] is Map<String, dynamic>) {
        return SubscriptionModel.fromJson(data['activeSubscription']);
      }
      if (data['subscription'] is Map<String, dynamic>) {
        return SubscriptionModel.fromJson(data['subscription']);
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

  String _extractMessage(DioException error, String fallback) {
    final data = error.response?.data;
    if (data is Map<String, dynamic>) {
      final message = data['message'];
      if (message is List && message.isNotEmpty) {
        return message.first.toString();
      }
      if (message != null) {
        return message.toString();
      }
    }
    return fallback;
  }
}
