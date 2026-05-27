# Tasks: Cadastro de API Google

**Input**: Design documents from `/specs/003-configurar-api-google/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/google-api-settings-contract.md

**Tests**: Não foram solicitados testes automatizados na spec; validação principal será via lint e fluxo manual do quickstart.

**Organization**: Tasks agrupadas por user story para implementação e validação independente.

## Format: `[ID] [P?] [Story] Description`

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Preparar base da feature e mapear arquivos-alvo reais do admin.

- [ ] T001 Revisar implementação atual em `src/app/(dashboard)/settings/page.tsx` e inventariar pontos de extensão para API Google
- [ ] T002 [P] Criar pasta de componentes de configuração em `src/components/settings/` (se não existir) para separar UI da lógica de tela

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Criar infraestrutura mínima compartilhada para leitura/escrita da configuração.

**?? CRITICAL**: Nenhuma user story inicia antes desta fase.

- [ ] T003 Definir contrato interno de configuração e tipos em `src/lib/` (ex.: `src/lib/settings/google-api-setting.ts`)
- [ ] T004 [P] Implementar camada de acesso/persistência da configuração ativa em `src/lib/` usando cliente Supabase existente
- [ ] T005 [P] Criar/ajustar endpoint administrativo de leitura/escrita em `src/app/api/admin/` para configuração da API Google
- [ ] T006 Implementar validação base compartilhada (trim + obrigatório) no mesmo módulo de domínio em `src/lib/`
- [ ] T007 Garantir restrição de escrita para perfil administrativo na rota de atualização em `src/app/api/admin/`

**Checkpoint**: Base pronta para UI e fluxos por história.

---

## Phase 3: User Story 1 - Cadastrar API Google nas Configurações (Priority: P1) ?? MVP

**Goal**: Permitir cadastrar e atualizar a API Google pela tela de Configurações.

**Independent Test**: Admin salva valor, recarrega tela e vê valor persistido; ao editar e salvar, novo valor substitui o anterior.

### Implementation for User Story 1

- [ ] T008 [P] [US1] Extrair bloco visual de configuração para componente dedicado em `src/components/settings/google-api-settings-card.tsx`
- [ ] T009 [US1] Integrar o componente na página `src/app/(dashboard)/settings/page.tsx` mantendo a view na estrutura macro
- [ ] T010 [US1] Implementar carregamento do valor atual no componente via endpoint/admin service
- [ ] T011 [US1] Implementar ação de salvar/atualizar com feedback de sucesso/erro no componente de settings
- [ ] T012 [US1] Garantir proteção contra envio duplicado rápido (estado de loading/bloqueio de botão) no componente

**Checkpoint**: US1 funcional e validável isoladamente.

---

## Phase 4: User Story 2 - Validar entrada para evitar configuração inválida (Priority: P2)

**Goal**: Bloquear salvamento com campo vazio ou inválido por regra básica definida.

**Independent Test**: Campo vazio/espacos não salva e exibe mensagem clara; campo preenchido segue fluxo normal.

### Implementation for User Story 2

- [ ] T013 [P] [US2] Implementar validação de formulário (obrigatório + trim) em `src/components/settings/google-api-settings-card.tsx`
- [ ] T014 [US2] Exibir mensagens de erro de validação na UI de configurações em `src/components/settings/google-api-settings-card.tsx`
- [ ] T015 [US2] Reforçar validação no backend (rota admin) para impedir bypass do cliente em `src/app/api/admin/`

**Checkpoint**: US2 funcional sem dependência de novas mudanças em US3.

---

## Phase 5: User Story 3 - Disponibilizar configuração para consumo mobile (Priority: P3)

**Goal**: Expor a API Google ativa para OCR/print no app mobile.

**Independent Test**: Consulta de consumidor retorna valor ativo atual; após atualização no admin, retorna novo valor.

### Implementation for User Story 3

- [ ] T016 [US3] Finalizar contrato de resposta da configuração ativa na rota de leitura em `src/app/api/admin/` (ou rota de consumo definida)
- [ ] T017 [US3] Garantir fallback explícito quando não houver configuração ativa, conforme contrato em `src/app/api/admin/`
- [ ] T018 [US3] Documentar payload esperado para consumidor mobile em `specs/003-configurar-api-google/contracts/google-api-settings-contract.md`

**Checkpoint**: US3 funcional e pronto para integração mobile.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Consolidação final e validação transversal.

- [ ] T019 [P] Atualizar documentação operacional da feature em `specs/003-configurar-api-google/quickstart.md` com passos reais pós-implementação
- [ ] T020 Executar `npm run lint` no projeto e corrigir eventuais problemas introduzidos
- [ ] T021 Executar validação manual ponta a ponta conforme quickstart (save, edit, erro de validação, leitura de consumo)

---

## Dependencies & Execution Order

### Phase Dependencies

- Phase 1 (Setup): inicia imediatamente
- Phase 2 (Foundational): depende da Phase 1 e bloqueia user stories
- Phases 3-5 (User Stories): dependem da conclusão da Phase 2
- Phase 6 (Polish): depende das histórias desejadas concluídas

### User Story Dependencies

- US1 (P1): inicia após Phase 2
- US2 (P2): inicia após Phase 2; aproveita componente criado em US1
- US3 (P3): inicia após Phase 2; pode usar saída de US1/US2, mantendo validação independente

### Parallel Opportunities

- T002 pode rodar em paralelo com T001
- T004 e T005 podem rodar em paralelo após T003
- T008 pode iniciar em paralelo a ajustes finais de base de API, desde que contrato de integração esteja estável
- T013 pode rodar em paralelo com ajustes não conflitantes de T016/T017
- T019 pode ocorrer em paralelo com T020

---

## Parallel Example: User Story 1

```bash
Task: "T008 [US1] Extrair componente google-api-settings-card em src/components/settings/google-api-settings-card.tsx"
Task: "T010 [US1] Implementar carregamento do valor atual no componente"
```

---

## Implementation Strategy

### MVP First (US1)

1. Finalizar Phase 1 e Phase 2
2. Entregar Phase 3 (US1)
3. Validar cenário independente de cadastro/edição

### Incremental Delivery

1. US1: cadastro e atualização
2. US2: endurecer validação de entrada
3. US3: consolidar contrato de consumo mobile
4. Polish: lint + validação manual final

### Parallel Team Strategy

1. Pessoa A: base de UI settings (US1/US2)
2. Pessoa B: rotas/serviços de configuração (Phase 2/US3)
3. Convergência em validação final (Phase 6)

---

## Notes

- Tasks com `[P]` não devem disputar o mesmo arquivo simultaneamente.
- Cada história mantém critério de teste independente conforme spec.
- Commits devem ser feitos por bloco lógico concluído.
