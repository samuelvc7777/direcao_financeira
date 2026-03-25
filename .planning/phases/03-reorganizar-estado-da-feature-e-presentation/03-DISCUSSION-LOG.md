# Phase 3: Reorganizar estado da feature e presentation - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md.

**Date:** 2026-03-25
**Phase:** 03-reorganizar-estado-da-feature-e-presentation
**Areas discussed:** escopo de presentation, organizacao de estado, limites da view

---

## Escopo de presentation

| Option | Description | Selected |
|--------|-------------|----------|
| Redesenhar a tela junto | Aproveita a mexida, mas cria escopo novo | |
| Limpar composicao mantendo o visual atual | Fase focada em estado e widgets, sem redesign | x |
| Misturar UI e runtime de novo | Quebra o isolamento da Fase 2 | |

**User's choice:** Seguir sem redesign visual amplo.
**Notes:** `JourneyView` permanece shell macro da tela.

---

## Organizacao de estado

| Option | Description | Selected |
|--------|-------------|----------|
| Manter todos os Rx no controller principal | Menor mudanca estrutural, pouco ganho de clareza | |
| Agrupar por dominio de tela | Melhora previsibilidade de historico, corridas e metricas | x |
| Criar muitos micro-controllers | Aumenta fragmentacao artificial | |

**User's choice:** Agrupar estado por dominio visual/funcional.
**Notes:** historico, corridas e metricas sao os candidatos naturais.

---

## Limites da view

| Option | Description | Selected |
|--------|-------------|----------|
| Empurrar regra para widgets | Reduz controller, mas piora manutencao | |
| Manter widgets como consumidores de estado pronto | Preserva padrao Flutter + GetX atual | x |
| Levar navegacao e composicao para dentro dos widgets | Aumenta acoplamento entre secoes | |

**User's choice:** Widgets recebem estado pronto e callbacks claros.
**Notes:** `JourneyView` continua apenas com estrutura macro, tabs e shell da tela.

---

## the agent's Discretion

- Forma exata do agrupamento de estado.
- Quais widgets merecem arquivos novos ou reorganizacao interna.

## Deferred Ideas

- Redesign visual amplo.
- Testes finais e verificacao completa da feature.
