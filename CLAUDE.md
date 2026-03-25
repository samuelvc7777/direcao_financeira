<!-- GSD:project-start source:PROJECT.md -->
## Project

**Refatoracao da Tela de Turnos**

Esta iniciativa organiza a refatoracao da tela de turnos do app mobile Direcao Financeira, concentrada no modulo `direcao_financeira_mobile/lib/app/presentation/modules/journey/`. O objetivo e reduzir o acoplamento atual da jornada sem quebrar o comportamento funcional que o usuario final ja usa para turno ativo, historico, corridas, metricas, rota e tracking.

O trabalho e voltado para o time que mantem o app Flutter e precisa continuar evoluindo a jornada com mais seguranca, clareza arquitetural e menor custo de manutencao.

**Core Value:** A tela de turnos deve continuar funcionando para o usuario final enquanto a arquitetura interna fica clara o suficiente para evoluir novas funcionalidades sem concentrar tudo no `JourneyController`.

### Constraints

- **Tech stack**: Flutter + GetX + arquitetura em camadas atual — manter consistencia com o projeto existente
- **Compatibilidade**: Providers `nest` e `supabase` precisam continuar funcionando — evitar regressao entre ambientes
- **Comportamento**: Fluxos atuais de turno, corridas, metricas, rota e tracking nao podem quebrar — proteger experiencia do usuario final
- **Escopo**: Prioridade e refatoracao incremental — reduzir risco e permitir validacao por etapas
- **Qualidade**: Testabilidade deve melhorar durante a refatoracao — sem depender apenas de verificacao manual
<!-- GSD:project-end -->

<!-- GSD:stack-start source:codebase/STACK.md -->
## Technology Stack

## Visao geral
- Mobile Flutter em `direcao_financeira_mobile/`
- Backend NestJS em `direcao_financeira_backend/`
- Admin web em Next.js em `direcao_financeira_admin_web/`
- Landing page em Next.js em `direcao_financeira_admin_land_page/`
## Mobile
- Flutter com Dart SDK `^3.11.1`
- GetX para rotas, DI e estado reativo
- Dio para HTTP quando o provider ativo e Nest
- Supabase Flutter para auth, dados e realtime quando o provider ativo e Supabase
- Socket.IO client para realtime com backend Nest
- GetStorage para persistencia local leve
- Sqflite e `path` para dados locais do modulo de jornada
- Geolocator para permissao e rastreamento de localizacao
- `flutter_background_service` e `flutter_local_notifications` para comportamento em segundo plano e notificacoes
- `flutter_map` e `latlong2` para exibicao de rotas de turno
- `in_app_purchase` para assinatura
- `dartz` para `Either<Failure, T>`
## Backend
- NestJS 11
- Prisma 7 com Postgres
- JWT e Passport para autenticacao
- Socket.IO no backend para realtime
- Jest para testes
- ESLint e Prettier
## Admin web e landing
- Next.js 16
- React 19
- TypeScript 5
- Tailwind CSS 4
- `direcao_financeira_admin_web/package.json`
- `direcao_financeira_admin_land_page/package.json`
## Variantes de provider no mobile
- `BackendProviderKind.nest`
- `BackendProviderKind.supabase`
## Arquivos-chave para a tela de turnos
- `direcao_financeira_mobile/lib/app/presentation/modules/journey/journey_view.dart`
- `direcao_financeira_mobile/lib/app/presentation/modules/journey/journey_controller.dart`
- `direcao_financeira_mobile/lib/app/domain/usecases/journey_use_cases.dart`
- `direcao_financeira_mobile/lib/app/data/repositories/journey_repository_impl.dart`
- `direcao_financeira_mobile/lib/app/data/services/journey_shift_lifecycle_service.dart`
- `direcao_financeira_mobile/lib/app/data/services/journey_sync_service.dart`
- `direcao_financeira_mobile/lib/app/data/datasources/journey_local_datasource.dart`
- `direcao_financeira_mobile/lib/app/data/datasources/location_tracking_datasource.dart`
## Leitura pratica
- GetX para ciclo de tela, DI e estado
- provider binding para escolher Nest ou Supabase
- repositorio de jornada para orquestrar remoto + local
- geolocalizacao + armazenamento local para turno ativo/offline
- realtime para refletir mudancas de corridas na jornada
<!-- GSD:stack-end -->

<!-- GSD:conventions-start source:CONVENTIONS.md -->
## Conventions

## Convencoes arquiteturais
- `Entity` no dominio
- `Model` na camada de dados
- `UseCase` para operacoes de negocio
- `Repository` como fronteira entre domain e data
- `Binding` para registrar dependencias com GetX
- `View` e widgets separados na presentation
- `ShiftEntity` em `domain/entities/shift_entity.dart`
- `ShiftModel` em `data/models/shift_model.dart`
- `GetShiftHistoryUseCase` em `domain/usecases/journey_use_cases.dart`
- `JourneyRepositoryImpl` em `data/repositories/journey_repository_impl.dart`
- `JourneyBinding` em `presentation/modules/journey/journey_binding.dart`
## Estado e reatividade
- `isLoading`
- `activeShift`
- `trackingStatus`
- `ridesList`
- `shiftsList`
- `selectedFilter`
## Tratamento de erro
- repository captura excecao
- `ApiErrorMapper` converte para `Failure`
- controller traduz para estado ou snackbar
- `direcao_financeira_mobile/lib/app/core/network/api_error_mapper.dart`
- `direcao_financeira_mobile/lib/app/data/repositories/journey_repository_impl.dart`
## Nomenclatura
- nomes de arquivos em `snake_case`
- classes em `PascalCase`
- nomes de rotas em strings constantes de `AppRoutes`
- metodos assinc em ingles, textos de UI em portugues
- codigo estrutural em ingles: `refreshJourneyData`, `getShiftHistory`
- UX em portugues: `Controle de turnos e corridas`, `Carregando jornada...`
## Convencao de composicao visual
- `journey_view.dart` cuida da estrutura geral e tabs
- secoes especializadas ficam em `widgets/`
## Dependencia por ambiente
- `core_binding.dart`
- `provider_binding.dart`
## Estilo de testes
- mapeadores
- repositories
- services
- controllers
## Convencao pratica para evoluir a tela de turnos
<!-- GSD:conventions-end -->

<!-- GSD:architecture-start source:ARCHITECTURE.md -->
## Architecture

## Padrao predominante
- `presentation`
- `domain`
- `data`
- `core`
## Fluxo da tela de turnos
- rota `AppRoutes.journey` em `direcao_financeira_mobile/lib/app/routes/app_pages.dart`
- tela `JourneyView` em `direcao_financeira_mobile/lib/app/presentation/modules/journey/journey_view.dart`
- binding `JourneyBinding` em `direcao_financeira_mobile/lib/app/presentation/modules/journey/journey_binding.dart`
## Responsabilidades por camada
### Presentation
- composicao da UI
- orquestracao de eventos do usuario
- leitura do estado observavel do controller
- `journey_view.dart`
- `daily_statistics_view.dart`
- `operational_metrics_view.dart`
- `shift_route_view.dart`
- `widgets/shift_history_section.dart`
- `widgets/rides_list_section.dart`
### Domain
- contratos de repositorio
- entidades
- use cases
- calculos reutilizaveis
- `domain/repositories/i_journey_repository.dart`
- `domain/entities/active_shift_entity.dart`
- `domain/entities/shift_entity.dart`
- `domain/entities/shift_route_entity.dart`
- `domain/usecases/journey_use_cases.dart`
- `domain/services/online_hourly_projection_calculator.dart`
### Data
- repositorio concreto
- mapeamento model/entity
- acesso remoto e local
- sincronizacao offline/online
- ciclo de vida operacional do turno
- `data/repositories/journey_repository_impl.dart`
- `data/services/journey_shift_lifecycle_service.dart`
- `data/services/journey_sync_service.dart`
- `data/datasources/journey_local_datasource.dart`
- `data/datasources/journey_route_local_datasource.dart`
- `data/datasources/location_tracking_datasource.dart`
### Core
- environment
- DI global
- sessao
- realtime bridge
- acessibilidade
- overlay
- mapeamento de erros
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
## Ponto fraco
- carga de dados
- filtros
- sincronizacao de metricas
- UX de permissao
- notificacoes
- semaforo
- assistente flutuante
<!-- GSD:architecture-end -->

<!-- GSD:workflow-start source:GSD defaults -->
## GSD Workflow Enforcement

Before using Edit, Write, or other file-changing tools, start work through a GSD command so planning artifacts and execution context stay in sync.

Use these entry points:
- `/gsd:quick` for small fixes, doc updates, and ad-hoc tasks
- `/gsd:debug` for investigation and bug fixing
- `/gsd:execute-phase` for planned phase work

Do not make direct repo edits outside a GSD workflow unless the user explicitly asks to bypass it.
<!-- GSD:workflow-end -->



<!-- GSD:profile-start -->
## Developer Profile

> Profile not yet configured. Run `/gsd:profile-user` to generate your developer profile.
> This section is managed by `generate-claude-profile` -- do not edit manually.
<!-- GSD:profile-end -->
