import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../domain/entities/subscription_entity.dart';
import '../../../domain/entities/user_entity.dart';
import '../../../domain/repositories/i_auth_repository.dart';
import '../../../routes/app_pages.dart';

class SettingsController extends GetxController {
  SettingsController({required this.authRepository});

  final IAuthRepository authRepository;

  final isDarkModeEnabled = true.obs;
  final userName = 'Samuel Vitor'.obs;
  final userEmail = 'samuelvitorcarvalho717@gmail.com'.obs;
  final planName = 'Plano Anual'.obs;
  final planStatus = 'Ativo'.obs;
  final remainingDays = 361.obs;
  final planProgress = 0.99.obs;

  final sections = <SettingsSection>[
    SettingsSection(
      title: 'Financas',
      items: const [
        SettingsItemData(
          title: 'Contas Bancarias e Carteira',
          subtitle: 'Saldos, contas correntes e carteira',
          icon: Icons.account_balance_wallet_outlined,
          accentColor: Color(0xFF03A696),
        ),
        SettingsItemData(
          title: 'Cartoes de Credito',
          subtitle: 'Gestao de cartoes e faturas',
          icon: Icons.credit_card_rounded,
          accentColor: Color(0xFF3B82F6),
        ),
      ],
    ),
    SettingsSection(
      title: 'Categorias',
      items: const [
        SettingsItemData(
          title: 'Categorias',
          subtitle: 'Gerencie categorias de entrada e saida',
          icon: Icons.category_rounded,
          accentColor: Color(0xFF03A696),
          footnote: 'Financeiro',
        ),
      ],
    ),
    SettingsSection(
      title: 'Configuracoes de Trabalho (Semaforo)',
      items: const [
        SettingsItemData(
          title: 'Configurar custo e ganhos',
          subtitle: 'Combustivel, consumo, taxas e ganhos do app',
          icon: Icons.local_gas_station_rounded,
          accentColor: Color(0xFFF2B366),
        ),
        SettingsItemData(
          title: 'Configurar semaforo',
          subtitle: 'Posicao, cores, tamanhos e comportamento',
          icon: Icons.grid_view_rounded,
          accentColor: Color(0xFF038C8C),
        ),
      ],
    ),
    SettingsSection(
      title: 'Jornada e Metas',
      items: const [
        SettingsItemData(
          title: 'Horarios de Trabalho',
          subtitle: 'Defina sua jornada semanal',
          icon: Icons.schedule_rounded,
          accentColor: Color(0xFF03A696),
        ),
        SettingsItemData(
          title: 'Configurar Metas',
          subtitle: 'Metas pessoais e de faturamento',
          icon: Icons.emoji_events_outlined,
          accentColor: Color(0xFFF2B366),
          footnote: '1 ativa',
        ),
      ],
    ),
  ].obs;

  @override
  void onInit() {
    super.onInit();
    _loadUser();
  }

  void _loadUser() {
    final UserEntity? user = authRepository.getStoredUser();
    if (user == null) {
      return;
    }

    userName.value = user.name;
    userEmail.value = user.email;
    _loadSubscription(user.activeSubscription);
  }

  void _loadSubscription(SubscriptionEntity? subscription) {
    if (subscription == null) {
      planName.value = 'Sem plano ativo';
      planStatus.value = 'Inativo';
      remainingDays.value = 0;
      planProgress.value = 0;
      return;
    }

    final plan = subscription.plan;
    planName.value = plan?.name ?? 'Plano atual';
    planStatus.value = _formatStatus(subscription.status);

    final now = DateTime.now();
    final endDate = subscription.endDate;
    final startDate = subscription.startDate;
    final durationDays = plan?.durationDays ?? 0;

    if (endDate != null) {
      final normalizedNow = DateTime(now.year, now.month, now.day);
      final normalizedEnd = DateTime(endDate.year, endDate.month, endDate.day);
      final days = normalizedEnd.difference(normalizedNow).inDays;
      remainingDays.value = days < 0 ? 0 : days;
    } else {
      remainingDays.value = durationDays;
    }

    if (startDate != null && endDate != null && endDate.isAfter(startDate)) {
      final total = endDate.difference(startDate).inSeconds;
      final elapsed = now.isAfter(startDate)
          ? now.difference(startDate).inSeconds
          : 0;
      final ratio = total <= 0 ? 0.0 : elapsed / total;
      planProgress.value = ratio.clamp(0.0, 1.0);
      return;
    }

    if (durationDays > 0 && remainingDays.value > 0) {
      final consumedRatio = 1 - (remainingDays.value / durationDays);
      planProgress.value = consumedRatio.clamp(0.0, 1.0);
      return;
    }

    planProgress.value = subscription.status.toUpperCase() == 'ACTIVE'
        ? 1.0
        : 0.0;
  }

  void toggleTheme(bool value) {
    isDarkModeEnabled.value = value;
    _showInfo(
      'Tema escuro',
      'A troca real de tema sera ligada nas proximas iteracoes.',
    );
  }

  void openSubscription() => Get.toNamed(AppRoutes.subscription);

  void openSettingItem(SettingsItemData item) {
    if (item.title == 'Categorias') {
      Get.toNamed(AppRoutes.categories);
      return;
    }

    openPlaceholder(item.title);
  }

  void openPlaceholder(String title) {
    _showInfo(
      title,
      'Essa configuracao ainda esta em modo demonstracao nesta entrega.',
    );
  }

  Future<void> logout() async {
    await authRepository.logout();
    Get.offAllNamed(AppRoutes.login);
  }

  void _showInfo(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 2),
    );
  }

  String _formatStatus(String status) {
    switch (status.toUpperCase()) {
      case 'ACTIVE':
        return 'Ativo';
      case 'CANCELED':
        return 'Cancelado';
      case 'EXPIRED':
        return 'Expirado';
      case 'PENDING':
        return 'Pendente';
      case 'TRIAL':
        return 'Teste';
      default:
        return status;
    }
  }
}

class SettingsSection {
  const SettingsSection({required this.title, required this.items});

  final String title;
  final List<SettingsItemData> items;
}

class SettingsItemData {
  const SettingsItemData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    this.footnote,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final String? footnote;
}
