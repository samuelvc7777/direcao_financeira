import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app/core/theme/app_scroll_behavior.dart';
import 'app/core/theme/app_theme.dart';
import 'app/routes/app_pages.dart';
import 'app/core/bindings/core_binding.dart';

void main() async {
  await GetStorage.init();
  await initializeDateFormatting('pt_BR', null);
  
  // Desativa o download de fontes em tempo de execução para garantir funcionamento offline
  GoogleFonts.config.allowRuntimeFetching = false;
  
  final storage = GetStorage();
  final token = storage.read('token');
  final initialRoute = token != null ? AppRoutes.initial : AppRoutes.login;
  
  final isDarkMode = storage.read<bool>('isDarkMode');
  final themeMode = isDarkMode == null ? ThemeMode.system : (isDarkMode ? ThemeMode.dark : ThemeMode.light);

  runApp(MyApp(initialRoute: initialRoute, themeMode: themeMode));
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  final ThemeMode themeMode;
  const MyApp({super.key, required this.initialRoute, required this.themeMode});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      scrollBehavior: const AppScrollBehavior(),
      title: 'Direção Financeira',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      initialBinding: CoreBinding(),
      initialRoute: initialRoute,
      getPages: AppPages.pages,
    );
  }
}
