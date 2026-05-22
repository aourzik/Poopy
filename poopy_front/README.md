# Poopy · Flutter App

Application mobile Flutter pour la gestion quotidienne des MICI (Maladie de Crohn, RCH).

## Stack

- **Frontend**: Flutter 3.x (Dart)
- **State management**: Riverpod 2.x
- **Navigation**: go_router
- **Backend**: Bun.js + Elysia (déjà fait)
- **DB**: PostgreSQL via Prisma

---

## Structure du projet

```
lib/
├── main.dart                          # Point d'entrée
├── core/
│   ├── theme/
│   │   └── app_theme.dart             # Tokens couleurs, typographie, thème
│   ├── utils/
│   │   └── app_router.dart            # Routes go_router
│   └── constants/
│       └── app_constants.dart         # URL API, clés storage
│
├── shared/
│   ├── models/
│   │   └── models.dart                # UserModel, StoolEntry, Medication, etc.
│   └── widgets/
│       ├── main_shell.dart            # Shell avec bottom nav flottant
│       └── poopy_widgets.dart         # PoopyCard, PoopyButton, PoopyTextField...
│
└── features/
    ├── auth/
    │   └── screens/
    │       ├── splash_screen.dart      # 01 · Splash
    │       └── register_screen.dart   # 02 · Inscription
    │
    ├── dashboard/
    │   └── screens/
    │       └── dashboard_screen.dart  # 03 · Dashboard
    │
    ├── journal/
    │   ├── screens/
    │   │   └── journal_screen.dart    # 04 · Journal de selles
    │   └── widgets/
    │       ├── bristol_scale.dart     # Sélecteur Bristol 1-5 (CustomPaint)
    │       ├── day_detail_card.dart   # Carte détail du jour sélectionné
    │       └── add_entry_sheet.dart   # Bottom sheet ajout/édition
    │
    ├── medications/
    │   └── screens/
    │       └── medications_screen.dart # 05 · Médicaments
    │
    ├── appointments/
    │   └── screens/
    │       └── appointments_screen.dart # 06 · Rendez-vous
    │
    └── profile/
        └── screens/
            └── profile_screen.dart    # 07 · Profil & Analyses
```

---

## Installation

### 1. Prérequis

```bash
flutter --version  # ≥ 3.19
dart --version     # ≥ 3.0
```

### 2. Dépendances

```bash
cd poopy_flutter
flutter pub get
```

### 3. Fonts Quicksand

Les fonts Quicksand sont servies via **google_fonts** (CDN auto) — pas besoin de les télécharger manuellement. Si tu veux les bundler hors-ligne :

1. Télécharge sur [fonts.google.com/specimen/Quicksand](https://fonts.google.com/specimen/Quicksand)
2. Place les `.ttf` dans `assets/fonts/`
3. Décommente le bloc `fonts:` dans `pubspec.yaml`

### 4. Mascot image

Place ton image mascotte dans `assets/images/mascot.png` puis dans `splash_screen.dart`, remplace :

```dart
child: const _MascotPlaceholder(),
```

par :

```dart
child: ClipOval(
  child: Image.asset('assets/images/mascot.png', fit: BoxFit.cover),
),
```

### 5. Backend URL

Dans `lib/core/constants/app_constants.dart`, mets l'URL de ton serveur Elysia :

```dart
static const String baseUrl = 'http://ton-serveur:3000';
```

### 6. Lancer

```bash
flutter run
```

---

## Tokens de design (fidèles au Claude Design)

| Token | Valeur |
|---|---|
| Background | `#FEF7EF` → `#FBF1E6` (gradient) |
| Surface | `#FFFFFF` |
| Text | `#1F1A14` |
| Pink / accent | `#F5A3B5` / `#E988A0` |
| Selles (coral) | `#FF6B6B` |
| Poids (violet) | `#BB86FC` |
| Méds (amber) | `#FFB562` |
| RDV (green) | `#6BCB77` |
| Analyses (blue) | `#4D96FF` |
| Font | Quicksand (400/500/600/700) |
| Border radius cards | 18-28px |
| Nav floating pill | `blur(24) saturate(180%)` |

---

## Prochaines étapes (connexion au back)

1. **Créer le service API** : `lib/core/services/api_service.dart` avec Dio
2. **Créer les providers Riverpod** dans chaque feature (`providers/`)
3. **Remplacer les données mock** dans chaque screen par les appels providers
4. **Auth JWT** : stocker le token dans `flutter_secure_storage`

Exemple de structure provider à ajouter dans chaque feature :

```dart
// features/journal/providers/journal_provider.dart
@riverpod
class JournalNotifier extends _$JournalNotifier {
  @override
  Future<List<StoolEntry>> build() async {
    return ref.watch(apiServiceProvider).getEntries();
  }

  Future<void> addEntry(StoolEntry entry) async {
    await ref.watch(apiServiceProvider).createEntry(entry);
    ref.invalidateSelf();
  }
}
```
