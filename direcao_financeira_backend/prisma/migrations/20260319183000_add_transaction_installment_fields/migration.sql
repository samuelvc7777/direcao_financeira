ALTER TABLE "Transaction"
ADD COLUMN "installmentGroupId" TEXT,
ADD COLUMN "installmentNumber" INTEGER,
ADD COLUMN "installmentCount" INTEGER;

CREATE INDEX "Transaction_installmentGroupId_idx" ON "Transaction"("installmentGroupId");
