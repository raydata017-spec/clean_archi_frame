import '../../database/app_database.dart';
import '../dao/reference_mapping_dao.dart';
import 'local_reference_repository.dart';

class DriftLocalReferenceRepository implements LocalReferenceRepository {
  final ReferenceMappingDao _dao;

  DriftLocalReferenceRepository(this._dao);

  /// Convenience constructor when only [AppDatabase] is available.
  factory DriftLocalReferenceRepository.fromDatabase(AppDatabase db) {
    return DriftLocalReferenceRepository(ReferenceMappingDao(db));
  }

  @override
  Future<void> saveMapping({
    required String clientId,
    required String serverId,
  }) {
    return _dao.upsertMapping(clientId: clientId, serverId: serverId);
  }

  @override
  Future<String?> getServerId(String clientId) {
    return _dao.getServerId(clientId);
  }

  @override
  Future<void> clearAllMappings() async {
    await _dao.clearAll();
  }
}
