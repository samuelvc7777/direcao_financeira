# Estrutura

## Estrutura de alto nivel

- `direcao_financeira_mobile/`: app Flutter principal
- `direcao_financeira_backend/`: API NestJS
- `direcao_financeira_admin_web/`: painel web
- `direcao_financeira_admin_land_page/`: landing page
- `layout/`: artefatos auxiliares de layout

## Estrutura relevante do mobile

Dentro de `direcao_financeira_mobile/lib/app/`:

- `core/`: infraestrutura transversal e bindings
- `data/`: datasources, models, providers e repositories
- `domain/`: entidades, repositorios e use cases
- `presentation/`: modulos de tela e widgets
- `routes/`: definicao de rotas GetX

## Localizacao do modulo de turnos

O modulo de turnos vive principalmente em:

- `direcao_financeira_mobile/lib/app/presentation/modules/journey/`

Arquivos de view:

- `journey_view.dart`
- `daily_statistics_view.dart`
- `operational_metrics_view.dart`
- `ride_details_view.dart`
- `shift_route_view.dart`
- `add_ride_view.dart`

Arquivos de binding/controller:

- `journey_binding.dart`
- `journey_controller.dart`
- `shift_route_binding.dart`
- `shift_route_controller.dart`
- `add_ride_binding.dart`
- `add_ride_controller.dart`

Widgets especializados:

- `widgets/shift_history_section.dart`
- `widgets/shift_card.dart`
- `widgets/shift_history_header.dart`
- `widgets/shift_history_panels.dart`
- `widgets/rides_list_section.dart`
- `widgets/daily_statistics_section.dart`
- `widgets/operational_metrics_section.dart`
- `widgets/shift_route_content.dart`

## Estrutura de dominio relacionada a turnos

Entidades centrais em `direcao_financeira_mobile/lib/app/domain/entities/`:

- `active_shift_entity.dart`
- `shift_entity.dart`
- `shift_route_entity.dart`
- `finish_shift_result_entity.dart`
- `location_tracking_status_entity.dart`
- `ride_entity.dart`
- `journey_statistics_entity.dart`

Use cases centrais:

- `direcao_financeira_mobile/lib/app/domain/usecases/journey_use_cases.dart`
- `direcao_financeira_mobile/lib/app/domain/usecases/get_rides_usecase.dart`
- `direcao_financeira_mobile/lib/app/domain/usecases/ride_status_use_cases.dart`

## Estrutura de dados relacionada a turnos

Camada de dados relevante:

- `data/datasources/i_journey_datasource.dart`
- `data/datasources/i_ride_datasource.dart`
- `data/datasources/journey_local_datasource.dart`
- `data/datasources/journey_route_local_datasource.dart`
- `data/datasources/location_tracking_datasource.dart`
- `data/repositories/journey_repository_impl.dart`
- `data/repositories/ride_repository_impl.dart`
- `data/services/journey_shift_lifecycle_service.dart`
- `data/services/journey_sync_service.dart`

Providers por backend:

- `data/providers/nest/journey/`
- `data/providers/supabase/journey/`

## Rotas relevantes

Definidas em `direcao_financeira_mobile/lib/app/routes/app_pages.dart`:

- `/journey`
- `/journey/metrics`
- `/journey/shift-metrics`
- `/journey/shift-route`
- `/journey/ride-details`
- `/journey/add-ride`

## Testes relacionados

Hoje nao ha uma pasta de testes dedicada ao modulo `journey`. Os testes mais proximos ficam espalhados em:

- `test/domain/services/online_hourly_projection_calculator_test.dart`
- `test/presentation/controllers/controller_contract_test.dart`
- `test/traffic_light_settings/traffic_light_settings_controller_test.dart`

Isso sugere cobertura ainda parcial para a tela de turnos como feature integrada.
