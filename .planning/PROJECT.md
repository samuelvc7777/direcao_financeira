# Refatoracao da Tela de Turnos

## What This Is

Esta iniciativa organiza a refatoracao da tela de turnos do app mobile Direcao Financeira, concentrada no modulo `direcao_financeira_mobile/lib/app/presentation/modules/journey/`. O objetivo e reduzir o acoplamento atual da jornada sem quebrar o comportamento funcional que o usuario final ja usa para turno ativo, historico, corridas, metricas, rota e tracking.

O trabalho e voltado para o time que mantem o app Flutter e precisa continuar evoluindo a jornada com mais seguranca, clareza arquitetural e menor custo de manutencao.

## Core Value

A tela de turnos deve continuar funcionando para o usuario final enquanto a arquitetura interna fica clara o suficiente para evoluir novas funcionalidades sem concentrar tudo no `JourneyController`.

## Current Milestone: v1.1 Home ativa com graficos reais

**Goal:** ativar o grafico ja existente na home com dados reais vindos do Supabase, incluindo estados de loading, vazio, erro e comportamento funcional para uso real.

**Target features:**
- Conectar o grafico existente da home a uma fonte real no Supabase
- Substituir dados mockados, placeholders ou estados estaticos por dados reais
- Garantir comportamento utilizavel para sucesso, vazio e erro no carregamento do grafico

## Requirements

### Validated

- ✓ O app mobile possui tela principal de jornada acessivel por `/journey` — existente
- ✓ O fluxo atual cobre turno ativo, historico, corridas, metricas, rota e tracking — existente
- ✓ O modulo opera sobre arquitetura em camadas `presentation/domain/data/core` com GetX — existente
- ✓ O app suporta providers diferentes para a mesma jornada (`nest` e `supabase`) — existente
- ✓ Existe comportamento offline/sincronizacao local para o modulo de jornada — existente

### Active

- [ ] Ativar o grafico ja existente na home com dados reais vindos do Supabase
- [ ] Remover dependencia de dados mockados ou placeholders no bloco de grafico da home
- [ ] Tratar corretamente estados de loading, vazio e erro para o grafico da home
- [ ] Deixar o bloco principal de grafico da home pronto para uso funcional real

### Out of Scope

- Reescrever a feature de jornada do zero — risco alto e desnecessario para o objetivo atual
- Trocar GetX por outra stack de estado/DI — nao resolve o gargalo principal agora
- Redesenhar visualmente toda a tela de turnos — o foco desta iniciativa e arquitetura e manutencao
- Mudar o contrato funcional dos providers remotos sem necessidade — pode gerar regressao ampla fora do escopo

## Context

O repositorio e um monorepo com mobile Flutter, backend NestJS, admin web e landing page, mas esta iniciativa foca no app em `direcao_financeira_mobile/`. O modulo de jornada mistura turno ativo, historico, corridas, metricas, rota, localizacao, offline/sync, realtime, semaforo e assistente flutuante.

O mapeamento da codebase em `.planning/codebase/` mostrou que o maior ponto de acoplamento esta em `direcao_financeira_mobile/lib/app/presentation/modules/journey/journey_controller.dart`, enquanto a `JourneyView` ja aponta para um caminho melhor de composicao com widgets menores. O projeto ja usa interfaces de repositorio e bindings por provider, o que favorece refatoracoes graduais sem reescrever tudo.

Com o milestone anterior encerrado, o proximo ciclo muda o foco para a home do app. A intencao imediata e tornar funcional o grafico que ja existe nessa tela, conectando-o aos dados reais do Supabase e cobrindo os estados necessarios para uso real.

## Constraints

- **Tech stack**: Flutter + GetX + arquitetura em camadas atual — manter consistencia com o projeto existente
- **Compatibilidade**: Providers `nest` e `supabase` precisam continuar funcionando — evitar regressao entre ambientes
- **Comportamento**: Fluxos atuais de turno, corridas, metricas, rota e tracking nao podem quebrar — proteger experiencia do usuario final
- **Escopo**: Prioridade e refatoracao incremental — reduzir risco e permitir validacao por etapas
- **Qualidade**: Testabilidade deve melhorar durante a refatoracao — sem depender apenas de verificacao manual
- **Fonte de dados**: O grafico da home deve consumir dados reais do Supabase — sem criar fonte paralela desnecessaria
- **Escopo do milestone**: O foco atual e o grafico ja existente da home — filtros avancados e outros blocos da home ficam fora por enquanto

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Tratar esta iniciativa como brownfield de refatoracao, nao como feature nova | A funcionalidade ja existe e precisa evoluir com seguranca | ✓ Good |
| Manter `JourneyView` como casca de composicao macro | Preserva legibilidade visual e evita mover regra de negocio para UI | — Pending |
| Priorizar extracao de responsabilidades do `JourneyController` antes de novas features | Esse e o maior gargalo tecnico identificado no mapa da codebase | — Pending |
| Preservar providers e comportamento funcional enquanto a arquitetura interna muda | Refatoracao sem equivalencia funcional nao atende o objetivo do projeto | — Pending |
| Abrir o milestone v1.1 focado na home, nao em novas mudancas na jornada | O milestone anterior estabilizou a base da jornada e agora o proximo ganho visivel esta na home | ✓ Good |
| Ativar primeiro o grafico que ja existe usando Supabase | Reaproveita a estrutura atual da home e entrega valor funcional sem ampliar escopo cedo demais | — Pending |
| Tratar loading, vazio e erro no mesmo milestone | O usuario quer o bloco funcional por completo, nao apenas conectado a dados reais | — Pending |

## Evolution

This document evolves at phase transitions and milestone boundaries.

**After each phase transition** (via `$gsd-transition`):
1. Requirements invalidated? → Move to Out of Scope with reason
2. Requirements validated? → Move to Validated with phase reference
3. New requirements emerged? → Add to Active
4. Decisions to log? → Add to Key Decisions
5. "What This Is" still accurate? → Update if drifted

**After each milestone** (via `$gsd-complete-milestone`):
1. Full review of all sections
2. Core Value check — still the right priority?
3. Audit Out of Scope — reasons still valid?
4. Update Context with current state

---
*Last updated: 2026-03-25 after milestone v1.1 kickoff*
