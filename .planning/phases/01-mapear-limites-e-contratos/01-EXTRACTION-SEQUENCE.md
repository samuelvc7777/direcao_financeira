# Extraction Sequence

## Objetivo

Definir a ordem segura de extracao para as proximas fases, reduzindo regressao funcional na tela de turnos.

## Criterios de pronto da Fase 1

A Fase 1 pode ser considerada concluida quando:

- existe mapa explicito do que fica e do que sai do `JourneyController`
- a arquitetura alvo da jornada esta documentada
- a sequencia de implementacao entre Fase 2 e Fase 3 esta clara
- a compatibilidade com `nest` e `supabase` foi preservada como restricao arquitetural

## Fase 2: o que entra primeiro

### Etapa 1

Extrair o ciclo de vida do turno para um coordenador dedicado:

- iniciar turno
- pausar turno
- retomar turno
- finalizar turno

Motivo:

- e o bloco com mais efeito colateral operacional
- concentra refresh, sincronizacao, feedback e validacao de pre-condicoes

### Etapa 2

Extrair o runtime operacional:

- tracking
- permissao de localizacao
- watch de status
- bind de realtime
- sincronizacao quando a conexao volta

Motivo:

- hoje esse bloco mistura `core`, stream, conectividade e refresh de UI
- a extracao reduz risco de quebrar a tela inteira ao mexer em comportamento operacional

### Etapa 3

Agrupar side effects de plataforma ligados ao runtime:

- semaforo
- acessibilidade
- assistente flutuante
- feedback operacional recorrente

Motivo:

- esses fluxos nao precisam continuar no controller principal
- sao pontos naturais para ficarem perto do coordenador operacional

## Fase 3: o que fica explicitamente para depois

### Etapa 4

Reorganizar o estado de leitura e composicao visual:

- historico de turnos
- corridas e filtros
- resumos por forma de pagamento
- estados de loading e erro por secao

### Etapa 5

Refinar metricas derivadas e presentation:

- composicao final de metricas
- custo operacional derivado
- distribuicao mais clara entre view e widgets

### Etapa 6

Avaliar se `JourneyController` continua unico ou se vale dividir parte do estado de tela em blocos auxiliares pequenos.

## Dependencias entre blocos

- O coordenador de ciclo de vida do turno vem antes porque tracking e sincronizacao reagem ao estado do turno.
- O runtime coordinator depende de contratos claros de start/pause/resume/finish para nao duplicar decisao.
- A reorganizacao de historico e corridas fica depois porque esses blocos consomem estado mais estavel quando o runtime ja estiver isolado.
- A limpeza final de presentation depende da reducao previa do acoplamento operacional.

## Riscos por bloco

### Ciclo de vida do turno

Risco:

- regressao em iniciar, pausar, retomar ou finalizar turno

Mitigacao:

- manter os mesmos use cases
- preservar mensagens e refresh existentes
- validar sincronizacao offline apos finish

### Tracking e localizacao

Risco:

- quebrar atualizacao de distancia, idle time ou fluxo de permissao

Mitigacao:

- extrair sem alterar contratos de `GetLocationTrackingStatusUseCase` e `WatchLocationTrackingStatusUseCase`
- manter follow-up de settings e warning atual

### Realtime e sincronizacao

Risco:

- parar de sincronizar pendencias ao voltar a conexao

Mitigacao:

- manter `JourneyRealtimeBridge` como dependencia central
- concentrar `_handleConnectionStatusChanged` e `_syncPendingShifts` num unico bloco

### Semaforo e assistente

Risco:

- side effects de plataforma deixarem a UI inconsistente

Mitigacao:

- extrair junto do runtime, nao em paralelo isolado
- preservar leitura de estado atual no carregamento da tela

### Historico, corridas e metricas

Risco:

- gerar refatoracao ampla demais cedo demais

Mitigacao:

- adiar para a Fase 3
- tratar primeiro a reducao do acoplamento operacional

## Regra de sequenciamento

- Fase 2 reduz responsabilidade operacional do controller.
- Fase 3 reorganiza estado e composicao da tela em cima de limites ja estabilizados.
- Fase 4 valida tudo com testes e verificacao.

## Resultado de continuidade

Com essa ordem, a Fase 2 ataca o maior risco estrutural sem abrir redesign visual. A Fase 3 passa a atuar sobre presentation e widgets com menos chance de reintroduzir acoplamento no `JourneyController`.
