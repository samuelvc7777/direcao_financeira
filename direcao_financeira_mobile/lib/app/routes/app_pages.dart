import 'package:get/get.dart';
import '../presentation/modules/login/login_view.dart';
import '../presentation/modules/login/login_binding.dart';
import '../presentation/modules/home/home_view.dart';
import '../presentation/modules/home/home_binding.dart';
import '../presentation/modules/register/register_view.dart';
import '../presentation/modules/register/register_binding.dart';
import '../presentation/modules/initial/initial_view.dart';
import '../presentation/modules/initial/initial_binding.dart';
import '../presentation/modules/settings/settings_binding.dart';
import '../presentation/modules/settings/settings_view.dart';
import '../presentation/modules/subscription/subscription_binding.dart';
import '../presentation/modules/subscription/subscription_view.dart';
import '../presentation/modules/categories/categories_binding.dart';
import '../presentation/modules/categories/categories_view.dart';

class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String dashboard = '/dashboard';
  static const String initial = '/initial';
  static const String settings = '/settings';
  static const String subscription = '/subscription';
  static const String categories = '/categories';
}

class AppPages {
  static final pages = [
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: AppRoutes.register,
      page: () => const RegisterView(),
      binding: RegisterBinding(),
    ),
    GetPage(
      name: AppRoutes.dashboard,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: AppRoutes.initial,
      page: () => const InitialView(),
      binding: InitialBinding(),
    ),
    GetPage(
      name: AppRoutes.settings,
      page: () => const SettingsView(),
      binding: SettingsBinding(),
    ),
    GetPage(
      name: AppRoutes.subscription,
      page: () => const SubscriptionView(),
      binding: SubscriptionBinding(),
    ),
    GetPage(
      name: AppRoutes.categories,
      page: () => const CategoriesView(),
      binding: CategoriesBinding(),
    ),
  ];
}
