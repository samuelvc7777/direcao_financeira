# Testing

## Stack de testes

### Mobile

No app Flutter, a base de testes e `flutter_test`, conforme `direcao_financeira_mobile/pubspec.yaml`.

Arquivos de teste existentes:

- `test/core/bindings/provider_binding_test.dart`
- `test/core/network/api_error_mapper_test.dart`
- `test/core/session/session_coordinator_test.dart`
- `test/data/mappers/provider_codecs_test.dart`
- `test/data/repositories/auth_repository_test.dart`
- `test/data/repositories/finance_repository_contract_test.dart`
- `test/data/repositories/subscription_repository_test.dart`
- `test/domain/services/online_hourly_projection_calculator_test.dart`
- `test/presentation/controllers/controller_contract_test.dart`
- `test/settings/settings_controller_test.dart`
- `test/settings/settings_view_test.dart`
- `test/traffic_light_settings/traffic_light_settings_controller_test.dart`

### Backend

No backend, a base de testes e Jest, conforme `direcao_financeira_backend/package.json`.

Scripts relevantes:

- `npm test`
- `npm run test:cov`
- `npm run test:e2e`

## Cobertura percebida para a tela de turnos

Existe alguma cobertura indireta da area:

- calculo de projecao por hora online em `test/domain/services/online_hourly_projection_calculator_test.dart`
- contrato de controllers em `test/presentation/controllers/controller_contract_test.dart`

Mas nao encontrei, no estado atual do diretório `test/`, suites especificas para:

- `JourneyController`
- `JourneyRepositoryImpl`
- `JourneyView`
- `ShiftRouteController`
- fluxo offline/sync de turno

## Lacunas mais importantes

Para a "tela de turnos completa", faltam testes de maior valor em:

- inicio, pausa, retomada e finalizacao de turno
- merge entre turnos pendentes locais e historico remoto
- comportamento offline e sincronizacao posterior
- atualizacao de corridas em tempo real refletindo metricas
- regras de permissao de localizacao antes de iniciar turno
- renderizacao das tabs Turnos/Corridas e navegacao derivada

## Mocks e suporte

Existe pasta de suporte em:

- `direcao_financeira_mobile/test/support/`

Arquivos:

- `dio_test_helpers.dart`
- `test_entities.dart`

Isso sugere estrategia de testes unitarios com doubles manuais e fixtures pequenas, nao um harness de integracao de tela completo.

## Recomendacao objetiva

Se a proxima feature tocar a tela de turnos, o melhor retorno de teste viria de:

1. testes unitarios para `JourneyController`
2. testes de repository para `JourneyRepositoryImpl`
3. testes widget focados em `JourneyView` e `ShiftHistorySection`

## Observacao

Durante o mapeamento, vi no `git status` sinais de novos testes ainda nao consolidados para mobile. Como nem todos esses arquivos estavam presentes fisicamente no diretório `test/` no momento da leitura, tratei o mapa com base apenas no que consegui confirmar em disco.
