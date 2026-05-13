import { Elysia, t } from "elysia";
import { PrismaClient } from "@prisma/client";
import { PrismaPg } from "@prisma/adapter-pg";
import { Pool } from "pg";

const connectionString = Bun.env.DATABASE_URL;

if (!connectionString) {
  console.error("❌ Erreur : La variable DATABASE_URL n'est pas définie.");
  process.exit(1);
}

const pool = new Pool({ connectionString });
const adapter = new PrismaPg(pool);
const prisma = new PrismaClient({ adapter });

const app = new Elysia()
  .get("/", () => ({ status: "Poopy API is running 💩" }))

  // 👤 ROUTE 1 : Créer un utilisateur
  .post("/user", async ({ body }) => {
    let user = await prisma.user.findUnique({
      where: { email: body.email }
    });

    if (!user) {
      user = await prisma.user.create({
        data: {
          email: body.email,
          name: body.name
        }
      });
    }

    return { message: "Utilisateur prêt !", user };
  }, {
    body: t.Object({
      email: t.String({ format: 'email' }),
      name: t.String()
    })
  })

  // 💩 ROUTE 2 : Enregistrer un épisode de selles
  .post("/stool", async ({ body, set }) => {
    // 1. On vérifie d'abord si l'utilisateur qui fait la demande existe bien en base
    const userExists = await prisma.user.findUnique({
      where: { id: body.userId }
    });

    if (!userExists) {
      set.status = 404;
      return { error: "Utilisateur non trouvé. Impossible d'enregistrer la selle." };
    }

    // 2. On crée l'enregistrement dans la table Stool
    const newStool = await prisma.stool.create({
      data: {
        userId: body.userId,
        bristol: body.bristol,
        count: body.count,
        blood: body.blood,
        urgency: body.urgency
      }
    });

    set.status = 201; // Statut HTTP: Created
    return {
      message: "Épisode de selles enregistré avec succès ! 💩",
      stool: newStool
    };
  }, {
    // Sécurité Elysia : On valide strictement tout ce qui entre
    body: t.Object({
      userId: t.String(),                       // L'ID de l'utilisateur (obligatoire)
      bristol: t.Integer({ minimum: 1, maximum: 7 }), // Échelle de Bristol officielle (1 à 7)
      count: t.Integer({ minimum: 1 }),         // Le nombre via ton stepper (minimum 1)
      blood: t.Boolean(),                       // Présence de sang (true/false)
      urgency: t.Boolean()                      // Faux besoins / Urgence (true/false)
    })
  })

  // 🔍 ROUTE TEMPORAIRE : Voir tous les utilisateurs et leurs IDs générés
  .get("/users-test", async () => {
    return await prisma.user.findMany();
  })


  .listen(3000);

console.log(`🚀 Le serveur Poopy tourne sur http://localhost:${app.server?.port}`);