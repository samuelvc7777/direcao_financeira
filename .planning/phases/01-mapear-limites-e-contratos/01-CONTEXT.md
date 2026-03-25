# Phase 1: Mapear limites e contratos - Context

**Gathered:** 2026-03-25
**Status:** Ready for planning

<domain>
## Phase Boundary

Esta fase define a arquitetura alvo da jornada e explicita quais responsabilidades deixam de pertencer ao `JourneyController`, sem ainda executar a grande extracao operacional das fases seguintes. O foco aqui e desenhar fronteiras, contratos e estrategia incremental de refatoracao dentro do modulo `journey`.

</domain>

<decisions>
## Implementation Decisions

### Fronteiras arquiteturais
- **D-01:** O `JourneyController` deve continuar existindo como ponto de coordenacao da tela principal, mas deixar de ser dono direto de todas as responsabilidades da feature.
- **D-02:** As responsabilidades devem ser separadas por dominio funcional, nao por micro-fragmentacao artificial. A meta e sair do controller monolitico para poucos componentes/coordenadores claros, nao para dezenas de classes pequenas sem ganho real.
- **D-03:** As fronteiras novas devem respeitar a divisao atual `presentation/domain/data/core`, evitando criar logica de negocio nova dentro de widgets.

### Estrategia de extracao
- **D-04:** A refatoracao deve ser incremental e compatibilizada com o comportamento atual, sem rewrite total da jornada.
- **D-05:** A primeira modelagem deve identificar no minimo estes blocos de responsabilidade: estado de tela/composicao, ciclo de vida do turno, integracoes operacionais (tracking/permissoes/realtime/notificacoes/overlay) e metricas derivadas.
- **D-06:** Onde for necessario manter transicao suave, adapters ou fachadas temporarias sao aceitaveis para reduzir risco entre fases.

### Contratos e compatibilidade
- **D-07:** A definicao de limites deve preservar compatibilidade com os providers `nest` e `supabase`, privilegiando contratos compartilhados acima de logica duplicada por provider.
- **D-08:** A fase deve produzir uma sequencia clara do que sera extraido primeiro nas fases 2 e 3, para que o planejamento nao misture refatoracao estrutural com mudanca funcional de UX.

### the agent's Discretion
- Escolha exata dos nomes das novas classes/coordenadores/servicos.
- Grau de formalizacao dos contratos intermediarios, desde que a separacao fique clara e testavel.
- Uso de controllers auxiliares, coordenadores ou facades, desde que preserve legibilidade e nao empurre regra para widgets.

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Projeto e escopo
- `.planning/PROJECT.md` - contexto da iniciativa, restricoes e decisoes-base do projeto
- `.planning/REQUIREMENTS.md` - requisitos `ARCH-01`, `ARCH-02` e `ARCH-03` desta fase
- `.planning/ROADMAP.md` - objetivo, sucesso esperado e ordem das fases
- `.planning/STATE.md` - estado atual do projeto e riscos ja identificados

### Mapa da codebase
- `.planning/codebase/ARCHITECTURE.md` - leitura atual da arquitetura da jornada e do acoplamento no `JourneyController`
- `.planning/codebase/STRUCTURE.md` - localizacao dos arquivos e modulos relevantes da feature
- `.planning/codebase/CONVENTIONS.md` - padroes do projeto para GetX, camadas e composicao Flutter
- `.planning/codebase/CONCERNS.md` - principais riscos tecnicos ja observados para a tela de turnos

### Arquivos centrais da jornada
- `direcao_financeira_mobile/lib/app/presentation/modules/journey/journey_controller.dart` - concentracao atual de responsabilidades da feature
- `direcao_financeira_mobile/lib/app/presentation/modules/journey/journey_view.dart` - casca macro da tela que deve permanecer enxuta
- `direcao_financeira_mobile/lib/app/presentation/modules/journey/journey_binding.dart` - composicao atual de dependencias e use cases da jornada
- `direcao_financeira_mobile/lib/app/domain/usecases/journey_use_cases.dart` - contratos de caso de uso ligados ao turno
- `direcao_financeira_mobile/lib/app/data/repositories/journey_repository_impl.dart` - fronteira atual entre remoto, local e sincronizacao
- `direcao_financeira_mobile/lib/app/core/bindings/provider_binding.dart` - compatibilidade e montagem por provider

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `JourneyView` em `direcao_financeira_mobile/lib/app/presentation/modules/journey/journey_view.dart`: ja atua como estrutura macro com tabs e secoes, o que favorece manter a view limpa.
- Widgets em `direcao_financeira_mobile/lib/app/presentation/modules/journey/widgets/`: a feature ja tem varias secoes extraidas e pode continuar nesse caminho sem concentrar regra visual numa unica view.
- `JourneyStatisticsDisplayComposer` em `direcao_financeira_mobile/lib/app/presentation/modules/journey/journey_statistics_display_data.dart`: ja existe um ponto de composicao/calculo que pode servir de referencia para novas extracoes.

### Established Patterns
- O projeto usa GetX para DI, estado e bindings, com repositories e use cases como fronteira entre camadas.
- O `JourneyRepositoryImpl` ja concentra parte da orquestracao entre local, remoto e sync, o que sugere que a refatoracao deve evitar jogar ainda mais regra para a presentation.
- O app e multi-provider (`nest`/`supabase`), entao novos limites precisam nascer compatibilizados com essa abstracao.

### Integration Points
- `journey_binding.dart` e o ponto natural para encaixar novos coordenadores/servicos da jornada.
- `journey_controller.dart` e o principal ponto de desmembramento progressivo.
- `provider_binding.dart`, `journey_use_cases.dart` e `journey_repository_impl.dart` precisam ser considerados em qualquer definicao de fronteira.

</code_context>

<specifics>
## Specific Ideas

- A fase deve sair com um mapa objetivo de "o que fica no controller principal" versus "o que vira coordenador/servico/controlador auxiliar".
- A refatoracao deve favorecer continuidade das proximas fases: primeiro definir os limites, depois extrair a orquestracao operacional, depois reorganizar estado e presentation.
- Nao ha requisito de redesign visual nesta fase.

</specifics>

<deferred>
## Deferred Ideas

- Detalhes finos de UX e reorganizacao visual profunda da tela ficam para a Fase 3.
- Extracao completa da logica operacional e validacao comportamental ampla ficam para a Fase 2.
- Ampliacao de cobertura automatizada e consolidacao de testes ficam para a Fase 4.

</deferred>

---

*Phase: 01-mapear-limites-e-contratos*
*Context gathered: 2026-03-25*
