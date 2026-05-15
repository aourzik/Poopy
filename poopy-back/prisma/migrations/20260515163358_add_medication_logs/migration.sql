/*
  Warnings:

  - You are about to drop the column `date` on the `Medication` table. All the data in the column will be lost.
  - You are about to drop the column `dosage` on the `Medication` table. All the data in the column will be lost.
  - You are about to drop the column `taken` on the `Medication` table. All the data in the column will be lost.
  - Added the required column `dose` to the `Medication` table without a default value. This is not possible if the table is not empty.
  - Added the required column `frequency` to the `Medication` table without a default value. This is not possible if the table is not empty.

*/
-- AlterTable
ALTER TABLE "Medication" DROP COLUMN "date",
DROP COLUMN "dosage",
DROP COLUMN "taken",
ADD COLUMN     "color" TEXT NOT NULL DEFAULT 'amber',
ADD COLUMN     "dose" TEXT NOT NULL,
ADD COLUMN     "frequency" TEXT NOT NULL,
ADD COLUMN     "isInjection" BOOLEAN NOT NULL DEFAULT false,
ADD COLUMN     "totalToday" INTEGER;

-- CreateTable
CREATE TABLE "MedicationLog" (
    "id" TEXT NOT NULL,
    "takenAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "medicationId" TEXT NOT NULL,

    CONSTRAINT "MedicationLog_pkey" PRIMARY KEY ("id")
);

-- AddForeignKey
ALTER TABLE "MedicationLog" ADD CONSTRAINT "MedicationLog_medicationId_fkey" FOREIGN KEY ("medicationId") REFERENCES "Medication"("id") ON DELETE CASCADE ON UPDATE CASCADE;
