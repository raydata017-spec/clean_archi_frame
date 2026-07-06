enum NotificationType {
  system,
  security,
  analytics,
  general,
  unknown;

  static NotificationType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'system':
        return NotificationType.system;
      case 'security':
        return NotificationType.security;
      case 'analytics':
        return NotificationType.analytics;
      case 'general':
        return NotificationType.general;
      default:
        return NotificationType.unknown;
    }
  }
}
