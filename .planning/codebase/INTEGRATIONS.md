# Integracoes

## Visao geral

O monorepo integra mobile, backend e interfaces web. A tela de turnos do app mobile depende principalmente de autenticacao, persistencia remota, sincronizacao local, localizacao, notificacoes e realtime.

## Integracoes do mobile

### Backend Nest

Registrado em `direcao_financeira_mobile/lib/app/core/bindings/provider_binding.dart` com:

- `NestAuthRemoteDataSource`
- `NestTransactionRemoteDataSource`
- `NestJourneyRemoteDataSource`
- `NestRideRemoteDataSource`
- `SocketIoRealtimeClient`

Arquivos relevantes:

- `direcao_financeira_mobile/lib/app/data/providers/nest/journey/nest_journey_remote_datasource.dart`
- `direcao_financeira_mobile/lib/app/data/providers/nest/journey/nest_ride_remote_datasource.dart`
- `direcao_financeira_mobile/lib/app/data/providers/nest/realtime/socket_io_realtime_client.dart`

### Supabase

Tambem registrado em `provider_binding.dart`:

- `SupabaseAuthRemoteDataSource`
- `SupabaseJourneyRemoteDataSource`
- `SupabaseRideRemoteDataSource`
- `SupabaseRealtimeClient`
- custos e ganhos via `SupabaseCostsGainsRemoteDataSource`

Arquivos relevantes:

- `direcao_financeira_mobile/lib/app/data/providers/supabase/journey/supabase_journey_remote_datasource.dart`
- `direcao_financeira_mobile/lib/app/data/providers/supabase/journey/supabase_ride_remote_datasource.dart`
- `direcao_financeira_mobile/lib/app/data/providers/supabase/realtime/supabase_realtime_client.dart`

## Integracoes locais do modulo de turnos

### Persistencia local

A jornada usa fontes locais para suportar turno ativo, rotas e sincronizacao posterior:

- `direcao_financeira_mobile/lib/app/data/datasources/journey_local_datasource.dart`
- `direcao_financeira_mobile/lib/app/data/datasources/journey_route_local_datasource.dart`
- `direcao_financeira_mobile/lib/app/data/datasources/location_tracking_datasource.dart`

Isso e central para o comportamento offline da tela de turnos.

### Localizacao

O controller usa `Geolocator` indiretamente e abre configuracoes do aparelho quando necessario:

- validacao antes de iniciar turno
- observacao do status de rastreamento
- leitura de distancia percorrida
- permissao foreground/background e precisao

Arquivo de orquestracao principal:

- `direcao_financeira_mobile/lib/app/presentation/modules/journey/journey_controller.dart`

### Notificacoes locais

O controller inicializa `FlutterLocalNotificationsPlugin` para lidar com ciclo de vida de corridas pendentes de confirmacao.

### Overlay e acessibilidade

A tela de turnos conversa com:

- `AppBubbleService` em `direcao_financeira_mobile/lib/app/core/app_bubble/`
- `AccessibilityService` em `direcao_financeira_mobile/lib/app/core/accessibility/`

Uso pratico:

- alternar o "assistente" flutuante
- ativar/desativar semaforo
- sincronizar contexto do semaforo com metricas da jornada

## Integracoes do backend

O backend em `direcao_financeira_backend/package.json` integra:

- Postgres via Prisma
- JWT/Passport para auth
- Socket.IO para realtime

Como o mobile e multi-provider, a tela de turnos pode depender do backend Nest ou de tabelas/eventos do Supabase, conforme o ambiente.

## Riscos de integracao para a tela de turnos

- Mudancas no contrato de jornada/corridas afetam simultaneamente `IJourneyDataSource`, `IRideDataSource`, repository e controller
- Realtime e estado offline podem divergir se o merge local/remoto nao for mantido
- Fluxos de permissao de localizacao e acessibilidade impactam UX e comportamento operacional do turno
