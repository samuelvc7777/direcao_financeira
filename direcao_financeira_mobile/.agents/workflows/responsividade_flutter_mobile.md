---
description: Responsividade Flutter Mobile - Padrão Sênior de mercado para interfaces responsivas em apps Flutter
---

# Responsividade Flutter Mobile

Este workflow define o padrão profissional para criar interfaces responsivas em qualquer app Flutter. Todos os valores visuais (fontes, paddings, margens, ícones) devem ser **proporcionais ao tamanho da tela**, nunca fixos em pixels.

## Regra de Ouro

> **"Nunca use valores fixos em pixels. Use proporções e limites."**

---

## Passo a Passo

### 1. Criar a Classe Responsive

Crie o arquivo: `lib/core/utils/responsive.dart`

```dart
import 'package:flutter/material.dart';

class Responsive {
  // Largura e altura da tela
  static double width(BuildContext context) =>
      MediaQuery.of(context).size.width;

  static double height(BuildContext context) =>
      MediaQuery.of(context).size.height;

  // Escala proporcional baseada em design de referência (375px = iPhone padrão)
  static double sp(BuildContext context, double size) {
    return size * (width(context) / 375);
  }

  // Padding proporcional horizontal (% da largura)
  static double hp(BuildContext context, double percent) {
    return width(context) * (percent / 100);
  }

  // Padding proporcional vertical (% da altura)
  static double vp(BuildContext context, double percent) {
    return height(context) * (percent / 100);
  }

  // Verifica o tipo de dispositivo
  static bool isMobile(BuildContext context) => width(context) < 600;
  static bool isTablet(BuildContext context) =>
      width(context) >= 600 && width(context) < 900;
  static bool isDesktop(BuildContext context) => width(context) >= 900;
}
```

---

### 2. Regras de Uso nos Widgets

#### Fontes e Ícones → Use `Responsive.sp()`
```dart
// ❌ ERRADO (fixo)
Text('Título', style: TextStyle(fontSize: 20))
Icon(Icons.add, size: 24)

// ✅ CORRETO (proporcional)
Text('Título', style: TextStyle(fontSize: Responsive.sp(context, 20)))
Icon(Icons.add, size: Responsive.sp(context, 24))
```

#### Padding Horizontal → Use `Responsive.hp()`
```dart
// ❌ ERRADO (fixo)
padding: EdgeInsets.symmetric(horizontal: 16)

// ✅ CORRETO (4% da largura da tela)
padding: EdgeInsets.symmetric(horizontal: Responsive.hp(context, 4))
```

#### Padding Vertical → Use `Responsive.vp()`
```dart
// ❌ ERRADO (fixo)
padding: EdgeInsets.symmetric(vertical: 12)

// ✅ CORRETO (1.5% da altura da tela)
padding: EdgeInsets.symmetric(vertical: Responsive.vp(context, 1.5))
```

#### Espaçamento entre Widgets → Use `SizedBox` com `Responsive`
```dart
// ❌ ERRADO (fixo)
SizedBox(width: 8)
SizedBox(height: 16)

// ✅ CORRETO (proporcional)
SizedBox(width: Responsive.hp(context, 2))
SizedBox(height: Responsive.vp(context, 2))
```

#### BorderRadius → Use `Responsive.sp()`
```dart
// ❌ ERRADO (fixo)
borderRadius: BorderRadius.circular(12)

// ✅ CORRETO (proporcional)
borderRadius: BorderRadius.circular(Responsive.sp(context, 12))
```

---

### 3. Cores: SEMPRE do Theme, NUNCA Hardcoded

```dart
// ❌ ERRADO (cor fixa)
color: Colors.grey
color: Colors.black87
color: Colors.red

// ✅ CORRETO (do Theme — funciona em claro e escuro)
color: Theme.of(context).colorScheme.onSurface
color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)
color: Theme.of(context).colorScheme.error
color: Theme.of(context).colorScheme.primary
```

---

### 4. Layouts Adaptativos por Dispositivo

Quando precisar de layouts diferentes por tamanho de tela:

```dart
@override
Widget build(BuildContext context) {
  if (Responsive.isTablet(context)) {
    return _buildTabletLayout();
  }
  return _buildMobileLayout();
}
```

Ou usando `LayoutBuilder` para espaço disponível:
```dart
LayoutBuilder(
  builder: (context, constraints) {
    if (constraints.maxWidth > 600) {
      return GridView(...);  // Grid em telas grandes
    }
    return ListView(...);    // Lista em telas pequenas
  },
)
```

---

### 5. Widgets Flexíveis (Preferir Sempre)

| ❌ Evitar | ✅ Usar | Por quê |
|---|---|---|
| `SizedBox(width: 300)` | `Expanded()` | Se adapta ao espaço |
| `Container(width: 200)` | `Flexible()` | Permite encolher |
| `Container(width: screenW)` | `FractionallySizedBox(widthFactor: 0.8)` | 80% da tela |
| Valores fixos no `const` | `Responsive.sp/hp/vp` | Escala proporcional |

---

### 6. Empty State (Tela Vazia)

Sempre adicione um estado vazio quando uma lista está vazia:

```dart
Obx(() {
  if (controller.items.isEmpty) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_rounded,
            size: Responsive.sp(context, 64),
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
          ),
          SizedBox(height: Responsive.vp(context, 2)),
          Text(
            'Nenhum item ainda!',
            style: TextStyle(
              fontSize: Responsive.sp(context, 16),
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }
  return ListView.builder(...);
})
```

---

### 7. Cards em vez de ListTile Puro

Para um visual mais polido, envolva seus itens em Cards:

```dart
Padding(
  padding: EdgeInsets.symmetric(
    horizontal: Responsive.hp(context, 2),
    vertical: Responsive.vp(context, 0.3),
  ),
  child: Card(
    elevation: 1,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(Responsive.sp(context, 12)),
    ),
    child: ListTile(
      contentPadding: EdgeInsets.symmetric(
        horizontal: Responsive.hp(context, 3),
        vertical: Responsive.vp(context, 0.5),
      ),
      // ...
    ),
  ),
)
```

---

## Tabela de Referência Rápida

| Método | Para quê | Exemplo de valor |
|---|---|---|
| `Responsive.sp(context, 16)` | Fontes, ícones, borderRadius | 16 = tamanho base |
| `Responsive.hp(context, 4)` | Padding/margem horizontal | 4 = 4% da largura |
| `Responsive.vp(context, 1.5)` | Padding/margem vertical | 1.5 = 1.5% da altura |
| `Responsive.isMobile(context)` | Checar se é celular | < 600px |
| `Responsive.isTablet(context)` | Checar se é tablet | 600-900px |

## Checklist de Validação

- [ ] Classe `Responsive` criada em `lib/core/utils/responsive.dart`
- [ ] Nenhum `fontSize` usa valor fixo (todos usam `Responsive.sp`)
- [ ] Nenhum `padding` usa `const EdgeInsets` com valores fixos
- [ ] Nenhuma cor está hardcoded (todas vêm do `Theme.of(context).colorScheme`)
- [ ] Ícones grandes usam `Responsive.sp` para o `size`
- [ ] Listas vazias têm Empty State
- [ ] Testado em pelo menos 2 tamanhos de tela diferentes
