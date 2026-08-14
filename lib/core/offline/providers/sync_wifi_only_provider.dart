import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../di/offline_di.dart';
import '../../storage/shared_pref_service.dart';

class SyncWifiOnlyNotifier extends Notifier<bool> {
  late final SharedPrefService _sharedPrefs;

  @override
  bool build() {
    _sharedPrefs = ref.watch(sharedPrefServiceProvider);
    return _sharedPrefs.getSyncWifiOnly();
  }

  Future<void> toggle(bool enabled) async {
    await _sharedPrefs.saveSyncWifiOnly(enabled);
    state = enabled;
    ref.read(offlineSyncEngineProvider).setSyncWifiOnly(enabled);
    ref.read(offlineSyncEngineProvider).triggerSync();
  }
}

final syncWifiOnlyProvider =
    NotifierProvider<SyncWifiOnlyNotifier, bool>(() {
  return SyncWifiOnlyNotifier();
});
