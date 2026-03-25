import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/app_bubble/app_bubble_service.dart';
import '../../../core/feedback/app_snackbar.dart';
import '../../../core/preferences/app_preferences.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/subscription_entity.dart';
import '../../../domain/usecases/auth_session_use_cases.dart';
import '../costs_gains_settings/costs_gains_flow_coordinator.dart';
import '../../../routes/app_pages.dart';

class SettingsController extends GetxController with WidgetsBindingObserver {
  SettingsController({
    required this.appBubbleService,
    required this.preferences,
    required this.getStoredUserUseCase,
    required this.logoutUseCase,
  });

  static const _appBubbleEnabledKey = 'appBubbleEnabled';

  final AppBubbleService appBubbleService;
  final AppPreferences preferences;
  final GetStoredUserUseCase getStoredUserUseCase;
  final LogoutUseCase logoutUseCase;
  var _pendingAppBubbleActivation = false;

  late final RxBool isDarkModeEnabled =
      (preferences.readBool('isDarkMode') ?? Get.isPlatformDarkMode).obs;
  late final RxBool isAppBubbleEnabled =
      (preferences.readBool(_appBubbleEnabledKey) ?? false).obs;
  final isAppBubblePermissionGranted = false.obs;
  final isAppBubbleBusy = false.obs;
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
          accentColor: AppColors.electricCyan,
        ),
        SettingsItemData(
          title: 'Cartoes de Credito',
          subtitle: 'Gestao de cartoes e faturas',
          icon: Icons.credit_card_rounded,
          accentColor: AppColors.violet,
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
          accentColor: AppColors.emerald,
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
          accentColor: AppColors.amber,
        ),
        SettingsItemData(
          title: 'Configurar semaforo',
          subtitle: 'Posicao, cores, tamanhos e comportamento',
          icon: Icons.grid_view_rounded,
          accentColor: AppColors.royalBlue,
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
          accentColor: AppColors.lime,
        ),
        SettingsItemData(
          title: 'Configurar Metas',
          subtitle: 'Metas pessoais e de faturamento',
          icon: Icons.emoji_events_outlined,
          accentColor: AppColors.rose,
          footnote: '1 ativa',
        ),
      ],
    ),
  ].obs;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _loadUser();
    _loadAppBubbleState();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      refreshAppBubblePermission();
    }
  }

  Future<void> _loadAppBubbleState() async {
    isAppBubblePermissionGranted.value = await appBubbleService
        .isOverlayPermissionGranted();
    final isBubbleRunning = await appBubbleService.isBubbleRunning();

    if (isAppBubbleEnabled.value &&
        isAppBubblePermissionGranted.value &&
        !isBubbleRunning) {
      try {
        await appBubbleService.startBubble();
      } catch (_) {
        isAppBubbleEnabled.value = false;
        await preferences.writeBool(_appBubbleEnabledKey, false);
      }
      return;
    }

    if (!isAppBubbleEnabled.value && isBubbleRunning) {
      await appBubbleService.stopBubble();
    }
  }

  void _loadUser() {
    final result = getStoredUserUseCase();
    result.fold(
      (failure) => debugPrint(
        '[SettingsController] Erro ao carregar usuario: ${failure.message}',
      ),
      (user) {
        if (user == null) return;
        userName.value = user.name;
        userEmail.value = user.email;
        _loadSubscription(user.activeSubscription);
      },
    );
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
    Get.changeThemeMode(value ? ThemeMode.dark : ThemeMode.light);
    preferences.writeBool('isDarkMode', value);
  }

  void openSubscription() => Get.toNamed(AppRoutes.subscription);

  Future<void> toggleAppBubble(bool value) async {
    if (isAppBubbleBusy.value) return;

    isAppBubbleBusy.value = true;
    try {
      if (!value) {
        _pendingAppBubbleActivation = false;
        await appBubbleService.stopBubble();
        isAppBubbleEnabled.value = false;
        await preferences.writeBool(_appBubbleEnabledKey, false);
        _showInfo('Balão flutuante', 'O balão foi desativado com sucesso.');
        return;
      }

      final hasPermission = await appBubbleService.isOverlayPermissionGranted();
      isAppBubblePermissionGranted.value = hasPermission;

      if (!hasPermission) {
        _pendingAppBubbleActivation = true;
        await appBubbleService.openOverlayPermissionSettings();
        _showInfo(
          'Permissão necessária',
          'Libere a permissão de sobreposição para exibir o balão sobre outros apps.',
        );
        return;
      }

      await appBubbleService.startBubble();
      _pendingAppBubbleActivation = false;
      isAppBubbleEnabled.value = true;
      await preferences.writeBool(_appBubbleEnabledKey, true);
      _showInfo(
        'Balão flutuante',
        'O balão da Direção Financeira já está ativo.',
      );
    } catch (_) {
      _showInfo(
        'Não foi possível ativar',
        'Falhou ao iniciar o balão flutuante neste momento.',
      );
    } finally {
      isAppBubbleBusy.value = false;
    }
  }

  Future<void> refreshAppBubblePermission() async {
    isAppBubblePermissionGranted.value = await appBubbleService
        .isOverlayPermissionGranted();

    if (_pendingAppBubbleActivation && isAppBubblePermissionGranted.value) {
      try {
        await appBubbleService.startBubble();
        isAppBubbleEnabled.value = true;
        await preferences.writeBool(_appBubbleEnabledKey, true);
      } catch (_) {
        isAppBubbleEnabled.value = false;
        await preferences.writeBool(_appBubbleEnabledKey, false);
      } finally {
        _pendingAppBubbleActivation = false;
      }
      return;
    }

    if (isAppBubbleEnabled.value && !isAppBubblePermissionGranted.value) {
      isAppBubbleEnabled.value = false;
      await preferences.writeBool(_appBubbleEnabledKey, false);
    }
  }

  Future<void> openAppBubblePermissionSettings() async {
    await appBubbleService.openOverlayPermissionSettings();
  }

  void openSettingItem(SettingsItemData item) {
    if (item.title == 'Categorias') {
      Get.toNamed(AppRoutes.categories);
      return;
    }

    if (item.title == 'Contas Bancarias e Carteira') {
      Get.toNamed(AppRoutes.bankAccounts);
      return;
    }

    if (item.title == 'Cartoes de Credito') {
      Get.toNamed(AppRoutes.creditCards);
      return;
    }

    if (item.title == 'Configurar semaforo') {
      Get.toNamed(AppRoutes.trafficLightSettings);
      return;
    }

    if (item.title == 'Configurar custo e ganhos') {
      CostsGainsFlowCoordinator.openEntry();
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
    await logoutUseCase();
    Get.offAllNamed(AppRoutes.login);
  }

  void _showInfo(String title, String message) {
    AppSnackbar.show(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
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
