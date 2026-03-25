# Summary: Phase 05 Plan 01

## What Changed

- o contrato de transacoes passou a aceitar `referenceMonth` em `GetTransactionsUseCase`, `ITransactionRepository`, `ITransactionDataSource` e `TransactionRepository`
- o datasource Supabase passou a buscar transacoes com filtro mensal na origem usando limites de inicio e fim exclusivo do mes
- o datasource Nest foi ajustado para a mesma assinatura com parametros de periodo
- a home passou a recarregar transacoes do mes selecionado ao carregar e ao navegar entre meses
- o grafico da home deixou de usar placeholder hardcoded e passou a usar `HomeExpenseChartItem`
- o widget `ExpensesChartSection` passou a consumir contrato tipado em vez de `Map<String, dynamic>`
- foram adicionados testes para a query mensal do Supabase e para o comportamento mensal do `HomeController`

## Verification

- `flutter test test/app/data/providers/supabase/finance/supabase_transaction_remote_datasource_test.dart`
- `flutter test test/app/presentation/modules/home/home_controller_test.dart`
- `flutter analyze lib/app/presentation/modules/home/home_controller.dart lib/app/presentation/modules/home/home_expense_chart_item.dart lib/app/presentation/modules/home/widgets/expenses_chart_section.dart lib/app/domain/usecases/transaction_use_cases.dart lib/app/domain/repositories/i_transaction_repository.dart lib/app/data/datasources/transaction_datasource.dart lib/app/data/repositories/transaction_repository.dart lib/app/data/providers/supabase/finance/supabase_transaction_remote_datasource.dart lib/app/data/providers/nest/finance/nest_transaction_remote_datasource.dart lib/app/presentation/modules/transactions/transactions_controller.dart`

## Outcome

- `HOME-01` coberto com busca mensal real no Supabase
- `HOME-02` coberto com recarga do mes selecionado na home
- `HOME-03` coberto com remocao do hardcode do grafico no `HomeController`
