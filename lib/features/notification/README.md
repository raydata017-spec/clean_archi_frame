# Flexible Notification Service (FCM Topic & Token Support)

This module provides a decoupled, highly configurable Notification Service for Flutter projects using Clean Architecture and Riverpod. It encapsulates Firebase Cloud Messaging (FCM) and Local Notifications into a single interface.

---

## Folder Structure

```
lib/
├── core/
│   └── services/
│       └── notification_service.dart     # Service entry point & Helper class
│
└── features/
    └── notification/
        ├── data/
        │   └── models/
        │       └── notification_model.dart  # JSON mapper for API and Firebase FCM
        │
        ├── domain/
        │   └── entities/
        │       └── notification_entity.dart # Core notification structure
        │
        └── presentation/
            ├── screens/
            │   └── notification_screen.dart # Notification list UI
            │
            ├── providers/
            │   └── notification_provider.dart  # Riverpod reactive state notifier
            │
            └── widgets/
                └── notification_card.dart   # Individual notification card
```

---

## Configuration & Usage

### 1. Initialize in `main.dart`
Initialize the notification service after bootstrapping your `ProviderContainer`:

```dart
final container = ProviderContainer();

await NotificationHelper.instance.initialize(
  container: container,
  enableTopics: true,                  // Enable topic subscriptions (default: true)
  enableToken: true,                   // Enable token registrations (default: true)
  defaultTopics: ["All", "Customer"], // Global/Group topics
  customNavigationHandler: (notification, rawData) {
    // Custom route handler on notification click
    if (notification.type == NotificationType.security) {
      NavigatorKeys.root.currentContext?.push('/security-logs');
    } else {
      NavigatorKeys.root.currentContext?.push(RouteNames.notificationPath);
    }
  },
);
```

### 2. Integration with Auth Lifecycles

Trigger topic subscription and token registration when the user signs in, and clean them up during sign-out.

#### Upon Login:
```dart
// Register FCM token to backend & subscribe to topics
await NotificationHelper.instance.onUserLogin(userId);
```

#### Upon Logout:
```dart
// Unsubscribe from topics, delete FCM token on backend, and wipe local tokens
await NotificationHelper.instance.onUserLogout(userId);
```

### 3. Displaying Incoming Messages

The `showNotification` method takes a `RemoteMessage` (received from Firebase Cloud Messaging) and displays it as a local system notification banner. It is automatically called inside the foreground message listener, but you can also call it manually:

```dart
import 'package:firebase_messaging/firebase_messaging.dart';

// Display a notification banner manually from an FCM RemoteMessage
await NotificationHelper.instance.showNotification(message);
```

---

## Architecture & Workflow Details

### 1. Topic-Based Routing (Broadcasting)
Ideal for broad or group-based delivery (e.g., Announcements).
- **Global Topics**: Configurable via `defaultTopics` parameter in `initialize` (e.g. `All`, `Customer`).
- **User-Specific Topics**: Registers to `enduser-$userId` on login. Allows backend servers to broadcast to all devices owned by a user without keeping track of multiple token keys.

### 2. Token-Based Routing (Targeting Specific Devices)
Ideal for targeting specific individual devices (e.g., direct chat messages, transactional system alerts).
- Retrieves FCM registration token via `FirebaseMessaging.instance.getToken()`.
- Sends token to API via `DioClient` (using `/api/users/fcm-token` endpoint by default).
- Set up an automated listener to watch for FCM token rotations (`onTokenRefresh`) and instantly sync the new token with the backend.

### 3. State Management & Local UI Updates
- Integrates with a Riverpod `NotifierProvider` (`notificationProvider`) to keep the list of notifications reactive.
- When the app is in the foreground, `onMessage` listener intercepts FCM messages, shows a local system banner via `flutter_local_notifications`, and pushes the notification model to Riverpod state to refresh the UI in real-time.
