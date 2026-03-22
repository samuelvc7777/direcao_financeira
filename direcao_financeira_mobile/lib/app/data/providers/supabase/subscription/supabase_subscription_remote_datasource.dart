import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../datasources/subscription_datasource.dart';
import '../../../models/plan_model.dart';
import '../../../models/subscription_model.dart';
import '../shared/supabase_table_names.dart';
import '../shared/supabase_user_scope.dart';

class SupabaseSubscriptionRemoteDataSource
    implements ISubscriptionRemoteDataSource {
  SupabaseSubscriptionRemoteDataSource({required this.client})
    : userScope = SupabaseUserScope(client: client);

  final SupabaseClient client;
  final SupabaseUserScope userScope;

  @override
  Future<SubscriptionModel?> getMySubscription() async {
    final userId = await userScope.getCurrentUserId();
    return userScope.getActiveSubscription(userId);
  }

  @override
  Future<List<SubscriptionModel>> getSubscriptionHistory() async {
    final userId = await userScope.getCurrentUserId();
    return userScope.getSubscriptionHistory(userId);
  }

  @override
  Future<List<PlanModel>> getAvailablePlans() async {
    final rows = await client
        .from(SupabaseTableNames.plans)
        .select()
        .eq('isActive', true)
        .order('priceCents');

    return (rows as List)
        .map((row) => PlanModel.fromJson(Map<String, dynamic>.from(row as Map)))
        .toList();
  }

  @override
  Future<SubscriptionModel?> changePlan(int planId) async {
    final userId = await userScope.getCurrentUserId();
    final planRow = await client
        .from(SupabaseTableNames.plans)
        .select()
        .eq('id', planId)
        .single();
    final plan = PlanModel.fromJson(Map<String, dynamic>.from(planRow));

    final active = await userScope.getActiveSubscription(userId);
    if (active != null) {
      await client
          .from(SupabaseTableNames.subscriptions)
          .update({
            'status': 'CANCELED',
            'canceledAt': DateTime.now().toUtc().toIso8601String(),
            'autoRenew': false,
          })
          .eq('id', active.id);
    }

    final inserted = await client
        .from(SupabaseTableNames.subscriptions)
        .insert({
          'userId': userId,
          'planId': plan.id,
          'status': 'ACTIVE',
          'startDate': DateTime.now().toUtc().toIso8601String(),
          'endDate': DateTime.now()
              .add(Duration(days: plan.durationDays))
              .toUtc()
              .toIso8601String(),
          'autoRenew': false,
        })
        .select()
        .single();

    return SubscriptionModel.fromJson({
      ...Map<String, dynamic>.from(inserted),
      'plan': plan.toJson(),
    });
  }

  @override
  Future<SubscriptionModel?> cancelSubscription() async {
    final active = await getMySubscription();
    if (active == null) {
      return null;
    }

    final updated = await client
        .from(SupabaseTableNames.subscriptions)
        .update({
          'status': 'CANCELED',
          'canceledAt': DateTime.now().toUtc().toIso8601String(),
          'autoRenew': false,
        })
        .eq('id', active.id)
        .select()
        .single();

    return SubscriptionModel.fromJson({
      ...Map<String, dynamic>.from(updated),
      if (active.plan != null)
        'plan': {
          'id': active.plan!.id,
          'code': active.plan!.code,
          'name': active.plan!.name,
          'description': active.plan!.description,
          'priceCents': active.plan!.priceCents,
          'durationDays': active.plan!.durationDays,
          'color': active.plan!.color,
          'isActive': active.plan!.isActive,
          'createdAt': active.plan!.createdAt?.toIso8601String(),
          'updatedAt': active.plan!.updatedAt?.toIso8601String(),
        },
    });
  }

  @override
  Future<SubscriptionModel?> renewSubscription({
    required bool autoRenew,
  }) async {
    final active = await getMySubscription();
    if (active == null) {
      return null;
    }

    final updated = await client
        .from(SupabaseTableNames.subscriptions)
        .update({'autoRenew': autoRenew})
        .eq('id', active.id)
        .select()
        .single();

    return SubscriptionModel.fromJson({
      ...Map<String, dynamic>.from(updated),
      if (active.plan != null)
        'plan': {
          'id': active.plan!.id,
          'code': active.plan!.code,
          'name': active.plan!.name,
          'description': active.plan!.description,
          'priceCents': active.plan!.priceCents,
          'durationDays': active.plan!.durationDays,
          'color': active.plan!.color,
          'isActive': active.plan!.isActive,
          'createdAt': active.plan!.createdAt?.toIso8601String(),
          'updatedAt': active.plan!.updatedAt?.toIso8601String(),
        },
    });
  }
}
