# Roadmap: Refatoracao da Tela de Turnos

**Created:** 2026-03-25
**Project:** Refatoracao da Tela de Turnos
**Phases:** 4
**v1 requirements:** 16

## Overview

Esta roadmap organiza a refatoracao da tela de turnos em fases pequenas e seguras, preservando comportamento funcional enquanto reduz acoplamento no modulo `journey`.

## Phases

| # | Phase | Goal | Requirements | Success Criteria |
|---|-------|------|--------------|------------------|
| 1 | Mapear limites e contratos | Definir claramente o que sai do `JourneyController` e quais fronteiras passam a existir | ARCH-01, ARCH-02, ARCH-03 | 4 |
| 2 | Extrair orquestracao operacional | Tirar do controller o que for ciclo de vida de turno, tracking, sync e integracoes operacionais | JORN-01, JORN-02, JORN-04, OPER-01, OPER-02 | 5 |
| 3 | Reorganizar estado da feature e presentation | Deixar view e widgets mais limpos, com estado de tela mais previsivel e componentes menores | JORN-03, OPER-03, PRES-01, PRES-02, PRES-03 | 5 |
| 4 | Blindar com testes e validacao | Fechar a refatoracao com testes prioritarios e validacao dos contratos novos | QUAL-01, QUAL-02, QUAL-03 | 4 |

## Phase Details

### Phase 1: Mapear limites e contratos

**Goal:** Definir a arquitetura alvo da jornada, explicitar fronteiras internas e estabelecer quais responsabilidades deixam de pertencer ao `JourneyController`.

**Requirements:** ARCH-01, ARCH-02, ARCH-03

**Success criteria:**
1. Existe definicao clara das responsabilidades que permanecem no controller principal e das que serao extraidas.
2. Os novos limites respeitam a estrutura `presentation/domain/data/core`.
3. Os contratos propostos nao quebram a compatibilidade entre providers `nest` e `supabase`.
4. A sequencia de implementacao das extracoes fica clara para fases posteriores.

**UI hint:** no

### Phase 2: Extrair orquestracao operacional

**Goal:** Mover logica operacional critica para componentes menores sem alterar a experiencia funcional do usuario na operacao do turno.

**Requirements:** JORN-01, JORN-02, JORN-04, OPER-01, OPER-02

**Success criteria:**
1. O ciclo de vida de turno deixa de ficar concentrado no `JourneyController`.
2. Tracking, sincronizacao e integracoes operacionais passam a ter pontos de orquestracao menores e mais testaveis.
3. Fluxos offline e sincronizacao posterior continuam preservados.
4. Tratamento de falhas operacionais continua consistente para o usuario.
5. A feature segue funcional com os providers atuais.

**UI hint:** no

### Phase 3: Reorganizar estado da feature e presentation

**Goal:** Deixar a composicao da tela mais previsivel, mantendo `JourneyView` enxuta e distribuindo melhor o estado da feature.

**Requirements:** JORN-03, OPER-03, PRES-01, PRES-02, PRES-03

**Success criteria:**
1. `JourneyView` continua como estrutura macro, sem concentrar regra de negocio.
2. Widgets da pasta `journey/widgets` permanecem ou ficam mais organizados e especializados.
3. O estado exposto para UI fica mais claro e menos dependente de um controller monolitico.
4. Fluxos de rota do turno e detalhes de corrida continuam acessiveis pelos caminhos existentes.
5. Atualizacao de metricas e secoes visuais continua coerente com o estado da jornada.

**UI hint:** yes

### Phase 4: Blindar com testes e validacao

**Goal:** Garantir que a nova estrutura e segura para evolucao futura, com testes nos fluxos mais criticos.

**Requirements:** QUAL-01, QUAL-02, QUAL-03

**Status:** Completed (2026-03-25)

**Plans:** 2 plans

Plans:
- [x] 04-01-PLAN.md - Blindar contratos e fluxos criticos com testes automatizados
- [x] 04-02-PLAN.md - Fechar a fase com validacao final e criterio de saida

**Success criteria:**
1. Existem testes cobrindo contratos e fluxos criticos da jornada refatorada.
2. Os componentes extraidos podem ser validados isoladamente.
3. O risco de regressao na tela de turnos fica menor do que no estado inicial.
4. A base fica pronta para novas funcionalidades sem reintroduzir o mesmo acoplamento.

**UI hint:** no

## Final Status

Milestone concluido em 2026-03-25.

Resumo do fechamento:
- Fase 2 extraiu a orquestracao operacional para coordenadores dedicados
- Fase 3 reorganizou o estado de presentation em blocos mais previsiveis
- Fase 4 ampliou testes criticos da jornada e fechou com validacao final e relatorio de risco residual

## Requirement Mapping

| Requirement | Phase |
|-------------|-------|
| ARCH-01 | Phase 1 |
| ARCH-02 | Phase 1 |
| ARCH-03 | Phase 1 |
| JORN-01 | Phase 2 |
| JORN-02 | Phase 2 |
| JORN-03 | Phase 3 |
| JORN-04 | Phase 2 |
| OPER-01 | Phase 2 |
| OPER-02 | Phase 2 |
| OPER-03 | Phase 3 |
| PRES-01 | Phase 3 |
| PRES-02 | Phase 3 |
| PRES-03 | Phase 3 |
| QUAL-01 | Phase 4 |
| QUAL-02 | Phase 4 |
| QUAL-03 | Phase 4 |

**Coverage:** 16/16 requirements mapped

---
*Last updated: 2026-03-25 after initial roadmap creation*
