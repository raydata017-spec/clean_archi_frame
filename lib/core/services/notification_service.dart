import 'dart:convert';
import 'dart:developer';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router/navigator_keys.dart';
import '../../app/router/route_names.dart';
import '../../features/notification/data/models/notification_model.dart';
import '../../features/notification/presentation/providers/notification_provider.dart';
import '../network/dio_client.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await NotificationHelper.instance.showNotification(message);
}

typedef NotificationNavigationHandler = void Function(
  NotificationModel notification,
  Map<String, dynamic> rawData,
);

class NotificationHelper {
  NotificationHelper._();
  static final NotificationHelper instance = NotificationHelper._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  bool _isFlutterLocalNotificationsInitialized = false;
  bool _areHandlersSetup = false;
  ProviderContainer? _container;

  // Configuration settings for flexibility
  bool _enableTopics = true;
  bool _enableToken = true;
  List<String> _defaultTopics = const ["All", "Customer"];
  NotificationNavigationHandler? _customNavigationHandler;

  Future<void> initialize({
    String? userId,
    required ProviderContainer container,
    bool enableTopics = true,
    bool enableToken = true,
    List<String> defaultTopics = const ["All", "Customer"],
    NotificationNavigationHandler? customNavigationHandler,
  }) async {
    _container = container;
    _enableTopics = enableTopics;
    _enableToken = enableToken;
    _defaultTopics = defaultTopics;
    _customNavigationHandler = customNavigationHandler;

    // Background handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Setup message handlers
    if (!_areHandlersSetup) {
      _setupMessageHandler(container);
      _areHandlersSetup = true;
    }

    // Initialize local notifications
    await setupFlutterNotifications();

    // Request permissions
    try {
      await _requestPermission();
    } catch (e) {
      log("Notification permission request failed: $e");
    }

    // Set up Token Refresh handler
    _messaging.onTokenRefresh.listen((fcmToken) async {
      log("FCM Token refreshed: $fcmToken");
      if (_enableToken && userId != null) {
        await sendFcmTokenToApi();
      }
    });

    // Handle initial topic subscription and token registration
    if (userId != null) {
      if (_enableToken) {
        await sendFcmTokenToApi();
      }
      if (_enableTopics) {
        await subscribeToTopics(userId);
      }
    }
  }

  Future<void> _requestPermission() async {
    await _messaging.requestPermission(alert: true, badge: true, sound: true);

    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  Future<void> sendFcmTokenToApi() async {
    if (_container == null) return;
    try {
      final fcmToken = await _messaging.getToken();
      if (fcmToken == null) {
        log("FCM token is null, skipping API update");
        return;
      }

      final dioClient = _container!.read(dioClientProvider);
      await dioClient.put(
        '/api/users/fcm-token',
        data: {"fcm_token": fcmToken},
      );
      log("FCM token successfully registered to server: $fcmToken");
    } catch (e) {
      log("Failed to send FCM token to API: $e");
    }
  }

  Future<void> deleteFcmTokenFromApi() async {
    if (_container == null) return;
    try {
      final dioClient = _container!.read(dioClientProvider);
      await dioClient.delete('/api/users/fcm-token');
      log("FCM token successfully removed from server");
    } catch (e) {
      log("Failed to delete FCM token from API: $e");
    }
  }

  Future<void> setupFlutterNotifications() async {
    if (_isFlutterLocalNotificationsInitialized) return;

    const channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.high,
      playSound: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );

    await _localNotifications.initialize(
      settings: 
      initializationSettings,
      onDidReceiveNotificationResponse: (response) {
        _onNotificationTap(response);
      },
    );

    _isFlutterLocalNotificationsInitialized = true;
  }

  Future<void> showNotification(RemoteMessage message) async {
    final notification = message.notification;

    if (notification != null) {
      await setupFlutterNotifications();

      final int notificationId = notification.hashCode;

      await _localNotifications.show(
        id: 
        notificationId,
        title:
        notification.title,
        body:
        notification.body,
        notificationDetails:
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel',
            'High Importance Notifications',
            channelDescription: 'This channel is used for important notifications.',
            importance: Importance.high,
            priority: Priority.high,
            playSound: true,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: jsonEncode(message.data),
      );
    }
  }

  Future<void> cancelNotification(int id) async {
    await _localNotifications.cancel(id: id);
  }

  Future<void> cancelAllNotification() async {
    await _localNotifications.cancelAll();
  }

  Future<void> _setupMessageHandler(ProviderContainer container) async {
    // 1. Foreground
    FirebaseMessaging.onMessage.listen((message) {
      showNotification(message);
      _checkAndRefreshState(message, container);
    });

    // 2. Background (App Minimized -> Open)
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _handleBackgroundMessage(message);
      _checkAndRefreshState(message, container);
    });

    // 3. Terminated (App Closed -> Open)
    try {
      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        _handleBackgroundMessage(initialMessage);
        _checkAndRefreshState(initialMessage, container);
      }
    } catch (e) {
      log("Error getting initial message: $e");
    }
  }

  Future<void> _handleNotificationClickNavigation(
    Map<String, dynamic> data,
  ) async {
    int attempts = 0;
    while (NavigatorKeys.root.currentContext == null && attempts < 10) {
      await Future.delayed(const Duration(milliseconds: 500));
      attempts++;
    }

    final context = NavigatorKeys.root.currentContext;
    if (context == null || !context.mounted) {
      log('Navigator context not available or not mounted after 10 attempts');
      return;
    }

    final notification = _parseNotificationFromData(data);

    if (notification != null && _container != null) {
      _container!
          .read(NotificationStates.notificationProvider.notifier)
          .markNotiAsReadById([notification.id]);
    }

    if (_customNavigationHandler != null && notification != null) {
      _customNavigationHandler!(notification, data);
    } else {
      // Default navigation fallback: open notification list screen
      context.push(RouteNames.notificationPath);
    }
  }

  void _handleBackgroundMessage(RemoteMessage message) {
    if (message.data.isNotEmpty) {
      _handleNotificationClickNavigation(message.data);
    }
  }

  void _onNotificationTap(NotificationResponse response) {
    try {
      final payload = response.payload;
      if (payload == null) return;

      final Map<String, dynamic> data = jsonDecode(payload);
      _handleNotificationClickNavigation(data);
    } catch (e) {
      log('Error handling notification tap: $e');
    }
  }

  NotificationModel? _parseNotificationFromData(Map<String, dynamic> data) {
    try {
      return NotificationModel.fromJson(data);
    } catch (e) {
      log('Error parsing notification from data: $e');
      return null;
    }
  }

  void _checkAndRefreshState(
    RemoteMessage message,
    ProviderContainer container,
  ) {
    try {
      final newNotification = _parseNotificationFromData(message.data);
      if (newNotification != null) {
        container
            .read(NotificationStates.notificationProvider.notifier)
            .addNewNotification(newNotification);
      }
    } catch (e) {
      log('Error adding new notification to state: $e');
    }
  }

  /// ---- Topic Management ----
  Future<void> subscribeToTopics(String userId) async {
    if (!_enableTopics) return;
    try {
      for (final topic in _defaultTopics) {
        await _messaging.subscribeToTopic(topic);
      }
      await subscribeToUserTopic(userId);
      log("Subscribed to all default topics and user-specific topics");
    } catch (e) {
      log("Error subscribing to topics: $e");
    }
  }

  Future<void> subscribeToUserTopic(String userId) async {
    if (!_enableTopics) return;
    try {
      await _messaging.subscribeToTopic('enduser-$userId');
      log("Subscribed to user topic: enduser-$userId");
    } catch (e) {
      log("Error subscribing to user topic: $e");
    }
  }

  Future<void> unsubscribeFromUserTopic(String userId) async {
    try {
      await _messaging.unsubscribeFromTopic('enduser-$userId');
      log("Unsubscribed from user topic: enduser-$userId");
    } catch (e) {
      log("Error unsubscribing from user topic: $e");
    }
  }

  Future<void> unsubscribeFromAllTopics(String userId) async {
    try {
      for (final topic in _defaultTopics) {
        await _messaging.unsubscribeFromTopic(topic);
      }
      await unsubscribeFromUserTopic(userId);
      log("Unsubscribed from all topics");
    } catch (e) {
      log("Error unsubscribing from all topics: $e");
    }
  }

  /// ---- Lifecycle Hooks to be called by Auth state changes ----
  Future<void> onUserLogin(String userId) async {
    if (_enableToken) {
      await sendFcmTokenToApi();
    }
    if (_enableTopics) {
      await subscribeToTopics(userId);
    }
  }

  Future<void> onUserLogout(String userId) async {
    if (_enableTopics) {
      await unsubscribeFromAllTopics(userId);
    }
    if (_enableToken) {
      await deleteFcmTokenFromApi();
      await _messaging.deleteToken();
    }
    cancelAllNotification();
  }
}
