import 'package:get/get.dart';

class InitialController extends GetxController {
  // Controle da aba atual selecionada na Bottom Navigation
  var currentIndex = 0.obs;

  void changeTab(int index) {
    currentIndex.value = index;
  }
}
