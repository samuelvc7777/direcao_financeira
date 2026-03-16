import 'plan_entity.dart';

class SubscriptionEntity {
  final int id;
  final String status;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? canceledAt;
  final bool autoRenew;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final PlanEntity? plan;

  SubscriptionEntity({
    required this.id,
    required this.status,
    this.startDate,
    this.endDate,
    this.canceledAt,
    required this.autoRenew,
    this.createdAt,
    this.updatedAt,
    this.plan,
  });
}
