/// Maps offline client-generated IDs to server IDs after successful sync.
///
/// Prefer Dual-ID on entities when possible; use this for cross-action
/// references that must be rewritten before a dependent outbox item syncs.
abstract class LocalReferenceRepository {
  /// Persists a client_id → server_id mapping.
  Future<void> saveMapping({
    required String clientId,
    required String serverId,
  });

  /// Resolves a client ID to its server ID, or null if not yet mapped.
  Future<String?> getServerId(String clientId);

  /// Clears all mappings (e.g. on logout).
  Future<void> clearAllMappings();
}
