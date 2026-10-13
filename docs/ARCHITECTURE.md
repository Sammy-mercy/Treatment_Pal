# Therapy Pal Architecture Guide

This guide describes the code as it exists in this repository. It uses software-engineering terms, with a plain-language explanation in parentheses at each use.

## 1. System At A Glance

Therapy Pal is a **full-stack application** (a product made from a user-facing app and a server-side app) with three main parts:

1. The Flutter client (the screens and interactions used by patients, clinicians, and admins) runs on web and mobile/desktop platforms.
2. The Express backend (the server that receives requests, applies rules, and returns data) exposes HTTP endpoints under `/api`.
3. Firebase Authentication (Google's hosted service that verifies patient and clinician email/password accounts) and MongoDB (the database that stores account profiles and visit analytics) provide identity and durable storage.

The backend currently persists user profiles and analytics to MongoDB. Regimens, adherence logs, and notifications are implemented with in-memory demo stores on the server, and the client also has local sample-data fallbacks. These demo records are not durable and can reset when the server restarts; they are not yet end-to-end MongoDB-backed features.

```text
Patient / Clinician / Admin
          |
          v
Flutter client (screens, navigation, local state)
     |                 |
     |                 +---- Firebase Auth (patient/clinician identity)
     v
Therapy Pal HTTP API (Express)
     |                 |
     +---- Firebase Admin (verifies Firebase ID tokens)
     |
     +---- MongoDB (profiles and visit analytics)
     |
     +---- In-memory demo stores (regimens, adherence, notifications)
```

## 2. Repository Layout

- `client/lib/main.dart` starts Flutter, initializes Firebase, constructs shared services, and registers state objects.
- `client/lib/app.dart` creates the root Material app, theme, and router.
- `client/lib/core/` contains shared networking, analytics tracking, constants, theme, and input validation.
- `client/lib/models/` contains data-transfer and domain objects such as users, regimens, regimen items, and adherence logs.
- `client/lib/features/` groups UI and logic by capability: authentication, home dashboards, regimens, adherence, patient directory, notifications, and administration.
- `client/lib/routing/` defines route names, page composition, and role-based access decisions.
- `client/lib/shared/` contains reusable widgets and patient/clinician page shells.
- `server/server.js` starts the backend process and connects to MongoDB.
- `server/app.js` configures Express middleware and mounts API route groups.
- `server/routes/` maps HTTP method and URL combinations to controllers.
- `server/controllers/` adapts incoming HTTP requests and outgoing responses.
- `server/services/` applies application rules and accesses storage.
- `server/middleware/` performs shared request checks, including identity verification and role authorization.
- `server/validators/` checks request data before controllers perform an operation.
- `server/config/` initializes MongoDB and Firebase Admin integrations.
- `.github/workflows/` contains GitHub Actions workflows (automated tasks run by GitHub) for Firebase Hosting previews and live deployment.

## 3. Flutter Client Structure

The client uses a **feature-oriented structure** (files are grouped by what users do, rather than by technical file type alone). Most features follow this path:

```text
Screen (visible page)
  -> Provider (holds changing UI state and notifies pages)
  -> Repository (chooses where feature data comes from)
  -> Service / ApiClient (sends HTTP requests)
  -> Express endpoint (server URL that handles a request)
```

Not every feature completes this full path today. Some repositories catch network errors and return sample data; some server services mutate in-memory arrays instead of MongoDB.

### Startup and shared state

`main.dart` initializes Flutter and Firebase, creates one `ApiClient` (a reusable HTTP request helper), starts anonymous visit tracking, and constructs repositories/providers. `MultiProvider` (a dependency-sharing widget that makes objects available to lower parts of the page tree) exposes these objects to screens.

`TherapyPalApp` in `app.dart` builds `MaterialApp.router` (Flutter's app shell that delegates page changes to a router). The selected light theme is shared across the app.

### State and data access

The app uses Provider's `ChangeNotifier` pattern (an object stores changing values and announces updates to listening screens). Examples include `AuthProvider`, `RegimenProvider`, `AdherenceProvider`, `PatientDirectoryProvider`, and `NotificationProvider`.

A repository (a boundary that gives a feature one place to request or save data) is injected into each provider. This keeps screen widgets from constructing raw HTTP requests themselves. The pattern is present, but several repositories deliberately fall back to local sample records, so a successful-looking screen does not always prove that the server stored a change.

`ApiClient` builds URLs from `AppConstants.apiBaseUrl`, adds JSON headers, attaches the active bearer token when one exists, applies request timeouts, and translates failed HTTP responses into API exceptions. The configured API base is `https://therapy-pal.vercel.app/api`; its health check is `https://therapy-pal.vercel.app/health`.

### Navigation and roles

`GoRouter` (the Flutter package that maps URL paths to screens) is configured in `client/lib/routing/app_router.dart`. Patient and clinician routes use separate shell layouts (persistent navigation frames surrounding related pages). Details and create/edit forms are routed as standalone pages.

`RouteGuard` (a navigation rule that redirects a user away from pages their role cannot access) checks whether a user is signed in and whether the destination matches the user's role. The client guard improves navigation behavior, but backend authorization remains necessary because clients can be modified or bypassed.

The sign-in page is selected using the browser's base path. At `/admin#/login`, the `/admin` hosting path selects the admin-only sign-in presentation. At the root `/#/login`, patient and clinician sign-in choices are shown. After sign-in, the app navigates to the home route for the verified role.

## 4. Identity And Sign-In

Patient/clinician identity and admin identity use separate paths.

### Patients and clinicians

1. The client calls Firebase Authentication to create or verify an email/password account.
2. Firebase returns a Firebase ID token (a signed proof that Firebase authenticated the user).
3. The client sends that token to the backend in the `Authorization: Bearer ...` HTTP header (a standard way to carry an access credential with a request).
4. `authenticateFirebase` verifies signup/session tokens using Firebase Admin.
5. On signup, `AuthService` creates a profile in MongoDB with the Firebase UID, name, email, role, and related profile fields.
6. On later sign-in, `/api/auth/session` looks up that MongoDB profile and returns the app role and profile data.

The client derives the requested role from the sign-in choice, but the server profile is the source used for the logged-in app role. Signup is only fully complete when Firebase account creation and the backend MongoDB profile creation both succeed; the client attempts to remove the just-created Firebase account if profile creation fails.

### Admin

Admin credentials are configured on the server with `ADMIN_EMAIL` and `ADMIN_PASSWORD`. `/api/auth/login` checks those values and returns an admin JWT (a signed token containing the admin identity and role). The token is signed with `ADMIN_TOKEN_SECRET` and expires after 12 hours. Admin sign-in does not create a Firebase Auth account or MongoDB user profile.

The backend authentication middleware first tries to verify an admin JWT with `ADMIN_TOKEN_SECRET`, then tries Firebase ID-token verification. `authorize('admin')` (a role check that permits only admin requests) protects admin dashboard statistics. Public registration is restricted to patient/clinician roles by validation and does not provision admins.

### Auth-related endpoints

- `POST /api/auth/login`: verifies configured admin credentials and issues an admin token.
- `POST /api/auth/session`: verifies a Firebase ID token and loads the associated MongoDB profile.
- `POST /api/auth/register`: verifies a Firebase ID token, validates the submitted profile, and creates its MongoDB profile.

## 5. Express Backend Structure

The server uses a **layered architecture** (responsibilities are split into levels so each part has a focused job):

1. The route layer (matches a URL and HTTP method) wires an endpoint to its controller.
2. Middleware (shared code that runs before or after endpoint logic) checks authentication, role access, or other request conditions.
3. The controller layer (translates HTTP input into a service call and formats an HTTP response) handles request/response details.
4. The service layer (implements application rules) chooses data and performs operations.
5. The database access layer (the shared code that reads and writes the database) is `server/config/db.js`.

`server.js` loads `server/.env`, awaits the MongoDB connection, then starts listening on `PORT` (default `5000`). If MongoDB cannot connect, startup stops rather than accepting requests without required storage.

`app.js` enables CORS (browser cross-origin request permission), JSON and URL-encoded request parsing, exposes `/health`, mounts route groups under `/api`, and finishes with a not-found handler and centralized error handler.

## 6. API Surface And Data Persistence

| Route group | Main endpoints | Current behavior and storage |
|---|---|---|
| `/api/auth` | `POST /login`, `/session`, `/register` | Admin login uses environment credentials; patient/clinician sessions use Firebase tokens and MongoDB profiles. |
| `/api/regimens` | `GET /`, `GET /:id`, `POST /`, `PUT /:id`, `PATCH /:id/items/:itemId/toggle` | Requires authentication. Creation/update is clinician-restricted where configured. The current `RegimenService` stores sample and changed regimens in a process-local array, not MongoDB. |
| `/api/adherence-logs` | `GET /`, `POST /`, `GET /compliance/:patientId?` | Requires authentication and validates dose submissions. The current `AdherenceService` stores logs in a process-local array, not MongoDB. |
| `/api/users` | `GET /?role=patient`, `GET /:id`, `PUT /:id/profile` | Requires authentication. Directory listing is clinician-restricted. User profiles are read/updated in MongoDB. |
| `/api/notifications` | `GET /`, `POST /read-all`, `POST /register-token` | Requires authentication. Current notification records and read state are held in a process-local array; device-token registration only logs a shortened token. |
| `/api/analytics` | `POST /visits`, `POST /visit` | Anonymous and authenticated visits are stored in MongoDB. Anonymous visits record a generated visitor ID, a shortened user-agent value, and timestamp, not the visitor's IP address. |
| `/api/admin` | `GET /dashboard-stats` | Requires a valid admin token and admin role. Statistics are computed from MongoDB profiles and visit records. |

The route table describes the implemented backend surface, not a promise that every client workflow is durable. For example, `RegimenRepository` and `AdherenceRepository` return local seed data after failed requests, while the corresponding server services also use in-memory arrays. A process-local array (data held only in the running server's memory) is lost on restart and is not shared across multiple server instances.

### MongoDB collections

`DatabaseService` connects using `DATABASE_URL` and automatically creates indexes (database-maintained lookup rules that speed searches and can enforce uniqueness):

- `users`: profile documents keyed by Firebase UID, with a unique sparse index on `firebaseUid` and a unique sparse index on `email`.
- `analytics_visits`: visit documents with indexes on visitor ID plus timestamp and user ID plus timestamp.

The analytics dashboard returns total non-admin users, active registered users today, returning registered users, total anonymous visits, distinct anonymous visitors today, and repeat anonymous visitors. The client stores the anonymous visitor ID in shared preferences (small device-local key/value storage) and reuses it across visits.

The JavaScript files under `server/models/` describe the shapes of user, regimen, regimen-item, and adherence-log objects. They are not a MongoDB ODM schema layer (a library-managed mapping between database documents and application objects); the project uses the official MongoDB driver directly for its existing persistent collections.

## 7. Security Boundaries

- Firebase Admin verifies patient/clinician Firebase ID tokens on the server; a client-side role value alone is not trusted.
- Admin JWTs use a separate `ADMIN_TOKEN_SECRET` and expire after 12 hours.
- `authenticateRequired` loads patient/clinician roles from MongoDB profiles; a Firebase identity without a registered profile is rejected for protected requests.
- `authorize` enforces role-specific backend access after authentication.
- Request validators check selected input fields before services run.
- Secrets belong in `server/.env` or GitHub Actions secrets, not in committed source files. Keep `FIREBASE_PRIVATE_KEY`, `ADMIN_PASSWORD`, `ADMIN_TOKEN_SECRET`, and database credentials private.
- The Flutter web app's Firebase client configuration identifies a public client; it is not a substitute for server-side identity checks or secret protection.

## 8. Configuration And Running Locally

Backend settings are listed in `server/.env.example`. The important values are:

- `PORT` and `NODE_ENV`: server port and runtime mode.
- `DATABASE_URL`: MongoDB connection string (`mongodb://...` for local MongoDB or `mongodb+srv://...` for Atlas).
- `FIREBASE_PROJECT_ID`, `FIREBASE_CLIENT_EMAIL`, and `FIREBASE_PRIVATE_KEY`: Firebase Admin service-account details used to verify Firebase ID tokens.
- `ADMIN_EMAIL`, `ADMIN_PASSWORD`, and `ADMIN_TOKEN_SECRET`: separately configured admin credentials and token signing key.
- `JWT_SECRET`: additional server configuration; admin tokens specifically use `ADMIN_TOKEN_SECRET` in the current implementation.

Typical local commands:

```powershell
# Backend
cd server
npm install
npm run dev

# Flutter client, in another terminal
cd client
flutter pub get
flutter run -d chrome
```

The client connects to the configured hosted API base URL unless `AppConstants` is changed. Local backend testing therefore requires pointing the client API constants at the local API when that is desired.

## 9. Tests And Deployment

`server/test/analytics.test.js` is an integration test (a test that exercises multiple real application layers together) using Node's built-in test runner and an in-memory test database adapter. It checks anonymous and authenticated analytics, registration/session behavior, admin login, and rejection of unauthorized dashboard access. Run it with `cd server && npm test`.

Flutter widget tests live under `client/test/`; they cover routing access and responsive shell behavior. Run them with `cd client && flutter test`. `flutter analyze` checks Dart code for compile-time and lint problems.

Firebase Hosting serves the built Flutter web files from `client/build/web`, using the rewrite in `client/firebase.json` to direct web paths to `index.html` so Flutter's URL router can handle them. GitHub Actions workflows in `.github/workflows/` build the Flutter web release and then call Firebase Hosting deployment:

- Pull requests publish a preview channel (a temporary hosted copy for reviewing a proposed change).
- Pushes to `main` publish the live site.

These workflows require the repository secret `FIREBASE_SERVICE_ACCOUNT_THERAPY_PAL_C90A4`. Automatic deployment starts after changes are committed and pushed; editing files only on a local machine does not trigger GitHub Actions.

## 10. Current Design Constraints And Next Architecture Step

The most important limitation is the split between durable and demo data. MongoDB currently stores profiles and analytics, but regimen, adherence, and notification service arrays are process-local. The client sample-data fallbacks can also mask backend outages by keeping screens populated.

A natural next step is to move regimen, regimen-item, adherence-log, and notification data into MongoDB collections, then remove or make explicit the silent sample-data fallbacks for production. That would make writes survive server restarts and allow all backend instances to share the same data. This is a suggested future change, not a description of current behavior.
