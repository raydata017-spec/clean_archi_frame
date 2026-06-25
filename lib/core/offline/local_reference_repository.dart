///if we use Dual-ID, we don't need LocalReferenceRepository
abstract class LocalReferenceRepository {
  /// Client ID နှင့် Server ID Mapping ကို သိမ်းဆည်းရန်
  Future<void> saveMapping({required String clientId, required String serverId});

  /// Client ID ကို ပေးပြီး Server ID ကို ပြန်ထုတ်ရန်
  Future<String?> getServerId(String clientId);

  /// အသုံးမလိုတော့သည့် Mapping များကို ရှင်းလင်းရန်
  Future<void> clearAllMappings();
}