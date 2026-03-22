import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../datasources/credit_card_datasource.dart';
import '../../../models/credit_card_model.dart';
import '../shared/supabase_table_names.dart';
import '../shared/supabase_user_scope.dart';

class SupabaseCreditCardRemoteDataSource implements ICreditCardDataSource {
  SupabaseCreditCardRemoteDataSource({required this.client})
    : userScope = SupabaseUserScope(client: client);

  final SupabaseClient client;
  final SupabaseUserScope userScope;

  @override
  Future<List<CreditCardModel>> getCreditCards() async {
    final userId = await userScope.getCurrentUserId();
    final rawCards = await client
        .from(SupabaseTableNames.creditCards)
        .select()
        .eq('userId', userId)
        .order('createdAt');
    final rawTransactions = await client
        .from(SupabaseTableNames.transactions)
        .select('creditCardId,type,amountCents')
        .eq('userId', userId);

    final usedByCard = <int, int>{};
    for (final transaction in rawTransactions as List) {
      final row = Map<String, dynamic>.from(transaction as Map);
      final cardId = row['creditCardId'] as int?;
      if (cardId == null) {
        continue;
      }

      final amount = row['amountCents'] as int? ?? 0;
      final type = row['type']?.toString().toUpperCase() ?? 'EXPENSE';
      final signal = type == 'INCOME' ? -1 : 1;
      usedByCard.update(
        cardId,
        (current) => current + (amount * signal),
        ifAbsent: () => amount * signal,
      );
    }

    return (rawCards as List).map((card) {
      final row = Map<String, dynamic>.from(card as Map);
      final cardId = row['id'] as int;
      final limit = row['limitCents'] as int? ?? 0;
      final used = usedByCard[cardId] ?? 0;
      final available = (limit - used).clamp(0, limit).toInt();

      return CreditCardModel.fromJson({
        ...row,
        'availableLimitCents': available,
      });
    }).toList();
  }

  @override
  Future<CreditCardModel> createCreditCard({
    required String name,
    required String brand,
    required String color,
    required int limitCents,
    required int closingDay,
    required int dueDay,
    required String lastFourDigits,
  }) async {
    final userId = await userScope.getCurrentUserId();
    final now = DateTime.now().toUtc().toIso8601String();
    final inserted = await client
        .from(SupabaseTableNames.creditCards)
        .insert({
          'userId': userId,
          'name': name,
          'brand': brand,
          'color': color,
          'limitCents': limitCents,
          'availableLimitCents': limitCents,
          'closingDay': closingDay,
          'dueDay': dueDay,
          'lastFourDigits': lastFourDigits,
          'isActive': true,
          'updatedAt': now,
        })
        .select()
        .single();

    return CreditCardModel.fromJson(Map<String, dynamic>.from(inserted));
  }

  @override
  Future<CreditCardModel> updateCreditCard({
    required int id,
    required String name,
    required String brand,
    required String color,
    required int limitCents,
    required int closingDay,
    required int dueDay,
    required String lastFourDigits,
    bool? isActive,
  }) async {
    final current = await client
        .from(SupabaseTableNames.creditCards)
        .select()
        .eq('id', id)
        .single();
    final currentRow = Map<String, dynamic>.from(current);
    final previousLimit = currentRow['limitCents'] as int? ?? 0;
    final previousAvailable = currentRow['availableLimitCents'] as int? ?? 0;
    final used = previousLimit - previousAvailable;
    final payload = <String, dynamic>{
      'name': name,
      'brand': brand,
      'color': color,
      'limitCents': limitCents,
      'availableLimitCents': (limitCents - used).clamp(0, limitCents).toInt(),
      'closingDay': closingDay,
      'dueDay': dueDay,
      'lastFourDigits': lastFourDigits,
      'updatedAt': DateTime.now().toUtc().toIso8601String(),
    };
    if (isActive != null) {
      payload['isActive'] = isActive;
    }

    final updated = await client
        .from(SupabaseTableNames.creditCards)
        .update(payload)
        .eq('id', id)
        .select()
        .single();

    return CreditCardModel.fromJson(Map<String, dynamic>.from(updated));
  }

  @override
  Future<void> deactivateCreditCard(int id) async {
    await client
        .from(SupabaseTableNames.creditCards)
        .update({
          'isActive': false,
          'updatedAt': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', id);
  }

  @override
  Future<void> reactivateCreditCard(int id) async {
    await client
        .from(SupabaseTableNames.creditCards)
        .update({
          'isActive': true,
          'updatedAt': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', id);
  }
}
