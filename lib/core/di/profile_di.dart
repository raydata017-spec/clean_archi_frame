import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/profile/data/data_sources/local/dao/profile_dao.dart';
import 'database_di.dart';

/// Provider for ProfileDao to access profile table queries.
final profileDaoProvider = Provider<ProfileDao>((ref) {
  final database = ref.watch(appDatabaseProvider);
  return ProfileDao(database);
});

/// Stream provider for profile table rows.
final profileListProvider = StreamProvider.autoDispose((ref) {
  return ref.watch(profileDaoProvider).watchProfiles();
});