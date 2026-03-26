# Transacoes do App

## Visao geral

A area de transacoes do aplicativo fica no modulo `lib/app/presentation/modules/transactions/`.
Ela concentra a tela principal de listagem, os fluxos de criacao e edicao, o agrupamento por dia, os filtros de visualizacao e o suporte a transacoes em conta bancaria e cartao de credito.

A tela principal e `TransactionsView`, ligada ao `TransactionsController` por meio de `TransactionsBinding`.

## Ligacoes principais

- **View principal**: `lib/app/presentation/modules/transactions/transactions_view.dart`
- **Controller**: `lib/app/presentation/modules/transactions/transactions_controller.dart`
- **Binding**: `lib/app/presentation/modules/transactions/transactions_binding.dart`
- **Rotas**: `lib/app/routes/app_pages.dart`
- **Entidade base**: `lib/app/domain/entities/transaction_entity.dart`
- **Casos de uso**: `lib/app/domain/usecases/transaction_use_cases.dart`
- **Contrato de repositorio**: `lib/app/domain/repositories/i_transaction_repository.dart`

## Estrutura da tela principal

Em `transactions_view.dart`, a tela e montada com:

1. `Scaffold`
2. `CustomAppBar`
3. `FloatingActionButton`
4. `AppMonthSelector`
5. `TransactionsSummaryCards`
6. `TransactionsFilterTabs`
7. `TransactionsEmptyState` ou `TransactionsDayGroupSection`

A tela usa:

- `Obx` para reagir ao estado do controller
- `LayoutBuilder` para ajustar o padding horizontal em telas largas
- `ConstrainedBox` com largura maxima de `720`
- `SingleChildScrollView` para permitir rolagem vertical

## Fluxo principal da tela

### Carregamento inicial

Quando `TransactionsController` e inicializado, o metodo `onInit()` chama `loadData()`.

Esse carregamento busca em paralelo:

- transacoes do mes selecionado
- categorias
- contas bancarias ativas
- cartoes de credito ativos

Depois da resposta:

- as categorias sao filtradas para `isActive`
- as contas sao filtradas para `isActive`
- os cartoes sao filtrados para `isActive`
- as transacoes sao ordenadas da mais recente para a mais antiga

Se existir transacao retornada, mas nenhuma no mes atualmente selecionado, o controller ajusta `selectedMonth` para o mes da transacao mais recente.

### Navegacao por mes

O seletor de mes da tela chama:

- `goToPreviousMonth()`
- `goToNextMonth()`

O controller recalcula os dados a partir do mes ativo e expoe:

- `selectedMonthSubtitle`
- `selectedMonthLabelUppercase`
- `monthTransactions`
- `visibleTransactions`
- `groupedVisibleTransactions`

### Filtros

A tela usa `TransactionsFilterTabs` para alternar entre:

- `Todos`
- `Entradas`
- `Saidas`

O estado selecionado fica em `selectedFilter`.

### Resumo mensal

Os cards de resumo exibem:

- total de entradas
- total de saidas
- saldo

Os valores sao derivados de:

- `totalIncomeCents`
- `totalExpenseCents`
- `balanceCents`

### Lista por dia

As transacoes visiveis sao agrupadas por data no controller e exibidas em `TransactionsDayGroupSection`.

Cada grupo mostra:

- data do dia
- quantidade de transacoes
- total consolidado do dia
- cards individuais das transacoes

Se nao houver resultado para o filtro/mês atual, a tela mostra `TransactionsEmptyState`.

## Fluxo de criacao

O botao flutuante chama `_openCreateTransactionFlow()`, que abre `TransactionTypeSelectorSheet`.

Esse bottom sheet oferece tres caminhos:

- **Nova Saida** -> `AppRoutes.transactionExpense`
- **Nova Entrada** -> `AppRoutes.transactionIncome`
- **Compra no Cartao** -> `AppRoutes.transactionCreditCard`

### Formulario de transacao normal

`TransactionFormView` trata entradas e saidas em conta bancaria.

O formulario usa:

- valor monetario com formatter
- selecao de tipo quando nao esta em edicao
- status pago/pendente
- selecao de data
- selecao de conta
- selecao de categoria
- descricao opcional

Na criacao, o formulario chama `controller.createTransaction()` com:

- `type`
- `assetType: AssetType.bankAccount`
- `amountCents`
- `categoryId`
- `description`
- `transactionDate`
- `bankAccountId`

### Formulario de compra no cartao

`CreditCardFormView` trata compras em cartao.

O formulario usa:

- valor monetario com formatter
- quantidade de parcelas
- selecao de data
- selecao de cartao
- selecao de categoria
- descricao opcional

Na criacao, o formulario chama `controller.createTransaction()` com:

- `type: TransactionType.expense`
- `assetType: AssetType.creditCard`
- `amountCents`
- `categoryId`
- `description`
- `transactionDate`
- `creditCardId`
- `installmentCount`

## Fluxo de edicao

### Edicao de transacao comum

Quando o usuario toca em editar em um card do dia, `TransactionsView` decide o destino:

- se `transaction.assetType == AssetType.creditCard`, abre `AppRoutes.transactionCreditCard`
- caso contrario, abre `AppRoutes.transactionExpense`

### Edicao de transacao em conta

Em `TransactionFormView`, quando existe `editingTransaction`, o formulario:

- preenche valor
- preenche descricao
- preenche data
- tenta selecionar a conta
- tenta selecionar a categoria

Na confirmacao, chama `controller.updateTransaction()` com `scope: TransactionMutationScope.current`.

### Edicao de compra no cartao

Em `CreditCardFormView`, quando existe `editingTransaction`, o formulario:

- preenche valor
- preenche descricao
- preenche data
- preenche numero de parcelas
- tenta selecionar o cartao
- tenta selecionar a categoria

Se a transacao fizer parte de um grupo parcelado, o formulario abre um dialog para escolher entre:

- alterar apenas a parcela atual
- alterar todas as parcelas

## Fluxo de exclusao

Em `TransactionsView`, a exclusao abre um `AlertDialog`.

Quando a transacao faz parte de parcelamento, o dialog oferece:

- cancelar
- excluir apenas a parcela atual
- excluir todas as parcelas

O controller executa `deleteTransaction()` e marca o id em `deletingTransactionIds` para evitar duplo envio.

## Estrutura de estado no controller

O `TransactionsController` mantem:

- `isLoading`
- `isSubmitting`
- `deletingTransactionIds`
- `transactions`
- `categories`
- `activeAccounts`
- `activeCards`
- `selectedFilter`
- `selectedMonth`

### Calculos derivados

- `incomeCategories`
- `expenseCategories`
- `monthTransactions`
- `visibleTransactions`
- `totalIncomeCents`
- `totalExpenseCents`
- `balanceCents`
- `groupedVisibleTransactions`

## Dependencias de dominio

O contrato de dados da tela e definido por:

- `TransactionType`
- `AssetType`
- `TransactionMutationScope`
- `TransactionStatus`
- `TransactionEntity`

Os casos de uso usados pela tela sao:

- `GetTransactionsUseCase`
- `GetCategoriesUseCase`
- `GetBankAccountsUseCase`
- `GetCreditCardsUseCase`
- `CreateTransactionUseCase`
- `UpdateTransactionUseCase`
- `DeleteTransactionUseCase`

O contrato do repositorio de transacoes e `ITransactionRepository`, que expõe:

- listar transacoes por mes
- buscar uma transacao
- criar transacao
- atualizar transacao
- excluir transacao

## Componentes visuais da area

- `TransactionsSummaryCards` mostra os tres cards do resumo mensal
- `TransactionsFilterTabs` renderiza os filtros de visualizacao
- `TransactionsEmptyState` mostra o estado vazio
- `TransactionsDayGroupSection` monta os blocos agrupados por dia
- `TransactionTypeSelectorSheet` abre o menu de escolha do tipo de transacao

## Formatos e regras visuais

Os widgets da area usam combinacoes de:

- `GetX` para estado reativo
- `Responsive` para espacamento e escala
- `AppColors` para acentos cromaticos
- `NumberFormat` para moeda `pt_BR`

O layout prioriza:

- leitura rapida do mes atual
- resumo financeiro no topo
- filtros logo abaixo do resumo
- lista agrupada por dia em seguida
- acoes de criacao e edicao com baixo atrito

## Rotas envolvidas

- `AppRoutes.transactionExpense`
- `AppRoutes.transactionIncome`
- `AppRoutes.transactionCreditCard`

Essas rotas usam `TransactionsBinding`, para garantir que os formularios tenham acesso ao mesmo controller e aos mesmos casos de uso.

## Arquivos relacionados

- `lib/app/presentation/modules/transactions/transactions_view.dart`
- `lib/app/presentation/modules/transactions/transactions_controller.dart`
- `lib/app/presentation/modules/transactions/transactions_binding.dart`
- `lib/app/presentation/modules/transactions/widgets/transactions_summary_cards.dart`
- `lib/app/presentation/modules/transactions/widgets/transactions_filter_tabs.dart`
- `lib/app/presentation/modules/transactions/widgets/transactions_day_group_section.dart`
- `lib/app/presentation/modules/transactions/widgets/transactions_empty_state.dart`
- `lib/app/presentation/modules/transactions/widgets/transaction_type_selector_sheet.dart`
- `lib/app/presentation/modules/transactions/views/transaction_form_view.dart`
- `lib/app/presentation/modules/transactions/views/credit_card_form_view.dart`
- `lib/app/domain/entities/transaction_entity.dart`
- `lib/app/domain/usecases/transaction_use_cases.dart`
- `lib/app/domain/repositories/i_transaction_repository.dart`
- `lib/app/routes/app_pages.dart`
