.PHONY: dev prod build down logs migrate shell

# ── Développement (PostgreSQL local) ─────────────────────────────────────────
dev:
	docker compose up --build

dev-bg:
	docker compose up --build -d

# ── Production (Neon) ─────────────────────────────────────────────────────────
prod:
	docker compose -f docker-compose.prod.yml up --build -d

prod-down:
	docker compose -f docker-compose.prod.yml down

# ── Arrêt et nettoyage ────────────────────────────────────────────────────────
down:
	docker compose down

down-volumes:
	docker compose down -v   # supprime aussi les volumes (reset DB)

# ── Logs ──────────────────────────────────────────────────────────────────────
logs:
	docker compose logs -f back

logs-db:
	docker compose logs -f db

# ── Prisma ────────────────────────────────────────────────────────────────────
migrate:
	docker compose exec back bunx prisma db push

studio:
	docker compose exec back bunx prisma studio

# ── Shell dans le container ───────────────────────────────────────────────────
shell:
	docker compose exec back sh

# ── Build seul (sans lancer) ─────────────────────────────────────────────────
build:
	docker compose build --no-cache
