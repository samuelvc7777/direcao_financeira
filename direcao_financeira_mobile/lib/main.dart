import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'app/core/theme/app_theme.dart';
import 'app/routes/app_pages.dart';
import 'app/core/bindings/core_binding.dart';

void main() async {
  await GetStorage.init();
  await initializeDateFormatting('pt_BR', null);
  
  final storage = GetStorage();
  final token = storage.read('token');
  final initialRoute = token != null ? AppRoutes.initial : AppRoutes.login;

  runApp(MyApp(initialRoute: initialRoute));
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Direção Financeira',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      initialBinding: CoreBinding(),
      initialRoute: initialRoute,
      getPages: AppPages.pages,
    );
  }
}
