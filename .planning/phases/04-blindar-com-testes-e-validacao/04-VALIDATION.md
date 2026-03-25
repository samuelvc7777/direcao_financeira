# Validacao Final da Fase 4

## Objetivo

Validar a refatoracao da jornada combinando prova automatizada e smoke funcional curto nos fluxos que mais expõem regressao ao usuario: turno ativo, historico, corridas e tracking/permissoes.

## Prova automatizada obrigatoria

Os comandos abaixo precisam passar antes do smoke manual:

```powershell
flutter test test/app/presentation/modules/journey/shift_lifecycle_coordinator_test.dart test/app/presentation/modules/journey/journey_runtime_coordinator_test.dart
flutter test test/presentation/controllers/controller_contract_test.dart --reporter expanded
```

## Smoke manual enxuto

### 1. Turno ativo

Passos:
- Abrir a tela `/journey`
- Iniciar um turno
- Confirmar que o estado ativo aparece corretamente
- Pausar e retomar o turno
- Encerrar o turno

Sinais esperados:
- feedback coerente de inicio, pausa, retomada e encerramento
- tempo e quilometragem visiveis sem estado inconsistente
- nenhum travamento ou retorno para estado anterior indevido

### 2. Historico

Passos:
- Permanecer na aba de turnos
- Validar a lista de historico recente
- Usar o filtro de periodo quando necessario

Sinais esperados:
- historico carregado sem erro inesperado
- totalizadores coerentes com a lista exibida
- mensagem de erro normalizada apenas quando houver falha real de carga

### 3. Corridas

Passos:
- Abrir a aba de corridas
- Alternar entre filtros como `Todos`, `Pendentes` e `Finalizados`
- Abrir o detalhe de uma corrida

Sinais esperados:
- filtros atualizam a lista sem quebrar o estado da tela
- contagem exibida acompanha o filtro ativo
- detalhes continuam acessiveis pelos caminhos existentes

### 4. Tracking/permissoes

Passos:
- Validar o banner e o estado de tracking/permissoes com localizacao completa
- Repetir em um cenario com permissao faltando ou tracking incompleto

Sinais esperados:
- banner coerente com o estado atual
- CTA de ajustes aparece apenas quando necessario
- mensagens ligadas a tracking/permissoes continuam compreensiveis e consistentes

## Criterio de saida da fase

A fase pode ser considerada pronta quando:
- os testes automatizados acima passam
- o smoke de turno ativo, historico, corridas e tracking/permissoes passa
- nao ha regressao observavel nos contratos novos da jornada
- os riscos residuais aceitos estao registrados no `04-RISK-REPORT.md`

## Registro desta execucao

- Coordenadores: validacao automatizada planejada e concluida
- Controller: validacao automatizada planejada e concluida
- Smoke manual: aguardando confirmacao humana
