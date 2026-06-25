abstract class SyncException implements Exception {
  final String message;

  SyncException(this.message);

  @override
  String toString() => message;
}

/// ဒေတာချင်း ထပ်နေသည့်အခါ (ဥပမာ - Unique Constraint, 409 Conflict)
class SyncConflictException extends SyncException {
  SyncConflictException(super.message);
}

/// အင်တာနက် လိုင်းကျသွားခြင်း သို့မဟုတ် Timeout ဖြစ်သွားသည့်အခါ
class SyncNetworkException extends SyncException {
  SyncNetworkException(super.message);
}

/// ဆာဗာဘက်မှ Error တက်သည့်အခါ (ဥပမာ - 500, 502, 503)
class SyncServerException extends SyncException {
  SyncServerException(super.message);
}

/// အခြား အထွေထွေ Error များအတွက်
class SyncUnknownException extends SyncException {
  SyncUnknownException(super.message);
}