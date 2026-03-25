# Phase 1: Mapear limites e contratos - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-03-25
**Phase:** 01-mapear-limites-e-contratos
**Areas discussed:** fronteiras arquiteturais, estrategia de extracao, contratos e compatibilidade

---

## Fronteiras arquiteturais

| Option | Description | Selected |
|--------|-------------|----------|
| Controller monolitico refinado | Manter quase tudo no `JourneyController`, apenas limpando internals | |
| Coordenacao principal + responsabilidades separadas | Manter um controller principal e extrair blocos claros por dominio funcional | ✓ |
| Fragmentacao ampla em muitos controllers pequenos | Dividir a feature em muitos controllers especializados desde o inicio | |

**User's choice:** Seguir com coordenacao principal + responsabilidades separadas.
**Notes:** Em modo padrao do Codex, foi adotada a opcao recomendada com base no roadmap, na codebase e no objetivo de reduzir acoplamento sem rewrite.

---

## Estrategia de extracao

| Option | Description | Selected |
|--------|-------------|----------|
| Rewrite total | Redesenhar a feature inteira antes de extrair responsabilidades | |
| Refatoracao incremental guiada por fronteiras | Definir limites primeiro e extrair por blocos nas fases seguintes | ✓ |
| Extracao oportunista sem mapa claro | Ir movendo codigo conforme problemas aparecem | |

**User's choice:** Refatoracao incremental guiada por fronteiras.
**Notes:** Escolha alinhada ao projeto brownfield e ao risco atual do modulo `journey`.

---

## Contratos e compatibilidade

| Option | Description | Selected |
|--------|-------------|----------|
| Priorizar um provider e adaptar o outro depois | Simplifica curto prazo, aumenta risco de divergencia | |
| Preservar contratos compartilhados entre providers | Define limites desde o inicio sem quebrar `nest` e `supabase` | ✓ |
| Duplicar caminhos por provider | Separa implementacoes, mas aumenta manutencao | |

**User's choice:** Preservar contratos compartilhados entre providers.
**Notes:** Opcao recomendada pelo mapa da codebase e pelos requisitos `ARCH-03`.

---

## the agent's Discretion

- Nome exato dos novos componentes arquiteturais
- Forma de documentar contratos intermediarios
- Escolha entre coordenadores, facades ou controllers auxiliares, desde que a separacao fique clara

## Deferred Ideas

- Ajustes profundos de presentation e UX visual ficaram para a Fase 3
- Extracao operacional efetiva ficou para a Fase 2
- Expansao de testes automatizados ficou para a Fase 4

