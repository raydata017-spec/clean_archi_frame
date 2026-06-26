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

This framework uses Drift for local database access. DAOs are simple classes that encapsulate table queries and updates.

### Example DAO

A sample DAO can be placed at:

- `lib/features/profile/data/data_sources/local/dao/profile_dao.dart`

It can extend `DatabaseAccessor<AppDatabase>` and use `db.profileTable` directly.

```dart
class ProfileDao extends DatabaseAccessor<AppDatabase> {
  ProfileDao(AppDatabase db) : super(db);

  Stream<List<ProfileTableData>> watchProfiles() {
    return select(db.profileTable).watch();
  }

  Future<int> insertProfile(ProfileTableCompanion companion) {
    return into(db.profileTable).insert(companion);
  }
}
```

### Do I need code generation?

- If your DAO is written manually like the example above, then you do not need Drift code generation for that class.
- If you add the DAO to `@DriftDatabase(daos: [ProfileDao])` or use `@DriftAccessor`, then you must run the generator.

### When to run the generator

Run generator only when you use Drift annotations and want generated DAO wiring or database code.

```bash
dart run build_runner build --delete-conflicting-outputs
```

### Core frame recommendation

For a clean core frame example, keep DAO classes manual and simple. This makes the frame easy to read and use without forcing generator setup.

---

## Offline Sync Processors

The offline core sends queued requests from the local outbox using processor classes. Each processor handles one `actionType` and implements `OutboxActionProcessor`.

### Processor example

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

    // Replace with your real HTTP or API client call
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
    // Mark local item as conflict, notify user, or open manual resolution UI.
  }

  @override
  Future<void> onFailure(Object error, OfflineOutboxItem item, int currentRetries) async {
    // Log retry progress, update UI state, or notify if retries are exhausted.
  }
}
```

### Registering processors

Register processors with the sync engine before the app starts or when your module initializes.

```dart
final engine = ref.watch(offlineSyncEngineProvider);
engine.registerProcessor(CreatePostProcessor());
engine.registerProcessor(UpdateProfileProcessor());
```

### Profile feature processor example

A real project may keep processors inside a feature directory.

- `lib/features/profile/data/data_sources/processors/update_profile_processor.dart`

This keeps offline sync logic close to the profile feature.

### How it works

- The engine watches the local outbox table.
- When an item is pending and network is available, it calls the matching processor.
- `process()` sends the payload to the server.
- `onConflict()` handles conflict errors.
- `onFailure()` handles retry/failure reporting.

### Real project advice

- Use `actionType` as the unique key for each request kind.
- Keep processors small and focused on one server endpoint.
- Let the engine manage retry counts, status, and cleanup.
