import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/credit_card_entity.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_filled_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/scale_button.dart';
import 'credit_cards_controller.dart';

class CreditCardsView extends GetView<CreditCardsController> {
  const CreditCardsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: 'Meus Cartoes',
        subtitle: 'Gestao de limites e faturas',
        leadingIcon: Icons.credit_card_rounded,
        actions: [
          IconButton(
            onPressed: () => _showCardForm(context),
            icon: const Icon(Icons.add_rounded, color: Colors.white),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCardForm(context),
        backgroundColor: AppColors.violet,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Novo Cartao'),
      ),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: context.theme.scaffoldBackgroundColor,
        ),
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.violet),
            );
          }

          final error = controller.errorMessage.value;
          if (error != null) {
            return _ErrorState(
              message: error,
              onRetry: controller.loadCreditCards,
            );
          }

          if (controller.creditCards.isEmpty) {
            return _EmptyState(onCreate: () => _showCardForm(context));
          }

          return RefreshIndicator(
            color: AppColors.violet,
            onRefresh: controller.loadCreditCards,
            child: ListView(
              physics: const ClampingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
              children: [
                _SummaryCard(cards: controller.activeCards),
                const SizedBox(height: 24),
                if (controller.activeCards.isNotEmpty) ...[
                  const _SectionHeader(title: 'ATIVOS'),
                  const SizedBox(height: 12),
                  ...controller.activeCards.map((card) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _CreditCardTile(
                          card: card,
                          onTap: () => _showCardForm(context, card: card),
                        ),
                      )),
                ],
                if (controller.inactiveCards.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  const _SectionHeader(title: 'INATIVOS'),
                  const SizedBox(height: 12),
                  ...controller.inactiveCards.map((card) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _CreditCardTile(
                          card: card,
                          onTap: () => _showCardForm(context, card: card),
                        ),
                      )),
                ],
              ],
            ),
          );
        }),
      ),
    );
  }

  void _showCardForm(BuildContext context, {CreditCardEntity? card}) {
    Get.bottomSheet(
      _CreditCardFormSheet(card: card, controller: controller),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }
}

class _CreditCardTile extends StatelessWidget {
  const _CreditCardTile({required this.card, required this.onTap});

  final CreditCardEntity card;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.simpleCurrency(locale: 'pt_BR');
    final isActive = card.isActive;

    return Opacity(
      opacity: isActive ? 1.0 : 0.5,
      child: ScaleButton(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                context.theme.colorScheme.surface.withValues(alpha: 0.96),
                context.theme.scaffoldBackgroundColor.withValues(alpha: 0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: context.theme.colorScheme.onSurface.withValues(alpha: 0.08)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: context.theme.colorScheme.onSurface.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(Icons.credit_card_rounded, color: context.theme.colorScheme.onSurface.withValues(alpha: 0.7), size: 22),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            card.name,
                            style: TextStyle(
                              color: context.theme.colorScheme.onSurface,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            'Final ${card.lastFourDigits}',
                            style: TextStyle(
                              color: context.theme.colorScheme.onSurface.withValues(alpha: 0.4),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Text(
                    card.brand.toUpperCase(),
                    style: TextStyle(
                      color: context.theme.colorScheme.onSurface.withValues(alpha: 0.54),
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Limite Disponivel',
                        style: TextStyle(
                          color: context.theme.colorScheme.onSurface.withValues(alpha: 0.4),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        currencyFormat.format(card.availableLimit),
                        style: const TextStyle(
                          color: AppColors.violet,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Limite Total',
                        style: TextStyle(
                          color: context.theme.colorScheme.onSurface.withValues(alpha: 0.4),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        currencyFormat.format(card.limit),
                        style: TextStyle(
                          color: context.theme.colorScheme.onSurface,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: card.usedPercentage,
                  backgroundColor: context.theme.colorScheme.onSurface.withValues(alpha: 0.05),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    card.usedPercentage > 0.9 ? AppColors.rose : AppColors.violet,
                  ),
                  minHeight: 6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CreditCardFormSheet extends StatefulWidget {
  const _CreditCardFormSheet({this.card, required this.controller});
  final CreditCardEntity? card;
  final CreditCardsController controller;

  @override
  State<_CreditCardFormSheet> createState() => _CreditCardFormSheetState();
}

class _CreditCardFormSheetState extends State<_CreditCardFormSheet> {
  late final GlobalKey<FormState> _formKey;
  late final TextEditingController _nameController;
  late final TextEditingController _brandController;
  late final TextEditingController _limitController;
  late final TextEditingController _closingDayController;
  late final TextEditingController _dueDayController;
  late final TextEditingController _lastFourController;

  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormState>();
    _nameController = TextEditingController(text: widget.card?.name ?? '');
    _brandController = TextEditingController(text: widget.card?.brand ?? '');
    _limitController = TextEditingController(text: widget.card != null ? (widget.card!.limitCents / 100.0).toStringAsFixed(2) : '');
    _closingDayController = TextEditingController(text: widget.card?.closingDay.toString() ?? '');
    _dueDayController = TextEditingController(text: widget.card?.dueDay.toString() ?? '');
    _lastFourController = TextEditingController(text: widget.card?.lastFourDigits ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _limitController.dispose();
    _closingDayController.dispose();
    _dueDayController.dispose();
    _lastFourController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
      child: Container(
        decoration: BoxDecoration(
          color: context.theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(child: Container(width: 48, height: 5, decoration: BoxDecoration(color: context.theme.colorScheme.onSurface.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(99)))),
                  const SizedBox(height: 24),
                  Text(widget.card == null ? 'Novo Cartao' : 'Editar Cartao', style: TextStyle(color: context.theme.colorScheme.onSurface, fontSize: 26, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 24),
                  CustomTextField(controller: _nameController, label: 'Nome no App', hint: 'Ex.: Nubank Platinum', icon: Icons.label_important_rounded, validator: (v) => v?.isEmpty ?? true ? 'Informe o nome.' : null),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(child: CustomTextField(controller: _brandController, label: 'Bandeira', hint: 'Visa, Master...', icon: Icons.branding_watermark_rounded, validator: (v) => v?.isEmpty ?? true ? 'Informe.' : null)),
                      const SizedBox(width: 12),
                      Expanded(child: CustomTextField(controller: _lastFourController, label: 'Final (4 digitos)', hint: '0000', icon: Icons.password_rounded, keyboardType: TextInputType.number, validator: (v) => v?.length != 4 ? '4 digitos.' : null)),
                    ],
                  ),
                  const SizedBox(height: 18),
                  CustomTextField(
                    controller: _limitController,
                    label: 'Limite Total',
                    hint: 'R\$ 0,00',
                    icon: Icons.attach_money_rounded,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.right,
                    inputFormatters: [
                      CurrencyTextInputFormatter.currency(
                        locale: 'pt_BR',
                        symbol: 'R\$',
                      ),
                    ],
                    validator: (v) {
                      if (v?.isEmpty ?? true) return 'Informe o limite.';
                      return null;
                    },
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(child: CustomTextField(controller: _closingDayController, label: 'Dia Fechamento', hint: '1-31', icon: Icons.calendar_today_rounded, keyboardType: TextInputType.number, validator: (v) {
                        final d = int.tryParse(v ?? '');
                        return (d == null || d < 1 || d > 31) ? 'Invalido' : null;
                      })),
                      const SizedBox(width: 12),
                      Expanded(child: CustomTextField(controller: _dueDayController, label: 'Dia Vencimento', hint: '1-31', icon: Icons.event_available_rounded, keyboardType: TextInputType.number, validator: (v) {
                        final d = int.tryParse(v ?? '');
                        return (d == null || d < 1 || d > 31) ? 'Invalido' : null;
                      })),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Obx(() {
                    final isLoading = widget.controller.isSubmitting.value;
                    if (widget.card == null) return CustomFilledButton(text: 'SALVAR CARTAO', icon: Icons.add_rounded, isLoading: isLoading, onPressed: _handleSave);
                    return Row(
                      children: [
                        Expanded(flex: 1, child: ScaleButton(onTap: isLoading ? () {} : () => widget.controller.toggleCardStatus(widget.card!), child: Container(height: 58, decoration: BoxDecoration(color: (widget.card!.isActive ? AppColors.rose : AppColors.violet).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16), border: Border.all(color: (widget.card!.isActive ? AppColors.rose : AppColors.violet).withValues(alpha: 0.25))), child: Center(child: Icon(widget.card!.isActive ? Icons.visibility_off_rounded : Icons.visibility_rounded, color: widget.card!.isActive ? AppColors.rose : AppColors.violet, size: 26))))),
                        const SizedBox(width: 12),
                        Expanded(flex: 3, child: CustomFilledButton(text: 'ATUALIZAR', icon: Icons.check_rounded, isLoading: isLoading, onPressed: _handleSave)),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    
    final rawLimit = _limitController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final limitCents = int.tryParse(rawLimit) ?? 0;

    if (widget.card == null) {
      await widget.controller.createCreditCard(name: _nameController.text.trim(), brand: _brandController.text.trim(), limitCents: limitCents, closingDay: int.parse(_closingDayController.text), dueDay: int.parse(_dueDayController.text), lastFourDigits: _lastFourController.text);
    } else {
      await widget.controller.updateCreditCard(id: widget.card!.id, name: _nameController.text.trim(), brand: _brandController.text.trim(), limitCents: limitCents, closingDay: int.parse(_closingDayController.text), dueDay: int.parse(_dueDayController.text), lastFourDigits: _lastFourController.text);
    }
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.cards});
  final List<CreditCardEntity> cards;

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.simpleCurrency(locale: 'pt_BR');
    final totalUsed = cards.fold(0.0, (sum, card) => sum + card.usedLimit);
    final totalLimit = cards.fold(0.0, (sum, card) => sum + card.limit);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppColors.violet.withValues(alpha: 0.15), context.theme.colorScheme.surface]), borderRadius: BorderRadius.circular(32), border: Border.all(color: context.theme.colorScheme.onSurface.withValues(alpha: 0.08))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Comprometimento Total', style: TextStyle(color: context.theme.colorScheme.onSurface.withValues(alpha: 0.5), fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(currencyFormat.format(totalUsed), style: TextStyle(color: context.theme.colorScheme.onSurface, fontSize: 30, fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          Text('de ${currencyFormat.format(totalLimit)} em limites', style: TextStyle(color: context.theme.colorScheme.onSurface.withValues(alpha: 0.3), fontSize: 13)),
          const SizedBox(height: 20),
          Row(
            children: [
              _MiniStat(label: 'Cartoes', value: cards.length.toString()),
              const SizedBox(width: 32),
              _MiniStat(label: 'Disponivel', value: currencyFormat.format(totalLimit - totalUsed), color: AppColors.violet),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value, this.color});
  final String label;
  final String value;
  final Color? color;
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label.toUpperCase(), style: TextStyle(color: context.theme.colorScheme.onSurface.withValues(alpha: 0.3), fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.2)), const SizedBox(height: 4), Text(value, style: TextStyle(color: color ?? context.theme.colorScheme.onSurface, fontSize: 15, fontWeight: FontWeight.w800))]);
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;
  @override
  Widget build(BuildContext context) {
    return Text(title, style: TextStyle(color: context.theme.colorScheme.onSurface.withValues(alpha: 0.3), fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.5));
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});
  final String message;
  final Future<void> Function() onRetry;
  @override
  Widget build(BuildContext context) {
    return Center(child: Padding(padding: const EdgeInsets.all(32), child: Column(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.error_outline_rounded, color: AppColors.amber, size: 48), const SizedBox(height: 16), Text('Erro ao carregar cartoes', style: TextStyle(color: context.theme.colorScheme.onSurface, fontSize: 18, fontWeight: FontWeight.bold)), const SizedBox(height: 8), Text(message, style: TextStyle(color: context.theme.colorScheme.onSurface.withValues(alpha: 0.6)), textAlign: TextAlign.center), const SizedBox(height: 24), CustomFilledButton(text: 'TENTAR NOVAMENTE', onPressed: onRetry)])));
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onCreate});
  final VoidCallback onCreate;
  @override
  Widget build(BuildContext context) {
    return Center(child: Padding(padding: const EdgeInsets.all(32), child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.credit_card_off_rounded, color: context.theme.colorScheme.onSurface.withValues(alpha: 0.1), size: 80), const SizedBox(height: 24), Text('Nenhum cartao cadastrado', style: TextStyle(color: context.theme.colorScheme.onSurface, fontSize: 20, fontWeight: FontWeight.w800)), const SizedBox(height: 12), Text('Cadastre seus cartoes de credito para gerenciar limites, faturas e datas de vencimento.', style: TextStyle(color: context.theme.colorScheme.onSurface.withValues(alpha: 0.6), height: 1.5), textAlign: TextAlign.center), const SizedBox(height: 32), CustomFilledButton(text: 'CADASTRAR MEU PRIMEIRO CARTAO', onPressed: onCreate)])));
  }
}
