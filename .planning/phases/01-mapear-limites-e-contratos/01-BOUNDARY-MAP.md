# Boundary Map: JourneyController

## Objetivo

Este documento registra o inventario atual de responsabilidades do `JourneyController` e o destino arquitetural proposto para cada bloco. O foco e preparar as Fases 2 e 3 sem rewrite total, preservando o comportamento existente da tela de turnos.

## Leitura-base

- `direcao_financeira_mobile/lib/app/presentation/modules/journey/journey_controller.dart`
- `direcao_financeira_mobile/lib/app/presentation/modules/journey/journey_binding.dart`
- `direcao_financeira_mobile/lib/app/data/repositories/journey_repository_impl.dart`
- `direcao_financeira_mobile/lib/app/core/bindings/provider_binding.dart`

## O que continua no JourneyController

O `JourneyController` deve continuar como controller principal da tela, responsavel por:

- expor o estado observavel consumido pela `JourneyView` e pelos widgets da feature
- receber eventos de UI de alto nivel
- coordenar os componentes extraidos nas proximas fases
- centralizar somente regras de composicao de tela que dependem de varios blocos ao mesmo tempo

Ele deixa de ser dono direto de todo o ciclo operacional da jornada.

## Mapa de blocos

| Bloco atual | Responsabilidade atual no `JourneyController` | Dependencias usadas | Sinais de acoplamento | Camada de destino proposta | Artefato alvo sugerido |
|---|---|---|---|---|---|
| Estado macro da tela e filtros | controla `selectedFilter`, intervalo customizado, pagina de historico, filtros de rides e estados de loading/erro | use cases de estatistica, historico e rides; reatividade GetX | mistura estado de tela com operacao de turno e side effects | presentation | `JourneyScreenController` ou o proprio `JourneyController` enxuto |
| Carregamento agregado da jornada | `refreshJourneyData`, `_loadActiveShift`, `_loadStatistics`, `_loadHistory`, `_loadRidesData` | `GetActiveShiftUseCase`, `GetDailyStatisticsUseCase`, `GetShiftHistoryUseCase`, `GetRidesUseCase` | um unico fluxo dispara dados de naturezas diferentes e trata erros em varios pontos | presentation/domain | facade de leitura da jornada ou `JourneyDataCoordinator` |
| Ciclo de vida do turno | `startShift`, `pauseShift`, `_togglePauseResumeShift`, `finishShift` | `StartShiftUseCase`, `PauseShiftUseCase`, `ResumeShiftUseCase`, `FinishShiftUseCase` | UI, validacao operacional, refresh e feedback estao no mesmo metodo | presentation/domain | `ShiftLifecycleCoordinator` |
| Localizacao e tracking | `_loadTrackingStatus`, `_ensureLocationReadyForShiftStart`, `_handleTrackingStatusUpdated`, `_openTrackingSettings` | `GetLocationTrackingStatusUseCase`, `WatchLocationTrackingStatusUseCase`, `EnsureReadyForShiftStartUseCase`, `Geolocator` | controller conhece detalhes de permissao, status, refresh visual e dialogos | presentation/core | `JourneyRuntimeCoordinator` com adaptador de permissao |
| Realtime e sincronizacao | `journeyRealtimeBridge.bind`, `_handleConnectionStatusChanged`, `_syncPendingShifts` | `JourneyRealtimeBridge`, `SyncPendingJourneyUseCase` | controller reage a conectividade, sincroniza dados e decide feedback | presentation/domain/core | `JourneyRuntimeCoordinator` |
| Metricas derivadas e composicao | `_syncDisplayedJourneyMetrics`, calculos de custo operacional, resumo por forma de pagamento | `JourneyStatisticsDisplayComposer`, `CostsGainsSettings`, estado de turno e rides | calculo derivado convive com IO, tracking e snackbar | presentation/domain | `JourneyMetricsComposerFacade` |
| Historico de turnos | `_loadHistory`, `loadMoreShifts`, contagem de pendencias | `GetShiftHistoryUseCase` | historico remoto e pendencias offline ficam expostos junto do turno ativo | presentation/domain | subestado `JourneyHistoryState` ou `JourneyHistoryController` |
| Corridas e detalhes | `_loadRidesData`, filtros por status, resumo de pagamentos, `openRideDetails` | `GetRidesUseCase`, navegacao GetX | regra de agregacao de corridas e navegacao ficam no mesmo controller gigante | presentation/domain | subestado `JourneyRidesState` ou `JourneyRidesController` |
| Semaforo e acessibilidade | `toggleTrafficLight`, `_handleAccessibilityStatusChanged`, `_showAccessibilityDialog` | `AccessibilityService` | controller conhece ativacao, dialogo, persistencia e snackbar | presentation/core | `AccessibilityJourneyCoordinator` ou absorvido pelo runtime coordinator |
| Assistente flutuante | `_loadAssistantStatus`, `toggleAssistant` | `AppBubbleService` | estado de overlay e regra de permissao ficam acoplados ao turno | presentation/core | `AssistantOverlayCoordinator` ou absorvido pelo runtime coordinator |
| Feedback ao usuario | `_showSuccess`, `_showWarning`, `_showError`, `_showSnackbar`, dialogs de permissao | `AppSnackbar`, `Get.dialog` | side effects espalhados por varios fluxos e dependentes do controller monolitico | presentation/core | facade de feedback da jornada |

## Destino por bloco

### 1. Estado de tela e composicao

Permanece em `presentation`. O controller principal continua dono do estado que a `JourneyView` precisa ler diretamente, mas deixa de implementar as regras operacionais profundas.

### 2. Ciclo de vida do turno

Vai para um coordenador proprio em `presentation` consumindo contratos de `domain`. O coordenador orquestra iniciar, pausar, retomar e finalizar turno, enquanto o `JourneyController` passa a acionar esse bloco e refletir o resultado na UI.

### 3. Tracking, realtime e sincronizacao

Vai para um coordenador operacional em `presentation`, apoiado em `core` para bridge de conectividade e servicos de plataforma. O controller principal deixa de lidar diretamente com bind/unbind, escuta de stream e follow-up de sincronizacao.

### 4. Metricas derivadas

Deve ficar em um compositor claro, preferencialmente ainda em `presentation` consumindo entidades de `domain`. O objetivo e manter os calculos reutilizaveis sem mover logica de negocio para widget.

### 5. Historico e corridas

Podem virar subestados especializados ou controllers auxiliares pequenos na Fase 3. Nesta iniciativa, o ganho principal e separar o bloco de leitura paginada e agregacao do runtime operacional.

### 6. Integracoes auxiliares

Semaforo, acessibilidade e assistente flutuante devem sair do controller principal porque sao side effects de plataforma. A fronteira mais segura e um coordenador operacional que dependa de servicos de `core`.

## Fronteiras por camada

### presentation

- `JourneyView` continua como casca macro da tela
- `JourneyController` continua como ponto de entrada da UI
- novos coordenadores ficam aqui quando o papel principal for orquestrar eventos da tela

### domain

- use cases continuam sendo a fronteira de negocio reutilizavel
- nao ha sinal de que o provider `nest` ou `supabase` precise alterar essa camada por causa da refatoracao

### data

- `JourneyRepositoryImpl` ja concentra boa parte da orquestracao entre local, remoto e sync
- nao devemos puxar para `presentation` responsabilidades que hoje ja pertencem corretamente ao repositorio

### core

- `JourneyRealtimeBridge`, `AccessibilityService` e `AppBubbleService` continuam em infraestrutura transversal
- `provider_binding.dart` continua definindo compatibilidade por provider; a refatoracao interna da jornada nao deve duplicar regra por provider

## Decisoes de limite

- Nao extrair tudo para micro-classes.
- Nao mover regra de negocio para widgets.
- Nao duplicar logica para `nest` e `supabase`.
- Nao quebrar `JourneyBinding`; ele continua sendo o ponto de composicao dos novos blocos.

## Resultado esperado para a Fase 2

Ao fim da Fase 2, o `JourneyController` deve parar de possuir diretamente:

- ciclo de vida do turno
- tracking e permissao de localizacao
- bind de realtime e sincronizacao online
- semaforo e assistente flutuante

Ao fim da Fase 3, ele ainda pode coordenar a tela, mas com estado de historico, corridas e metricas melhor distribuido.
