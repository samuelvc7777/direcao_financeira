# Phase 3: Reorganizar estado da feature e presentation - Context

**Gathered:** 2026-03-25
**Status:** Ready for planning

<domain>
## Phase Boundary

Esta fase reorganiza o estado exposto pela feature de jornada e limpa a composicao da presentation, mantendo `JourneyView` como estrutura macro da tela. O foco e distribuir melhor o estado de historico, corridas, metricas e secoes visuais sem mexer novamente na orquestracao operacional extraida na Fase 2.

</domain>

<decisions>
## Implementation Decisions

### Limite da Fase 3
- **D-01:** `JourneyView` continua enxuta, responsavel apenas pela estrutura macro da tela, tabs e navegacao local.
- **D-02:** A Fase 3 nao deve recolocar no `JourneyController` responsabilidades operacionais que sairam para `ShiftLifecycleCoordinator` e `JourneyRuntimeCoordinator`.
- **D-03:** Historico, corridas, filtros, payment method summary e metricas derivadas entram como alvo principal desta fase.

### Estrategia de organizacao
- **D-04:** O estado da tela deve ficar mais previsivel, com agrupamentos por dominio visual/funcional em vez de uma lista grande de `Rx` soltos no controller.
- **D-05:** Widgets da pasta `journey/widgets` podem ser reorganizados, divididos ou especializados quando isso reduzir acoplamento e duplicacao.
- **D-06:** A limpeza deve ser incremental: extrair secoes e subestados claros sem redesign visual amplo.

### Presentation e navegacao
- **D-07:** Fluxos de rota do turno e detalhes de corrida devem continuar acessiveis pelos caminhos atuais.
- **D-08:** `ShiftHistorySection` e `RidesListSection` continuam sendo pontos naturais de composicao das abas, mesmo que a logica de dados associada fique mais enxuta.
- **D-09:** Nenhuma regra de negocio nova deve ser empurrada para widget; widgets recebem estado pronto ou callbacks claros.

### Contratos e testabilidade
- **D-10:** Se surgirem subestados ou facades de presentation, eles devem continuar sob `presentation/modules/journey/` e respeitar o padrao GetX atual.
- **D-11:** A fase deve preparar terreno para testar presentation e estado de tela com menos dependencia do controller monolitico.
- **D-12:** Compatibilidade com `nest` e `supabase` continua herdada dos contratos atuais e nao deve ser reaberta nesta fase.

### the agent's Discretion
- Escolha exata entre subcontrollers, view models auxiliares ou agrupadores de estado.
- Nivel de reorganizacao da pasta `journey/widgets`, desde que a macro-estrutura da tela seja preservada.
- Selecao de quais blocos visuais merecem arquivo proprio versus permanencia no arquivo atual.

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Projeto e requisitos
- `.planning/PROJECT.md` - contexto geral da iniciativa
- `.planning/REQUIREMENTS.md` - requisitos `JORN-03`, `OPER-03`, `PRES-01`, `PRES-02` e `PRES-03`
- `.planning/ROADMAP.md` - objetivo e sucesso esperado da Fase 3
- `.planning/STATE.md` - estado atual do projeto

### Decisoes das fases anteriores
- `.planning/phases/01-mapear-limites-e-contratos/01-CONTEXT.md` - limites arquiteturais fixados
- `.planning/phases/01-mapear-limites-e-contratos/01-TARGET-ARCHITECTURE.md` - definicao do que fica na presentation
- `.planning/phases/01-mapear-limites-e-contratos/01-EXTRACTION-SEQUENCE.md` - sequencia segura entre Fase 2 e Fase 3
- `.planning/phases/02-extrair-orquestracao-operacional/02-CONTEXT.md` - restricoes da extracao operacional
- `.planning/phases/02-extrair-orquestracao-operacional/02-01-SUMMARY.md` - resultado efetivo da Fase 2

### Arquivos centrais da implementacao
- `direcao_financeira_mobile/lib/app/presentation/modules/journey/journey_view.dart` - casca macro que deve permanecer enxuta
- `direcao_financeira_mobile/lib/app/presentation/modules/journey/journey_controller.dart` - estado atual da feature apos extracao operacional
- `direcao_financeira_mobile/lib/app/presentation/modules/journey/widgets/shift_history_section.dart` - composicao da aba de turnos
- `direcao_financeira_mobile/lib/app/presentation/modules/journey/widgets/rides_list_section.dart` - composicao da aba de corridas
- `direcao_financeira_mobile/lib/app/presentation/modules/journey/widgets/operational_metrics_section.dart` - secao de metricas com potencial de simplificacao
- `direcao_financeira_mobile/lib/app/presentation/modules/journey/journey_statistics_display_data.dart` - composicao atual de metricas derivadas

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `JourneyView` ja e uma boa casca macro com `TabBar` e `TabBarView`.
- A pasta `journey/widgets` ja contem secoes separadas para historico, corridas e metricas.
- `JourneyStatisticsDisplayComposer` ja pode servir como fronteira para diminuir calculo visual acoplado ao controller.

### Established Patterns
- O projeto prefere `View` macro + widgets menores na presentation.
- GetX continua sendo o padrao para estado e injecao de dependencias.
- A Fase 2 ja retirou runtime e ciclo de vida do turno, entao a Fase 3 nao precisa mais lidar com bridge, tracking e side effects de plataforma como foco principal.

### Integration Points
- `JourneyController` ainda e o maior ponto de agregacao de estado da feature.
- `ShiftHistorySection`, `RidesListSection` e `operational_metrics_section.dart` sao os melhores candidatos para reorganizar consumo de estado.
- `journey_view.dart` deve permanecer simples, servindo apenas de shell da tela.

</code_context>

<specifics>
## Specific Ideas

- Agrupar estado por dominio de tela tende a ser melhor do que manter dezenas de `Rx` no mesmo controller.
- A Fase 3 deve favorecer leitura e manutencao do modulo antes de qualquer refinamento visual profundo.
- Se a `JourneyView` continuar pequena e as abas ficarem mais especializadas, a feature tende a ficar muito mais previsivel para novas funcionalidades.

</specifics>

<deferred>
## Deferred Ideas

- Novos testes mais amplos de widget e verificacao final ficam para a Fase 4.
- Redesign visual da jornada continua fora do escopo.
- Reavaliar modularizacao maior da feature so depois da estabilizacao da Fase 3 e Fase 4.

</deferred>

---

*Phase: 03-reorganizar-estado-da-feature-e-presentation*
*Context gathered: 2026-03-25*
