# Home do App

## Visão geral

A home principal do aplicativo financeiro é a rota `'/dashboard'`, registrada em `lib/app/routes/app_pages.dart`. Essa rota abre a `HomeView` e injeta o `HomeBinding`.

A tela é organizada como um dashboard financeiro mensal. No topo há um app bar customizado com o título `Dashboard` e o subtítulo `Resumo financeiro do mes`. Logo abaixo, a composição da tela segue uma coluna com o seletor de mês e as seções financeiras da home.

## Ligações principais

- **Rota da home**: `AppRoutes.dashboard`
- **View principal**: `HomeView`
- **Binding**: `HomeBinding`
- **Controller**: `HomeController`
- **Seletor de mês**: `MonthSelector`
- **Componente visual do seletor**: `AppMonthSelector`

## Estrutura da tela

Em `lib/app/presentation/modules/home/home_view.dart`, a home é montada com:

1. `CustomAppBar`
2. `MonthSelector`
3. `BalanceCard`
4. `AccountsSection`
5. `CreditCardsSection`
6. `ExpensesChartSection`
7. `RecentTransactionsSection`
8. `GoalsSection`

A tela usa `LayoutBuilder` para calcular o espaçamento horizontal conforme a largura disponível, e envolve o conteúdo em `SingleChildScrollView` para permitir rolagem vertical. O conteúdo central fica limitado por um `ConstrainedBox` com largura máxima de `720`.

## Seletor de mês

O seletor de mês da home está em `lib/app/presentation/modules/home/widgets/month_selector.dart`.

Ele:

- lê `controller.selectedMonth`
- formata o mês com `DateFormat('MMMM yyyy', 'pt_BR')`
- converte o texto para maiúsculas
- repassa as ações de navegação para `controller.previousMonth` e `controller.nextMonth`

O widget visual reutilizável fica em `lib/app/presentation/widgets/app_month_selector.dart`. Esse componente renderiza:

- botão de mês anterior
- rótulo central com o mês atual
- botão de próximo mês

## Estado e dados

O `HomeController` guarda o mês selecionado em `selectedMonth`, inicializado com `DateTime.now()`.

Os métodos ligados ao seletor são:

- `previousMonth()`
- `nextMonth()`

Quando o mês muda, o controller chama `loadDashboardData(silent: true)`. Essa mesma rotina também é usada na carga inicial e em atualizações automáticas.

Dentro de `loadDashboardData`, o controller chama:

- `loadBankAccountsUseCase()`
- `loadCreditCardsUseCase()`
- `getTransactionsUseCase(selectedMonth.value)`

Os dados carregados alimentam:

- `contas`
- `cartoes`
- `ultimasTransacoes`
- `gastosPorCategoria`

## Comportamento do dashboard

Além do mês, a home mantém outros estados observáveis no `HomeController`, como:

- `isLoading`
- `userName`
- `isBalanceVisible`
- `currentTabIndex`

O controller também escuta:

- `dashboardRefreshNotifier.refreshTick`
- evento realtime `transaction.created`

Nos dois casos, a home recarrega os dados do dashboard.

## Relação com a navegação

Em `lib/app/routes/app_pages.dart`, a home está conectada ao fluxo geral do app por meio de `GetPage`:

- `AppRoutes.dashboard` -> `HomeView`
- `HomeBinding` resolve as dependências da tela

Dentro da home, o método `openTransactionsTab()` chama `homeTabNavigation.openTransactionsTab()`, que é usado pela seção de transações recentes.

## Arquivos relacionados

- `lib/app/routes/app_pages.dart`
- `lib/app/presentation/modules/home/home_view.dart`
- `lib/app/presentation/modules/home/home_binding.dart`
- `lib/app/presentation/modules/home/home_controller.dart`
- `lib/app/presentation/modules/home/widgets/month_selector.dart`
- `lib/app/presentation/widgets/app_month_selector.dart`

