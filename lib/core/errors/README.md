# Error Handling System

ဤ project ၏ error handling system သည် network errors, API errors, app-level errors များကို **တစ်နေရာ centralize** လုပ်ထားပြီး feature တိုင်းတွင် consistent ဖြစ်အောင် ဆောင်ရွက်ပေးသည်။

---

## Folder Structure

```
lib/
├── core/
│   ├── errors/
│   │   ├── error_service.dart       ← Central error router (main entry point)
│   │   ├── app_error_widget.dart    ← UI widget to display errors
│   │   ├── exceptions.dart          ← (Placeholder — custom exceptions)
│   │   └── failures.dart            ← (Placeholder — domain failures)
│   └── utils/
│       └── enums/
│           ├── error_type_enum.dart     ← Network/IO error categories
│           └── app_error_type_enum.dart ← App-level error categories
│
└── shared/
    └── models/
        ├── api_error_model.dart     ← API response error structure
        └── app_error_model.dart     ← App-level custom error model
```

---

## Components

### 1. `ErrorService` — Central Error Router

`lib/core/errors/error_service.dart` ထဲတွင် ရှိပြီး error object တစ်ခုကို receive လုပ်ကာ မှန်ကန်သော action ကို ဆောင်ရွက်ပေးသည်။

| Method | Purpose |
|---|---|
| `getErrorMessage(Object error)` | Error ကို user-friendly String ပြောင်းပေးသည် |
| `getErrorType(Object error)` | `ErrorType` enum ပြန်ပေးသည် (UI switching အတွက်) |
| `getUIError(Object error)` | `UIError` object (type + title + message) ပြန်ပေးသည် |
| `showErrorToast(Object error)` | Error toast ကို directly ပြပေးသည် |
| `getErrorMessageFromException(Exception)` | Exception-only variant |

### 2. `ErrorType` — Error Categories

```dart
enum ErrorType {
  noInternet,   // SocketException
  serverError,  // HttpException, 5xx, HTML response
  timeout,      // TimeoutException
  formatError,  // FormatException (invalid JSON)
  apiError,     // ApiError with non-5xx status
  unknown,      // Everything else
}
```

### 3. `AppError` — App-level Custom Error

Domain layer မှ throw လုပ်ရန် သုံးသည်။ `Exception` ကို implement လုပ်ထားသည်။

```dart
class AppError implements Exception {
  final String message;
  final AppErrorType type; // defaultError | mockLocationError | cameraPermissionError
}
```

### 4. `ApiError` — API Response Error

`DioClient` interceptor မှ JSON error response ကို parse လုပ်ပြီး throw လုပ်သည်။

```dart
// JSON structure expected from server:
// { "error": { "code": "...", "message": "...", "details": [...] }, "message": "..." }

ApiError.fromJson(json, statusCode: 422);
apiError.displayMessage; // Smart message extraction
```

### 5. `AppErrorWidget` — UI Error Display

```dart
AppErrorWidget(
  error: someError,          // Object? — any error type
  onRetry: () => _fetch(),   // Optional retry callback
  color: Colors.red,         // Optional text color
  btnColor: Colors.blue,     // Optional button color
  retryBtnText: 'Reload',    // Optional custom button label
)
```

`error` parameter ၌ `String`, `AppError`, `ApiError`, `SocketException`, `TimeoutException`, `FormatException` — အားလုံး pass ဖြစ်သည်။ `ErrorService.getErrorMessage()` မှ internally handle လုပ်မည်။

---

## Usage Examples

### A. Riverpod Provider တွင် Error ကို Toast ပြသည်

```dart
// In a Notifier or StateNotifier
Future<void> fetchData() async {
  try {
    state = const AsyncValue.loading();
    final result = await _repo.getData();
    state = AsyncValue.data(result);
  } catch (e, st) {
    state = AsyncValue.error(e, st);
    ErrorService.showErrorToast(e); // ← one line
  }
}
```

### B. UI တွင် `AppErrorWidget` သုံးသည်

```dart
// In a build method, watching an AsyncValue
ref.watch(myProvider).when(
  data: (data) => MyDataWidget(data: data),
  loading: () => const CircularProgressIndicator(),
  error: (error, _) => AppErrorWidget(
    error: error,
    onRetry: () => ref.invalidate(myProvider),
  ),
);
```

### C. Error Type ကိုကြည့်ပြီး UI ကွဲပြားစေသည်

```dart
final uiError = ErrorService.getUIError(error);

switch (uiError.type) {
  case ErrorType.noInternet:
    return const NoInternetWidget();
  case ErrorType.serverError:
    return ServerErrorWidget(message: uiError.message);
  default:
    return AppErrorWidget(error: error, onRetry: onRetry);
}
```

### D. Domain Use Case မှ `AppError` throw လုပ်သည်

```dart
// In a repository implementation
Future<User> getUser(String id) async {
  try {
    return await _dataSource.getUser(id);
  } on ApiError {
    rethrow; // Let ErrorService handle it
  } catch (_) {
    throw AppError(
      message: 'Failed to load user profile.',
      type: AppErrorType.defaultError,
    );
  }
}
```

---

## Integration Guide (New Feature)

New feature တစ်ခု add လုပ်သောအခါ ဤ steps ကို လိုက်နာပါ:

**Step 1** — Repository ထဲတွင် error ကို rethrow သာလုပ်ပါ
```dart
// ✅ Correct
} catch (e) { rethrow; }

// ❌ Wrong — ErrorService ကို repository ထဲတွင် မသုံးပါနှင့်
} catch (e) { ErrorService.showErrorToast(e); }
```

**Step 2** — Notifier/BLoC ထဲတွင် error ကို catch ပြီး handle လုပ်ပါ
```dart
} catch (e, st) {
  state = AsyncValue.error(e, st);
  ErrorService.showErrorToast(e); // optional toast
}
```

**Step 3** — UI ထဲတွင် `AppErrorWidget` သုံးပါ
```dart
error: (error, _) => AppErrorWidget(
  error: error,
  onRetry: () => ref.invalidate(myProvider),
),
```

---

## Extending the System

### New `AppErrorType` add လုပ်ရန်
`lib/core/utils/enums/app_error_type_enum.dart` ထဲတွင် enum case ထည့်ပါ:
```dart
enum AppErrorType {
  defaultError,
  mockLocationError,
  cameraPermissionError,
  permissionDenied,  // ← add here
}
```

### New Network Error Category add လုပ်ရန်
`lib/core/utils/enums/error_type_enum.dart` ထဲတွင် case ထည့်ပြီး `ErrorService.getErrorType()` ကို update လုပ်ပါ:
```dart
enum ErrorType {
  noInternet,
  serverError,
  timeout,
  formatError,
  apiError,
  unauthorized, // ← new
  unknown,
}
```

---

## Error Message Precedence

`ErrorService.getErrorMessage()` သည် အောက်ပါ order ဖြင့် message ရွေးချယ်သည်:

```
1. String   → directly return (with "INTERNAL_SERVER_ERROR" special case)
2. ApiError → errorDetail[0].message → message → rootMessage → fallback
3. AppError → error.message
4. HttpException → error.message
5. SocketException → "No internet connection."
6. FormatException → HTML detection → specific status code messages
7. TimeoutException → "Request timed out."
8. Exception/Error → strip prefix, return clean message
9. Fallback → "An unexpected error occurred."
```

---

## Known Limitations

> [!NOTE]
> `exceptions.dart`, `failures.dart` are intentional placeholder files in `lib/core/errors/` reserved for future domain-layer Failure classes (e.g., Either<Failure, T> pattern).

> [!NOTE]
> `ErrorService.getUIError()` titles (`'No Connection'`, `'Server Error'` etc.) are currently hardcoded in English. Localize them via `t.errors.*` if multi-language title support is needed.

