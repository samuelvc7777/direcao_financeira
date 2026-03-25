# Requirements: Milestone v1.1 Home ativa com graficos reais

**Defined:** 2026-03-25
**Core Value:** ativar o grafico ja existente na home com dados reais vindos do Supabase, incluindo estados de loading, vazio, erro e comportamento funcional para uso real.

## v1 Requirements

### Dados Reais

- [ ] **HOME-01**: O grafico ja existente na home deve carregar dados reais vindos do Supabase
- [ ] **HOME-02**: Os dados exibidos no grafico devem refletir corretamente o mes selecionado na home
- [ ] **HOME-03**: O bloco do grafico nao deve mais depender de dados hardcoded ou placeholders fixos no `HomeController`

### Comportamento do Grafico

- [ ] **HOME-04**: Quando houver dados validos, o grafico deve renderizar categorias, percentuais e total de saidas de forma coerente com o periodo selecionado
- [ ] **HOME-05**: Quando nao houver dados para o periodo selecionado, a home deve exibir um estado vazio claro e utilizavel no lugar do grafico
- [ ] **HOME-06**: Quando ocorrer falha ao buscar ou transformar os dados do Supabase, a home deve exibir um estado de erro claro sem quebrar a tela

### Presentation e Fluxo

- [ ] **HOME-07**: A troca de mes na home deve atualizar o bloco do grafico para o novo periodo selecionado
- [ ] **HOME-08**: O bloco do grafico deve expor um estado de loading compreensivel para o usuario durante o carregamento real
- [ ] **HOME-09**: A home deve continuar carregando os demais blocos existentes sem regressao funcional enquanto o grafico passa a usar dados reais

### Qualidade

- [ ] **HOME-10**: A integracao do grafico com dados reais deve ficar testavel em camadas adequadas, sem concentrar toda a regra no widget
- [ ] **HOME-11**: Os cenarios de sucesso, vazio e erro do grafico devem ter cobertura automatizada compativel com a arquitetura atual

## Future Requirements

### Evolucao da Home

- **HOME-FUT-01**: Expandir a home para outros cards e resumos com dados reais apos estabilizar o grafico principal
- **HOME-FUT-02**: Revisar filtros adicionais, comparativos e periodos mais ricos para a experiencia analitica da home
- **HOME-FUT-03**: Evoluir a home com mais de um grafico ou visoes complementares quando a base de dados estiver consolidada

## Out of Scope

| Feature | Reason |
|---------|--------|
| Ativar todos os blocos da home no mesmo milestone | O foco atual e entregar primeiro o grafico principal com comportamento completo |
| Redesenhar a home inteira | O objetivo do milestone e funcionalidade real, nao redesign amplo |
| Trocar a fonte de dados para algo diferente de Supabase | A origem dos dados ja foi decidida para este ciclo |
| Implementar filtros analiticos avancados alem do mes atual | Isso amplia escopo antes de validar o fluxo principal do grafico |

## Traceability

| Requirement | Phase | Status |
|-------------|-------|--------|
| HOME-01 | Unmapped | Pending |
| HOME-02 | Unmapped | Pending |
| HOME-03 | Unmapped | Pending |
| HOME-04 | Unmapped | Pending |
| HOME-05 | Unmapped | Pending |
| HOME-06 | Unmapped | Pending |
| HOME-07 | Unmapped | Pending |
| HOME-08 | Unmapped | Pending |
| HOME-09 | Unmapped | Pending |
| HOME-10 | Unmapped | Pending |
| HOME-11 | Unmapped | Pending |

**Coverage:**
- v1 requirements: 11 total
- Mapped to phases: 0
- Unmapped: 11

---
*Requirements defined: 2026-03-25*
*Last updated: 2026-03-25 after milestone v1.1 definition*
