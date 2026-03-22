import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../widgets/custom_app_bar.dart';
import '../../widgets/portfolio_shared_widgets.dart';
import 'credit_cards_controller.dart';
import 'widgets/credit_card_form_sheet.dart';
import 'widgets/credit_cards_content.dart';

class CreditCardsView extends GetView<CreditCardsController> {
  const CreditCardsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: 'Meus Cartoes',
        subtitle: 'Limite, ritmo de uso e faturas com outra presenca visual',
        leadingIcon: Icons.credit_card_rounded,
        actions: [
          IconButton(
            onPressed: () => _showCardForm(),
            icon: const Icon(Icons.add_rounded, color: Colors.white),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCardForm(),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Novo Cartao'),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final error = controller.errorMessage.value;
        if (error != null) {
          return PortfolioErrorState(
            title: 'Erro ao carregar cartoes',
            message: error,
            accentColor: controller.colorFromHex(controller.colorOptions[5]),
            onRetry: controller.loadCreditCards,
          );
        }

        return RefreshIndicator(
          onRefresh: controller.loadCreditCards,
          child: CreditCardsContent(
            activeCards: controller.activeCards,
            inactiveCards: controller.inactiveCards,
            onCreatePressed: _showCardForm,
            onCardPressed: (card) => _showCardForm(cardId: card.id),
          ),
        );
      }),
    );
  }

  void _showCardForm({int? cardId}) {
    final card = cardId == null
        ? null
        : controller.creditCards.firstWhereOrNull((item) => item.id == cardId);

    Get.bottomSheet(
      CreditCardFormSheet(card: card, controller: controller),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }
}
