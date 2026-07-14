import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final connectivityStreamProvider = StreamProvider<bool>((ref) {
  final controller = StreamController<bool>();
  Timer? timer;
  List<ConnectivityResult> lastResults = [];

  Future<void> checkConnection(List<ConnectivityResult> results) async {
    lastResults = results;
    if (results.contains(ConnectivityResult.none)) {
      timer?.cancel();
      timer = null;
      controller.add(false);
      return;
    }

    final hasInternet = await _checkInternetAccess();
    controller.add(hasInternet);

    // If connected to a network interface, start periodic check to detect loss of internet (e.g. WiFi without internet)
    timer ??= Timer.periodic(const Duration(seconds: 5), (_) async {
      if (!lastResults.contains(ConnectivityResult.none)) {
        final activeCheck = await _checkInternetAccess();
        if (!controller.isClosed) {
          controller.add(activeCheck);
        }
      }
    });
  }

  // Initial check
  Connectivity().checkConnectivity().then(checkConnection);

  final subscription = Connectivity().onConnectivityChanged.listen(checkConnection);

  ref.onDispose(() {
    timer?.cancel();
    subscription.cancel();
    controller.close();
  });

  return controller.stream;
});

// Helper function to perform DNS lookup to verify actual internet access
Future<bool> _checkInternetAccess() async {
  try {
    final result = await InternetAddress.lookup('google.com').timeout(const Duration(seconds: 3));
    return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
  } catch (_) {
    return false;
  }
}

// This provider can be used for one-time checks of connectivity status
final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  return ConnectivityService();
});

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();

  Future<bool> hasInternet() async {
    final results = await _connectivity.checkConnectivity();
    if (results.contains(ConnectivityResult.none)) {
      return false;
    }
    return _checkInternetAccess();
  }
}
