---
description: Animações Flutter Mobile - Padrão Sênior de mercado para micro-interações e animações premium em apps Flutter
---

# Animações Flutter Mobile - Padrão Sênior

Este workflow define os padrões profissionais de animação para apps Flutter. Toda animação deve ter **propósito**, **performance** e **duração curta**.

## Regras de Ouro

1. **Duração entre 200ms e 400ms** — acima disso o app parece lento.
2. **Sempre use `Curves`** — nunca animação linear (de robô). Prefira `Curves.easeOutQuad` ou `Curves.easeInOut`.
3. **Toda animação tem um propósito** — guiar o olhar, confirmar uma ação ou dar feedback.
4. **Performance primeiro** — use widgets de animação implícita sempre que possível.
5. **Respeite acessibilidade** — cheque `MediaQuery.disableAnimations` antes de animar.

---

## Nível 1: Animações Implícitas (O Básico Sênior)

Widgets que animam sozinhos quando um valor muda. Sem controllers, sem complexidade.

### AnimatedContainer (Cor, Tamanho, Borda)
```dart
AnimatedContainer(
  duration: const Duration(milliseconds: 300),
  curve: Curves.easeInOut,
  decoration: BoxDecoration(
    color: isActive ? Colors.blue : Colors.grey,
    borderRadius: BorderRadius.circular(isActive ? 16 : 8),
  ),
  padding: EdgeInsets.all(isActive ? 20 : 12),
  child: child,
)
```

### AnimatedOpacity (Aparecer/Sumir)
```dart
AnimatedOpacity(
  duration: const Duration(milliseconds: 300),
  opacity: isVisible ? 1.0 : 0.0,
  child: widget,
)
```

### AnimatedDefaultTextStyle (Estilo de Texto)
```dart
AnimatedDefaultTextStyle(
  duration: const Duration(milliseconds: 300),
  style: TextStyle(
    fontSize: isSelected ? 20 : 16,
    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
    color: isDone ? Colors.grey : Colors.black,
    decoration: isDone ? TextDecoration.lineThrough : null,
  ),
  child: Text(texto),
)
```

### AnimatedAlign (Mover Posição)
```dart
AnimatedAlign(
  duration: const Duration(milliseconds: 300),
  alignment: isExpanded ? Alignment.centerLeft : Alignment.center,
  child: widget,
)
```

### AnimatedSwitcher (Trocar Widget com Transição)
```dart
AnimatedSwitcher(
  duration: const Duration(milliseconds: 300),
  transitionBuilder: (child, animation) => FadeTransition(
    opacity: animation,
    child: child,
  ),
  child: isLoading
      ? const CircularProgressIndicator(key: ValueKey('loading'))
      : const Icon(Icons.check, key: ValueKey('done')),
)
```

---

## Nível 2: Animações de Lista (UX Fluida)

### Entrada Escalonada (Itens aparecem um após o outro)
```dart
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300 + (index * 50)),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutQuad,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: ItemWidget(item: items[index]),
    );
  },
)
```

### AnimatedList (Inserir/Remover com Animação)
```dart
// No Controller
final listKey = GlobalKey<AnimatedListState>();

void addItem(Item item) {
  items.add(item);
  listKey.currentState?.insertItem(items.length - 1);
}

void removeItem(int index) {
  final removed = items.removeAt(index);
  listKey.currentState?.removeItem(index, (context, animation) {
    return SizeTransition(
      sizeFactor: animation,
      child: ItemWidget(item: removed),
    );
  });
}

// Na Page
AnimatedList(
  key: controller.listKey,
  initialItemCount: controller.items.length,
  itemBuilder: (context, index, animation) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutQuad,
      )),
      child: ItemWidget(item: controller.items[index]),
    );
  },
)
```

---

## Nível 3: Micro-interações (Feedback Premium)

### Feedback Tátil (Haptic)
```dart
import 'package:flutter/services.dart';

// Ao clicar em item normal
HapticFeedback.lightImpact();

// Ao completar uma tarefa
HapticFeedback.mediumImpact();

// Ao deletar
HapticFeedback.heavyImpact();

// Ao selecionar (mais sutil que light)
HapticFeedback.selectionClick();
```

### Botão com Escala ao Pressionar (Scale Down)
```dart
class ScaleButton extends StatefulWidget {
  final VoidCallback onTap;
  final Widget child;
  const ScaleButton({super.key, required this.onTap, required this.child});

  @override
  State<ScaleButton> createState() => _ScaleButtonState();
}

class _ScaleButtonState extends State<ScaleButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeInOut,
        child: widget.child,
      ),
    );
  }
}
```

### InkWell + Ripple Effect (Efeito de Ondulação)
```dart
Material(
  color: Colors.transparent,
  child: InkWell(
    borderRadius: BorderRadius.circular(12),
    splashColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
    highlightColor: Theme.of(context).colorScheme.primary.withOpacity(0.05),
    onTap: () {
      HapticFeedback.lightImpact();
      // ação
    },
    child: widget,
  ),
)
```

---

## Nível 4: Transições de Página

### Slide de Página (Direita para Esquerda)
```dart
GetPage(
  name: '/detalhes',
  page: () => DetalhesPage(),
  transition: Transition.rightToLeft,
  transitionDuration: const Duration(milliseconds: 300),
)
```

### Transição Customizada com Hero
```dart
// Na lista
Hero(
  tag: 'item-${item.id}',
  child: Card(child: Text(item.title)),
)

// Na página de detalhe
Hero(
  tag: 'item-${item.id}',
  child: Material(child: Text(item.title, style: TextStyle(fontSize: 24))),
)
```

---

## Nível 5: Animações Externas (Lottie e Rive)

### Lottie (JSON animado — padrão de mercado)
```yaml
dependencies:
  lottie: ^3.3.1
```

```dart
// Empty State com animação
Lottie.asset(
  'assets/animations/empty_list.json',
  width: Responsive.sp(context, 200),
  height: Responsive.sp(context, 200),
  repeat: true,
)
```

### Rive (Animações interativas avançadas)
```yaml
dependencies:
  rive: ^0.14.0
```

```dart
RiveAnimation.asset(
  'assets/animations/check.riv',
  onInit: (artboard) {
    final controller = StateMachineController.fromArtboard(artboard, 'State Machine');
    artboard.addController(controller!);
  },
)
```

---

## Nível 6: Respeitar Acessibilidade

Alguns usuários desativam animações no dispositivo. Um app profissional respeita isso:

```dart
Widget buildAnimatedWidget(BuildContext context) {
  final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context);

  if (reduceMotion) {
    return child; // Entrega o widget sem animação
  }

  return AnimatedContainer(
    duration: const Duration(milliseconds: 300),
    // ... animação normal
    child: child,
  );
}
```

---

## Tabela de Referência Rápida

| Situação | Widget/Técnica | Duração |
|---|---|---|
| Cor/tamanho muda | `AnimatedContainer` | 300ms |
| Texto muda estilo | `AnimatedDefaultTextStyle` | 300ms |
| Widget aparece/some | `AnimatedOpacity` | 300ms |
| Trocar widget na tela | `AnimatedSwitcher` | 300ms |
| Item entra na lista | `TweenAnimationBuilder` | 300-500ms |
| Item é deletado | `AnimatedList.removeItem` | 300ms |
| Clique em botão | `AnimatedScale` (0.95) | 100ms |
| Toque no celular | `HapticFeedback` | instantâneo |
| Transição de página | `GetPage.transition` | 300ms |
| Widget compartilhado entre páginas | `Hero` | automático |
| Ilustração animada | `Lottie` | loop |
| Empty state animado | `Lottie` | loop |

## Checklist de Validação

- [ ] Nenhuma animação dura mais que 500ms
- [ ] Todas as animações usam `Curves` (nunca linear)
- [ ] Botões têm feedback tátil (`HapticFeedback`)
- [ ] Lista vazia tem animação ou ilustração
- [ ] Itens da lista aparecem com animação suave
- [ ] Transições de página são fluidas (não corte seco)
- [ ] Acessibilidade é respeitada (reduce motion)
- [ ] Cores do tema são usadas nos splashColor/highlightColor
