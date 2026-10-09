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
flutter run -d chrome     # Run in Chrome
flutter run -d windows    # Run as Windows desktop app
```
