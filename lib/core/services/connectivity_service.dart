import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final connectivityStreamProvider = StreamProvider<bool>((ref) {
  final service = ref.watch(connectivityServiceProvider);
  return service.onStatusChanged;
});

final connectivityServiceProvider = Provider<ConnectivityChecker>((ref) {
  final service = ConnectivityService();
  ref.onDispose(service.dispose);
  return service;
});

/// Minimal contract used by [OfflineSyncEngine] (easy to fake in tests).
abstract class ConnectivityChecker {
  Future<bool> hasInternet();
  Stream<bool> get onStatusChanged;
  void dispose();
}

class ConnectivityService implements ConnectivityChecker {
  final Connectivity _connectivity;
  final StreamController<bool> _statusController =
      StreamController<bool>.broadcast();

  StreamSubscription<List<ConnectivityResult>>? _subscription;
  Timer? _timer;
  List<ConnectivityResult> _lastResults = [];
  bool? _lastEmitted;
  bool _started = false;

  ConnectivityService({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  @override
  Stream<bool> get onStatusChanged {
    _ensureStarted();
    return _statusController.stream;
  }

  void _ensureStarted() {
    if (_started) return;
    _started = true;

    _connectivity.checkConnectivity().then(_onConnectivityChanged);
    _subscription =
        _connectivity.onConnectivityChanged.listen(_onConnectivityChanged);
  }

  Future<void> _onConnectivityChanged(List<ConnectivityResult> results) async {
    _lastResults = results;
    if (results.contains(ConnectivityResult.none)) {
      _timer?.cancel();
      _timer = null;
      _emit(false);
      return;
    }

    final hasInternet = await _checkInternetAccess();
    _emit(hasInternet);

    _timer ??= Timer.periodic(const Duration(seconds: 5), (_) async {
      if (!_lastResults.contains(ConnectivityResult.none)) {
        final activeCheck = await _checkInternetAccess();
        _emit(activeCheck);
      }
    });
  }

  void _emit(bool value) {
    if (_statusController.isClosed) return;
    if (_lastEmitted == value) return;
    _lastEmitted = value;
    _statusController.add(value);
  }

  @override
  Future<bool> hasInternet() async {
    final results = await _connectivity.checkConnectivity();
    if (results.contains(ConnectivityResult.none)) {
      return false;
    }
    return _checkInternetAccess();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _subscription?.cancel();
    _statusController.close();
  }
}

Future<bool> _checkInternetAccess() async {
  try {
    final result = await InternetAddress.lookup('google.com')
        .timeout(const Duration(seconds: 3));
    return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
  } catch (_) {
    return false;
  }
}
