# Phase 4: Blindar com testes e validacao - Context

**Gathered:** 2026-03-25
**Status:** Ready for planning

<domain>
## Phase Boundary

Esta fase fecha a refatoracao da tela de turnos com uma camada de seguranca objetiva: ampliar cobertura automatizada dos contratos e fluxos mais criticos da jornada, complementar com validacao final enxuta e garantir que a base refatorada possa evoluir sem voltar ao acoplamento anterior.

</domain>

<decisions>
## Implementation Decisions

### Prioridade de cobertura
- **D-01:** A cobertura deve priorizar primeiro `JourneyController`, `ShiftLifecycleCoordinator` e `JourneyRuntimeCoordinator`, porque concentram os contratos novos e o maior risco de regressao.
- **D-02:** Em seguida, a fase pode ampliar cobertura para presentation da jornada onde houver risco funcional claro, sem tentar testar toda a UI indiscriminadamente.

### Tipo de teste dominante
- **D-03:** A fase deve priorizar testes de unidade e de contrato como eixo principal da blindagem.
- **D-04:** Widget tests entram apenas onde houver fluxo visual realmente critico ou comportamento de tela que nao fique bem coberto por contrato.
- **D-05:** A fase nao precisa perseguir end-to-end amplo agora; o foco e cobertura pragmatica com boa relacao entre custo e seguranca.

### Validacao final
- **D-06:** Alem dos testes automatizados, a fase deve incluir uma validacao manual enxuta dos fluxos principais da jornada.
- **D-07:** Essa validacao manual deve cobrir pelo menos turno ativo, historico, corridas e tracking/permissoes em nivel de smoke test funcional.

### Criterio de saida
- **D-08:** A fase so deve ser considerada pronta quando os contratos novos estiverem cobertos, os fluxos criticos estiverem validados e a base estiver mais segura para novas funcionalidades.
- **D-09:** A fase nao deve reabrir refatoracao arquitetural grande; se surgir necessidade estrutural nova, isso vira trabalho posterior.

### the agent's Discretion
- Escolha exata dos cenarios de teste adicionais desde que a prioridade continue nos contratos e fluxos de maior risco.
- Grau de complementaridade entre testes de controller, coordenadores e widget tests pontuais.
- Forma de documentar a validacao final, desde que fique claro o que foi validado e o que ainda permanece como risco residual.

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Projeto e requisitos
- `.planning/PROJECT.md` - contexto geral e valor central da iniciativa
- `.planning/REQUIREMENTS.md` - requisitos `QUAL-01`, `QUAL-02` e `QUAL-03`
- `.planning/ROADMAP.md` - objetivo e criterios de sucesso da Fase 4
- `.planning/STATE.md` - estado atual do projeto e riscos remanescentes

### Decisoes e resultados das fases anteriores
- `.planning/phases/02-extrair-orquestracao-operacional/02-CONTEXT.md` - limites e garantias da extracao operacional
- `.planning/phases/02-extrair-orquestracao-operacional/02-01-SUMMARY.md` - o que foi efetivamente extraido para coordenadores
- `.planning/phases/03-reorganizar-estado-da-feature-e-presentation/03-CONTEXT.md` - decisoes da reorganizacao de estado e presentation
- `.planning/phases/03-reorganizar-estado-da-feature-e-presentation/03-01-SUMMARY.md` - resultado atual da reorganizacao da feature

### Arquivos centrais de implementacao e testes
- `direcao_financeira_mobile/lib/app/presentation/modules/journey/journey_controller.dart` - fachada principal da tela apos as fases anteriores
- `direcao_financeira_mobile/lib/app/presentation/modules/journey/shift_lifecycle_coordinator.dart` - contrato extraido para ciclo de vida do turno
- `direcao_financeira_mobile/lib/app/presentation/modules/journey/journey_runtime_coordinator.dart` - contrato extraido para runtime operacional
- `direcao_financeira_mobile/test/app/presentation/modules/journey/shift_lifecycle_coordinator_test.dart` - cobertura atual do lifecycle coordinator
- `direcao_financeira_mobile/test/app/presentation/modules/journey/journey_runtime_coordinator_test.dart` - cobertura atual do runtime coordinator
- `direcao_financeira_mobile/test/presentation/controllers/controller_contract_test.dart` - contrato atual de controllers e jornada

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- Ja existem testes dedicados para `ShiftLifecycleCoordinator` e `JourneyRuntimeCoordinator`, o que favorece ampliar cobertura a partir de um padrao que ja existe.
- `controller_contract_test.dart` ja concentra verificacoes relevantes de contrato para a camada de presentation.

### Established Patterns
- O projeto ja usa testes de unidade/contrato com fakes locais e inicializacao controlada de `Get`.
- A refatoracao recente preservou `JourneyView` como shell macro e empurrou menos responsabilidade direta para os widgets, o que reforca a estrategia de blindar contratos em vez de tentar testar toda a UI.

### Integration Points
- Os melhores alvos da Fase 4 sao os novos contratos da jornada e os fluxos de maior risco funcional.
- A validacao manual final deve se apoiar nos fluxos que atravessam turno, historico, corridas e tracking, porque e onde o usuario percebe regressao primeiro.

</code_context>

<specifics>
## Specific Ideas

- A Fase 4 deve ser pragmatica: testar o que mais protege a refatoracao, nao inflar numero de testes sem ganho real.
- A base ideal depois desta fase e uma base em que novas funcionalidades da jornada possam nascer sem medo de quebrar turno ativo ou os contratos extraidos.

</specifics>

<deferred>
## Deferred Ideas

- Limpeza mais ampla de codigo legado inativo, como trechos antigos em `operational_metrics_section.dart`, pode acontecer depois se ainda fizer sentido.
- Ampliacao de testes de widget ou fluxos mais proximos de integracao alem do necessario para blindagem inicial fica para evolucao futura.

</deferred>

---

*Phase: 04-blindar-com-testes-e-validacao*
*Context gathered: 2026-03-25*
