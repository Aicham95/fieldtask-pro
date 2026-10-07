# FieldTask Pro

Application Flutter **offline-first** pour les techniciens itinérants de TechFix (examen pratique UGB 2026).
Le technicien consulte ses interventions, change leur statut, prend des photos, écrit des notes et fait signer le client sur son écran, même sans réseau. Tout est enregistré sur le téléphone, puis envoyé au serveur dès que la connexion revient.

Légende : ✅ fichier déjà présent dans le projet · 🔲 fichier à créer · **L1 / L2 / L3** = lot de l'étudiant responsable (voir la fiche de répartition).

---

## 1. Fonctionnalités et écrans

Les écrans viennent de la maquette Figma, adaptés au téléphone : le menu latéral devient une barre de navigation en bas, les cartes de chiffres passent en grille 2×2, et la fenêtre « Détails » devient une page.

| Écran | Ce que fait l'utilisateur | Exigence du sujet |
|---|---|---|
| **Connexion** | Saisit email et mot de passe. Le token JWT (simulé) est gardé en sécurité sur le téléphone. La session est retrouvée au prochain lancement. | Login, JWT, `flutter_secure_storage` |
| **Tableau de bord** | Voit ses chiffres du jour (à faire, en cours, terminées, prioritaires), « Votre journée » (nombre d'interventions et durée cumulée), les prochaines interventions, et les actions rapides (voir la carte, synchroniser, nouvelle intervention). | Tableau de bord, indicateur En ligne / Hors ligne |
| **Mes interventions** | Liste avec filtres En attente / En cours / Terminées, tri par priorité ou par date, recherche texte (client, titre, adresse, équipement). | Filtres, tri par priorité, recherche |
| **Fiche d'intervention** | Lit client, adresse, description du problème, équipement et consignes. Passe le statut de En attente à En cours puis Terminée. Ajoute des photos et des notes, fait signer le client. | Fiche détaillée, photos, notes, signature |
| **Nouvelle intervention** | Crée une intervention, même hors ligne. Elle est mise dans la file d'attente et envoyée plus tard. | Interventions « créées » hors ligne |
| **Carte des sites** | Voit les interventions en pins et sa propre position. Un clic sur un pin ouvre la fiche rapide. | Carte, `geolocator`, fiche rapide |
| **Profil** | Voit son nom et son équipe, se déconnecte. | Authentification et profil |

Fonctions transversales : badge et bandeau **hors ligne** avec le nombre d'éléments en attente, bouton **Synchroniser**, notification locale de rappel avant une intervention.

Écrans de la maquette **non retenus** pour tenir le délai : Rapports, Paramètres, Aide et sélecteur d'espace. L'écran Planning est fusionné dans « Votre journée » du tableau de bord.

### Qui voit quoi

Chaque intervention appartient à un technicien (`technicianId`). C'est le responsable qui les assigne. Il n'a pas d'écran dans ce projet : dans la démo, on ajoute une intervention dans `mock_api/db.json` avec le bon `technicianId`.

1. À la connexion, le serveur renvoie l'identifiant du technicien.
2. L'app télécharge `GET /interventions?technicianId=<id>` : seulement les siennes.
3. Elles sont copiées dans SQLite, et les écrans lisent SQLite.
4. Hors ligne, le technicien travaille avec ce qu'il a déjà téléchargé. Au retour du réseau, ses modifications partent, puis les nouvelles missions sont téléchargées.
5. À la déconnexion, s'il reste des éléments à envoyer, l'app prévient et demande de synchroniser d'abord. Sinon elle vide la base locale (le téléphone peut être partagé).

Les interventions créées dans l'app prennent l'identifiant du technicien connecté, avec un identifiant généré sur le téléphone.

Limites à citer dans le rapport : `json-server` ne vérifie pas le token (un vrai serveur filtrerait d'après le token), et il n'y a pas de notification push. Les nouvelles missions arrivent à l'ouverture de l'app, au retour du réseau et avec le bouton Synchroniser.

---

## 2. Lancer le projet (Android Studio)

1. Créer un projet Flutter nommé exactement `fieldtask_pro` (sinon les imports `package:fieldtask_pro/...` ne marchent pas).
2. Remplacer `lib/`, `test/` et ajouter `mock_api/` à partir du projet fourni. Ne pas écraser le `pubspec.yaml` du projet.
3. Ajouter les dépendances. Deux versions sont imposées : `connectivity_plus` et `flutter_local_notifications` utilisent chacun une version différente de la bibliothèque `dbus`, et la combinaison par défaut échoue.

```
flutter pub add flutter_riverpod go_router dio connectivity_plus:^7.3.1 sqflite path flutter_secure_storage geolocator flutter_map latlong2 image_picker signature flutter_local_notifications:^22.3.1 timezone path_provider equatable intl
flutter pub add --dev mocktail
```

4. `android/app/src/main/AndroidManifest.xml`, avant `<application>` :

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
<uses-feature android:name="android.hardware.camera" android:required="false"/>
<uses-feature android:name="android.hardware.location.gps" android:required="false"/>
```

   Dans la balise `<application>` : `android:usesCleartextTraffic="true"` (appel HTTP en développement), et, entre `<application>` et `</application>`, les récepteurs des rappels programmés :

```xml
<receiver android:exported="false"
    android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver" />
<receiver android:exported="false"
    android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver">
    <intent-filter>
        <action android:name="android.intent.action.BOOT_COMPLETED"/>
    </intent-filter>
</receiver>
```

5. `android/app/build.gradle.kts` : activer le désucrage Java, exigé par `flutter_local_notifications`. Si les blocs `compileOptions` et `dependencies` existent déjà, ajouter seulement la ligne manquante dedans.

```kotlin
android {
    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
```

6. Backend de test : `npx json-server@0.17.4 --watch mock_api/db.json --port 3000` (version fixée car les versions récentes ont supprimé `--watch`). Laisser ce terminal ouvert. Depuis l'émulateur, l'adresse est `http://10.0.2.2:3000`.
7. `flutter clean`, `flutter pub get`, `flutter run` · tests : `flutter test`.

Comptes de test (mot de passe `1234`) :

| Email | Technicien | Interventions |
|---|---|---|
| `tech@techfix.com` | Diallo Sy | 6 |
| `fatou@techfix.com` | Fatou Ndiaye | 2 |

Les dates des interventions de `mock_api/db.json` sont fixes (6 octobre 2026). Le jour de la démonstration, remplacer ces dates par celle du jour (Ctrl+R dans Android Studio), sinon « Votre journée » affichera 0.

---

## 3. Architecture

Clean Architecture découpée par fonctionnalité. Chaque fonctionnalité a ses trois couches.

- **presentation** : écrans, widgets et providers Riverpod. Elle ne connaît que le domaine.
- **domain** : entités, interfaces de repository, cas d'usage. Du Dart pur, sans Flutter, SQLite ni Dio.
- **data** : modèles, mappers, sources de données, implémentation des repositories. Elle implémente les interfaces du domaine.

Sens des dépendances : `presentation` → `domain` ← `data`.

Les plugins matériels (GPS, notifications) sont appelés **uniquement depuis la couche data**, derrière une interface du domaine. La présentation ne touche jamais un plugin directement.

```
lib/
├── main.dart                         ✅
├── app.dart                          ✅
├── core/
│   ├── constants/api_constants.dart  🔲
│   ├── errors/failures.dart          🔲
│   ├── router/app_router.dart        🔲
│   ├── theme/app_theme.dart          🔲
│   ├── network/  (dio_client 🔲, connectivity_provider ✅)
│   ├── database/app_database.dart    ✅
│   └── sync/     (sync_service ✅, sync_provider 🔲)
├── features/
│   ├── auth/           data · domain · presentation
│   ├── dashboard/      presentation
│   ├── interventions/  data · domain · presentation
│   └── map/            data · domain · presentation
└── shared/widgets/
```

---

## 4. Rôle de chaque fichier

### Racine

| Fichier | Lot | Rôle |
|---|---|---|
| ✅ `main.dart` | L1 | Initialise Flutter et lance l'app dans un `ProviderScope` (obligatoire pour Riverpod). |
| ✅ `app.dart` | L1 | Widget racine `FieldTaskApp`. Écran vide pour l'instant : à remplacer par `MaterialApp.router` avec le thème et le routeur. |
| ✅ `README.md` | tous | Ce document. |
| ✅ `mock_api/db.json` | L2 | Données de `json-server` : 2 techniciens (Diallo Sy et Fatou Ndiaye) et 8 interventions de Saint-Louis, chacune avec son `technicianId`. Diallo Sy en a 6 (2 en attente, 2 en cours, 2 terminées), identiques à la maquette. Fatou Ndiaye en a 2. |

### core/ : ce qui est partagé par toute l'app

| Fichier | Lot | Rôle |
|---|---|---|
| 🔲 `constants/api_constants.dart` | L1 | `baseUrl` (`http://10.0.2.2:3000`) et chemins `/users`, `/interventions`. |
| 🔲 `errors/failures.dart` | L1 | Erreurs métier (réseau, authentification, base locale) pour ne pas faire remonter d'exceptions brutes à l'écran. |
| 🔲 `router/app_router.dart` | L1 | Routes `go_router` : `/login`, `/dashboard`, `/interventions`, `/interventions/new`, `/interventions/:id`, `/map`, `/profile`. Renvoie vers `/login` s'il n'y a pas de session. |
| 🔲 `theme/app_theme.dart` | L1 | Thème Material 3 : bleu marine de la maquette, couleurs des statuts (en attente, en cours, terminée) et des priorités (normale, élevée, urgente). |
| 🔲 `network/dio_client.dart` | L1 | Crée l'instance `Dio` avec la `baseUrl` et un intercepteur qui ajoute `Authorization: Bearer <token>`. Utilisée par les sources distantes et par `SyncService`. |
| ✅ `network/connectivity_provider.dart` | L1 | `connectivityProvider` (instance `Connectivity`) et `isOnlineProvider` (flux `true` / `false`). Alimente le badge En ligne / Hors ligne. |
| ✅ `database/app_database.dart` | L2 | Ouvre SQLite et crée 2 tables. `interventions` : toutes les données d'une mission, avec `technician_id`, plus `synced` (0 = modification pas encore envoyée). `sync_queue` : une ligne par opération à rejouer (`entity_id`, `operation` = `create` ou `update`, `payload` JSON, `retry_count`). `clearUserData()` vide les deux tables à la déconnexion. |
| ✅ `sync/sync_service.dart` | L2 | Moteur de synchro. `start()` écoute `connectivity_plus`. `processQueue()` lit `sync_queue` dans l'ordre : `create` → `POST /interventions`, `update` → `PATCH /interventions/:id`. Succès : ligne supprimée et `synced = 1`. Erreur réseau : `retry_count + 1` et arrêt pour garder l'ordre. `pendingCount()` donne le nombre d'éléments en attente. `stateStream` publie `idle`, `syncing` ou `error` pour le badge et le bouton Synchroniser. |
| 🔲 `sync/sync_provider.dart` | L2 | Providers Riverpod : crée `SyncService` et le démarre au lancement, expose l'état de synchro et le nombre d'éléments en attente. |

### features/auth/ : connexion, session, profil

| Fichier | Lot | Rôle |
|---|---|---|
| 🔲 `domain/entities/user.dart` | L1 | Entité `User` (id du technicien, nom, email, équipe). L'id sert ensuite à télécharger les interventions du technicien. |
| 🔲 `domain/repositories/auth_repository.dart` | L1 | Interface : `login`, `logout`, `getSavedSession`. |
| 🔲 `domain/usecases/login_usecase.dart` | L1 | Appelle `login` du repository. |
| 🔲 `domain/usecases/logout_usecase.dart` | L1 | Déconnexion : si `pendingCount()` n'est pas 0, refuse et prévient l'utilisateur. Sinon efface la session et appelle `clearUserData()`. |
| 🔲 `domain/usecases/get_saved_session_usecase.dart` | L1 | Au démarrage, retrouve la session pour passer l'écran de connexion. |
| 🔲 `data/models/user_model.dart` | L1 | Représentation JSON de l'utilisateur (`fromJson`). |
| 🔲 `data/mappers/user_mapper.dart` | L1 | Convertit `UserModel` en `User`. |
| 🔲 `data/datasources/auth_remote_datasource.dart` | L1 | Cherche l'utilisateur dans l'API (`/users?email=…&password=…`), renvoie son identifiant et fabrique un JWT simulé. |
| 🔲 `data/datasources/auth_local_datasource.dart` | L1 | Lit et écrit le token et l'identifiant du technicien avec `flutter_secure_storage`. |
| 🔲 `data/repositories/auth_repository_impl.dart` | L1 | Implémente l'interface en combinant les deux sources. |
| 🔲 `presentation/providers/auth_provider.dart` | L1 | État de connexion (déconnecté, chargement, connecté, erreur) exposé aux écrans. Fournit aussi le technicien connecté aux autres fonctionnalités. |
| 🔲 `presentation/pages/login_page.dart` | L1 | Écran de connexion. |
| 🔲 `presentation/pages/profile_page.dart` | L1 | Écran Profil : nom, équipe, bouton Déconnexion. |
| 🔲 `presentation/widgets/login_form.dart` | L1 | Champs email et mot de passe, validation, message d'erreur. |

### features/interventions/ : le cœur de l'app

**domain/**

| Fichier | Lot | Rôle |
|---|---|---|
| ✅ `entities/intervention.dart` | L2 | Entité `Intervention` : technicien assigné (`technicianId`), référence (`INT-2026-084`), titre, client, ville, adresse, description du problème, équipement, consignes, priorité (`normal`, `high`, `urgent`), statut (`pending`, `inProgress`, `done`), position GPS, date prévue, durée estimée, notes, chemins des photos, chemin de la signature, `synced`. `copyWith` produit une version modifiée sans toucher l'originale. |
| ✅ `repositories/intervention_repository.dart` | L2 | Contrat du domaine : `watchAll()` (flux depuis SQLite), `getById`, `refreshFromServer(technicianId)`, `create`, `updateStatus`, `saveFieldWork` (notes, photos, signature). |
| ✅ `usecases/get_interventions.dart` | L2 | Filtre par statut, recherche texte, tri par priorité (urgente d'abord, puis date) ou par date. Alimente la liste. |
| ✅ `usecases/get_dashboard_stats.dart` | L2 | Calcule les chiffres du tableau de bord : à faire, en cours, terminées, prioritaires, urgentes, nombre et durée des interventions du jour. |
| ✅ `usecases/update_intervention_status.dart` | L2 | Règle métier : seul le statut suivant est permis (en attente → en cours → terminée). Lève une erreur sinon. |
| 🔲 `usecases/create_intervention.dart` | L2 | Crée une intervention pour le technicien connecté, avec un identifiant généré sur le téléphone (écrite en local, mise dans la file en `create`). |
| 🔲 `usecases/save_field_work.dart` | L3 | Enregistre notes, photos et signature d'une intervention. |
| 🔲 `usecases/refresh_interventions.dart` | L2 | Télécharge depuis le serveur les interventions du technicien connecté quand on est en ligne. |
| 🔲 `usecases/schedule_reminder.dart` | L3 | Programme un rappel avant l'heure prévue d'une intervention. |
| 🔲 `services/reminder_scheduler.dart` | L3 | Interface du domaine pour programmer une notification (le domaine ne connaît pas le plugin). |

**data/**

| Fichier | Lot | Rôle |
|---|---|---|
| 🔲 `models/intervention_model.dart` | L2 | Version « données » : `fromJson` / `toJson` pour l'API, `fromMap` / `toMap` pour SQLite. |
| 🔲 `mappers/intervention_mapper.dart` | L2 | Convertit `InterventionModel` ↔ `Intervention` (statuts et priorités en entiers ↔ enums, liste de photos ↔ JSON). |
| 🔲 `datasources/intervention_local_datasource.dart` | L2 | Requêtes SQLite : lire, insérer, modifier, et **ajouter une ligne dans `sync_queue`** à chaque création ou modification. |
| 🔲 `datasources/intervention_remote_datasource.dart` | L2 | Appels REST : `GET /interventions?technicianId=<id>` pour le téléchargement. |
| 🔲 `repositories/intervention_repository_impl.dart` | L2 | Implémente le contrat : écrit toujours en local d'abord (`synced = 0` + file d'attente), puis laisse `SyncService` envoyer. |
| 🔲 `repositories/fake_intervention_repository.dart` | L2 | Version en mémoire pour que L1 et L3 construisent leurs écrans sans attendre SQLite. À livrer dès le premier jour. |
| 🔲 `services/local_notification_scheduler.dart` | L3 | Implémente `ReminderScheduler` avec `flutter_local_notifications`. |

**presentation/**

| Fichier | Lot | Rôle |
|---|---|---|
| 🔲 `providers/interventions_provider.dart` | L1 | Providers Riverpod : filtre choisi, texte de recherche, tri, liste résultante, intervention sélectionnée. |
| 🔲 `pages/interventions_list_page.dart` | L1 | Écran « Mes interventions » : recherche, onglets de statut, tri, liste, bouton Nouvelle intervention. |
| 🔲 `pages/intervention_detail_page.dart` | L3 | Fiche complète : détails, bouton de changement de statut, photos, notes, signature, bouton Terminer. |
| 🔲 `pages/create_intervention_page.dart` | L2 | Formulaire de création avec validation. |
| 🔲 `widgets/intervention_card.dart` | L1 | Une carte de la liste : client, titre, adresse, heure, durée, distance, priorité, statut. |
| 🔲 `widgets/status_filter_tabs.dart` | L1 | Onglets Tout / En attente / En cours / Terminées avec compteurs. |
| 🔲 `widgets/sort_menu.dart` | L1 | Menu « Trier par » (priorité, date). |
| 🔲 `widgets/photo_section.dart` | L3 | Bouton « ajouter photo » (`image_picker`) et miniatures. |
| 🔲 `widgets/notes_field.dart` | L3 | Zone de notes explicatives. |
| 🔲 `widgets/signature_pad.dart` | L3 | Zone de dessin de la signature du client, exportée en PNG. |

### features/dashboard/presentation/ : le tableau de bord

Il réutilise les cas d'usage de `interventions` : pas de couches `data` ni `domain` propres.

| Fichier | Lot | Rôle |
|---|---|---|
| 🔲 `providers/dashboard_provider.dart` | L1 | Expose `GetDashboardStats` et la liste des prochaines interventions. |
| 🔲 `pages/dashboard_page.dart` | L1 | Écran d'accueil : salutation, bandeau réseau, chiffres, « Votre journée », prochaines interventions, actions rapides. |
| 🔲 `widgets/stat_card.dart` | L1 | Une carte de chiffre (à faire, en cours, terminées, prioritaires). |
| 🔲 `widgets/day_summary.dart` | L1 | « Votre journée » : nombre d'interventions du jour et durée sur le terrain. |
| 🔲 `widgets/quick_actions.dart` | L1 | Voir mes interventions, Voir la carte, Synchroniser, Nouvelle intervention. |

### features/map/ : la carte

| Fichier | Lot | Rôle |
|---|---|---|
| 🔲 `domain/repositories/location_repository.dart` | L3 | Interface : donne la position actuelle. |
| 🔲 `domain/usecases/get_current_position.dart` | L3 | Demande la position via l'interface. |
| 🔲 `data/datasources/location_datasource.dart` | L3 | Demande la permission et lit la position avec `geolocator`. |
| 🔲 `data/repositories/location_repository_impl.dart` | L3 | Implémente l'interface avec la source `geolocator`. |
| 🔲 `presentation/pages/map_page.dart` | L3 | Carte `flutter_map` avec les pins et la position de l'utilisateur. |
| 🔲 `presentation/widgets/intervention_marker.dart` | L3 | Pin coloré selon le statut. |
| 🔲 `presentation/widgets/intervention_quick_sheet.dart` | L3 | Fiche rapide ouverte au clic sur un pin, avec lien vers la fiche complète. |

### shared/widgets/ : composants communs

| Fichier | Lot | Rôle |
|---|---|---|
| 🔲 `app_scaffold.dart` | L1 | Barre de navigation du bas (Accueil, Interventions, Carte, Profil). |
| 🔲 `connectivity_badge.dart` | L1 | Pastille En ligne / Hors ligne avec « n éléments en attente ». |
| 🔲 `sync_banner.dart` | L1 | Bandeau « Vous êtes hors connexion » avec message et état de synchro. |
| 🔲 `status_badge.dart` | L1 | Pastille de statut (en attente, en cours, terminée). |
| 🔲 `priority_badge.dart` | L1 | Pastille de priorité (normale, élevée, urgente). |

### test/

| Fichier | Lot | Rôle |
|---|---|---|
| ✅ `helpers/intervention_fixture.dart` | L2 | `makeIntervention(...)` : fabrique une intervention de test avec des valeurs par défaut. |
| ✅ `update_intervention_status_test.dart` | L2 | La transition autorisée passe, le saut de statut est refusé (repository simulé avec `mocktail`). |
| ✅ `get_dashboard_stats_test.dart` | L2 | Les chiffres du tableau de bord (statuts, prioritaires, durée du jour) sont corrects. |
| 🔲 `get_interventions_test.dart` | L2 | Filtre, recherche et tri. |
| 🔲 `intervention_mapper_test.dart` | L2 | Conversion modèle ↔ entité. |
| 🔲 `sync_service_test.dart` | L2 | La file est vidée en cas de succès, conservée en cas d'erreur réseau. |

---

## 5. Stratégie offline-first (pour le rapport)

1. L'écran lit uniquement SQLite, jamais le réseau.
2. Chaque création ou modification est écrite en local avec `synced = 0`, puis ajoutée à `sync_queue`.
3. `connectivity_plus` détecte le retour du réseau. `SyncService.processQueue()` rejoue la file dans l'ordre : `create` en POST, `update` en PATCH.
4. Succès : la ligne quitte la file et `synced` passe à 1. Échec réseau : `retry_count` augmente, on s'arrête et on réessaie plus tard.
5. Conflits : le dernier modifié gagne, d'après `updatedAt`.
6. Photos et signature : sur le serveur de test, seuls les chemins de fichiers sont envoyés.
7. Chaque technicien ne reçoit et ne garde que ses interventions. La base locale est vidée à la déconnexion, mais jamais tant que des éléments attendent d'être envoyés.
8. L'interface montre l'état à tout moment : badge En ligne / Hors ligne, nombre d'éléments en attente, bouton Synchroniser.
