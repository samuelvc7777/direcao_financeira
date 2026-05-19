alter table public."Subscription"
  add column if not exists "googlePlayProductId" text,
  add column if not exists "googlePlayPurchaseToken" text,
  add column if not exists "googlePlayOrderId" text,
  add column if not exists "googlePlayLinkedAt" timestamptz,
  add column if not exists "googlePlayExpiresAt" timestamptz;

create unique index if not exists "Subscription_googlePlayPurchaseToken_key"
  on public."Subscription" ("googlePlayPurchaseToken")
  where "googlePlayPurchaseToken" is not null;

create index if not exists "Subscription_googlePlayProductId_idx"
  on public."Subscription" ("googlePlayProductId");

create table if not exists public."GooglePlaySubscriptionEvent" (
  "id" bigserial primary key,
  "purchaseToken" text not null,
  "productId" text,
  "notificationType" integer,
  "eventTime" timestamptz,
  "payload" jsonb not null,
  "processedAt" timestamptz,
  "createdAt" timestamptz not null default now()
);

create index if not exists "GooglePlaySubscriptionEvent_purchaseToken_idx"
  on public."GooglePlaySubscriptionEvent" ("purchaseToken");

create index if not exists "GooglePlaySubscriptionEvent_createdAt_idx"
  on public."GooglePlaySubscriptionEvent" ("createdAt" desc);
