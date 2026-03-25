# Target Architecture: Jornada

## Visao geral

A arquitetura alvo da jornada mantem `JourneyView` como composicao macro da tela e preserva `JourneyController` como ponto principal de entrada da UI. A mudanca principal e reduzir o tamanho do controller, deslocando orquestracao operacional e composicao derivada para poucos componentes centrais, com fronteiras explicitas entre `presentation/domain/data/core`.

Esta fase nao implementa a extracao. Ela apenas fixa os contratos e os limites que orientam as Fases 2 e 3.

## Componentes centrais propostos

### 1. JourneyView

Continua responsavel por:

- estrutura macro da tela
- tabs, secoes e navegacao local
- renderizacao de widgets menores da pasta `journey/widgets`

Nao deve absorver:

- regras de negocio
- sincronizacao operacional
- calculos pesados de metricas
- detalhes de permissao ou dialogos operacionais

### 2. JourneyController

Continua responsavel por:

- receber eventos de alto nivel da `JourneyView`
- expor estado observavel consolidado para a tela
- compor resultados vindos dos componentes especializados
- decidir quando a UI precisa refrescar estados macro

Deixa de ser responsavel direto por:

- ciclo de vida do turno
- tracking, realtime e sincronizacao
- assistente flutuante e semaforo
- implementacao detalhada dos calculos derivados de metricas

### 3. ShiftLifecycleCoordinator

Componente de `presentation` que orquestra:

- iniciar turno
- pausar turno
- retomar turno
- finalizar turno

Entradas principais:

- comandos vindos do `JourneyController`
- use cases de turno da camada `domain`

Saidas principais:

- resultado operacional normalizado
- pedido de refresh de jornada
- feedback estruturado para a camada de presentation

### 4. JourneyRuntimeCoordinator

Componente de `presentation` para a parte operacional em tempo real, apoiado em `core`:

- bind e unbind do `JourneyRealtimeBridge`
- escuta de `WatchLocationTrackingStatusUseCase`
- leitura do status de tracking
- follow-up de sincronizacao de pendencias
- orquestracao de permissoes relacionadas ao runtime
- integracao de semaforo e assistente quando isso fizer sentido

Entradas principais:

- eventos de conectividade
- eventos de ciclo de vida do turno
- servicos de `core`

Saidas principais:

- estado operacional simplificado para o `JourneyController`
- comandos de refresh quando houver mudanca real
- eventos de feedback ao usuario

### 5. JourneyMetricsComposerFacade

Componente para centralizar:

- composicao de metricas exibidas na tela
- reconcilio entre estatistica carregada, turno ativo e tracking
- calculo derivado de custo operacional
- resumo por forma de pagamento

Ele deve consumir entidades e estados ja carregados, sem virar um novo repositorio e sem assumir IO.

## Fronteiras por camada

### presentation/domain/data/core

#### presentation

- `JourneyView`
- `JourneyController`
- `ShiftLifecycleCoordinator`
- `JourneyRuntimeCoordinator`
- `JourneyMetricsComposerFacade`
- possiveis subestados de historico e corridas na Fase 3

#### domain

- use cases de jornada
- entidades de turno, estatistica, tracking, rota e corridas
- contratos de repositorio

#### data

- `JourneyRepositoryImpl`
- datasources locais e remotos
- `JourneyShiftLifecycleService`
- `JourneySyncService`

#### core

- `JourneyRealtimeBridge`
- `AccessibilityService`
- `AppBubbleService`
- infraestrutura global de provider, sessao, feedback e conectividade

## Contratos principais

### Contrato 1: controller principal para coordenadores

O `JourneyController` dispara comandos e recebe respostas normalizadas dos coordenadores. O objetivo e evitar que o controller conheca detalhes de permissao, stream, conectividade ou sincronizacao.

### Contrato 2: coordenadores para use cases

`ShiftLifecycleCoordinator` e `JourneyRuntimeCoordinator` falam com `domain` via use cases, preservando a independencia de provider.

### Contrato 3: presentation para core

Quando houver dependencia de plataforma, bridge ou servico transversal, ela deve ficar encapsulada no coordenador apropriado. A `JourneyView` nao chama `AppBubbleService` nem `AccessibilityService` diretamente.

### Contrato 4: presentation para data

A presentation nao passa a falar com datasource nem com implementacao concreta de repositorio. `JourneyRepositoryImpl` continua escondido atras de interfaces e bindings existentes.

## Relacao com JourneyBinding

`JourneyBinding` continua sendo o ponto de composicao da feature. A evolucao esperada e:

- manter o registro dos use cases atuais
- adicionar registro dos coordenadores/facades novos
- injetar no `JourneyController` apenas os blocos que ele realmente precisa coordenar

Isso evita espalhar inicializacao da feature e preserva o padrao atual de GetX.

## Compatibilidade com nest e supabase

Compatibilidade com `nest` e `supabase` deve ser preservada porque:

- a refatoracao proposta atua principalmente na `presentation`
- os contratos da `domain` permanecem os mesmos
- `provider_binding.dart` continua como ponto de decisao da implementacao concreta
- `JourneyRepositoryImpl` e seus contratos continuam isolando detalhes de provider

Decisao explicita: nenhum novo componente da jornada deve conter `if` por provider para reproduzir regra de negocio. Se surgir diferenca de infraestrutura, ela continua encapsulada abaixo da fronteira de repositorio/binding.

## O que fica no JourneyController

- estado reativo de alto nivel da tela
- roteamento interno de eventos da UI
- sincronizacao de subestados vindos dos componentes especializados
- exposicao de getters e flags consumidos pela view

## O que fica fora do JourneyController

- detalhes do ciclo de vida do turno
- escuta e decisao de runtime em tracking/realtime
- side effects de assistente e semaforo
- calculo derivado mais denso de metricas e agregacoes

## O que ainda nao sera extraido nesta fase

Esta fase nao:

- cria novas classes de producao
- muda UX da jornada
- reorganiza profundamente os widgets
- altera contratos de `domain`
- mexe em `provider_binding.dart` alem de usar sua compatibilidade como restricao

## Limites para a Fase 3

Historico, corridas e presentation refinada ficam para a Fase 3 porque:

- primeiro precisamos remover o acoplamento operacional mais perigoso
- so depois vale redistribuir subestados de tela e composicao visual
- isso protege a `JourneyView` de receber extracoes apressadas

## Resultado esperado

Com essa arquitetura alvo, a feature continua com uma entrada principal clara, mas deixa de depender de um `JourneyController` monolitico. O ganho procurado e mais testabilidade, menos side effect espalhado e base melhor para novas funcionalidades da tela de turnos.
