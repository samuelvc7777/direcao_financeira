-- CreateTable
CREATE TABLE "CostsGainsSettings" (
    "id" SERIAL NOT NULL,
    "userId" INTEGER NOT NULL,
    "desiredMonthlyProfitCents" INTEGER NOT NULL,
    "workDaysPerWeek" INTEGER NOT NULL,
    "workHoursPerDay" DOUBLE PRECISION NOT NULL,
    "kmPerDay" DOUBLE PRECISION NOT NULL,
    "financeOrRentMonthlyCents" INTEGER NOT NULL,
    "insuranceMonthlyCents" INTEGER NOT NULL,
    "maintenanceMonthlyCents" INTEGER NOT NULL,
    "annualTaxesCents" INTEGER NOT NULL,
    "fuelPricePerLiterCents" INTEGER NOT NULL,
    "kmPerLiter" DOUBLE PRECISION NOT NULL,
    "platformFeeType" TEXT NOT NULL,
    "platformFeeValue" DOUBLE PRECISION NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "CostsGainsSettings_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "CostsGainsSettings_userId_key" ON "CostsGainsSettings"("userId");

-- CreateIndex
CREATE INDEX "CostsGainsSettings_userId_idx" ON "CostsGainsSettings"("userId");

-- AddForeignKey
ALTER TABLE "CostsGainsSettings" ADD CONSTRAINT "CostsGainsSettings_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
