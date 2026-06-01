#!/bin/sh
set -e

echo "🔧 Synchronisation du schéma Prisma..."
bunx prisma db push --url "$DATABASE_URL"

echo "🚀 Démarrage du serveur Poopy..."
exec bun run src/index.ts
