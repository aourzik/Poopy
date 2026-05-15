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
      .post("/", async ({ body }) => {
        let user = await prisma.user.findUnique({ where: { email: body.email } });
        if (!user) {
          user = await prisma.user.create({ data: { email: body.email, name: body.name } });
        }
        return user;
      }, {
        body: t.Object({ email: t.String({ format: 'email' }), name: t.String() })
      })
      .get("/all-test", async () => await prisma.user.findMany())// Ta route test déplacée ici
      .get("/:id", async ({ params }) => {
        return await prisma.user.findUnique({
          where: { id: params.id }
        });
      })
  )


 // ---------------------------------------------------------
  // 💩 GROUPE : SELLES (STOOLS)
  // ---------------------------------------------------------
  .group("/stool", (group) =>
    group
      // 💩 ROUTE : Enregistrer (Créer) ou Modifier
      .post("/", async ({ body, set }) => {
  try {
    const { id, userId, bristol, count, blood, urgency, date } = body;

    // Détection ultra-sécurisée de l'ID
    const isUpdate = id && id !== "" && id !== "null" && id !== "undefined";

    if (isUpdate) {
      console.log(`📝 Modification de la selle : ${id}`);
      return await prisma.stool.update({
        where: { id: id },
        data: {
          bristol,
          count,
          blood,
          urgency,
          date: date ? new Date(date) : undefined,
        },
      });
    } 

    console.log(`🆕 Création d'une nouvelle selle pour l'user : ${userId}`);
    return await prisma.stool.create({
      data: {
        userId,
        bristol,
        count,
        blood,
        urgency,
        date: date ? new Date(date) : new Date(),
      },
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

      // 🔥 ROUTE : Récupérer les selles d'un utilisateur
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

  // 💊 GROUPE : MÉDICAMENTS
  .group("/medication", (group) =>
    group
      // 📝 Créer un nouveau médicament
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

      // 📈 Récupérer les médocs
.get("/user/:userId", async ({ params, set }) => {
  try {
    const meds = await prisma.medication.findMany({
      where: { userId: params.userId },
      include: {
        logs: {
          where: {
            takenAt: { gte: new Date(new Date().setHours(0,0,0,0)) }
          }
        }
      }
    });
    return meds;
  } catch (e) {
    console.error("❌ Erreur GET:", e);
    set.status = 500; return [];
  }
})

// ✅ Action : Marquer comme pris
.post("/log", async ({ body, set }) => {
  try {
    console.log("📝 Log pour medicationId:", body.medicationId);
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

// 🗑️ Action : Supprimer
.delete("/:id", async ({ params, set }) => {
  try {
    const { id } = params;
    console.log("🗑️ Tentative de suppression du médoc:", id);
    
    // On utilise une transaction pour être sûr que tout part
    return await prisma.$transaction([
      prisma.medicationLog.deleteMany({ where: { medicationId: id } }),
      prisma.medication.delete({ where: { id: id } })
    ]);
  } catch (error) {
    console.error("❌ Erreur Suppression:", error);
    set.status = 500;
    return { error: "Erreur" };
  }
})
  )

  .listen({
    port: 3000,
    hostname: '0.0.0.0'
  }, ({ hostname, port }) => {
    console.log(`🚀 Serveur Poopy prêt sur http://${hostname}:${port}`);
  });