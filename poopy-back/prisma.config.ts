// On utilise l'API de base de Node/Bun présente partout pour lire les fichiers
import { readFileSync } from "fs";
import { join } from "path";

// Fonction maison ultra-robuste pour lire le .env à la main sans aucune dépendance
function getDatabaseUrl() {
  try {
    const envPath = join(process.cwd(), ".env");
    const envFile = readFileSync(envPath, "utf-8");
    const match = envFile.match(/^DATABASE_URL=["']?(.+?)["']?$/m);
    return match ? match[1] : undefined;
  } catch (e) {
    return undefined;
  }
}

export default {
  datasource: {
    url: getDatabaseUrl(),
  },
};