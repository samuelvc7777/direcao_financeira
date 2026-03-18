# Arquitetura do Backend

## Visao geral

O backend segue NestJS como framework de borda e composicao, com organizacao interna por feature em estilo Clean Architecture.

Cada feature fica dentro de `src/modules/<feature>` e deve concentrar tudo o que pertence a esse contexto de negocio.

Estrutura padrao:

```text
src/
  app.module.ts
  main.ts
  common/
  prisma/
  test-utils/
  modules/
    <feature>/
      interface/
      application/
      domain/
      infrastructure/
```

## Responsabilidade por camada

### `interface`

Camada de entrada e saida da feature.

Aqui ficam:

- `*.controller.ts`
- `*.module.ts`
- `*.service.ts` apenas como fachada/orquestrador de borda, quando necessario
- `dto/`
- `decorators/`, `guards/`, `strategies/` e `types/` no caso de auth
- testes de montagem/contrato da interface quando fizer sentido

Regras:

- nao colocar regra de negocio complexa
- nao acessar Prisma diretamente
- receber input HTTP e delegar para use cases
- preservar contratos externos da API

### `application`

Camada de casos de uso.

Aqui ficam:

- `use-cases/`
- `presenters/` quando necessario para modelar resposta

Regras:

- orquestra fluxo de negocio
- depende de contratos do dominio
- nao conhece detalhes concretos de Prisma, Nest HTTP ou banco

### `domain`

Camada central da regra de negocio.

Aqui ficam:

- `entities/`
- `repositories/` com contratos
- `services/` com regra pura e invariantes

Regras:

- nao importar NestJS HTTP, PrismaService ou detalhes de infra
- concentrar validacoes e comportamento de negocio puro

### `infrastructure`

Camada concreta de integracao.

Aqui ficam:

- repositories Prisma
- adapters de JWT, hash, gateways externos

Regras:

- implementa contratos do dominio
- encapsula Prisma, transacoes e integracoes externas

## Convencoes adotadas

- nomear casos de uso com verbo de negocio, por exemplo `CreatePlanUseCase`
- nomear contratos por intencao, por exemplo `PlanRepository`
- nomear implementacoes concretas com tecnologia, por exemplo `PrismaPlanRepository`
- manter imports apontando para a propria feature sempre que possivel
- evitar criar pastas globais por tipo tecnico fora de `modules/`

## Convencao de testes

Padrao atual:

- testes de contrato HTTP ficam em `test/*.contract.e2e-spec.ts`
- testes e2e gerais ficam em `test/*.e2e-spec.ts`
- testes unitarios de use case e domain service ficam proximos ao codigo
- testes de interface legada/fachada ficam em `src/modules/<feature>/interface/tests`

Objetivo:

- comportamento de negocio coberto perto da regra
- contrato externo coberto no nivel HTTP
- montagem de controllers/services coberta sem depender de banco real

## Dependencias permitidas

Fluxo de dependencia esperado:

```text
interface -> application -> domain
infrastructure -> domain
```

Regras praticas:

- `interface` pode usar `application`
- `application` pode usar contratos e servicos de `domain`
- `infrastructure` pode usar contratos de `domain`
- `domain` nao deve depender de `interface`, `application` nem `infrastructure`

## O que evitar

- controller chamando Prisma direto
- regra de negocio espalhada em controller, guard ou DTO
- use case importando `PrismaService`
- repository concreto vazando detalhes tecnicos para controller
- criar novas features fora de `src/modules`

## Como evoluir uma feature nova

Ordem recomendada:

1. criar contratos e regras em `domain`
2. criar use cases em `application`
3. implementar adapters concretos em `infrastructure`
4. expor endpoints em `interface`
5. adicionar testes unitarios e de contrato

## Estado atual

Features principais padronizadas:

- `admin`
- `auth`
- `finance`
- `plan`
- `subscription`
- `user`

O backend deve continuar evoluindo dentro desse padrao. Novas features ou refatores devem manter a organizacao por feature e a separacao entre `interface`, `application`, `domain` e `infrastructure`.
