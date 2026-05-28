# Tasks: Responsividade Global da Aplicacao

**Input**: Design documents from `/specs/001-melhorar-responsividade-global/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/, quickstart.md

**Tests**: A especificacao nao exige TDD formal; incluir validacoes funcionais e visuais orientadas por cenarios multi-viewport.

**Organization**: Tasks agrupadas por user story para permitir implementacao e validacao independente.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Pode executar em paralelo (arquivos diferentes, sem dependencia direta)
- **[Story]**: Mapeia a tarefa para a user story (US1, US2, US3)
- Todas as descricoes incluem caminho de arquivo

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Preparar baseline e mapa de escopo para responsividade global

- [X] T001 Atualizar inventario de rotas ativas e criticidade em `specs/001-melhorar-responsividade-global/quickstart.md`
- [X] T002 Definir matriz final de viewport para validacao em `specs/001-melhorar-responsividade-global/contracts/responsive-quality-contract.md`
- [X] T003 [P] Padronizar checklist operacional de validacao por tela em `specs/001-melhorar-responsividade-global/quickstart.md`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Estabelecer fundacao reutilizavel antes dos ajustes por historia

- [X] T004 Consolidar tokens e regras globais de espacamento/tipografia responsiva em `src/app/globals.css`
- [X] T005 Definir comportamento responsivo base do shell do dashboard em `src/app/(dashboard)/layout.tsx`
- [X] T006 [P] Criar utilitarios de layout responsivo compartilhados em `src/lib/responsive.ts`
- [X] T007 [P] Criar componentes utilitarios para containers e stacks responsivos em `src/components/layout/responsive-container.tsx`
- [X] T008 Integrar utilitarios responsivos nas areas comuns de navegacao em `src/app/layout.tsx`

**Checkpoint**: Fundacao pronta; historias podem avancar por prioridade.

---

## Phase 3: User Story 1 - Navegacao Confiavel em Qualquer Tela (Priority: P1) 🎯 MVP

**Goal**: Garantir uso funcional sem quebra visual em todas as rotas principais, incluindo redimensionamento dinamico.

**Independent Test**: Abrir rotas P1 em mobile/tablet/desktop, redimensionar janela durante uso e confirmar ausencia de corte/sobreposicao e continuidade das acoes principais.

### Implementation for User Story 1

- [X] T009 [US1] Mapear rotas P1 e pontos de quebra visual em `specs/001-melhorar-responsividade-global/research.md`
- [X] T010 [P] [US1] Ajustar responsividade da home do dashboard em `src/app/(dashboard)/page.tsx`
- [X] T011 [P] [US1] Ajustar responsividade da tela de usuarios em `src/app/(dashboard)/users/page.tsx`
- [X] T012 [P] [US1] Ajustar responsividade da tela de planos em `src/app/(dashboard)/plans/page.tsx`
- [X] T013 [US1] Corrigir comportamento de overflow e empilhamento nos componentes compartilhados do dashboard em `src/components/`
- [X] T014 [US1] Validar redimensionamento dinamico das rotas P1 sem recarga em `specs/001-melhorar-responsividade-global/quickstart.md`

**Checkpoint**: US1 funcional e validavel de forma independente.

---

## Phase 4: User Story 2 - Leitura e Acao sem Friccao (Priority: P2)

**Goal**: Melhorar legibilidade e alcance de acoes principais em tabelas, formularios e cards.

**Independent Test**: Em telas reduzidas, concluir operacoes principais sem zoom manual e sem perda de legibilidade de informacoes criticas.

### Implementation for User Story 2

- [X] T015 [US2] Definir padrao de tipografia responsiva por densidade de informacao em `src/app/globals.css`
- [X] T016 [P] [US2] Ajustar layout e prioridade visual da tela de billing em `src/app/(dashboard)/billing/page.tsx`
- [X] T017 [P] [US2] Ajustar layout e prioridade visual da tela de configuracoes em `src/app/(dashboard)/settings/page.tsx`
- [X] T018 [P] [US2] Ajustar layout e prioridade visual da tela de ajuda em `src/app/(dashboard)/help/page.tsx`
- [X] T019 [US2] Garantir visibilidade/alcance de acoes primarias em formularios de autenticacao em `src/components/auth/login-form.tsx`
- [X] T020 [US2] Registrar validacao de legibilidade e acionabilidade por viewport em `specs/001-melhorar-responsividade-global/quickstart.md`

**Checkpoint**: US2 completa sem depender de US3.

---

## Phase 5: User Story 3 - Experiencia Consistente entre Modulos (Priority: P3)

**Goal**: Padronizar comportamento responsivo de componentes equivalentes em modulos diferentes.

**Independent Test**: Comparar modulos distintos em viewports equivalentes e confirmar consistencia de comportamento, hierarquia e interacao.

### Implementation for User Story 3

- [X] T021 [US3] Catalogar componentes equivalentes e variacoes atuais em `specs/001-melhorar-responsividade-global/data-model.md`
- [X] T022 [P] [US3] Padronizar containers de secao e grid em componentes compartilhados em `src/components/`
- [X] T023 [P] [US3] Padronizar comportamento responsivo de cabecalhos e acoes recorrentes em `src/app/(dashboard)/`
- [X] T024 [US3] Alinhar consistencia responsiva entre areas autenticadas e nao autenticadas em `src/app/(auth)/login/page.tsx`
- [X] T025 [US3] Atualizar contrato com checklist final de consistencia cross-modulo em `specs/001-melhorar-responsividade-global/contracts/responsive-quality-contract.md`

**Checkpoint**: US3 independente e verificavel.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Fechar validacao global e reduzir risco de regressao

- [X] T026 [P] Executar validacao final de todas as rotas contra SC-001 a SC-004 e registrar evidencias em `specs/001-melhorar-responsividade-global/quickstart.md`
- [X] T027 Executar lint do projeto e registrar resultado em `specs/001-melhorar-responsividade-global/research.md`
- [X] T028 Revisar documentacao da feature e consolidar status final em `specs/001-melhorar-responsividade-global/plan.md`

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1 (Setup)**: inicia imediatamente
- **Phase 2 (Foundational)**: depende da Phase 1 e bloqueia historias
- **Phase 3-5 (US1-US3)**: dependem da Phase 2; podem seguir por prioridade ou paralelizar por equipe
- **Phase 6 (Polish)**: depende das historias desejadas concluidas

### User Story Dependencies

- **US1 (P1)**: inicia apos Foundational; sem dependencia de US2/US3
- **US2 (P2)**: inicia apos Foundational; independente, com aproveitamento da base de US1
- **US3 (P3)**: inicia apos Foundational; pode ocorrer em paralelo com US2 se houver capacidade

### Parallel Opportunities

- Setup: T003
- Foundational: T006, T007
- US1: T010, T011, T012
- US2: T016, T017, T018
- US3: T022, T023
- Polish: T026

---

## Parallel Example: User Story 1

```bash
Task: "Ajustar responsividade da home do dashboard em src/app/(dashboard)/page.tsx"
Task: "Ajustar responsividade da tela de usuarios em src/app/(dashboard)/users/page.tsx"
Task: "Ajustar responsividade da tela de planos em src/app/(dashboard)/plans/page.tsx"
```

---

## Implementation Strategy

### MVP First (US1)

1. Concluir Setup e Foundational
2. Entregar US1 completa
3. Validar cenarios independentes de US1
4. Demonstrar ganho imediato sem esperar cobertura total

### Incremental Delivery

1. US1 (quebras criticas)
2. US2 (legibilidade e acao)
3. US3 (consistencia entre modulos)
4. Polish final e consolidacao de criterios de sucesso

### Parallel Team Strategy

1. Time fecha Setup + Foundational
2. Apos base pronta:
   - Dev A: US1
   - Dev B: US2
   - Dev C: US3
3. Integracao e validacao cruzada na Phase 6

---

## Notes

- Todas as tarefas seguem formato checklist com ID e caminho de arquivo.
- Tarefas com [P] foram marcadas apenas quando nao ha dependencia direta de arquivo/ordem.
- Escopo mantido em responsividade/UX sem alterar regras de negocio.


