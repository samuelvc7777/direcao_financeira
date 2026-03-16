-- CreateEnum
CREATE TYPE "SubscriptionStatus" AS ENUM ('TRIAL', 'ACTIVE', 'PAST_DUE', 'CANCELED', 'EXPIRED');

-- CreateEnum
CREATE TYPE "PaymentStatus" AS ENUM ('PENDING', 'PAID', 'FAILED', 'REFUNDED', 'CANCELED');

-- CreateEnum
CREATE TYPE "PaymentMethod" AS ENUM ('PIX', 'CARD');

-- AlterTable
ALTER TABLE "Plan"
ADD COLUMN "code" TEXT,
ADD COLUMN "priceCents" INTEGER;

-- Backfill required plan fields before making them mandatory
UPDATE "Plan"
SET
  "code" = UPPER(REGEXP_REPLACE("name", '[^A-Za-z0-9]+', '_', 'g')),
  "priceCents" = ROUND("price" * 100)::INTEGER
WHERE "code" IS NULL OR "priceCents" IS NULL;

-- Ensure generated codes stay unique even if names collide
WITH duplicated_codes AS (
  SELECT "id", "code", ROW_NUMBER() OVER (PARTITION BY "code" ORDER BY "id") AS row_num
  FROM "Plan"
)
UPDATE "Plan" p
SET "code" = CONCAT(p."code", '_', duplicated_codes.row_num)
FROM duplicated_codes
WHERE p."id" = duplicated_codes."id"
  AND duplicated_codes.row_num > 1;

ALTER TABLE "Plan"
ALTER COLUMN "code" SET NOT NULL,
ALTER COLUMN "priceCents" SET NOT NULL;

-- CreateTable
CREATE TABLE "Subscription" (
    "id" SERIAL NOT NULL,
    "userId" INTEGER NOT NULL,
    "planId" INTEGER NOT NULL,
    "status" "SubscriptionStatus" NOT NULL DEFAULT 'ACTIVE',
    "startDate" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "endDate" TIMESTAMP(3),
    "canceledAt" TIMESTAMP(3),
    "autoRenew" BOOLEAN NOT NULL DEFAULT false,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Subscription_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Payment" (
    "id" SERIAL NOT NULL,
    "subscriptionId" INTEGER NOT NULL,
    "amountCents" INTEGER NOT NULL,
    "status" "PaymentStatus" NOT NULL DEFAULT 'PENDING',
    "method" "PaymentMethod" NOT NULL,
    "externalReference" TEXT,
    "dueDate" TIMESTAMP(3),
    "paidAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Payment_pkey" PRIMARY KEY ("id")
);

-- Backfill subscriptions from the legacy direct plan relation
INSERT INTO "Subscription" ("userId", "planId", "status", "startDate", "autoRenew", "createdAt", "updatedAt")
SELECT
  "id",
  "planId",
  'ACTIVE'::"SubscriptionStatus",
  CURRENT_TIMESTAMP,
  false,
  CURRENT_TIMESTAMP,
  CURRENT_TIMESTAMP
FROM "User"
WHERE "planId" IS NOT NULL;

-- CreateIndex
CREATE UNIQUE INDEX "Plan_code_key" ON "Plan"("code");

-- CreateIndex
CREATE INDEX "Subscription_userId_status_idx" ON "Subscription"("userId", "status");

-- CreateIndex
CREATE INDEX "Subscription_planId_idx" ON "Subscription"("planId");

-- CreateIndex
CREATE INDEX "Payment_subscriptionId_status_idx" ON "Payment"("subscriptionId", "status");

-- AddForeignKey
ALTER TABLE "Subscription" ADD CONSTRAINT "Subscription_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Subscription" ADD CONSTRAINT "Subscription_planId_fkey" FOREIGN KEY ("planId") REFERENCES "Plan"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Payment" ADD CONSTRAINT "Payment_subscriptionId_fkey" FOREIGN KEY ("subscriptionId") REFERENCES "Subscription"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- DropForeignKey
ALTER TABLE "User" DROP CONSTRAINT "User_planId_fkey";

-- AlterTable
ALTER TABLE "User" DROP COLUMN "planId";

-- AlterTable
ALTER TABLE "Plan" DROP COLUMN "price";
