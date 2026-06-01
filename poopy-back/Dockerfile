# ─────────────────────────────────────────────────────────────
# Stage 1 — Dépendances
# ─────────────────────────────────────────────────────────────
FROM oven/bun:1-alpine AS deps

WORKDIR /app

COPY package.json bun.lock* ./
RUN bun install --frozen-lockfile


# ─────────────────────────────────────────────────────────────
# Stage 2 — Génération du client Prisma
# ─────────────────────────────────────────────────────────────
FROM oven/bun:1-alpine AS prisma-gen

WORKDIR /app

COPY --from=deps /app/node_modules ./node_modules
COPY package.json ./
COPY prisma ./prisma

RUN bunx prisma generate


# ─────────────────────────────────────────────────────────────
# Stage 3 — Image de production (minimale et sécurisée)
# ─────────────────────────────────────────────────────────────
FROM oven/bun:1-alpine AS runner

WORKDIR /app

# Utilisateur non-root pour la sécurité
RUN addgroup --system --gid 1001 poopy \
 && adduser  --system --uid 1001 --ingroup poopy poopy

# Copie uniquement ce qui est nécessaire
COPY --from=prisma-gen /app/node_modules ./node_modules
COPY src            ./src
COPY prisma         ./prisma
COPY prisma.config.ts ./prisma.config.ts
COPY package.json   ./

COPY entrypoint.sh ./entrypoint.sh
RUN chmod +x ./entrypoint.sh

USER poopy

EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=5s --start-period=20s --retries=3 \
  CMD wget -qO- http://localhost:3000/ || exit 1

ENTRYPOINT ["./entrypoint.sh"]
