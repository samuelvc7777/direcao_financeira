# Implementation Plan: Cadastro de API Google

**Branch**: `003-configurar-api-google` | **Date**: 2026-05-27 | **Spec**: [specs/003-configurar-api-google/spec.md](./spec.md)
**Input**: Feature specification from `/specs/003-configurar-api-google/spec.md`

## Summary

Adicionar na tela de Configurações administrativa o cadastro e atualização da API Google, com validação básica, persistência e disponibilização da configuração ativa para consumo do app mobile nos fluxos de OCR e print.

## Technical Context

**Language/Version**: TypeScript (Next.js App Router)  
**Primary Dependencies**: Next.js, React, Supabase client já existente no projeto  
**Storage**: Banco Supabase (tabela/configuração administrativa já existente no domínio)  
**Testing**: npm run lint + validação manual do fluxo de configuração  
**Target Platform**: Web (painel administrativo)  
**Project Type**: web-application (frontend + rotas API no mesmo projeto)  
**Performance Goals**: salvar/atualizar configuração em até 2 segundos em condição normal de rede  
**Constraints**: somente usuários administrativos podem editar; não permitir valor vazio; manter uma única configuração ativa  
**Scale/Scope**: 1 tela administrativa de configurações + 1 ponto de leitura para consumo mobile

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

A constituição em `.specify/memory/constitution.md` está em formato template sem princípios efetivamente definidos. Portanto, não há gates normativos concretos para bloquear o plano nesta fase.

Resultado pré-Phase 0: **PASS** (sem regras concretas para violação).

Recheck pós-Phase 1: **PASS** (mantido, sem mudança de governança aplicável).

## Project Structure

### Documentation (this feature)

```text
specs/003-configurar-api-google/
+-- plan.md
+-- research.md
+-- data-model.md
+-- quickstart.md
+-- contracts/
¦   +-- google-api-settings-contract.md
+-- tasks.md
```

### Source Code (repository root)

```text
src/
+-- app/
¦   +-- (dashboard)/
¦   ¦   +-- settings/
¦   ¦       +-- page.tsx
¦   +-- api/
¦       +-- admin/
¦           +-- [endpoint de configuração]
+-- components/
¦   +-- settings/
¦       +-- [componentes de formulário]
+-- lib/
    +-- supabase/
        +-- [clientes/helpers já existentes]
```

**Structure Decision**: manter implementação no monolito Next.js atual, com UI em `src/app/(dashboard)/settings` e integração de persistência/consulta via camadas já existentes em `src/lib` e `src/app/api`.

## Complexity Tracking

Sem violações que exijam justificativa.
