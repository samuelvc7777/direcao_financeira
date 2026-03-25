# Risk Report da Fase 4

## Riscos cobertos nesta fase

- regressao nos contratos de `ShiftLifecycleCoordinator` em start, pause/resume e finish
- regressao nos contratos de `JourneyRuntimeCoordinator` em bind/unbind, tracking, sincronizacao e assistente
- regressao no `JourneyController` em reconexao, banner derivado, tracking/permissoes, filtros de corridas e metricas derivadas
- perda de previsibilidade na camada de presentation ao evoluir a jornada

## Riscos residuais aceitos agora

- o smoke funcional final ainda depende de confirmacao humana na build do app
- ainda existe codigo legado inativo fora do caminho critico, especialmente em partes antigas de metricas
- a blindagem atual e forte para contrato e fluxo critico, mas nao cobre toda a interface com widget test amplo

## Trabalhos explicitamente fora de escopo

- limpeza arquitetural adicional fora do necessario para blindagem da fase
- ampliacao de testes end-to-end completos da jornada
- redesign visual ou reorganizacao estrutural nova da feature

## Criterio de saida aplicado

A fase fecha quando os contratos novos estao cobertos por testes automatizados, os fluxos criticos estao validados por smoke funcional e os riscos residuais acima ficam explicitados sem reabrir refatoracao grande.
