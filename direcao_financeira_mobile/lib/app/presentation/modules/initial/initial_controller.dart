import 'package:get/get.dart';

import '../home/home_binding.dart';
import '../journey/journey_binding.dart';
import '../settings/settings_binding.dart';
import '../transactions/transactions_binding.dart';

class InitialController extends GetxController {
  // Controle da aba atual selecionada na Bottom Navigation
  var currentIndex = 0.obs;
  final visitedIndexes = <int>{0}.obs;

  @override
  void onInit() {
    super.onInit();
    _ensureTabDependencies(0);
  }

  void changeTab(int index) {
    if (!visitedIndexes.contains(index)) {
      visitedIndexes.add(index);
    }
    _ensureTabDependencies(index);
    currentIndex.value = index;
  }

  bool isTabLoaded(int index) => visitedIndexes.contains(index);

  void _ensureTabDependencies(int index) {
    switch (index) {
      case 0:
        HomeBinding().dependencies();
        break;
      case 1:
        TransactionsBinding().dependencies();
        break;
      case 2:
        JourneyBinding().dependencies();
        break;
      case 3:
        SettingsBinding().dependencies();
        break;
    }
  }
}
