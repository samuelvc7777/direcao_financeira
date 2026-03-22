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
    final previewColor = widget.controller.colorFromHex(_selectedColor);

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.92,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: context.theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(34)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 54,
                      height: 5,
                      decoration: BoxDecoration(
                        color: context.theme.colorScheme.onSurface.withValues(
                          alpha: 0.12,
                        ),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _CardPreviewHeader(
                    title: widget.card == null
                        ? 'Novo cartao'
                        : 'Editar cartao',
                    subtitle:
                        'Uma experiencia mais forte, com preview imediato do plastico.',
                    previewColor: previewColor,
                    cardName: _nameController.text.isEmpty
                        ? 'Cartao premium'
                        : _nameController.text,
                    brand: _brandController.text.isEmpty
                        ? 'Bandeira'
                        : _brandController.text,
                    lastFourDigits: _lastFourController.text.isEmpty
                        ? '0000'
                        : _lastFourController.text,
                  ),
                  const SizedBox(height: 24),
                  CustomTextField(
                    controller: _nameController,
                    label: 'Nome no app',
                    hint: 'Ex.: Nubank Platinum',
                    icon: Icons.label_important_rounded,
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Informe o nome.' : null,
                    onChanged: (_) => setState(() {}),
                    textCapitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          controller: _brandController,
                          label: 'Bandeira',
                          hint: 'Visa, Mastercard',
                          icon: Icons.branding_watermark_rounded,
                          validator: (value) => value?.isEmpty ?? true
                              ? 'Informe a bandeira.'
                              : null,
                          onChanged: (_) => setState(() {}),
                          textCapitalization: TextCapitalization.words,
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
                              value?.length != 4 ? 'Use 4 digitos.' : null,
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
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
                        value?.isEmpty ?? true ? 'Informe o limite.' : null,
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          controller: _closingDayController,
                          label: 'Dia fechamento',
                          hint: '1-31',
                          icon: Icons.calendar_today_rounded,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            final day = int.tryParse(value ?? '');
                            return (day == null || day < 1 || day > 31)
                                ? 'Dia invalido.'
                                : null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CustomTextField(
                          controller: _dueDayController,
                          label: 'Dia vencimento',
                          hint: '1-31',
                          icon: Icons.event_available_rounded,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            final day = int.tryParse(value ?? '');
                            return (day == null || day < 1 || day > 31)
                                ? 'Dia invalido.'
                                : null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _SectionLabel(title: 'Assinatura visual'),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 58,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: widget.controller.colorOptions.length,
                      separatorBuilder: (_, index) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final colorHex = widget.controller.colorOptions[index];
                        final color = widget.controller.colorFromHex(colorHex);
                        final isSelected = _selectedColor == colorHex;

                        return GestureDetector(
                          onTap: () =>
                              setState(() => _selectedColor = colorHex),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            width: 54,
                            height: 54,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color.alphaBlend(
                                    Colors.white.withValues(alpha: 0.18),
                                    color,
                                  ),
                                  color,
                                ],
                              ),
                              border: Border.all(
                                color: isSelected
                                    ? context.theme.colorScheme.onSurface
                                    : Colors.transparent,
                                width: isSelected ? 2.5 : 0,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: color.withValues(
                                    alpha: isSelected ? 0.34 : 0.16,
                                  ),
                                  blurRadius: isSelected ? 16 : 10,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: isSelected
                                ? Icon(
                                    Icons.check_rounded,
                                    color: context.theme.colorScheme.surface,
                                  )
                                : null,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 32),
                  Obx(() {
                    final isLoading = widget.controller.isSubmitting.value;
                    if (widget.card == null) {
                      return CustomFilledButton(
                        text: 'SALVAR CARTAO',
                        icon: Icons.add_rounded,
                        isLoading: isLoading,
                        backgroundColor: previewColor,
                        onPressed: _handleSave,
                      );
                    }

                    return Row(
                      children: [
                        Expanded(
                          child: ScaleButton(
                            onTap: isLoading
                                ? () {}
                                : () => widget.controller.toggleCardStatus(
                                    widget.card!,
                                  ),
                            child: Container(
                              height: 58,
                              decoration: BoxDecoration(
                                color:
                                    (widget.card!.isActive
                                            ? AppColors.rose
                                            : previewColor)
                                        .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color:
                                      (widget.card!.isActive
                                              ? AppColors.rose
                                              : previewColor)
                                          .withValues(alpha: 0.28),
                                ),
                              ),
                              child: Icon(
                                widget.card!.isActive
                                    ? Icons.visibility_off_rounded
                                    : Icons.visibility_rounded,
                                color: widget.card!.isActive
                                    ? AppColors.rose
                                    : previewColor,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 3,
                          child: CustomFilledButton(
                            text: 'ATUALIZAR',
                            icon: Icons.check_rounded,
                            isLoading: isLoading,
                            backgroundColor: previewColor,
                            onPressed: _handleSave,
                          ),
                        ),
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

class _CardPreviewHeader extends StatelessWidget {
  const _CardPreviewHeader({
    required this.title,
    required this.subtitle,
    required this.previewColor,
    required this.cardName,
    required this.brand,
    required this.lastFourDigits,
  });

  final String title;
  final String subtitle;
  final Color previewColor;
  final String cardName;
  final String brand;
  final String lastFourDigits;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.alphaBlend(
              previewColor.withValues(alpha: 0.24),
              Colors.white,
            ),
            Color.alphaBlend(
              previewColor.withValues(alpha: 0.08),
              context.theme.colorScheme.surface,
            ),
          ],
        ),
        border: Border.all(color: previewColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: context.theme.colorScheme.onSurface,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              color: context.theme.colorScheme.onSurface.withValues(
                alpha: 0.58,
              ),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: previewColor,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: previewColor.withValues(alpha: 0.28),
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.credit_card_rounded,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      brand.toUpperCase(),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.86),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Text(
                  cardName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Final $lastFourDigits',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.74)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        color: context.theme.colorScheme.onSurface,
        fontWeight: FontWeight.w800,
        fontSize: 15,
      ),
    );
  }
}
