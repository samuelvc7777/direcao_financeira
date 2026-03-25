# Convencoes

## Convencoes arquiteturais

No mobile, o padrao dominante e:

- `Entity` no dominio
- `Model` na camada de dados
- `UseCase` para operacoes de negocio
- `Repository` como fronteira entre domain e data
- `Binding` para registrar dependencias com GetX
- `View` e widgets separados na presentation

Exemplos:

- `ShiftEntity` em `domain/entities/shift_entity.dart`
- `ShiftModel` em `data/models/shift_model.dart`
- `GetShiftHistoryUseCase` em `domain/usecases/journey_use_cases.dart`
- `JourneyRepositoryImpl` em `data/repositories/journey_repository_impl.dart`
- `JourneyBinding` em `presentation/modules/journey/journey_binding.dart`

## Estado e reatividade

O app usa fortemente `Rx`, `Rxn` e `Obx` do GetX.

Na tela de turnos, o `JourneyController` expoe muitos estados reativos como:

- `isLoading`
- `activeShift`
- `trackingStatus`
- `ridesList`
- `shiftsList`
- `selectedFilter`

## Tratamento de erro

O dominio usa `Either<Failure, T>` com `dartz`.

Padrao visto:

- repository captura excecao
- `ApiErrorMapper` converte para `Failure`
- controller traduz para estado ou snackbar

Arquivos relevantes:

- `direcao_financeira_mobile/lib/app/core/network/api_error_mapper.dart`
- `direcao_financeira_mobile/lib/app/data/repositories/journey_repository_impl.dart`

## Nomenclatura

Convencoes recorrentes:

- nomes de arquivos em `snake_case`
- classes em `PascalCase`
- nomes de rotas em strings constantes de `AppRoutes`
- metodos assinc em ingles, textos de UI em portugues

Isso fica bem claro na jornada:

- codigo estrutural em ingles: `refreshJourneyData`, `getShiftHistory`
- UX em portugues: `Controle de turnos e corridas`, `Carregando jornada...`

## Convencao de composicao visual

O modulo `journey` ja mostra uma tendencia boa de separar a view macro de widgets menores:

- `journey_view.dart` cuida da estrutura geral e tabs
- secoes especializadas ficam em `widgets/`

Esse padrao esta alinhado com manutencao senior em Flutter e deve ser preservado em novas features da tela de turnos.

## Dependencia por ambiente

As dependencias concretas sao registradas em bindings globais:

- `core_binding.dart`
- `provider_binding.dart`

Isso e uma convencao importante do projeto: telas nao instanciam infraestrutura diretamente.

## Estilo de testes

Os testes existentes privilegiam unidade/contrato, por exemplo:

- mapeadores
- repositories
- services
- controllers

Nao ha indicio forte de testes widget/E2E amplos para a jornada completa.

## Convencao pratica para evoluir a tela de turnos

Ao adicionar funcionalidade nova, o padrao mais consistente do projeto e:

1. criar/ajustar entidade ou contrato se necessario
2. passar por use case
3. ajustar repository/datasource
4. expor estado no controller
5. manter a `View` enxuta e extrair widgets
