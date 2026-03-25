# Phase 2: Extrair orquestracao operacional - Context

**Gathered:** 2026-03-25
**Status:** Ready for planning

<domain>
## Phase Boundary

Esta fase extrai do `JourneyController` a logica operacional critica da tela de turnos, especialmente ciclo de vida do turno, tracking/localizacao, realtime/sincronizacao e side effects operacionais de plataforma. O objetivo e reduzir acoplamento sem alterar a experiencia funcional do usuario e sem abrir refatoracao ampla de presentation.

</domain>

<decisions>
## Implementation Decisions

### Blocos que entram na Fase 2
- **D-01:** A Fase 2 deve atacar primeiro o ciclo de vida do turno: iniciar, pausar, retomar e finalizar.
- **D-02:** Em seguida, deve extrair o runtime operacional: tracking, permissao de localizacao, watch de status, bind/unbind de realtime e sincronizacao ao voltar a conexao.
- **D-03:** Semaforo, acessibilidade e assistente flutuante entram nesta fase apenas como side effects operacionais acoplados ao runtime, nao como refatoracao visual.

### Estrategia de extracao
- **D-04:** A extracao deve ser incremental, mantendo o `JourneyController` como fachada de tela e usando coordenadores/facades pequenos em vez de micro-classes.
- **D-05:** O `JourneyController` continua expondo o estado consumido pela UI, mas deixa de possuir diretamente os fluxos operacionais profundos.
- **D-06:** A fase nao deve mover regra de negocio para widgets e nao deve redesenhar a `JourneyView`.

### Contratos e compatibilidade
- **D-07:** Os novos componentes devem continuar consumindo use cases existentes da camada `domain`; nao devem falar com datasource nem com implementacoes concretas da camada `data`.
- **D-08:** Compatibilidade com `nest` e `supabase` continua obrigatoria, sem duplicacao de regra por provider.
- **D-09:** `JourneyBinding` continua sendo o ponto de composicao para registrar os novos coordenadores e injetar apenas o necessario no `JourneyController`.

### Garantias comportamentais
- **D-10:** Iniciar, pausar, retomar e finalizar turno devem manter as mesmas mensagens e efeitos visiveis para o usuario, salvo ajustes pequenos de texto estritamente necessarios.
- **D-11:** Offline, sincronizacao posterior, follow-up de tracking e dialogos de permissao devem continuar operacionais apos a extracao.
- **D-12:** Historico, corridas, filtros e reorganizacao de widgets ficam fora desta fase; isso sera tratado na Fase 3.

### the agent's Discretion
- Escolha exata dos nomes dos coordenadores, desde que a separacao funcional fique clara.
- Grau de normalizacao do retorno dos coordenadores para o `JourneyController`.
- Uso de facade unica para feedback operacional, se isso reduzir repeticao sem esconder fluxo demais.

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Projeto e requisitos
- `.planning/PROJECT.md` - contexto geral da iniciativa e restricoes estruturais
- `.planning/REQUIREMENTS.md` - requisitos `JORN-01`, `JORN-02`, `JORN-04`, `OPER-01` e `OPER-02`
- `.planning/ROADMAP.md` - objetivo e sucesso esperado da Fase 2
- `.planning/STATE.md` - estado atual do projeto e riscos em aberto

### Decisoes da Fase 1
- `.planning/phases/01-mapear-limites-e-contratos/01-CONTEXT.md` - decisoes que fixaram os limites arquiteturais
- `.planning/phases/01-mapear-limites-e-contratos/01-BOUNDARY-MAP.md` - mapa do que sai do `JourneyController`
- `.planning/phases/01-mapear-limites-e-contratos/01-TARGET-ARCHITECTURE.md` - arquitetura alvo com componentes centrais propostos
- `.planning/phases/01-mapear-limites-e-contratos/01-EXTRACTION-SEQUENCE.md` - ordem segura de extracao entre Fase 2 e Fase 3

### Arquivos centrais da implementacao
- `direcao_financeira_mobile/lib/app/presentation/modules/journey/journey_controller.dart` - concentracao atual dos fluxos operacionais
- `direcao_financeira_mobile/lib/app/presentation/modules/journey/journey_binding.dart` - ponto de composicao de dependencias da feature
- `direcao_financeira_mobile/lib/app/domain/usecases/journey_use_cases.dart` - contratos de caso de uso usados pelo fluxo operacional
- `direcao_financeira_mobile/lib/app/data/repositories/journey_repository_impl.dart` - fronteira que preserva comportamento multi-provider e offline
- `direcao_financeira_mobile/lib/app/core/bindings/provider_binding.dart` - compatibilidade com `nest` e `supabase`

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `JourneyBinding`: ja e o lugar correto para registrar coordenadores novos e manter a composicao da feature centralizada.
- `JourneyRealtimeBridge`: ja expone o estado online e bind/unbind de eventos, servindo como ponto natural para um runtime coordinator.
- `JourneyStatisticsDisplayComposer`: ja concentra parte da composicao de metricas, entao a Fase 2 nao precisa inventar um novo caminho para calculo visual.

### Established Patterns
- O projeto usa GetX com `Binding`, `Controller`, `UseCase` e `Repository` bem definidos.
- O tratamento de erro segue `Either<Failure, T>` no dominio e traducao para estado/snackbar na presentation.
- A `JourneyView` ja esta relativamente separada dos widgets visuais, o que permite focar esta fase na extracao operacional sem mexer em layout.

### Integration Points
- `onInit` e `onClose` do `JourneyController` sao os principais pontos de extracao do runtime operacional.
- `startShift`, `_togglePauseResumeShift` e `finishShift` sao os principais pontos de extracao do ciclo de vida do turno.
- `_ensureLocationReadyForShiftStart`, `_handleConnectionStatusChanged`, `_syncPendingShifts`, `toggleTrafficLight` e `toggleAssistant` sao os pontos mais claros de side effects operacionais.

</code_context>

<specifics>
## Specific Ideas

- O controller principal deve virar um orquestrador fino da tela, nao um executor de tracking e de permissao.
- O bloco de ciclo de vida deve sair antes do bloco de runtime para evitar duplicar regra entre start/pause/resume/finish e eventos de tracking.
- Se houver necessidade de adaptacao temporaria, wrappers/facades sao aceitaveis desde que a direcao final continue clara.

</specifics>

<deferred>
## Deferred Ideas

- Reorganizar historico, corridas, filtros e agregacoes de payment method fica para a Fase 3.
- Refinar composicao de metricas e limpeza de widgets continua fora desta fase.
- Cobertura de testes dedicada aos novos contratos fica consolidada na Fase 4, embora pequenos testes de seguranca possam aparecer antes se ajudarem a extracao.

</deferred>

---

*Phase: 02-extrair-orquestracao-operacional*
*Context gathered: 2026-03-25*
