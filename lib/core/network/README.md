# Network Layer (Dio Client)

ဤ project ၏ network layer ကို `Dio` HTTP library အပေါ်တွင် အခြေခံ၍ တည်ဆောက်ထားပြီး interceptors နှင့် custom exceptions များကို standard တကျ စီစဉ်ထားသည်။

---

## Folder Structure

```
lib/core/network/
├── dio_client.dart                  ← Main API Client with GET, POST, etc. and error mapping
├── exceptions/
│   ├── api_exception.dart           ← Base exception for non-2xx responses (wraps ApiError)
│   ├── network_exception.dart       ← Exception for socket/connection/timeout failures
│   └── unauthorized_exception.dart  ← Specific exception for 401 Unauthorized
└── interceptors/
    ├── auth_interceptor.dart        ← Appends Bearer token & handles automatic OAuth2 Token Refresh via QueuedInterceptor
    ├── logger_interceptor.dart      ← Pretty prints requests, responses, and errors in debug mode
    └── retry_interceptor.dart       ← Retries failed idempotent requests (GET, PUT, DELETE)
```

---

## Usage Examples

### A. API Call ပြုလုပ်ရန် (Data Source Layer)

```dart
class AuthRemoteDataSource {
  final DioClient _client;

  AuthRemoteDataSource(this._client);

  Future<UserResponse> login(String email, String password) async {
    final response = await _client.post(
      '/auth/login',
      data: {
        'email': email,
        'password': password,
      },
      options: Options(extra: {kIsPublicExtra: true}), // Public request (No token injected)
    );
    
    return UserResponse.fromJson(response.data);
  }
}
```

### B. Custom Exception Mapping

`DioClient` သည် internal error များကို automatically handle လုပ်ပြီး အောက်ပါအတိုင်း standard exceptions အဖြစ် transform လုပ်ပေးသည်:

| Dio Error type | Transformed Exception |
|---|---|
| Timeout (connection/receive/send) | `TimeoutException` |
| Bad Response (401) | `UnauthorizedException` |
| Bad Response (400, 422, etc.) | `ApiException` (which contains `ApiError`) |
| Connection Error | `SocketException` |
| Unknown / Socket Error | `SocketException` or `NetworkException` |

ထို့ကြောင့် Presentation/UI Layer ၌ `ErrorService.getErrorMessage(error)` ကို သုံးလိုက်သည်နှင့် ၎င်း exceptions များကို automatically identify လုပ်ပြီး user-friendly message ပြသပေးမည်ဖြစ်သည်။

---

## Token Refresh Mechanism (Access + Refresh Token)

`AuthInterceptor` ကို `QueuedInterceptor` အဖြစ် တည်ဆောက်ထားပြီး access token သက်တမ်းကုန်သွားပါက refresh token သုံး၍ အလိုအလျောက် သက်တမ်းတိုးပေးသည့်စနစ် ပါဝင်သည်။

### အလုပ်လုပ်ပုံအဆင့်ဆင့်:
1. API request များတွင် access token ကို request header (`Authorization: Bearer <token>`) အဖြစ် အလိုအလျောက် ထည့်သွင်းပေးသည်။
2. API မှ status code `401 Unauthorized` ပြန်လာပါက:
   - `AuthInterceptor` သည် dynamic request များကို ခေတ္တ lock/queue လုပ်ထားသည်။
   - သီးခြား isolated `Dio` client ကိုသုံးပြီး `refreshPath` (Default: `/auth/refresh`) သို့ `refreshToken` ပေးပို့ကာ သက်တမ်းတိုးရန် တောင်းဆိုသည်။
3. **တောင်းဆိုမှု အောင်မြင်ပါက**:
   - အသစ်ရရှိလာသော access token နှင့် refresh token များကို local memory (`SharedPrefService`) တွင် အစားထိုး သိမ်းဆည်းသည်။
   - 401 ကြောင့် ကျန်ရှိနေခဲ့သည့် မူလ request အား headers အသစ်ဖြင့် retry လုပ်ပြီး retry response အောင်မြင်စွာ ပြန်ပေးသည်။
   - Queue ထဲရှိ စောင့်ဆိုင်းနေသော ကျန် request အားလုံးကို retry ပြန်လုပ်ပေးသည်။
4. **သက်တမ်းတိုးမှု မအောင်မြင်ပါက (ဥပမာ - Refresh Token ပါ သက်တမ်းကုန်ဆုံးသွားခြင်း)**:
   - သိမ်းဆည်းထားသော tokens အားလုံးကို storage မှ ဖျက်ပစ်သည် (Logout လုပ်သည်)။
   - `401 UnauthorizedException` ကို UI layer အထိ rethrow လုပ်ပြီး Login screen သို့ redirect ဖြစ်စေရန် လုပ်ဆောင်သည်။
   
> [!TIP]
> Token Refresh endpoint သို့ တောင်းဆိုမှုများကို infinite loop မဖြစ်စေရန် refresh request options များတွင် automatically check လုပ်ပြီး filter လုပ်ပေးထားသည်။

