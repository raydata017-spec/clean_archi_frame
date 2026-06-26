import 'package:drift/drift.dart';

import '../../../../../../core/database/app_database.dart';
import '../schema/profiles_schema.dart';

part 'profile_dao.g.dart';

@DriftAccessor(tables: [ProfileTable])
class ProfileDao extends DatabaseAccessor<AppDatabase> with _$ProfileDaoMixin {
  ProfileDao(super.db);

  Stream<List<ProfileTableData>> watchProfiles() {
    return select(profileTable).watch();
  }

  Future<ProfileTableData?> getProfileById(int id) {
    return (select(profileTable)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

  Future<int> insertProfile(ProfileTableCompanion companion) {
    return into(profileTable).insert(companion);
  }

  Future<int> updateProfile(int id, ProfileTableCompanion companion) {
    return (update(profileTable)..where((tbl) => tbl.id.equals(id))).write(companion);
  }
}
