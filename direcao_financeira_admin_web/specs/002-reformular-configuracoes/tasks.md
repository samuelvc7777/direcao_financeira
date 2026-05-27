# Tasks: Reformular tela de configuracoes

**Input**: Design documents from `/specs/002-reformular-configuracoes/`
**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md, contracts/

**Tests**: Nao foram solicitados testes automatizados no spec desta feature. A validacao obrigatoria sera funcional/manual conforme cenarios de aceitacao.

**Organization**: Tasks agrupadas por user story para permitir implementacao e validacao independente.

## Format: `[ID] [P?] [Story] Description`

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Preparar estrutura da feature e base de navegação da nova tela.

- [x] T001 Criar estrutura base da feature em `src/app/(dashboard)/settings/page.tsx`
- [x] T002 [P] Criar pasta de componentes da feature em `src/components/settings/`
- [x] T003 [P] Criar tipos iniciais da feature em `src/lib/services/settings/types.ts`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Base compartilhada que bloqueia a entrega de qualquer user story.

- [x] T004 Criar serviço central de configurações em `src/lib/services/settings/settings-service.ts`
- [x] T005 [P] Criar contrato de estado e feedback de ações (loading/sucesso/erro) em `src/lib/services/settings/settings-feedback.ts`
- [x] T006 [P] Criar mapeamento de seções e metadados da tela em `src/components/settings/settings-sections.ts`
- [x] T007 Implementar layout responsivo macro da tela de configurações em `src/app/(dashboard)/settings/page.tsx`
- [x] T008 Implementar shell visual compartilhado das seções em `src/components/settings/settings-section-card.tsx`

**Checkpoint**: Fundacao pronta - implementacao das historias pode comecar.

---

## Phase 3: User Story 1 - Gerenciar conta com seguranca (Priority: P1) 🎯 MVP

**Goal**: Entregar perfil, troca de senha, sessoes remotas e exclusao de conta com seguranca e feedback funcional.

**Independent Test**: Atualizar perfil, trocar senha, encerrar sessoes remotas e validar fluxo de exclusao com dupla confirmacao sem depender das outras secoes.

### Implementation for User Story 1

- [x] T009 [P] [US1] Implementar card de perfil (nome, email, avatar, edicao) em `src/components/settings/account/profile-settings-card.tsx`
- [x] T010 [P] [US1] Implementar card de troca de senha em `src/components/settings/account/password-settings-card.tsx`
- [x] T011 [P] [US1] Implementar card de sessoes ativas/remotas em `src/components/settings/account/sessions-settings-card.tsx`
- [x] T012 [US1] Implementar dialogo de exclusao com dupla confirmacao em `src/components/settings/account/delete-account-dialog.tsx`
- [x] T013 [US1] Integrar acoes de conta/seguranca ao serviço em `src/lib/services/settings/settings-service.ts`
- [x] T014 [US1] Compor secao de conta e seguranca na pagina em `src/app/(dashboard)/settings/page.tsx`

**Checkpoint**: US1 funcional e validavel isoladamente.

---

## Phase 4: User Story 2 - Ajustar preferencias do produto (Priority: P2)

**Goal**: Entregar preferencias de tema, idioma, formato regional e notificacoes com persistencia por usuario.

**Independent Test**: Alterar preferencias, salvar, recarregar sessao e confirmar persistencia dos valores.

### Implementation for User Story 2

- [x] T015 [P] [US2] Implementar card de aparencia e tema em `src/components/settings/preferences/theme-settings-card.tsx`
- [x] T016 [P] [US2] Implementar card de idioma e formato regional em `src/components/settings/preferences/regional-settings-card.tsx`
- [x] T017 [P] [US2] Implementar card de notificacoes por categoria em `src/components/settings/preferences/notification-settings-card.tsx`
- [x] T018 [US2] Integrar persistencia de preferencias no serviço em `src/lib/services/settings/settings-service.ts`
- [x] T019 [US2] Compor secao de preferencias na pagina em `src/app/(dashboard)/settings/page.tsx`

**Checkpoint**: US2 funcional e validavel isoladamente.

---

## Phase 5: User Story 3 - Administrar integracoes e suporte operacional (Priority: P3)

**Goal**: Entregar monitoramento de integracoes, dados de sistema e canais de suporte acessiveis.

**Independent Test**: Visualizar estados de integracoes, executar reconexao, abrir changelog/politicas e acessar suporte sem erro.

### Implementation for User Story 3

- [x] T020 [P] [US3] Implementar card de integracoes com status/reconexao em `src/components/settings/operations/integrations-settings-card.tsx`
- [x] T021 [P] [US3] Implementar card de sistema (versao e changelog) em `src/components/settings/operations/system-settings-card.tsx`
- [x] T022 [P] [US3] Implementar card de suporte (ajuda, contato, reporte) em `src/components/settings/operations/support-settings-card.tsx`
- [x] T023 [US3] Integrar operacoes de integracao e suporte no serviço em `src/lib/services/settings/settings-service.ts`
- [x] T024 [US3] Compor secao de integracoes/sistema/suporte na pagina em `src/app/(dashboard)/settings/page.tsx`

**Checkpoint**: US3 funcional e validavel isoladamente.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Ajustes finais de qualidade, consistencia e validacao geral da feature.

- [x] T025 [P] Revisar acessibilidade basica (labels, foco, estados de erro) em `src/components/settings/`
- [x] T026 [P] Refinar mensagens de feedback e estados vazios em `src/components/settings/`
- [x] T027 Validar fluxos funcionais ponta a ponta em desktop e mobile via roteiro de `specs/002-reformular-configuracoes/quickstart.md`
- [x] T028 Executar lint do projeto e registrar ajustes necessarios em `package.json` (script `lint`)

---

## Dependencies & Execution Order

### Phase Dependencies

- Phase 1 (Setup) inicia imediatamente.
- Phase 2 (Foundational) depende da Phase 1 e bloqueia todas as historias.
- Phase 3 (US1), Phase 4 (US2) e Phase 5 (US3) dependem da conclusao da Phase 2.
- Phase 6 (Polish) depende das historias selecionadas para entrega.

### User Story Dependencies

- **US1 (P1)**: sem dependencia de US2/US3, define o MVP.
- **US2 (P2)**: independente funcionalmente apos fundacao pronta.
- **US3 (P3)**: independente funcionalmente apos fundacao pronta.

### Parallel Opportunities

- Setup: T002 e T003 em paralelo apos T001.
- Foundational: T005 e T006 em paralelo apos T004.
- US1: T009, T010 e T011 em paralelo.
- US2: T015, T016 e T017 em paralelo.
- US3: T020, T021 e T022 em paralelo.
- Polish: T025 e T026 em paralelo.

---

## Parallel Example: User Story 1

```bash
Task: "Implementar card de perfil em src/components/settings/account/profile-settings-card.tsx"
Task: "Implementar card de troca de senha em src/components/settings/account/password-settings-card.tsx"
Task: "Implementar card de sessoes em src/components/settings/account/sessions-settings-card.tsx"
```

---

## Implementation Strategy

### MVP First (US1)

1. Concluir Phase 1 e Phase 2.
2. Entregar Phase 3 (US1).
3. Validar criterios independentes de US1.

### Incremental Delivery

1. Entregar US1 (MVP).
2. Entregar US2 e validar persistencia de preferencias.
3. Entregar US3 e validar operacao/suporte.
4. Finalizar com Phase 6.

### Parallel Team Strategy

1. Time fecha Setup + Foundational.
2. Depois, dividir US1/US2/US3 entre devs diferentes.
3. Consolidar no Polish com validacao integrada.

---

## Notes

- Todas as tasks seguem formato checklist com ID e caminho de arquivo.
- Tasks marcadas com `[P]` sao paralelizaveis por atuarem em arquivos/escopos distintos.
- Cada historia foi planejada para permanecer implementavel e validavel de forma independente.
