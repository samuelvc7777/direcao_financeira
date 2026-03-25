# Phase 4: Blindar com testes e validacao - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md - this log preserves the alternatives considered.

**Date:** 2026-03-25
**Phase:** 04-blindar-com-testes-e-validacao
**Areas discussed:** Prioridade de cobertura, Tipo de teste dominante, Validacao final, Criterio de saida

---

## Prioridade de cobertura

| Option | Description | Selected |
|--------|-------------|----------|
| Contratos principais | Cobrir primeiro `JourneyController`, `ShiftLifecycleCoordinator` e `JourneyRuntimeCoordinator` | ✓ |
| Presentation ampla | Priorizar varias secoes visuais logo de inicio | |
| Distribuido | Espalhar cobertura por toda a feature sem eixo dominante | |

**User's choice:** Seguir com todos os pontos recomendados.
**Notes:** A recomendacao foi priorizar os contratos e pontos de maior risco de regressao.

---

## Tipo de teste dominante

| Option | Description | Selected |
|--------|-------------|----------|
| Unidade e contrato | Blindagem principal com testes isolados e de contrato | ✓ |
| Widget-first | Priorizar widget tests como eixo principal | |
| Mistura ampla | Distribuir esforco igualmente entre varios tipos de teste | |

**User's choice:** Seguir com todos os pontos recomendados.
**Notes:** Widget tests ficam como complemento pontual, nao como estrategia dominante.

---

## Validacao final

| Option | Description | Selected |
|--------|-------------|----------|
| Smoke manual enxuto | Validar turno ativo, historico, corridas e tracking apos os testes | ✓ |
| Apenas automatizado | Confiar apenas em teste automatizado | |
| Validacao extensa | Rodar uma bateria manual ampla nesta fase | |

**User's choice:** Seguir com todos os pontos recomendados.
**Notes:** A validacao manual deve ser objetiva e focada nos fluxos que mais expõem regressao ao usuario.

---

## Criterio de saida

| Option | Description | Selected |
|--------|-------------|----------|
| Contratos cobertos + fluxos validados | Encerrar a fase quando a base estiver segura para evolucao | ✓ |
| Cobertura numerica | Encerrar por quantidade de testes ou percentual alvo | |
| Aberto | Encerrar sem criterio claro, conforme percepcao do momento | |

**User's choice:** Seguir com todos os pontos recomendados.
**Notes:** A fase nao deve reabrir arquitetura nem perseguir perfeccionismo fora do caminho critico.

---

## the agent's Discretion

- Escolher os cenarios de teste adicionais de maior valor para blindar a refatoracao.
- Decidir onde widget tests pontuais realmente agregam seguranca.

## Deferred Ideas

- Limpeza adicional de codigo legado inativo pode virar melhoria futura fora do caminho critico da Fase 4.
