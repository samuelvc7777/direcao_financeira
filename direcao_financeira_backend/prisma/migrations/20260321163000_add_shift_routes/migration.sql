CREATE TABLE "ShiftRoute" (
    "id" SERIAL NOT NULL,
    "shiftId" INTEGER NOT NULL,
    "points" JSONB NOT NULL,
    "pointCount" INTEGER NOT NULL DEFAULT 0,
    "totalDistanceMeters" DOUBLE PRECISION NOT NULL DEFAULT 0,
    "startedAt" TIMESTAMP(3) NOT NULL,
    "endedAt" TIMESTAMP(3) NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "ShiftRoute_pkey" PRIMARY KEY ("id")
);

CREATE UNIQUE INDEX "ShiftRoute_shiftId_key" ON "ShiftRoute"("shiftId");

ALTER TABLE "ShiftRoute"
ADD CONSTRAINT "ShiftRoute_shiftId_fkey"
FOREIGN KEY ("shiftId") REFERENCES "Shift"("id") ON DELETE CASCADE ON UPDATE CASCADE;
