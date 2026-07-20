import 'package:drift/drift.dart';

import '../../database/app_database.dart';
import '../schema/reference_mapping_table.dart';

part 'reference_mapping_dao.g.dart';

@DriftAccessor(tables: [ReferenceMappingTable])
class ReferenceMappingDao extends DatabaseAccessor<AppDatabase>
    with _$ReferenceMappingDaoMixin {
  ReferenceMappingDao(super.db);

  Future<void> upsertMapping({
    required String clientId,
    required String serverId,
  }) {
    return into(referenceMappingTable).insertOnConflictUpdate(
      ReferenceMappingTableCompanion.insert(
        clientId: clientId,
        serverId: serverId,
      ),
    );
  }

  Future<String?> getServerId(String clientId) async {
    final row = await (select(referenceMappingTable)
          ..where((t) => t.clientId.equals(clientId)))
        .getSingleOrNull();
    return row?.serverId;
  }

  Future<int> clearAll() {
    return delete(referenceMappingTable).go();
  }
}
