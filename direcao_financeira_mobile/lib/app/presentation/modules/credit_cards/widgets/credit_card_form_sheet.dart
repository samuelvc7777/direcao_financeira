import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../domain/entities/credit_card_entity.dart';
import '../../../widgets/custom_filled_button.dart';
import '../../../widgets/custom_text_field.dart';
import '../../../widgets/scale_button.dart';
import '../credit_cards_controller.dart';

class CreditCardFormSheet extends StatefulWidget {
  const CreditCardFormSheet({super.key, this.card, required this.controller});

  final CreditCardEntity? card;
  final CreditCardsController controller;

  @override
  State<CreditCardFormSheet> createState() => _CreditCardFormSheetState();
}

class _CreditCardFormSheetState extends State<CreditCardFormSheet> {
  late final GlobalKey<FormState> _formKey;
  late final TextEditingController _nameController;
  late final TextEditingController _brandController;
  late final TextEditingController _limitController;
  late final TextEditingController _closingDayController;
  late final TextEditingController _dueDayController;
  late final TextEditingController _lastFourController;
  late String _selectedColor;

  bool get _isEditing => widget.card != null;

  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormState>();
    _nameController = TextEditingController(text: widget.card?.name ?? '');
    _brandController = TextEditingController(text: widget.card?.brand ?? '');
    _limitController = TextEditingController(
      text: widget.card == null
          ? ''
          : (widget.card!.limitCents / 100.0).toStringAsFixed(2),
    );
    _closingDayController = TextEditingController(
      text: widget.card?.closingDay.toString() ?? '',
    );
    _dueDayController = TextEditingController(
      text: widget.card?.dueDay.toString() ?? '',
    );
    _lastFourController = TextEditingController(
      text: widget.card?.lastFourDigits ?? '',
    );
    _selectedColor = widget.card?.color ?? widget.controller.colorOptions[5];
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
    final colorScheme = context.theme.colorScheme;
    final accentColor = widget.controller.colorFromHex(_selectedColor);

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 46,
                height: 5,
                decoration: BoxDecoration(
                  color: colorScheme.onSurface.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _CardHero(
                        accentColor: accentColor,
                        eyebrow: _isEditing ? 'EDITAR CARTAO' : 'NOVO CARTAO',
                        title: _nameController.text.trim().isEmpty
                            ? 'Seu cartao com outra presenca'
                            : _nameController.text.trim(),
                        subtitle: _brandController.text.trim().isEmpty
                            ? 'Crie um cadastro simples, elegante e com leitura imediata.'
                            : '${_brandController.text.trim()} • Final ${_lastFourController.text.trim().isEmpty ? '0000' : _lastFourController.text.trim()}',
                      ),
                      const SizedBox(height: 24),
                      Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _SectionCard(
                              title: 'Identidade',
                              subtitle:
                                  'As informacoes principais para reconhecer o cartao.',
                              child: Column(
                                children: [
                                  CustomTextField(
                                    controller: _nameController,
                                    label: 'Nome do cartao',
                                    hint: 'Ex.: Inter Black',
                                    icon: Icons.credit_card_rounded,
                                    validator: (value) =>
                                        value?.trim().isEmpty ?? true
                                        ? 'Informe o nome.'
                                        : null,
                                    onChanged: (_) => setState(() {}),
                                    textCapitalization:
                                        TextCapitalization.words,
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: CustomTextField(
                                          controller: _brandController,
                                          label: 'Bandeira',
                                          hint: 'Visa, Mastercard',
                                          icon:
                                              Icons.branding_watermark_rounded,
                                          validator: (value) =>
                                              value?.trim().isEmpty ?? true
                                              ? 'Informe a bandeira.'
                                              : null,
                                          onChanged: (_) => setState(() {}),
                                          textCapitalization:
                                              TextCapitalization.words,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: CustomTextField(
                                          controller: _lastFourController,
                                          label: 'Final',
                                          hint: '0000',
                                          icon: Icons.password_rounded,
                                          keyboardType: TextInputType.number,
                                          validator: (value) =>
                                              value?.trim().length != 4
                                              ? 'Use 4 digitos.'
                                              : null,
                                          onChanged: (_) => setState(() {}),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            _SectionCard(
                              title: 'Fatura',
                              subtitle:
                                  'Limite e calendario para acompanhar melhor o uso.',
                              child: Column(
                                children: [
                                  CustomTextField(
                                    controller: _limitController,
                                    label: 'Limite total',
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
                                    validator: (value) =>
                                        value?.trim().isEmpty ?? true
                                        ? 'Informe o limite.'
                                        : null,
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: CustomTextField(
                                          controller: _closingDayController,
                                          label: 'Fechamento',
                                          hint: '1-31',
                                          icon: Icons.calendar_today_rounded,
                                          keyboardType: TextInputType.number,
                                          validator: (value) {
                                            final day = int.tryParse(
                                              value ?? '',
                                            );
                                            return (day == null ||
                                                    day < 1 ||
                                                    day > 31)
                                                ? 'Dia invalido.'
                                                : null;
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: CustomTextField(
                                          controller: _dueDayController,
                                          label: 'Vencimento',
                                          hint: '1-31',
                                          icon: Icons.event_available_rounded,
                                          keyboardType: TextInputType.number,
                                          validator: (value) {
                                            final day = int.tryParse(
                                              value ?? '',
                                            );
                                            return (day == null ||
                                                    day < 1 ||
                                                    day > 31)
                                                ? 'Dia invalido.'
                                                : null;
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            _SectionCard(
                              title: 'Visual',
                              subtitle:
                                  'Escolha uma cor marcante para identificar esse cartao.',
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Cor',
                                    style: TextStyle(
                                      color: colorScheme.onSurface.withValues(
                                        alpha: 0.7,
                                      ),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Wrap(
                                    spacing: 12,
                                    runSpacing: 12,
                                    children: widget.controller.colorOptions
                                        .map((colorHex) {
                                          final color = widget.controller
                                              .colorFromHex(colorHex);
                                          final isSelected =
                                              _selectedColor == colorHex;

                                          return _ColorTile(
                                            color: color,
                                            isSelected: isSelected,
                                            onTap: () => setState(
                                              () => _selectedColor = colorHex,
                                            ),
                                          );
                                        })
                                        .toList(),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            Obx(() {
                              final isLoading =
                                  widget.controller.isSubmitting.value;

                              if (!_isEditing) {
                                return CustomFilledButton(
                                  text: 'CRIAR CARTAO',
                                  icon: Icons.check_rounded,
                                  isLoading: isLoading,
                                  backgroundColor: accentColor,
                                  onPressed: _handleSave,
                                );
                              }

                              return Row(
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: ScaleButton(
                                      onTap: isLoading
                                          ? () {}
                                          : () => widget.controller
                                                .toggleCardStatus(widget.card!),
                                      child: Container(
                                        height: 58,
                                        decoration: BoxDecoration(
                                          color:
                                              (widget.card!.isActive
                                                      ? AppColors.rose
                                                      : accentColor)
                                                  .withValues(alpha: 0.12),
                                          borderRadius: BorderRadius.circular(
                                            18,
                                          ),
                                          border: Border.all(
                                            color:
                                                (widget.card!.isActive
                                                        ? AppColors.rose
                                                        : accentColor)
                                                    .withValues(alpha: 0.28),
                                          ),
                                        ),
                                        child: Center(
                                          child: Icon(
                                            widget.card!.isActive
                                                ? Icons.visibility_off_rounded
                                                : Icons.visibility_rounded,
                                            color: widget.card!.isActive
                                                ? AppColors.rose
                                                : accentColor,
                                            size: 24,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    flex: 3,
                                    child: CustomFilledButton(
                                      text: 'SALVAR ALTERACOES',
                                      icon: Icons.check_rounded,
                                      isLoading: isLoading,
                                      backgroundColor: accentColor,
                                      onPressed: _handleSave,
                                    ),
                                  ),
                                ],
                              );
                            }),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final rawLimit = _limitController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final limitCents = int.tryParse(rawLimit) ?? 0;

    if (!_isEditing) {
      await widget.controller.createCreditCard(
        name: _nameController.text.trim(),
        brand: _brandController.text.trim(),
        color: _selectedColor,
        limitCents: limitCents,
        closingDay: int.parse(_closingDayController.text),
        dueDay: int.parse(_dueDayController.text),
        lastFourDigits: _lastFourController.text.trim(),
      );
      return;
    }

    await widget.controller.updateCreditCard(
      id: widget.card!.id,
      name: _nameController.text.trim(),
      brand: _brandController.text.trim(),
      color: _selectedColor,
      limitCents: limitCents,
      closingDay: int.parse(_closingDayController.text),
      dueDay: int.parse(_dueDayController.text),
      lastFourDigits: _lastFourController.text.trim(),
    );
  }
}

class _CardHero extends StatelessWidget {
  const _CardHero({
    required this.accentColor,
    required this.eyebrow,
    required this.title,
    required this.subtitle,
  });

  final Color accentColor;
  final String eyebrow;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accentColor.withValues(alpha: 0.18),
            accentColor.withValues(alpha: 0.05),
          ],
        ),
        border: Border.all(color: accentColor.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: colorScheme.surface.withValues(alpha: 0.68),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.credit_card_rounded,
              color: accentColor,
              size: 24,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            eyebrow,
            style: TextStyle(
              color: colorScheme.onSurface.withValues(alpha: 0.55),
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 24,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: TextStyle(
              color: colorScheme.onSurface.withValues(alpha: 0.62),
              fontSize: 14,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.onSurface.withValues(alpha: 0.035),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: colorScheme.onSurface.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              color: colorScheme.onSurface.withValues(alpha: 0.58),
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _ColorTile extends StatelessWidget {
  const _ColorTile({
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? context.theme.colorScheme.onSurface
                : Colors.transparent,
            width: isSelected ? 2.4 : 0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.36),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ]
              : [],
        ),
        child: isSelected
            ? Icon(
                Icons.check_rounded,
                color: context.theme.colorScheme.surface,
              )
            : null,
      ),
    );
  }
}
