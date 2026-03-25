# Requirements: Refatoracao da Tela de Turnos

**Defined:** 2026-03-25
**Core Value:** A tela de turnos deve continuar funcionando para o usuario final enquanto a arquitetura interna fica clara o suficiente para evoluir novas funcionalidades sem concentrar tudo no `JourneyController`.

## v1 Requirements

### Arquitetura

- [ ] **ARCH-01**: O modulo de jornada deve separar explicitamente responsabilidades de orquestracao, estado de UI e integracoes operacionais hoje concentradas no `JourneyController`
- [ ] **ARCH-02**: Cada responsabilidade extraida deve ter fronteira clara entre `presentation`, `domain`, `data` e `core`
- [ ] **ARCH-03**: A tela de turnos deve continuar suportando os providers atuais sem duplicar regra de negocio por provider

### Comportamento de Jornada

- [ ] **JORN-01**: O usuario pode continuar iniciando, pausando, retomando e finalizando turno sem regressao funcional
- [ ] **JORN-02**: O usuario pode continuar vendo historico de turnos, metricas e corridas com os mesmos resultados esperados
- [ ] **JORN-03**: O usuario pode continuar acessando rota do turno e detalhes de corrida a partir dos fluxos existentes
- [ ] **JORN-04**: O comportamento offline e a sincronizacao posterior de turnos devem permanecer operacionais

### Integracoes Operacionais

- [ ] **OPER-01**: Localizacao, tracking, realtime, semaforo e assistente flutuante devem ficar organizados em pontos de orquestracao menores e testaveis
- [ ] **OPER-02**: Falhas de permissao, conectividade e sincronizacao devem continuar tratadas sem espalhar mensagens e side effects por toda a feature
- [ ] **OPER-03**: A atualizacao de metricas derivadas da jornada deve continuar coerente com o estado ativo do turno e das corridas

### Presentation

- [ ] **PRES-01**: `JourneyView` deve continuar responsavel apenas pela estrutura macro da tela e navegacao local entre tabs/secoes
- [ ] **PRES-02**: Widgets visuais da pasta `journey/widgets` devem permanecer ou ficar mais organizados, sem absorver regras de negocio
- [ ] **PRES-03**: A feature deve expor estados mais claros para a UI, reduzindo dependencia de um controller monolitico

### Qualidade

- [ ] **QUAL-01**: A refatoracao deve aumentar a cobertura automatizada dos fluxos criticos da tela de turnos
- [ ] **QUAL-02**: Os principais contratos extraidos da jornada devem poder ser testados isoladamente
- [ ] **QUAL-03**: A base deve permitir adicionar novas funcionalidades na jornada com menor risco de efeito colateral global

## v2 Requirements

### Evolucao

- **EVOL-01**: Reavaliar a necessidade de subdividir ainda mais a feature em submodulos de jornada apos a primeira rodada de refatoracao
- **EVOL-02**: Revisar oportunidades de unificacao adicional entre providers apos estabilizacao da arquitetura interna
- **EVOL-03**: Expandir testes de widget e fluxos end-to-end da jornada apos estabilizar os contratos internos

## Out of Scope

| Feature | Reason |
|---------|--------|
| Reescrever visual completo da jornada | A iniciativa e estrutural, nao de redesign |
| Migrar GetX para outra solucao | Escopo grande demais para o problema atual |
| Alterar regras de negocio do produto sem necessidade | O objetivo e preservar comportamento e melhorar arquitetura |
| Refatorar todo o app mobile de uma vez | A iniciativa e focada na tela de turnos e seus arredores diretos |

## Traceability

| Requirement | Phase | Status |
|-------------|-------|--------|
| ARCH-01 | Phase 1 | Pending |
| ARCH-02 | Phase 1 | Pending |
| ARCH-03 | Phase 1 | Pending |
| JORN-01 | Phase 2 | Pending |
| JORN-02 | Phase 2 | Pending |
| JORN-03 | Phase 3 | Pending |
| JORN-04 | Phase 2 | Pending |
| OPER-01 | Phase 2 | Pending |
| OPER-02 | Phase 2 | Pending |
| OPER-03 | Phase 3 | Pending |
| PRES-01 | Phase 3 | Pending |
| PRES-02 | Phase 3 | Pending |
| PRES-03 | Phase 3 | Pending |
| QUAL-01 | Phase 4 | Pending |
| QUAL-02 | Phase 4 | Pending |
| QUAL-03 | Phase 4 | Pending |

**Coverage:**
- v1 requirements: 16 total
- Mapped to phases: 16
- Unmapped: 0 ✓

---
*Requirements defined: 2026-03-25*
*Last updated: 2026-03-25 after initial definition*
