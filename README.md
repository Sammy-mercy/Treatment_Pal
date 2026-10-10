# Treatment Pal

Dual-role treatment regimen and medication adherence management platform for patients and clinicians.

## 📁 Project Structure

```
Treatment_Pal/
├── .vscode/                 # Multi-target VS Code launch & debug configurations
├── client/                  # Flutter mobile & web application
│   ├── android/             # Android platform runner
│   ├── ios/                 # iOS platform runner
│   ├── web/                 # Web platform runner
│   ├── windows/             # Windows desktop runner
│   ├── lib/
│   │   ├── main.dart        # Flutter entry point & MultiProvider initialization
│   │   ├── app.dart         # Root MaterialApp.router & theme configuration
│   │   ├── core/            # Network client, theme, constants, and utilities
│   │   ├── routing/         # GoRouter configuration, route paths & guards
│   │   ├── models/          # Shared domain models (User, Regimen, Adherence, etc.)
│   │   ├── features/        # Feature modules (auth, home, regimen, adherence, etc.)
│   │   └── shared/          # Reusable UI widgets and layout shells
│   ├── pubspec.yaml         # Flutter dependencies
│   └── analysis_options.yaml
└── server/                  # Node.js Express REST API backend
    ├── server.js            # Server entry point
    ├── app.js               # Express application configuration & middleware
    ├── .env                 # Environment configuration
    ├── .env.example
    ├── config/              # Database and Firebase Admin configurations
    ├── models/              # Data models (User, Regimen, RegimenItem, AdherenceLog)
    ├── routes/              # Express API route definitions
    ├── controllers/         # Request handling and HTTP responses
    ├── services/            # Business logic layer
    ├── middleware/          # Authentication, authorization, and error handling
    ├── validators/          # Input schema validation
    └── package.json
```

## 🚀 Running with VS Code

Open this repository in VS Code:
1. Open the **Run and Debug** view (`Ctrl+Shift+D` or `Cmd+Shift+D`).
2. Select any of the preset launch configurations:
   - **`Full Stack: Client (Chrome) & Server`**: Runs both backend and web frontend concurrently.
   - **`Full Stack: Client (Windows) & Server`**: Runs both backend and Windows desktop frontend.
   - **`Flutter Client (Chrome)`**: Runs the Flutter client on Chrome.
   - **`Flutter Client (Windows)`**: Runs the Flutter client on Windows.
   - **`Node.js Server`**: Runs the Express backend server on port 5000.
3. Press **F5** to start debugging.

## 💻 Running via Terminal

### Server (Express API)
```bash
cd server
npm install
npm start
# or for live reloading during development:
npm run dev
```

### Client (Flutter)
```bash
cd client
flutter pub get
flutter run -d chrome --dart-define=FIREBASE_PROJECT_ID=your-project-id --dart-define=FIREBASE_WEB_API_KEY=your-web-api-key --dart-define=FIREBASE_WEB_APP_ID=your-web-app-id --dart-define=FIREBASE_MESSAGING_SENDER_ID=your-sender-id --dart-define=FIREBASE_AUTH_DOMAIN=your-project-id.firebaseapp.com
```

## Authentication And Storage

Enable **Authentication → Sign-in method → Email/Password** in Firebase Console. Register a Firebase Web app under **Project settings → General → Your apps**, then use its `apiKey`, `appId`, `messagingSenderId`, `projectId`, and `authDomain` as the `--dart-define` values above. The web API key/app IDs identify the client app; they are not service-account secrets. Android and iOS builds also need their platform-specific API key and app ID supplied as `FIREBASE_ANDROID_API_KEY`, `FIREBASE_ANDROID_APP_ID`, `FIREBASE_IOS_API_KEY`, and `FIREBASE_IOS_APP_ID`; iOS additionally uses `FIREBASE_IOS_BUNDLE_ID`.

The Node API uses Firebase Admin only to verify Firebase ID tokens. Put the service-account `project_id`, `client_email`, and `private_key` in `server/.env` as `FIREBASE_PROJECT_ID`, `FIREBASE_CLIENT_EMAIL`, and `FIREBASE_PRIVATE_KEY`. Keep the private key server-side; the literal `\n` sequences inside the quoted one-line value are converted to PEM line breaks. Firestore does not need to be enabled for this setup.

Set `DATABASE_URL` in `server/.env` to a running MongoDB instance, for example `mongodb://localhost:27017/therapy_pal` for local MongoDB or a MongoDB Atlas connection string. The API creates `users` and `analytics_visits` collections and indexes automatically. User signup creates a Firebase Auth account, then stores the profile in MongoDB; login uses Firebase Auth and sends its ID token to the API. The API loads the app role from the MongoDB profile. Signup is not complete until both Firebase Auth and the MongoDB profile write succeed.

Admin access is provisioned on the server, not through Firebase or public signup. Set a unique `ADMIN_EMAIL`, a strong `ADMIN_PASSWORD`, a separate random `ADMIN_TOKEN_SECRET`, and a strong random `JWT_SECRET` in `server/.env`. Select **Admin** on the login screen and use those configured credentials. The dashboard route is `/admin/dashboard`; its API endpoint `/api/admin/dashboard-stats` rejects non-admin sessions.

The dashboard reports total users, users active today, returning registered users, anonymous visits, distinct anonymous visitors today, and repeat anonymous visitors. Anonymous visitor IDs are stored locally by the client; the API stores those IDs and visit timestamps in MongoDB, not IP addresses. Other regimen/adherence features may still use their existing mock service data; this migration moves authentication profiles and analytics into MongoDB.
