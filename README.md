# isramaramapp

Flutter app with auth. Runs on **Windows** and **macOS**.

## Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install)
- **Windows:** Visual Studio 2022 with "Desktop development with C++" workload
- **macOS:** Xcode (from App Store)

## Steps to Run

### 1. Clone the repo

```bash
git clone https://github.com/DeganiOmaar/isramaramapp.git
cd isramaramapp
```

### 2. Get dependencies

```bash
flutter pub get
```

### 3. Run the app

**Auto-detect platform (recommended):**

```bash
npm run app
```

**Or run manually:**

```bash
# On Windows
flutter run -d windows

# On macOS
flutter run -d macos
```

### 4. Backend

The app connects to a backend API. Clone and run it separately:

```bash
git clone https://github.com/DeganiOmaar/isramaramback.git
cd isramaramback
npm install
# Create .env with PORT, MONGO_URI, JWT_SECRET
npm run dev
```

The app expects the backend at `http://127.0.0.1:3000/api`.
