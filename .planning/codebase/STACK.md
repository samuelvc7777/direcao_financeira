# Stack

## Visao geral

Repositorio monorepo com quatro frentes visiveis:

- Mobile Flutter em `direcao_financeira_mobile/`
- Backend NestJS em `direcao_financeira_backend/`
- Admin web em Next.js em `direcao_financeira_admin_web/`
- Landing page em Next.js em `direcao_financeira_admin_land_page/`

O foco funcional mais maduro no momento e a jornada/turnos do app mobile, concentrada em `direcao_financeira_mobile/lib/app/presentation/modules/journey/`.

## Mobile

Stack principal do app em `direcao_financeira_mobile/pubspec.yaml`:

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

Stack principal do backend em `direcao_financeira_backend/package.json`:

- NestJS 11
- Prisma 7 com Postgres
- JWT e Passport para autenticacao
- Socket.IO no backend para realtime
- Jest para testes
- ESLint e Prettier

## Admin web e landing

Os dois projetos web usam:

- Next.js 16
- React 19
- TypeScript 5
- Tailwind CSS 4

Arquivos base:

- `direcao_financeira_admin_web/package.json`
- `direcao_financeira_admin_land_page/package.json`

## Variantes de provider no mobile

O app mobile e multi-provider. A selecao parte de `direcao_financeira_mobile/lib/app/core/bindings/provider_binding.dart`:

- `BackendProviderKind.nest`
- `BackendProviderKind.supabase`

Isso impacta diretamente a tela de turnos, porque jornada, corridas, realtime e custos podem vir de implementacoes diferentes mantendo as mesmas interfaces de dominio.

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

Se a proxima feature for na tela de turnos, a combinacao de tecnologias que mais importa hoje e:

- GetX para ciclo de tela, DI e estado
- provider binding para escolher Nest ou Supabase
- repositorio de jornada para orquestrar remoto + local
- geolocalizacao + armazenamento local para turno ativo/offline
- realtime para refletir mudancas de corridas na jornada
