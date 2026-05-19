ALTER TABLE "Transaction"
ADD COLUMN "recurrenceGroupId" TEXT,
ADD COLUMN "recurrenceNumber" INTEGER,
ADD COLUMN "recurrenceCount" INTEGER;

CREATE INDEX "Transaction_recurrenceGroupId_idx" ON "Transaction"("recurrenceGroupId");
