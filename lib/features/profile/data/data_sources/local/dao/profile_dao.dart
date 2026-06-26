import 'package:drift/drift.dart';

import '../../../../../../core/database/app_database.dart';

class ProfileDao extends DatabaseAccessor<AppDatabase> {
  ProfileDao(super.db);

  Stream<List<ProfileTableData>> watchProfiles() {
    return select(db.profileTable).watch();
  }

  Future<ProfileTableData?> getProfileById(int id) {
    return (select(db.profileTable)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

  Future<int> insertProfile(ProfileTableCompanion companion) {
    return into(db.profileTable).insert(companion);
  }

  Future<int> updateProfile(int id, ProfileTableCompanion companion) {
    return (update(db.profileTable)..where((tbl) => tbl.id.equals(id))).write(companion);
  }
}
