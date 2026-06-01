import { Elysia, t } from "elysia";
import { cors } from '@elysiajs/cors';
import { PrismaClient } from "@prisma/client";
import { PrismaPg } from "@prisma/adapter-pg";
import { Pool } from "pg";

const connectionString = Bun.env.DATABASE_URL;
if (!connectionString) {
  console.error("❌ Erreur : DATABASE_URL manquante.");
  process.exit(1);
}

const pool = new Pool({ connectionString });
const adapter = new PrismaPg(pool);
const prisma = new PrismaClient({ adapter });

const app = new Elysia()
  .use(cors())
  .get("/", () => ({ status: "Poopy API is running 💩" }))

  // ---------------------------------------------------------
  // 👤 GROUPE : UTILISATEURS
  // ---------------------------------------------------------
  .group("/user", (group) =>
    group
      .post("/", async ({ body, set }) => {
        try {
          const existing = await prisma.user.findUnique({ where: { email: body.email } });
          if (existing) {
            set.status = 409;
            return { error: "Un compte existe déjà avec cet email." };
          }
          const user = await prisma.user.create({
            data: { email: body.email, name: body.name, diagnosis: body.diagnosis ?? null }
          });
          return user;
        } catch (error) {
          console.error("❌ Erreur Create User:", error);
          set.status = 500;
          return { error: "Erreur lors de la création du compte" };
        }
      }, {
        body: t.Object({
          email: t.String({ format: 'email' }),
          name: t.String(),
          diagnosis: t.Optional(t.String()),
        })
      })

      .get("/login", async ({ query, set }) => {
        const { email, name } = query;
        if (!email) { set.status = 400; return { error: "Email requis" }; }
        const user = await prisma.user.findUnique({ where: { email } });
        if (!user) { set.status = 404; return { error: "Aucun compte trouvé avec cet email." }; }
        if (name && user.name.toLowerCase() !== name.toLowerCase()) {
          set.status = 401;
          return { error: "Nom d'utilisateur incorrect." };
        }
        return user;
      })

      .get("/:id", async ({ params }) => {
        return await prisma.user.findUnique({ where: { id: params.id } });
      })

      .patch("/:id", async ({ params, body, set }) => {
        try {
          const updated = await prisma.user.update({
            where: { id: params.id },
            data: {
              ...(body.name !== undefined && { name: body.name }),
              ...(body.diagnosis !== undefined && { diagnosis: body.diagnosis }),
              ...(body.avatarUrl !== undefined && { avatarUrl: body.avatarUrl }),
            },
          });
          return updated;
        } catch (error) {
          console.error("❌ Erreur Update User:", error);
          set.status = 500;
          return { error: "Impossible de mettre à jour l'utilisateur" };
        }
      }, {
        body: t.Object({
          name: t.Optional(t.String()),
          diagnosis: t.Optional(t.String()),
          avatarUrl: t.Optional(t.String()),
        })
      })
  )

  // ---------------------------------------------------------
  // 💩 GROUPE : SELLES (STOOLS)
  // ---------------------------------------------------------
  .group("/stool", (group) =>
    group
      .post("/", async ({ body, set }) => {
        try {
          const { id, userId, bristol, count, blood, urgency, date } = body;
          const isUpdate = id && id !== "" && id !== "null" && id !== "undefined";

          if (isUpdate) {
            return await prisma.stool.update({
              where: { id },
              data: { bristol, count, blood, urgency, date: date ? new Date(date) : undefined },
            });
          }

          return await prisma.stool.create({
            data: { userId, bristol, count, blood, urgency, date: date ? new Date(date) : new Date() },
          });
        } catch (error) {
          console.error("❌ Erreur Prisma Stool:", error);
          set.status = 500;
          return { error: "Erreur lors de l'enregistrement" };
        }
      }, {
        body: t.Object({
          id: t.Optional(t.String()),
          userId: t.String(),
          bristol: t.Integer(),
          count: t.Integer(),
          blood: t.Boolean(),
          urgency: t.Boolean(),
          date: t.Optional(t.String())
        })
      })

      .get("/user/:userId", async ({ params, set }) => {
        try {
          return await prisma.stool.findMany({
            where: { userId: params.userId },
            orderBy: { date: 'desc' }
          });
        } catch (error) {
          console.error("❌ Erreur Fetch Stools:", error);
          set.status = 500;
          return [];
        }
      })
  )

  // ---------------------------------------------------------
  // 💊 GROUPE : MÉDICAMENTS
  // ---------------------------------------------------------
  .group("/medication", (group) =>
    group
      .post("/", async ({ body, set }) => {
        try {
          return await prisma.medication.create({
            data: {
              name: body.name,
              dose: body.dose,
              frequency: body.frequency,
              totalToday: body.totalToday,
              isInjection: body.isInjection,
              color: body.color,
              userId: body.userId,
            }
          });
        } catch (error) {
          console.error("❌ Erreur Create Medication:", error);
          set.status = 500;
          return { error: "Impossible de créer le médicament" };
        }
      }, {
        body: t.Object({
          name: t.String(),
          dose: t.String(),
          frequency: t.String(),
          totalToday: t.Optional(t.Integer()),
          isInjection: t.Boolean(),
          color: t.String(),
          userId: t.String()
        })
      })

      .get("/user/:userId", async ({ params, set }) => {
        try {
          return await prisma.medication.findMany({
            where: { userId: params.userId },
            include: {
              logs: {
                where: { takenAt: { gte: new Date(new Date().setHours(0, 0, 0, 0)) } }
              }
            }
          });
        } catch (e) {
          console.error("❌ Erreur GET medications:", e);
          set.status = 500;
          return [];
        }
      })

      .post("/log", async ({ body, set }) => {
        try {
          return await prisma.medicationLog.create({
            data: { medicationId: body.medicationId }
          });
        } catch (error) {
          console.error("❌ Erreur Log:", error);
          set.status = 500;
          return { error: "Erreur" };
        }
      }, {
        body: t.Object({ medicationId: t.String() })
      })

      .delete("/:id", async ({ params, set }) => {
        try {
          return await prisma.$transaction([
            prisma.medicationLog.deleteMany({ where: { medicationId: params.id } }),
            prisma.medication.delete({ where: { id: params.id } })
          ]);
        } catch (error) {
          console.error("❌ Erreur Suppression medication:", error);
          set.status = 500;
          return { error: "Erreur" };
        }
      })
  )

  // ---------------------------------------------------------
  // 🏥 GROUPE : RENDEZ-VOUS
  // ---------------------------------------------------------
  .group("/appointment", (group) =>
    group
      .post("/", async ({ body, set }) => {
        try {
          const newAppt = await prisma.appointment.create({
            data: {
              date: new Date(body.date),
              doctor: body.doctor,
              location: body.location,
              type: body.type,
              notes: body.notes ?? null,
              preparation: body.preparation ?? null,
              userId: body.userId,
            },
          });
          set.status = 201;
          return newAppt;
        } catch (error) {
          console.error("❌ Erreur Create Appointment:", error);
          set.status = 500;
          return { error: "Erreur serveur" };
        }
      }, {
        body: t.Object({
          date: t.String(),
          doctor: t.String(),
          location: t.String(),
          type: t.String(),
          notes: t.Optional(t.String()),
          preparation: t.Optional(t.String()),
          userId: t.String()
        })
      })

      .get("/user/:userId", async ({ params }) => {
        const all = await prisma.appointment.findMany({
          where: { userId: params.userId },
          orderBy: { date: 'asc' }
        });
        const now = new Date();
        return {
          upcoming: all.filter(a => new Date(a.date) >= now),
          past: all.filter(a => new Date(a.date) < now).reverse().slice(0, 3)
        };
      })
  )

  // ---------------------------------------------------------
  // 📈 GROUPE : POIDS (WEIGHT)
  // ---------------------------------------------------------
  .group("/weight", (group) =>
    group
      .post("/", async ({ body, set }) => {
        try {
          return await prisma.weight.create({
            data: {
              userId: body.userId,
              value: body.value,
              date: body.date ? new Date(body.date) : new Date(),
            }
          });
        } catch (error) {
          console.error("❌ Erreur Create Weight:", error);
          set.status = 500;
          return { error: "Impossible d'enregistrer le poids" };
        }
      }, {
        body: t.Object({
          userId: t.String(),
          value: t.Number(),
          date: t.Optional(t.String())
        })
      })

      .get("/user/:userId", async ({ params, set }) => {
        try {
          return await prisma.weight.findMany({
            where: { userId: params.userId },
            orderBy: { date: 'asc' }
          });
        } catch (error) {
          console.error("❌ Erreur Fetch Weights:", error);
          set.status = 500;
          return [];
        }
      })
  )

  // ---------------------------------------------------------
  // 🧪 GROUPE : ANALYSES MEDICALES (LABS)
  // ---------------------------------------------------------
  .group("/lab", (group) =>
    group
      .post("/", async ({ body, set }) => {
        try {
          return await prisma.medicalLab.create({
            data: {
              userId: body.userId,
              type: body.type,
              crp: body.crp ?? null,
              calprotectin: body.calprotectin ?? null,
              b12: body.b12 ?? null,
              b9: body.b9 ?? null,
              ferritin: body.ferritin ?? null,
              iron: body.iron ?? null,
              notes: body.notes ?? null,
              date: body.date ? new Date(body.date) : new Date(),
            }
          });
        } catch (error) {
          console.error("❌ Erreur Create Lab:", error);
          set.status = 500;
          return { error: "Erreur lors de l'enregistrement" };
        }
      }, {
        body: t.Object({
          userId: t.String(),
          type: t.String(),
          crp: t.Optional(t.Number()),
          calprotectin: t.Optional(t.Number()),
          b12: t.Optional(t.Number()),
          b9: t.Optional(t.Number()),
          ferritin: t.Optional(t.Number()),
          iron: t.Optional(t.Number()),
          notes: t.Optional(t.String()),
          date: t.Optional(t.String())
        })
      })

      .get("/user/:userId", async ({ params, set }) => {
        try {
          return await prisma.medicalLab.findMany({
            where: { userId: params.userId },
            orderBy: { date: 'desc' }
          });
        } catch (error) {
          console.error("❌ Erreur Fetch Labs:", error);
          set.status = 500;
          return [];
        }
      })
  )

  // ---------------------------------------------------------
  // 🚀 CONFIGURATION DU SERVEUR
  // ---------------------------------------------------------
  .listen({
    port: 3000,
    hostname: '0.0.0.0'
  }, ({ hostname, port }) => {
    console.log(`🚀 Serveur Poopy prêt sur http://${hostname}:${port}`);
  });
