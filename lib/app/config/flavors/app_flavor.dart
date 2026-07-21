enum AppFlavor {
  defaultApp,
  clientA,
  clientB,
}

extension AppFlavorExtension on AppFlavor {
  String get name {
    switch (this) {
      case AppFlavor.defaultApp:
        return 'default';
      case AppFlavor.clientA:
        return 'client_a';
      case AppFlavor.clientB:
        return 'client_b';
    }
  }

  String get displayName {
    switch (this) {
      case AppFlavor.defaultApp:
        return 'BDATA Core Template';
      case AppFlavor.clientA:
        return 'Client A Pro';
      case AppFlavor.clientB:
        return 'Client B Enterprise';
    }
  }
}
