# Padrao de Banco de Dados - Proxima Fase

## Objetivo

Evoluir o banco atual para suportar crescimento da aplicacao sem acoplar o usuario diretamente ao plano contratado.

Hoje o sistema possui:

- `User`
- `Plan`
- Relacao direta `user.planId`

Isso funciona no inicio, mas limita:

- historico de mudanca de plano
- renovacao de assinatura
- cancelamento sem perda de historico
- cobranca e controle de pagamentos
- auditoria

## Padrao recomendado

Separar o banco em 4 camadas:

1. Identidade: quem usa o sistema
2. Catalogo: quais planos existem
3. Assinatura: qual plano foi contratado e em que periodo
4. Financeiro: o que foi cobrado e pago

## Entidades recomendadas

### `users`

Responsavel pelos dados de acesso e perfil.

Campos base:

- `id`
- `name`
- `email`
- `password_hash`
- `role`
- `is_active`
- `created_at`
- `updated_at`
- `deleted_at` opcional para soft delete

Regras:

- `email` deve ser unico
- `password` nunca deve ser salvo com esse nome no banco; use `password_hash`
- `role` deve continuar em enum

### `plans`

Representa o catalogo de planos disponiveis para venda.

Campos base:

- `id`
- `code`
- `name`
- `description`
- `price_cents`
- `duration_days`
- `color`
- `is_active`
- `created_at`
- `updated_at`

Regras:

- `code` deve ser unico e estavel, por exemplo `BASICO`, `PRO`, `PREMIUM`
- preferir `price_cents` em vez de `Float`
- o plano nao deve guardar quem esta usando; essa informacao pertence a assinatura

### `subscriptions`

Nova entidade principal da proxima fase.

Representa a contratacao de um plano por um usuario.

Campos base:

- `id`
- `user_id`
- `plan_id`
- `status`
- `start_date`
- `end_date`
- `canceled_at`
- `auto_renew`
- `created_at`
- `updated_at`

Status sugeridos:

- `TRIAL`
- `ACTIVE`
- `PAST_DUE`
- `CANCELED`
- `EXPIRED`

Regras:

- um usuario pode ter varias assinaturas ao longo do tempo
- idealmente apenas uma assinatura ativa por usuario
- o historico deve ser preservado

### `payments`

Responsavel pelo controle financeiro de cada assinatura.

Campos base:

- `id`
- `subscription_id`
- `amount_cents`
- `status`
- `method`
- `external_reference`
- `due_date`
- `paid_at`
- `created_at`
- `updated_at`

Status sugeridos:

- `PENDING`
- `PAID`
- `FAILED`
- `REFUNDED`
- `CANCELED`

Metodos sugeridos:

- `PIX`
- `CARD`

Decisao recomendada para este projeto:

- manter apenas meios digitais de alta adesao no Brasil
- nao modelar `BOLETO` nem `CASH` nesta fase

## Relacionamentos

Padrao recomendado:

- `User 1:N Subscription`
- `Plan 1:N Subscription`
- `Subscription 1:N Payment`

Padrao atual que deve ser evitado na proxima fase:

- `User N:1 Plan` por `planId` direto no usuario

## Convencoes

### Nomenclatura

- tabelas no plural: `users`, `plans`, `subscriptions`, `payments`
- colunas em `snake_case`
- foreign keys com sufixo `_id`
- timestamps padrao: `created_at`, `updated_at`

### Tipos

- `Int` para ids numericos simples
- `String` para nomes, codigos e referencias externas
- `Boolean` para flags
- `DateTime` para datas e eventos
- valores monetarios em centavos

### Integridade

- indices em todas as foreign keys
- unique em `users.email`
- unique em `plans.code`
- indice composto em `subscriptions(user_id, status)`
- validar exclusao com historico em vez de apagar dados sensiveis

### Exclusao

- evitar delete fisico em entidades de negocio
- preferir `is_active` ou `deleted_at`
- pagamentos e assinaturas devem manter historico

## Exemplo de modelagem Prisma

```prisma
enum Role {
  USER
  ADMIN
  ATTENDANT
}

enum SubscriptionStatus {
  TRIAL
  ACTIVE
  PAST_DUE
  CANCELED
  EXPIRED
}

enum PaymentStatus {
  PENDING
  PAID
  FAILED
  REFUNDED
  CANCELED
}

enum PaymentMethod {
  PIX
  CARD
}

model User {
  id            Int            @id @default(autoincrement())
  name          String
  email         String         @unique
  passwordHash  String         @map("password_hash")
  role          Role           @default(USER)
  isActive      Boolean        @default(true) @map("is_active")
  createdAt     DateTime       @default(now()) @map("created_at")
  updatedAt     DateTime       @updatedAt @map("updated_at")
  deletedAt     DateTime?      @map("deleted_at")
  subscriptions Subscription[]

  @@map("users")
}

model Plan {
  id            Int            @id @default(autoincrement())
  code          String         @unique
  name          String
  description   String
  priceCents    Int            @map("price_cents")
  durationDays  Int            @map("duration_days")
  color         String
  isActive      Boolean        @default(true) @map("is_active")
  createdAt     DateTime       @default(now()) @map("created_at")
  updatedAt     DateTime       @updatedAt @map("updated_at")
  subscriptions Subscription[]

  @@map("plans")
}

model Subscription {
  id          Int                @id @default(autoincrement())
  userId      Int                @map("user_id")
  planId      Int                @map("plan_id")
  status      SubscriptionStatus
  startDate   DateTime           @map("start_date")
  endDate     DateTime?          @map("end_date")
  canceledAt  DateTime?          @map("canceled_at")
  autoRenew   Boolean            @default(false) @map("auto_renew")
  createdAt   DateTime           @default(now()) @map("created_at")
  updatedAt   DateTime           @updatedAt @map("updated_at")
  user        User               @relation(fields: [userId], references: [id])
  plan        Plan               @relation(fields: [planId], references: [id])
  payments    Payment[]

  @@index([userId, status])
  @@index([planId])
  @@map("subscriptions")
}

model Payment {
  id                Int           @id @default(autoincrement())
  subscriptionId    Int           @map("subscription_id")
  amountCents       Int           @map("amount_cents")
  status            PaymentStatus
  method            PaymentMethod
  externalReference String?       @map("external_reference")
  dueDate           DateTime?     @map("due_date")
  paidAt            DateTime?     @map("paid_at")
  createdAt         DateTime      @default(now()) @map("created_at")
  updatedAt         DateTime      @updatedAt @map("updated_at")
  subscription      Subscription  @relation(fields: [subscriptionId], references: [id])

  @@index([subscriptionId, status])
  @@map("payments")
}
```

## Migracao recomendada

Fazer em etapas para evitar quebra no backend:

1. Criar `subscriptions` e `payments`
2. Migrar usuarios com `planId` para uma assinatura inicial
3. Ajustar servicos para ler o plano ativo via assinatura
4. Remover dependencias de `user.planId`
5. So depois remover `planId` de `users`

## Regras de negocio recomendadas

- admin e attendant podem existir sem assinatura
- user final deve ter no maximo uma assinatura ativa
- mudanca de plano gera nova assinatura ou atualiza periodo de forma auditavel
- cancelamento nao apaga historico
- plano inativo nao pode ser vendido, mas pode continuar ligado a historico antigo

## Decisoes que valem a pena manter desde ja

- usar `snake_case` no banco
- usar `@@map` e `@map` no Prisma se quiser manter codigo em camelCase
- evitar `Float` para dinheiro
- separar autenticacao de assinatura
- preparar todas as entidades de negocio com timestamps
- restringir meios de pagamento a `PIX` e `CARD`

## Resumo

Para a proxima fase, o melhor padrao para este projeto e:

- manter `User` como identidade
- manter `Plan` como catalogo
- criar `Subscription` como centro da regra de negocio
- criar `Payment` para o fluxo financeiro

Esse desenho encaixa bem no backend atual em Nest + Prisma e permite crescer sem retrabalho estrutural.
