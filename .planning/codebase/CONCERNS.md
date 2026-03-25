# Concerns

## Principal area de risco

A tela de turnos completa esta funcionalmente concentrada demais em `direcao_financeira_mobile/lib/app/presentation/modules/journey/journey_controller.dart`.

O controller acumula:

- carga de turno ativo
- metricas e filtros
- historico de turnos
- corridas e detalhes
- integracao com realtime
- sincronizacao de semaforo
- notificacoes locais
- permissao de localizacao
- assistente flutuante

Isso dificulta manutencao, teste e evolucao segura.

## Risco de acoplamento cruzado

Mudancas na tela de turnos podem exigir ajustes simultaneos em:

- `journey_binding.dart`
- `journey_controller.dart`
- `journey_use_cases.dart`
- `journey_repository_impl.dart`
- datasources locais/remotos
- widgets de jornada

O custo cognitivo da feature ja e alto.

## Offline + realtime

O modulo depende de uma combinacao delicada:

- turno ativo local
- historico remoto
- sincronizacao posterior
- atualizacao de corridas via realtime

Arquivos sensiveis:

- `data/services/journey_sync_service.dart`
- `data/services/journey_shift_lifecycle_service.dart`
- `data/repositories/journey_repository_impl.dart`
- `core/network/journey_realtime_bridge.dart`

Qualquer regressao nesses pontos tende a aparecer como dado duplicado, turno "sumido" ou metrica inconsistente.

## Cobertura de testes insuficiente

Nao encontrei cobertura automatizada especifica e evidente para a tela de turnos como fluxo completo. Isso aumenta o risco de quebrar:

- filtros de periodo
- contagens paginadas
- sincronizacao de turnos pendentes
- atualizacao ao vivo de metricas
- regras de permissao antes de iniciar turno

## Multi-provider

O projeto suporta Nest e Supabase pelo mesmo app. Isso e uma vantagem arquitetural, mas tambem uma fonte de fragilidade:

- comportamento divergente entre providers
- contratos remotos evoluindo em velocidades diferentes
- bugs reproduziveis em um provider e nao no outro

Arquivo central desse risco:

- `direcao_financeira_mobile/lib/app/core/bindings/provider_binding.dart`

## Sinais de worktree em movimento

O repositório esta com varios arquivos modificados no mobile, incluindo jornada, acessibilidade, ride status e traffic light. Tambem havia no `git status` referencia a testes novos nao presentes no diretório lido depois.

Leitura pratica:

- existe trabalho em progresso nessa area
- o mapa atual e confiavel para estrutura, mas o comportamento pode estar mudando agora

## Prioridades de saneamento

Se for investir na tela de turnos completa, a ordem mais segura seria:

1. separar responsabilidades do `JourneyController`
2. cobrir repository/controller com testes especificos
3. isolar offline/sync/realtime em contratos mais previsiveis
4. manter a `JourneyView` como casca de composicao, sem empurrar regra para UI
