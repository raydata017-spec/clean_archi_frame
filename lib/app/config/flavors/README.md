# White-Label Flavors Architecture Guide

This directory contains the central **White-Label Architecture & Flavor Configuration System** for `clean_archi_frame`. 

The framework is designed around a single principle: **Developers only need to modify configuration files to configure or add a client app**. UI components, themes, splash screens, default settings, and feature flags adapt dynamically without requiring any UI code modifications.

---

## 📁 Folder Structure

```
lib/app/config/flavors/
├── app_flavor.dart            # Enum definitions & extension for app flavors
├── app_config.dart            # Central AppConfig model & client preset definitions
├── flavor_config_provider.dart # Riverpod provider (appConfigProvider) for state injection
└── README.md                  # Flavor setup & usage documentation (This file)
```

---

## ⚙️ Configuration Reference (`AppConfig`)

| Property | Type | Description |
| :--- | :--- | :--- |
| `appName` | `String` | App Title displayed in MaterialApp, Headers, and System task manager |
| `flavor` | `AppFlavor` | Flavor Enum (`defaultApp`, `clientA`, `clientB`, etc.) |
| `apiBaseUrl` | `String` | Base URL for REST API HTTP Client |
| `primaryColor` | `Color` | Flat corporate primary brand color |
| `secondaryColor` | `Color` | Flat corporate secondary brand color |
| `appLogoAsset` | `String` | Asset path for App Logo & Splash Screen logo |
| `defaultThemeMode` | `ThemeMode` | Initial theme when unsaved (`system`, `light`, `dark`) |
| `defaultLocaleMode`| `AppLocaleMode`| Initial language when unsaved (`system`, `english`, `burmese`)|
| `featureFlags` | `Map<String, bool>`| Feature toggles (`enableBiometrics`, `enableOfflineSync`, `enableInAppUpdate`) |

---

## 🚀 How to Setup a New Client Flavor (Step-by-Step)

To add a new flavor (e.g., **Client C**):

### 1. Add Enum Entry in `app_flavor.dart`

```dart
enum AppFlavor {
  defaultApp,
  clientA,
  clientB,
  clientC, // <--- Add new flavor
}
```

### 2. Define Client Configuration in `app_config.dart`

```dart
static const AppConfig clientC = AppConfig(
  appName: 'Client C Logistics',
  flavor: AppFlavor.clientC,
  apiBaseUrl: 'https://api.clientc.example.com',
  primaryColor: Color(0xFF0F766E),
  secondaryColor: Color(0xFFF59E0B),
  appLogoAsset: 'assets/images/logo_client_c.png',
  defaultThemeMode: ThemeMode.system,
  defaultLocaleMode: AppLocaleMode.system,
  featureFlags: {
    'enableBiometrics': true,
    'enableOfflineSync': true,
    'enableInAppUpdate': true,
  },
);
```

Update `fromFlavor` helper method:

```dart
static AppConfig fromFlavor(AppFlavor flavor) {
  switch (flavor) {
    case AppFlavor.clientA:
      return clientA;
    case AppFlavor.clientB:
      return clientB;
    case AppFlavor.clientC:
      return clientC;
    case AppFlavor.defaultApp:
      return defaultApp;
  }
}
```

### 3. Create Entrypoint File (`lib/main_client_c.dart`)

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'app/config/env.dart';
import 'app/config/flavors/app_config.dart';
import 'app/config/flavors/flavor_config_provider.dart';
import 'app/config/localization/generated/translations.g.dart';
import 'core/storage/shared_pref_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Client C Flavor Config
  Env.init(AppConfig.clientC);

  LocaleSettings.useDeviceLocale();
  final sharedPreferences = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        appConfigProvider.overrideWithValue(AppConfig.clientC),
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: TranslationProvider(
        child: const MyApp(),
      ),
    ),
  );
}
```

### 4. Configure Android Native Build (`android/app/build.gradle.kts`)

Add `client_c` inside `productFlavors`:

```kotlin
productFlavors {
    create("client_c") {
        dimension = "app"
        applicationIdSuffix = ".client_c"
        resValue("string", "app_name", "Client C Logistics")
    }
}
```

### 5. Add VS Code Debug Profile (`.vscode/launch.json`)

```json
{
  "name": "Client C (Logistics)",
  "request": "launch",
  "type": "dart",
  "program": "lib/main_client_c.dart",
  "args": ["--flavor", "client_c"]
}
```

---

## 💻 How to Use in Code (Usage Examples)

### 1. Riverpod Provider Access (Recommended for UI)

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clean_archi_frame/app/config/flavors/flavor_config_provider.dart';

class MyFeatureWidget extends ConsumerWidget {
  const MyFeatureWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Read active flavor configuration
    final appConfig = ref.watch(appConfigProvider);

    return Column(
      children: [
        Text(appConfig.appName),
        Image.asset(appConfig.appLogoAsset),

        // Check feature flag - UI automatically hides if false
        if (appConfig.isFeatureEnabled('enableBiometrics'))
          ElevatedButton(
            onPressed: () {},
            child: const Text('Biometric Login'),
          ),
      ],
    );
  }
}
```

### 2. Static Environment Helper Access (Recommended for Repositories/Services)

```dart
import 'package:clean_archi_frame/app/config/env.dart';

// Get API Endpoint
final String url = Env.apiBaseUrl;

// Check Feature Status
if (Env.isFeatureEnabled('enableOfflineSync')) {
  // Execute Outbox Sync Logic
}
```

---

## 🏃 Run & Debug Commands

```bash
# Run Default App
flutter run --flavor defaultApp -t lib/main.dart

# Run Client A (Enterprise)
flutter run --flavor client_a -t lib/main_client_a.dart

# Run Client B (Commerce)
flutter run --flavor client_b -t lib/main_client_b.dart

# Run Client C (Logistics)
flutter run --flavor client_c -t lib/main_client_c.dart
```
