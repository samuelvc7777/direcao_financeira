# Roadmap: v1.1 Home ativa com graficos reais

**Created:** 2026-03-25
**Project:** Direcao Financeira
**Milestone:** v1.1 Home ativa com graficos reais
**Phases:** 3
**v1 requirements:** 11

## Overview

Esta roadmap pertence ao milestone `v1.1 Home ativa com graficos reais` e continua a numeracao do milestone anterior, encerrado na fase 4. O foco deste ciclo e apenas ativar o grafico ja existente da home com dados reais do Supabase, incluindo estados de loading, vazio, erro e comportamento funcional completo sem regressao nos demais blocos da tela.

## Historical Context

O milestone anterior foi concluido na fase 4 com a refatoracao da tela de turnos. Esse historico permanece relevante como contexto arquitetural, mas a execucao atual passa a seguir as fases 5 a 7 abaixo.

## Phases

- [x] **Phase 5: Integracao real do grafico** - Conectar o bloco existente da home ao Supabase e remover dependencia de dados mockados.
- [ ] **Phase 6: Estados funcionais e atualizacao por periodo** - Garantir loading, vazio, erro e atualizacao correta do grafico ao trocar o mes.
- [ ] **Phase 7: Blindagem e nao regressao da home** - Fechar o fluxo com testabilidade adequada, cobertura automatizada e protecao dos demais blocos da home.

## Phase Details

### Phase 5: Integracao real do grafico
**Goal**: O grafico ja existente da home passa a consumir dados reais do Supabase para o mes selecionado, sem depender de dados hardcoded ou placeholders fixos.
**Depends on**: Phase 4
**Requirements**: HOME-01, HOME-02, HOME-03
**Success Criteria** (what must be TRUE):
1. Ao abrir a home, o grafico carrega dados reais vindos do Supabase.
2. O conteudo exibido pelo grafico corresponde ao mes atualmente selecionado na home.
3. O bloco do grafico deixa de exibir valores mockados ou placeholders fixos originados do `HomeController`.
**Plans**: TBD
**UI hint**: yes

### Phase 6: Estados funcionais e atualizacao por periodo
**Goal**: O bloco do grafico responde corretamente aos estados reais de carregamento e aos cenarios de sucesso, vazio e erro sem quebrar a experiencia da home.
**Depends on**: Phase 5
**Requirements**: HOME-04, HOME-05, HOME-06, HOME-07, HOME-08
**Success Criteria** (what must be TRUE):
1. Quando existem dados validos, o grafico renderiza categorias, percentuais e total de saidas de forma coerente com o periodo selecionado.
2. Quando o usuario troca o mes na home, o bloco do grafico atualiza para o novo periodo sem exigir reabertura da tela.
3. Durante o carregamento real, a home exibe um estado de loading compreensivel no lugar do grafico.
4. Quando nao existem dados para o periodo, a home exibe um estado vazio claro e utilizavel no bloco do grafico.
5. Quando ocorre falha ao buscar ou transformar os dados, a home exibe um estado de erro claro sem quebrar a tela.
**Plans**: TBD
**UI hint**: yes

### Phase 7: Blindagem e nao regressao da home
**Goal**: A integracao real do grafico fica sustentavel na arquitetura atual, com cobertura automatizada dos cenarios criticos e sem regressao funcional nos demais blocos da home.
**Depends on**: Phase 6
**Requirements**: HOME-09, HOME-10, HOME-11
**Success Criteria** (what must be TRUE):
1. Os demais blocos existentes da home continuam carregando e funcionando enquanto o grafico usa dados reais.
2. A integracao do grafico pode ser validada em camadas adequadas, sem concentrar toda a regra no widget.
3. Existem testes automatizados cobrindo os cenarios de sucesso, vazio e erro do bloco do grafico.
**Plans**: TBD
**UI hint**: yes

## Progress

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 5. Integracao real do grafico | 1/1 | Complete | 2026-03-25 |
| 6. Estados funcionais e atualizacao por periodo | 0/0 | Not started | - |
| 7. Blindagem e nao regressao da home | 0/0 | Not started | - |

## Requirement Mapping

| Requirement | Phase |
|-------------|-------|
| HOME-01 | Phase 5 |
| HOME-02 | Phase 5 |
| HOME-03 | Phase 5 |
| HOME-04 | Phase 6 |
| HOME-05 | Phase 6 |
| HOME-06 | Phase 6 |
| HOME-07 | Phase 6 |
| HOME-08 | Phase 6 |
| HOME-09 | Phase 7 |
| HOME-10 | Phase 7 |
| HOME-11 | Phase 7 |

**Coverage:** 11/11 requirements mapped

---
*Last updated: 2026-03-25 after roadmap creation for milestone v1.1*
