# Arquitetura

## Padrao predominante

O mobile segue uma arquitetura em camadas relativamente clara:

- `presentation`
- `domain`
- `data`
- `core`

O acoplamento real da tela de turnos esta concentrado no modulo `journey`, que atravessa todas essas camadas.

## Fluxo da tela de turnos

Entrada principal:

- rota `AppRoutes.journey` em `direcao_financeira_mobile/lib/app/routes/app_pages.dart`
- tela `JourneyView` em `direcao_financeira_mobile/lib/app/presentation/modules/journey/journey_view.dart`
- binding `JourneyBinding` em `direcao_financeira_mobile/lib/app/presentation/modules/journey/journey_binding.dart`

Fluxo de dependencia:

1. `JourneyBinding` resolve use cases e servicos via GetX
2. `JourneyController` concentra o estado reativo da jornada
3. use cases em `domain/usecases/journey_use_cases.dart` delegam para `IJourneyRepository`
4. `JourneyRepositoryImpl` decide entre dados remotos, locais e sincronizacao
5. datasources e services executam IO real

## Responsabilidades por camada

### Presentation

Responsavel por:

- composicao da UI
- orquestracao de eventos do usuario
- leitura do estado observavel do controller

Arquivos-chave:

- `journey_view.dart`
- `daily_statistics_view.dart`
- `operational_metrics_view.dart`
- `shift_route_view.dart`
- `widgets/shift_history_section.dart`
- `widgets/rides_list_section.dart`

### Domain

Responsavel por:

- contratos de repositorio
- entidades
- use cases
- calculos reutilizaveis

Arquivos-chave:

- `domain/repositories/i_journey_repository.dart`
- `domain/entities/active_shift_entity.dart`
- `domain/entities/shift_entity.dart`
- `domain/entities/shift_route_entity.dart`
- `domain/usecases/journey_use_cases.dart`
- `domain/services/online_hourly_projection_calculator.dart`

### Data

Responsavel por:

- repositorio concreto
- mapeamento model/entity
- acesso remoto e local
- sincronizacao offline/online
- ciclo de vida operacional do turno

Arquivos-chave:

- `data/repositories/journey_repository_impl.dart`
- `data/services/journey_shift_lifecycle_service.dart`
- `data/services/journey_sync_service.dart`
- `data/datasources/journey_local_datasource.dart`
- `data/datasources/journey_route_local_datasource.dart`
- `data/datasources/location_tracking_datasource.dart`

### Core

Responsavel por infraestrutura transversal:

- environment
- DI global
- sessao
- realtime bridge
- acessibilidade
- overlay
- mapeamento de erros

Arquivos-chave:

- `core/bindings/core_binding.dart`
- `core/bindings/provider_binding.dart`
- `core/network/journey_realtime_bridge.dart`
- `core/session/session_coordinator.dart`

## Caracteristicas arquiteturais da tela de turnos

- Mescla dados historicos remotos com estado operacional local
- Usa stream de rastreamento para atualizar distancia e idle time em tempo real
- Tem comportamento resiliente a offline com sincronizacao posterior
- Mistura metricas de turno, corridas, acessibilidade, semaforo e assistente no mesmo controller

## Ponto forte

A existencia de interfaces (`IJourneyRepository`, `IJourneyDataSource`, `IRideDataSource`) e bindings por provider reduz o impacto de troca entre Nest e Supabase.

## Ponto fraco

`JourneyController` virou centro de muitas responsabilidades:

- carga de dados
- filtros
- sincronizacao de metricas
- UX de permissao
- notificacoes
- semaforo
- assistente flutuante

Isso aumenta custo de manutencao para a "tela de turnos completa" e sugere futura divisao em controllers/coordenadores menores.
