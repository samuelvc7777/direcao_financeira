# Phase 2: Extrair orquestracao operacional - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md.

**Date:** 2026-03-25
**Phase:** 02-extrair-orquestracao-operacional
**Areas discussed:** ordem de extracao, contratos operacionais, limites de escopo

---

## Ordem de extracao

| Option | Description | Selected |
|--------|-------------|----------|
| Extrair presentation primeiro | Mexer em widgets e estado visual antes do operacional | |
| Extrair ciclo de vida e runtime primeiro | Reduz o maior acoplamento estrutural antes da limpeza visual | x |
| Refatorar tudo em paralelo | Acelera a mudanca, mas aumenta regressao | |

**User's choice:** Seguir a sequencia definida na Fase 1, com foco na extracao operacional primeiro.
**Notes:** A Fase 3 fica reservada para estado de tela e presentation.

---

## Contratos dos novos blocos

| Option | Description | Selected |
|--------|-------------|----------|
| Falar direto com repository/data | Encurta caminho, mas quebra fronteira de camada | |
| Consumir use cases existentes | Preserva arquitetura atual e compatibilidade multi-provider | x |
| Duplicar logica por provider | Permite customizacao pontual, mas aumenta acoplamento | |

**User's choice:** Manter a fronteira atual via use cases.
**Notes:** `nest` e `supabase` seguem protegidos por `provider_binding.dart` e pelos contratos atuais.

---

## Limites de escopo

| Option | Description | Selected |
|--------|-------------|----------|
| Incluir UI e widgets na mesma fase | Aproveita a mexida, mas amplia muito o risco | |
| Focar so na orquestracao operacional | Mantem a fase pequena e com impacto direto no controller monolitico | x |
| Fazer rewrite completo da jornada | Muda tudo de uma vez, com alto risco | |

**User's choice:** Focar so na orquestracao operacional nesta fase.
**Notes:** `JourneyView`, historico, corridas e widgets ficam para a Fase 3.

---

## the agent's Discretion

- Nomes finais dos coordenadores.
- Formato do retorno operacional para o `JourneyController`.

## Deferred Ideas

- Limpeza ampla de presentation e widgets.
- Refino de metricas derivadas fora do escopo operacional.
