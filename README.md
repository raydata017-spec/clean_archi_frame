# clean_archi_frame

Mobile Clean Architecture Framework for generator.

This framework is built with **Riverpod**, **Clean Architecture**, and **SharedPreferences** to provide a robust, scalable, and easy-to-use foundation for enterprise-level Flutter applications.

---

## Theme Architecture

Theme စနစ်ကို UI မှ လွယ်ကူစွာ ခေါ်သုံးနိုင်ရန် `Extension` များဖြင့် တည်ဆောက်ထားပါသည်။

- **Raw Colors (`config/colors.dart`):** Hex code အရောင်များ အားလုံးကို ဤနေရာတွင် သိမ်းပါသည်။
- **Theme Extension (`config/theme/app_colors_extension.dart`):** Light Mode နှင့် Dark Mode အတွက် အရောင်များကို ခွဲခြားသတ်မှတ်ပေးပါသည်။
- **Context Extension (`core/utils/extensions/context_extension.dart`):** Developer များ UI ရေးရာတွင် အလွယ်တကူ ခေါ်သုံးနိုင်ရန် တံတားထိုးပေးပါသည်။

### UI တွင် အသုံးပြုနည်း (Usage)

Theme အရောင်များကို `Theme.of(context)` အရှည်ကြီး ရေးစရာမလိုဘဲ အလွယ်တကူ ခေါ်သုံးနိုင်ပါသည်။

```dart
import '../../core/utils/extensions/context_extension.dart';

// ၁။ Custom Colors များ ခေါ်သုံးခြင်း (Light/Dark အလိုလို ပြောင်းပါမည်)
Container(color: context.colors.customBackground)

// ၂။ Material Default Colors များ ခေါ်သုံးခြင်း
Text('BDATA', style: TextStyle(color: context.colorScheme.primary))

// ၃။ TextTheme ခေါ်သုံးခြင်း
Text('Hello', style: context.textTheme.headlineMedium)
```

### Theme အပြောင်းအလဲ လုပ်နည်း (Toggle Theme)

```dart
ref.read(themeControllerProvider.notifier).toggleTheme();
```

> **Note:** ပြောင်းလဲလိုက်သော Theme ကို SharedPreferences ဖြင့် အလိုအလျောက် သိမ်းဆည်းပေးပြီး၊ App ပြန်ဖွင့်ပါက Flicker (မျက်တောင်ခတ်ခြင်း) မရှိဘဲ မှန်ကန်သော Theme ဖြင့် တန်းပွင့်လာပါမည်။

---

## Localization & i18n

စာသားများအားလုံးကို Type-safe ဖြစ်စေရန်နှင့် အမှားကင်းစေရန် slang package ကို အသုံးပြုထားပါသည်။

### စာသားအသစ်များ ထည့်သွင်းခြင်း

**`lib/app/config/localization/i18n/`** အောက်ရှိ **`strings_en.i18n.json`** နှင့် **`strings_my.i18n.json`** ဖိုင်များတွင် သွားရောက် ထည့်သွင်းရပါမည်။

```json
{
  "hello": "Hello World",
  "changeLanguage": "Change Language",
  "welcomeMessage": "Welcome back, $name! You have $point points."
}
```

**Must Do**

> JSON ဖိုင်များတွင် စာသားအသစ်ထည့်ပြီးတိုင်း မဖြစ်မနေ အောက်ပါ Command ကို Terminal တွင် Run ပေးရပါမည်။ သို့မှသာ UI တွင် ခေါ်သုံး၍ ရပါမည်။

```bash
dart run slang
```

### UI တွင် အသုံးပြုနည်း (Usage)

```dart
import '../config/localization/generated/translations.g.dart';

// ၁။ ရိုးရိုး စာသားများ ခေါ်သုံးခြင်း
Text(t.hello)

// ၂။ Dynamic Variables များ ခေါ်သုံးခြင်း (Type-safe)
Text(t.welcomeMessage(name: 'Kaung Mrat', point: 1500))
```

### ဘာသာစကား ပြောင်းနည်း (Change Language)

```dart
import '../config/localization/locale_provider.dart';

// ဥပမာ - မြန်မာဘာသာသို့ ပြောင်းရန်
ref.read(localeControllerProvider.notifier).changeLocale(AppLocale.my);
```

> Note: ရွေးချယ်လိုက်သော ဘာသာစကားကို Local Storage တွင် အလိုအလျောက် မှတ်သားထားမည် ဖြစ်သည်။

---

## DAO (Data Access Object)

This framework uses Drift to store and query local data. A DAO is a small class that keeps SQL-related logic in one place.

### What is a DAO?

- A DAO contains query methods for one or more tables.
- It keeps database access separate from UI and business logic.
- It usually extends `DatabaseAccessor<AppDatabase>`.

### Example DAO

Put the example DAO here:

- `lib/features/profile/data/data_sources/local/dao/profile_dao.dart`

```dart
import 'package:drift/drift.dart';
import '../../../../../../core/database/app_database.dart';

class ProfileDao extends DatabaseAccessor<AppDatabase> {
  ProfileDao(AppDatabase db) : super(db);

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
```

### How to use a DAO

1. Create the DAO class in your feature folder.
2. Inject it using a Riverpod provider or pass it into your repository.
3. Call `watchProfiles()` for streams or `insertProfile(...)` for writes.

### Do I need code generation?

- This project uses ready-made DAO wiring with `@DriftDatabase(daos: [ProfileDao, OutboxDao])`.
- `@DriftAccessor` generates the table mixins for each DAO.
- Yes — when you use these Drift annotations, run the generator to produce the DAO mixins.

### When should I run the generator?

Run `build_runner` whenever you change the DAO annotations, table definitions, or `@DriftDatabase` configuration.

```bash
dart run build_runner build --delete-conflicting-outputs
```

### Recommended clean frame approach

- Keep DAOs simple and manual for the framework.
- Avoid adding generated DAO wiring unless you need it.
- This makes the core frame easier to understand and reuse.

---

## Offline Sync Processors

The offline core processes queued actions from the local outbox. A processor handles one action type and sends it to the server.

### What is an offline processor?

- It implements `OutboxActionProcessor`.
- It has one `actionType`, such as `create_post` or `update_profile`.
- It performs the network call in `process()`.
- It handles conflict and failure cases in `onConflict()` and `onFailure()`.

### Example processor

```dart
import 'package:clean_archi_frame/core/offline/offline_outbox_item.dart';
import 'package:clean_archi_frame/core/offline/outbox_action_processor.dart';
import 'package:clean_archi_frame/core/utils/exceptions/sync_exceptions.dart';

class CreatePostProcessor extends OutboxActionProcessor {
  @override
  String get actionType => 'create_post';

  @override
  Future<Map<String, dynamic>?> process(OfflineOutboxItem item) async {
    final payload = item.payloadAsMap;

    // TODO: Replace with your real API client.
    final response = await apiClient.createPost(payload);

    if (response.statusCode == 409) {
      throw SyncConflictException('Conflict creating post');
    }

    if (response.statusCode >= 500) {
      throw SyncServerException('Server error');
    }

    if (!response.isOk) {
      throw SyncNetworkException('Network error');
    }

    return response.body;
  }

  @override
  Future<void> onConflict(Object error, OfflineOutboxItem item) async {
    // Example: mark the item as conflicted or ask the user to resolve it.
  }

  @override
  Future<void> onFailure(Object error, OfflineOutboxItem item, int currentRetries) async {
    // Example: log the failure or show a message after retries are exhausted.
  }
}
```

### Where to place processors

A good location for feature processors is inside the feature folder:

- `lib/features/profile/data/data_sources/processors/update_profile_processor.dart`

This makes feature-specific sync logic easy to find.

### How to register processors

Register processors in app startup or feature initialization:

```dart
final engine = ref.watch(offlineSyncEngineProvider);
engine.registerProcessor(CreatePostProcessor());
engine.registerProcessor(UpdateProfileProcessor());
```

### How the offline sync engine works

- It watches the local outbox database.
- When a pending item appears and there is internet, it triggers sync.
- It finds a processor by `actionType`.
- It calls `process()` to send data to the server.
- On conflict, it calls `onConflict()`.
- On failure, it calls `onFailure()` and retries as configured.

### Real project advice

- Use a unique `actionType` for each offline request type.
- Keep processors focused on one endpoint.
- Keep the engine logic in the core and feature-specific logic in processor classes.
- Use the local outbox only for queued write actions, not for read-only queries.

---

## Auth Type Configuration (AuthTypeEnum)

Commercial project တစ်ခုချင်းစီ၏ လိုအပ်ချက်ပေါ်မူတည်၍ Login/Register ပုံစံများကို `AuthTypeEnum` အသုံးပြုကာ [app_router.dart](file:///d:/Projects/clean_archi_frame/lib/app/router/app_router.dart) တွင် လွယ်ကူစွာ သတ်မှတ်ပေးနိုင်ပါသည်။

- `AuthTypeEnum.both`: Email နှင့် Phone login/register နှစ်မျိုးလုံးကို tab selector ဖြင့် ပြသပေးပါမည်။
- `AuthTypeEnum.emailOnly`: Email ဖြင့်သာ login/register ပြုလုပ်နိုင်ရန် tab selector ကို ဖျောက်ထားပြီး email field ကို တိုက်ရိုက်ပြသပါမည်။
- `AuthTypeEnum.phoneOnly`: Phone ဖြင့်သာ login/register ပြုလုပ်နိုင်ရန် tab selector ကို ဖျောက်ထားပြီး phone field ကို တိုက်ရိုက်ပြသပါမည်။

### `app_router.dart` တွင် သတ်မှတ်ပုံဥပမာ (Usage Example in App Router)

[app_router.dart](file:///d:/Projects/clean_archi_frame/lib/app/router/app_router.dart) တွင် အောက်ပါအတိုင်း dynamic သို့မဟုတ် static config အနေဖြင့် သတ်မှတ်နိုင်ပါသည် -

```dart
import 'package:clean_archi_frame/core/utils/enums/auth_type_enum.dart';

// ...

GoRoute(
  path: RouteNames.loginPath,
  name: RouteNames.loginName,
  builder: (context, state) {
    // Project constraints အရ email သာလက်ခံရန် သတ်မှတ်ခြင်း
    return const LoginScreen(loginType: AuthTypeEnum.emailOnly);
  },
),
GoRoute(
  path: RouteNames.registerPath,
  name: RouteNames.registerName,
  builder: (context, state) {
    // Project constraints အရ email သာလက်ခံရန် သတ်မှတ်ခြင်း
    return const RegisterScreen(loginType: AuthTypeEnum.emailOnly);
  },
),
```
