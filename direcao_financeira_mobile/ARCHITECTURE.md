# Arquitetura do Mobile

## Objetivo
Este app segue `Clean Architecture + GetX` com separacao previsivel entre `presentation`, `domain`, `data` e `core`.

## Estrutura
- `lib/app/core`
  - configuracoes transversais, tema, bindings globais e erros
- `lib/app/domain`
  - `entities`, `repositories` e `usecases`
  - nao deve depender de Flutter, Dio, GetStorage ou detalhes de API
- `lib/app/data`
  - `datasources`, `models` e `repositories`
  - concentra serializacao, IO, chamadas HTTP e persistencia local
- `lib/app/presentation`
  - `modules`, `controllers`, `views` e `widgets`
  - expõe estado para UI e delega fluxo para use cases

## Fluxo permitido
- `view/widget -> controller -> use case -> repository -> datasource`
- `datasource -> model -> entity`

## Regras
- controller nao acessa datasource diretamente
- controller nao depende de implementacao concreta de repository
- repository retorna `Either<Failure, T>` nos fluxos falháveis
- `try/catch` fica em repository ou infraestrutura equivalente
- widgets nao carregam regra de negocio
- bindings montam dependencias por feature

## Bindings
- `CoreBinding`
  - registra infra compartilhada: `Dio`, `GetStorage`, datasources e repositories
- bindings de feature
  - registram `usecases` e `controllers`
  - podem reutilizar dependencias ja registradas com `Get.isRegistered`

## Padrao por feature
1. definir ou ajustar `Entity`
2. definir interface do `Repository`
3. criar `UseCases`
4. criar `Model`
5. criar `DataSource`
6. implementar `Repository`
7. registrar no `Binding`
8. ligar o `Controller`
9. conectar a `View`

## Anti-padroes
- controller chamando repository diretamente quando a feature ja tem use case
- repository misturando HTTP e estado local sem separar datasource remoto/local
- bindings duplicando a mesma composicao sem checagem
- `dynamic` e casts evitaveis na presentation
