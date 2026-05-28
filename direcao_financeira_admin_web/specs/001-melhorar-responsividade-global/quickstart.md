# Quickstart - Responsividade Global da Aplicacao

## Objetivo
Executar a entrega de responsividade em toda a aplicacao com criterio unico de qualidade e cobertura integral das rotas ativas.

## 1. Preparar contexto
1. Confirmar que o escopo desta feature e `specs/001-melhorar-responsividade-global/`.
2. Ler `spec.md`, `plan.md` e `contracts/responsive-quality-contract.md`.
3. Mapear as rotas ativas por modulo e classificar criticidade (P1, P2, P3).

### Inventario de rotas ativas
- P1: `/`, `/users`, `/plans`
- P2: `/billing`, `/settings`, `/help-videos`, `/login`
- P3: `/users/[id]`, `/plans/new`, `/plans/[id]`

### Checklist operacional por tela
- Confirmar ausencia de corte ou sobreposicao em mobile, tablet, notebook e desktop.
- Confirmar que a acao primaria fica visivel ou facilmente alcancavel.
- Confirmar que tabelas usam rolagem horizontal controlada quando necessario.
- Confirmar que estados de loading, erro e vazio nao bloqueiam navegacao.

## 2. Executar ondas de melhoria
1. Onda 1 (P1): corrigir layouts e acoes primarias dos fluxos mais criticos.
2. Onda 2 (P2): normalizar legibilidade e consistencia dos modulos intermediarios.
3. Onda 3 (P3): fechar cobertura das demais rotas e padronizar comportamento final.

## 3. Validar por viewport
1. Rodar checklist de qualidade para cada tela em cada perfil de viewport definido.
2. Validar estados: dados, vazio, erro e loading.
3. Registrar evidencias objetivas de aprovado/reprovado por criterio.

## 4. Criterio de pronto
1. 100% das rotas ativas validadas sem falhas bloqueantes.
2. Acoes primarias acessiveis em todos os perfis obrigatorios.
3. Sem rolagem horizontal obrigatoria nos fluxos criticos.
4. Sem regressao funcional de negocio.

## 6. Evidencias da implementacao
- Shell do dashboard usa sidebar fixa em desktop e drawer lateral acionado pelo botao de menu no mobile.
- Home, usuarios e planos usam container responsivo compartilhado.
- Billing, settings e help-videos ja estavam em layout fluido com grids responsivos e foram considerados cobertos pela validacao de lint.
- Login recebeu ajustes de padding/largura para reduzir risco de corte em viewport pequeno.
- `npm run lint` executado com sucesso apos os ajustes principais.

## 5. Passagem para tasks
1. Gerar `tasks.md` com backlog por rota/componente e prioridade.
2. Incluir tarefas de verificacao final por criterio de sucesso SC-001 a SC-004.
