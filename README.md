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

## Local Database (Drift) & DAO

ဤ project တွင် local data သိမ်းဆည်းရန်နှင့် query များ ပြုလုပ်ရန် **Drift (SQLite)** ကို အသုံးပြုထားပါသည်။ `ProfileTable` နှင့် `ProfileDao` တို့သည် နမူနာအဖြစ်သာ ထည့်သွင်းထားခြင်း ဖြစ်ပြီး၊ ပရောဂျက်အသစ် ရေးသားသောအခါ မိမိတို့ လိုအပ်သော Table များနှင့် DAOs များကို အောက်ပါအဆင့်များအတိုင်း တည်ဆောက်/ပြင်ဆင် ရပါမည်။

---

### Step-by-Step: Table အသစ်နှင့် DAO အသစ် ဖန်တီးခြင်း

#### အဆင့် ၁ — Table Schema သတ်မှတ်ခြင်း
မိမိတို့ ဖန်တီးမည့် feature ၏ `data/data_sources/local/schema/` အောက်တွင် Table class တစ်ခု ဖန်တီးပါ။ (ဥပမာ - `products_schema.dart`)
```dart
import 'package:drift/drift.dart';

class ProductTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  RealColumn get price => real()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
```

#### အဆင့် ၂ — DAO (Data Access Object) ဖန်တီးခြင်း
SQL queries များကို စုစည်းထားရန် သက်ဆိုင်ရာ feature ၏ `data/data_sources/local/dao/` အောက်တွင် DAO class တစ်ခု ဖန်တီးပါ။ (ဥပမာ - `product_dao.dart`)
> **Note:** Database code generator မပြေးရသေးမီ mixin template ဖြစ်သည့် `_$ProductDaoMixin` သည် compile error ပြနေပါလိမ့်မည်။ Code generation ပြေးပြီးပါက error ပျောက်သွားပါမည်။
```dart
import 'package:drift/drift.dart';
import '../../../../../../core/database/app_database.dart';
import '../schema/products_schema.dart';

@DriftAccessor(tables: [ProductTable])
class ProductDao extends DatabaseAccessor<AppDatabase> with _$ProductDaoMixin {
  ProductDao(AppDatabase db) : super(db);

  // Queries များကို ဤနေရာတွင် ရေးပါ
  Future<List<ProductTableData>> getAllProducts() => select(productTable).get();
  Stream<List<ProductTableData>> watchProducts() => select(productTable).watch();
  Future<int> insertProduct(ProductTableCompanion entity) => into(productTable).insert(entity);
}
```

#### အဆင့် ၃ — AppDatabase တွင် Table နှင့် DAO ကို Register ပြုလုပ်ခြင်း
[`lib/core/database/app_database.dart`](file:///d:/Projects/clean_archi_frame/lib/core/database/app_database.dart) သို့သွားပြီး `@DriftDatabase` annotation တွင် မိမိတို့ဖန်တီးခဲ့သော Table နှင့် DAO ကို ထည့်သွင်းပေးပါ။
```dart
import '../../features/product/data/data_sources/local/schema/products_schema.dart';
import '../../features/product/data/data_sources/local/dao/product_dao.dart';

@DriftDatabase(
  tables: [
    ProfileTable, 
    OutboxTable,
    ReferenceMappingTable,
    ProductTable, // ← စာရင်းအသစ် ထည့်သွင်းရန်
  ],
  daos: [
    ProfileDao, 
    OutboxDao,
    ReferenceMappingDao,
    ProductDao, // ← စာရင်းအသစ် ထည့်သွင်းရန်
  ],
)
class AppDatabase extends _$AppDatabase { ... }
```

#### အဆင့် ၄ — Code Generation ပြေးခြင်း
Annotation များ ပြင်ဆင်ပြီးပါက Terminal တွင် အောက်ပါ command ကို run ၍ code generate လုပ်ပေးရပါမည်။
```bash
dart run build_runner build --delete-conflicting-outputs
```

#### အဆင့် ၅ — Riverpod Provider ဖြင့် Dependency Injection လုပ်ခြင်း
သက်ဆိုင်ရာ Feature ၏ DI file သို့မဟုတ် database access လုပ်မည့် repository တွင် အသုံးပြုနိုင်ရန် Riverpod Provider ဆောက်ပေးပါ။
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/app_database.dart';
import '../di/database_di.dart';

final productDaoProvider = Provider<ProductDao>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return ProductDao(db);
});
```

---

## Network & API Client (DioClient)

API ချိတ်ဆက်မှုများနှင့် request များ ပြုလုပ်ရန် `DioClient` (`core/network/dio_client.dart`) ကို အသုံးပြုထားပါသည်။ ၎င်းသည် automatic header attachment, error handling, token refresh logic နှင့် retry mechanisms များ ပါဝင်သော application-level provider ဖြစ်သည်။

### Providers
- **`dioProvider`**: Standard `Dio` instance ကို configure လုပ်ပေးပါသည်။
- **`dioClientProvider`**: Request verbs များကို wrap လုပ်ထားသော `DioClient` provider ဖြစ်သည်။

### Request ပြုလုပ်ပုံ နမူနာများ (Usage Examples)

```dart
final client = ref.watch(dioClientProvider);

// GET request
final response = await client.get('/items');

// POST request
final response = await client.post('/items', data: {'name': 'New Item'});
```

### ပုံနှင့် Files များ API သို့ ပေးပို့ခြင်း (File & Image Uploads)

ပုံ သို့မဟုတ် file များကို multipart format ဖြင့် upload ပြုလုပ်ရန် `multipartRequest` method ကို အသုံးပြုရပါမည်။

```dart
final client = ref.watch(dioClientProvider);

// File/Image upload configuration
final response = await client.multipartRequest(
  '/upload-profile',
  method: 'POST',
  data: {
    'name': 'John Doe',
    'avatar': File('/path/to/avatar.jpg'), // File type ကို auto detect လုပ်ပြီး MultipartFile ပြောင်းပေးပါမည်
    'attachments': [
      File('/path/to/doc1.pdf'),
      File('/path/to/doc2.pdf'),
    ], // List<File> ကိုလည်း အလိုအလျောက် detect လုပ်ပေးပါမည်
  },
);
```

#### အင်္ဂါရပ်များနှင့် ကန့်သတ်ချက်များ (Features & Constraints)
1. **Auto FormData Parsing**: parameter data map ထဲတွင် `File` သို့မဟုတ် `List<File>` ပါဝင်ပါက manual ရေးသားစရာမလိုဘဲ `MultipartFile` အဖြစ် အလိုအလျောက် conversion လုပ်ဆောင်ပေးသွားမည် ဖြစ်သည်။
2. **File Size Validation**: `dimensions.dart` တွင် သတ်မှတ်ထားသော maximum file upload size (5MB) အား ကျော်လွန်ခြင်း ရှိမရှိ အလိုအလျောက် စစ်ဆေးပေးပြီး ကျော်လွန်ပါက `NetworkException` ကို error throw ပေးမည် ဖြစ်သည်။
3. **Content-Type Overriding**: Content-Type အား `'multipart/form-data'` ဟု အလိုအလျောက် dynamic configuration ပြုလုပ်ပေးသည်။

---

## Offline Sync Processors

The offline core processes queued actions from the local outbox. A processor handles one action type and sends it to the server.

### Enqueue an offline write

Use `OfflineWriteCoordinator` so local DB writes and outbox inserts stay atomic:

```dart
final coordinator = ref.read(offlineWriteCoordinatorProvider);

await coordinator.writeLocalThenEnqueue(
  localWrite: () async {
    // Save/update the local Drift entity here
    await profileDao.upsert(localProfile);
  },
  params: OutboxEnqueueParams(
    url: '/api/profile',
    method: 'PUT',
    actionType: 'update_profile',
    payload: {'id': clientId, 'name': name},
    clientReferenceId: clientId, // optional — maps to server id after sync
    maxRetries: 3,
  ),
);
```

Enqueue-only (no local write):

```dart
await ref.read(offlineWriteCoordinatorProvider).enqueue(
  OutboxEnqueueParams(
    url: '/api/posts',
    method: 'POST',
    actionType: 'create_post',
    payload: {'title': title},
    clientReferenceId: localTempId,
  ),
);
```

### Retry / crash recovery (built-in)

- Failed network/server errors set `nextRetryAt` with exponential backoff (30s → 180s → …).
- Exhausted retries stay `failed` and are no longer picked for sync.
- On engine start, items stuck in `syncing` (app crash) are reset to `pending`.
- Connectivity uses a real internet check (DNS), not only Wi‑Fi/cellular interface.

### Client → server ID mapping

After a successful sync, if the outbox item has `clientReferenceId` and the API returns `{ "id": "..." }`, the engine stores the mapping via `LocalReferenceRepository`. Resolve later with:

```dart
final serverId = await ref.read(offlineSyncEngineProvider).resolveServerId(clientId);
```

### End-to-end sample: Offline Profile

A complete sample feature is included under `features/profile`:

| Piece | Role |
|---|---|
| `OfflineProfileRepository` | Local Drift write + outbox enqueue (one transaction) |
| `CreateProfileProcessor` / `UpdateProfileProcessor` | Sync to server by `actionType` |
| `profileOfflineBootstrapProvider` | Registers processors at app startup (`MyApp`) |

**Usage**

```dart
final result = await ref.read(offlineProfileRepositoryProvider).createOffline(
  name: 'Aye',
  email: 'aye@example.com',
);
// result.localId, result.outboxId, result.clientReferenceId

// Later, after sync succeeds:
final serverId = await ref
    .read(offlineSyncEngineProvider)
    .resolveServerId(result.clientReferenceId);
```

**Tests** — `test/core/offline/offline_sync_engine_test.dart` covers:

- FIFO enqueue order
- `nextRetryAt` backoff window
- Exhausted retries skipped
- Stuck `syncing` crash recovery
- Client → server ID mapping
- Conflict unblocks the queue
- Full `createOffline` → sync → mapping path

Run:

```bash
flutter test test/core/offline/offline_sync_engine_test.dart
```

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

---

## 6. Flexible Navigation Configuration (Bottom Nav / Drawer)

Commercial project တစ်ခုချင်းစီ၏ လိုအပ်ချက်ပေါ်မူတည်၍ App ၏ ပင်မ Navigation ပုံစံများကို `NavigationType` အသုံးပြုကာ [navigation_config.dart](file:///d:/Projects/clean_archi_frame/lib/app/config/navigation_config.dart) တွင် လွယ်ကူစွာ သတ်မှတ်ပြောင်းလဲနိုင်ပါသည်။

### ရွေးချယ်နိုင်သော Navigation Modes များ

- `NavigationType.bottomNav`: App ၏အောက်ခြေတွင် Bottom Navigation Bar သက်သက်ကိုသာ ပြသပေးပါမည်။ Drawer ကို ဖျောက်ထားပါမည်။
- `NavigationType.drawer`: Bottom Navigation Bar ကို ဖျောက်ထားပြီး ဘေးတိုက်ဆွဲဖွင့်နိုင်သော Left Navigation Drawer ကိုသာ ပြသပေးပါမည်။
- `NavigationType.both`: Bottom Navigation Bar နှင့် Left Navigation Drawer နှစ်မျိုးလုံးကို တွဲဖက်ပြသပေးပြီး အပြန်အလှန် ချိတ်ဆက်လုပ်ဆောင်ပေးပါမည်။

### `navigation_config.dart` တွင် သတ်မှတ်ပုံဥပမာ (Usage Example)

[navigation_config.dart](file:///d:/Projects/clean_archi_frame/lib/app/config/navigation_config.dart) တွင် `mode` static constant တန်ဖိုးကို လိုအပ်သလို ပြောင်းလဲသတ်မှတ်ပေးနိုင်ပါသည် -

```dart
import 'package:clean_archi_frame/app/config/navigation_config.dart';

class NavigationConfig {
  // Navigation layout ကို bottomNav, drawer, သို့မဟုတ် both ဟု သတ်မှတ်ခြင်း
  static const NavigationType mode = NavigationType.both;
  
  // Scaffold global key
  static final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
}
```

သတ်မှတ်ထားသည့် mode ပေါ်မူတည်၍ Screen တစ်ခုချင်းစီ၏ `AppBar` များတွင် Drawer ကို ဆွဲဖွင့်ရန် Hamburger Menu Icon ကို အလိုအလျောက် သင့်လျော်သလို တွဲဖက်ပြသပေးမည် ဖြစ်ပါသည်။

---

## Reusable Empty State Widget (AppEmptyWidget)

App အတွင်း data မရှိသည့် အခြေအနေများ (ဥပမာ - empty inbox, no search results, no notification) တွင် အသုံးပြုရန် [AppEmptyWidget](file:///d:/Projects/clean_archi_frame/lib/shared/widgets/app_empty_widget.dart) ကို ဖန်တီးထားပါသည်။

၎င်း Widget သည် SVG နှင့် PNG ပုံများ (Both Svg and Png) ကို အလိုအလျောက် ခွဲခြားကာ ပြသပေးနိုင်စွမ်း ရှိပါသည်။

### အသုံးပြုနိုင်သော parameter များ (Parameters)

- `imageUrl`: ပြသလိုသော asset image path (ဥပမာ - `AppAssets.noNotification` သို့မဟုတ် path text) ဖြစ်ပြီး SVG `.svg` သို့မဟုတ် PNG / JPG format မည်သည့်ပုံကိုမဆို ပံ့ပိုးပေးပါသည်။
- `title`: အဓိကပြသမည့် စာသားအကျဉ်း။
- `subtitle`: အသေးစိတ်ဖော်ပြချက် စာသား။
- `action`: Empty state တွင် ထည့်သွင်းလိုသော ခလုတ် သို့မဟုတ် လုပ်ဆောင်ချက် widget (ဥပမာ - `AppButton`, `ElevatedButton`)။

### UI တွင် အသုံးပြုနည်း ဥပမာ (Usage Example)

```dart
import 'package:clean_archi_frame/shared/widgets/app_empty_widget.dart';

// ၁။ SVG image ဖြင့် သုံးခြင်း
AppEmptyWidget(
  imageUrl: 'assets/images/app_images/empty_box.svg',
  title: 'ဒေတာ မရှိပါ',
  subtitle: 'လောလောဆယ်တွင် ပြသရန် ဒေတာ မရှိသေးပါ။',
  action: ElevatedButton(
    onPressed: () => ref.refresh(dataProvider),
    child: const Text('Refresh'),
  ),
)

// ၂။ PNG image ဖြင့် သုံးခြင်း
AppEmptyWidget(
  imageUrl: 'assets/images/app_images/empty_state.png',
  title: 'No Notifications',
)
```

---

## Alert Extension (`showAppAlert`)

Flutter ၏ built-in `showDialog(...)` သို့မဟုတ် `showModalBottomSheet(...)` တို့ကို ကိုယ်တိုင်ခေါ်ယူရေးသားခြင်းအစား Center Dialog သို့မဟုတ် BottomSheet Layout များကို လိုသလို ပြောင်းလဲပြသပေးနိုင်သော `context.showAppAlert(...)` extension ကို အသုံးပြုရပါမည်။

- **ဖိုင်တည်နေရာ:** [dialog_extension.dart](file:///d:/Projects/clean_archi_frame/lib/core/utils/extensions/dialog_extension.dart)
- **Extension:** `DialogContextExtension on BuildContext`

### Layout ပုံစံများ (AlertLayout Modes)

`AlertLayout` [alert_layout.dart](file:///d:/Projects/clean_archi_frame/lib/core/utils/enums/alert_layout.dart) enum အား အသုံးပြုပြီး Layout ပုံစံကို ရွေးချယ်နိုင်ပါသည် -

- `AlertLayout.dialog`: Center Dialog ပုံစံဖြင့် `AppAlertDialog` ကို ပြသပေးပါမည်။
- `AlertLayout.bottomSheet`: အောက်ခြေမှ ပွင့်တက်လာသော Bottom Sheet ပုံစံဖြင့် `AppAlertBottomSheet` ကို ပြသပေးပါမည်။

### Parameter များ

| Parameter | Type | Default | ရှင်းလင်းချက် |
|---|---|---|---|
| `title` | `String` | required | Alert box ၏ ခေါင်းစဉ်စာသား |
| `content` | `String` | required | Alert box ၏ အဓိကဖော်ပြချက် စာသား |
| `layout` | `AlertLayout` | `AlertLayout.dialog` | ပြသလိုသော Layout ပုံစံ (dialog သို့မဟုတ် bottomSheet) |
| `contentAlign` | `TextAlign?` | `null` | content စာသား၏ alignment |
| `barrierDismissible` | `bool` | `true` | အပြင်ဘက်ကိုနှိပ်ပါက Alert box ကို ပိတ်ခွင့်ပြုမလား |
| `confirmLabel` | `String` | `'OK'` | Confirm button ၏ စာသား |
| `confirmColor` | `Color?` | `null` | Confirm button text သို့မဟုတ် background ၏ အရောင် |
| `onConfirm` | `VoidCallback?` | `null` | Confirm button နှိပ်သည့်အခါ လုပ်ဆောင်မည့် callback |
| `cancelLabel` | `String` | `'Cancel'` | Cancel button ၏ စာသား |
| `cancelColor` | `Color?` | `null` | Cancel button text သို့မဟုတ် background ၏ အရောင် |
| `onCancel` | `VoidCallback?` | `null` | Cancel button နှိပ်သည့်အခါ လုပ်ဆောင်မည့် callback |
| `isConfirmElevated` | `bool` | `false` | Confirm button အား ElevatedButton (solid fill) ပုံစံ ပြသမလား |
| `isCancelElevated` | `bool` | `false` | Cancel button အား ElevatedButton (solid fill) ပုံစံ ပြသမလား |

### UI တွင် အသုံးပြုနည်း ဥပမာများ (Usage Examples)

```dart
import 'package:clean_archi_frame/core/utils/extensions/dialog_extension.dart';
import 'package:clean_archi_frame/core/utils/enums/alert_layout.dart';

// Dialog ပုံစံဖြင့် ပြသခြင်း (Default)
context.showAppAlert(
  title: 'Delete Data',
  content: 'Are you sure you want to delete this profile?',
  confirmLabel: 'Delete',
  confirmColor: context.colorScheme.error,
  cancelLabel: 'Cancel',
  onCancel: () => context.pop(),
  onConfirm: () {
    // delete logic
    context.pop();
  },
);

// BottomSheet ပုံစံဖြင့် ပြသခြင်း (Elevated Confirm Button ဖြင့်)
context.showAppAlert(
  layout: AlertLayout.bottomSheet,
  title: 'Logout',
  content: 'Are you sure you want to sign out?',
  confirmColor: context.colorScheme.error,
  cancelLabel: 'Cancel',
  onCancel: () => context.pop(),
  confirmLabel: 'Logout',
  isConfirmElevated: true, // Confirm button ကို ElevatedButton ပုံစံပြသရန်
  onConfirm: () {
    // logout logic
  },
);
```

---

## Permission Helper (`PermissionHelper`)

`PermissionHelper` သည် App တွင် မရှိမဖြစ်လိုအပ်သော Permissions များအား တောင်းခံရာတွင် User က ငြင်းပယ်ခြင်း (Deny) သို့မဟုတ် လုံးဝပိတ်ပင်ခြင်း (Permanently Denied) များကို UI Layer တွင် စနစ်တကျ ပြန်လည်ကိုင်တွယ်နိုင်ရန် ဖန်တီးထားသော utility class ဖြစ်သည်။ global context ကို အသုံးပြုထားသဖြင့် `BuildContext` ပေးပို့ရန် မလိုအပ်တော့ပါ။

- **ဖိုင်တည်နေရာ:** [permission_helper.dart](file:///d:/Projects/clean_archi_frame/lib/core/utils/helpers/permission_helper.dart)

### Features
- **Automatic Flow Handling**: Permission status ပေါ်မူတည်၍ သင့်လျော်သော dialog များအား အလိုအလျောက် ပြသပေးခြင်း။
- **App Settings Redirection**: User မှ permission အား လုံးဝပိတ်ထားပါက (Permanently Denied) App settings သို့ သွားရောက်ဖွင့်ခိုင်းရန် "Open Settings" dialog အား ပြသပေးခြင်း။
- **Granular Storage Compatibility**: Android 13+ (SDK 33) တွင် storage permission တောင်းဆိုသည့်အခါ `Permission.photos` သို့ အလိုအလျောက် ပြောင်းလဲတောင်းဆိုပေးခြင်း။
- **Context-Free Requesting**: Global `NavigatorKeys.root` ကို အသုံးပြုထားသဖြင့် UI tree အပြင်ဘက် (ဥပမာ- startup services သို့မဟုတ် configuration files) မှလည်း BuildContext မလိုဘဲ ခေါ်ယူအသုံးပြုနိုင်ပါသည်။
- **Localization Integration**: Dialog ရှိ စာသားများကို Slang localization (မြန်မာ/အင်္ဂလိပ်) ဖြင့် ချိတ်ဆက်ပြသပေးပါသည်။

### အသုံးပြုနည်း ဥပမာ (Usage Example)
ခွင့်ပြုချက်တစ်ခု တောင်းခံရန် `PermissionHelper.requestPermission` ကို ခေါ်ယူအသုံးပြုပါ။

```dart
import 'package:clean_archi_frame/core/services/permission_service.dart';
import 'package:clean_archi_frame/core/utils/helpers/permission_helper.dart';
import 'package:app_settings/app_settings.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';

void _checkAndProceedLocation(WidgetRef ref) async {
  final hasLocation = await PermissionHelper.requestPermission(
    permission: Permission.location,
    permissionName: 'Location',
    permissionService: ref.read(permissionServiceProvider),
    settingsType: AppSettingsType.location, // Location setting သို့ တိုက်ရိုက်သွားရန်
  );

  if (hasLocation) {
    // Permission ရရှိသွားပြီဖြစ်သဖြင့် လုပ်ဆောင်ချက်များကို ဆက်လက်လုပ်ဆောင်ပါ
    _startLocationTracking();
  } else {
    // Permission မရရှိပါက block လုပ်ခြင်း သို့မဟုတ် error screen ပြခြင်း ပြုလုပ်နိုင်ပါသည်
    _showPermissionRequiredBanner();
  }
}
```

### Parameter များ (requestPermission)

| Parameter | Type | Required | Description |
|---|---|---|---|
| `permission` | `Permission` | Yes | စစ်ဆေး/တောင်းခံမည့် permission အမျိုးအစား (ဥပမာ- `Permission.location`, `Permission.camera`) |
| `permissionName` | `String` | Yes | Permission အမည် (ဥပမာ- `'Location'`)။ ၎င်းကို translation messages များတွင် ထည့်သွင်းပြသရန် အသုံးပြုသည်။ |
| `permissionService` | `PermissionService` | Yes | Settings ဖွင့်လှစ်ရန် အသုံးပြုမည့် service Provider instance။ |
| `settingsType` | `AppSettingsType` | No (Default: `settings`) | "Open Settings" နှိပ်ချိန်တွင် သွားရောက်မည့် စနစ်၏ settings စာမျက်နှာ အမျိုးအစား။ |

---

## Biometrics Authentication (ဇီဝအမှတ်အသား စစ်ဆေးခြင်း)

ဤ framework တွင် biometric authentication (လက်ဗွေ သို့မဟုတ် မျက်နှာစနစ်) ကို အသုံးပြုနိုင်ရန် **`local_auth`** package ကို အသုံးပြုထားပြီး dynamic setup များနှင့် fallback mechanisms များကို စနစ်တကျ ရေးသားထားပါသည်။

### အလုပ်လုပ်ပုံ ရှင်းလင်းချက် (How it Works)
1. **Dynamic Support Detection:** စက်ပစ္စည်း (Device) တွင် biometric hardware ပါဝင်ခြင်း ရှိမရှိနှင့် biometrics ထည့်သွင်းထားခြင်း (enrolled) ရှိမရှိကို runtime တွင် dynamic စစ်ဆေးပေးပါသည်။
2. **Dynamic UI Icon & Label:** စက်ပစ္စည်းပေါ်မူတည်၍ UI ကို အလိုအလျောက် ပြောင်းလဲပြသပေးပါသည်။
   - Face ID သုံးသောစက်များ (ဥပမာ- iPhone X+) တွင် **Face icon** နှင့် **"Face ID"** စာသားကို ပြသမည်။
   - Fingerprint သုံးသောစက်များတွင် **Fingerprint icon** နှင့် **"Fingerprint"** စာသားကို ပြသမည်။
   - Hardware type ကို သဲသဲကွဲကွဲ မသိရလျှင် generic **"Biometric Authentication"** စာသားနှင့် **Security icon** ကို ပြသမည်။
3. **App Password Fallback Enforcement (biometricOnly: true):** Biometric verify မလုပ်နိုင်ပါက ဖုန်း၏ Screen lock PIN/Pattern ဖြင့် Bypass လုပ်ပြီး ဝင်ရောက်ခြင်းကို ကာကွယ်ရန် `biometricOnly: true` ဟု သတ်မှတ်ထားပါသည်။ သို့မှသာ biometric မအောင်မြင်လျှင် ဖုန်း PIN ဖြင့် bypass လုပ်၍မရဘဲ App ၏ သီးသန့် အကောင့်စကားဝှက် (App Password) ကိုသာ အတင်းအကျပ် ဖြည့်စွက်ဝင်ရောက်ခိုင်းမည် ဖြစ်သဖြင့် ပိုမိုလုံခြုံစိတ်ချရပါသည်။
4. **Security Settings Fallback (Password Verification BottomSheet):** User မှ settings တွင် biometric authentication ကို switch toggling လုပ်ပြီး အဖွင့်/အပိတ် ပြုလုပ်ချိန်၌ biometric verify မလုပ်နိုင်ပါက (ဥပမာ- finger ညစ်ပတ်နေခြင်း သို့မဟုတ် biometric ပျက်စီးနေခြင်း) fallback အနေဖြင့် **အကောင့်စကားဝှက် (Password)** ရေးသွင်းအတည်ပြုပြီး ပြောင်းလဲနိုင်ရန် **Modal BottomSheet** dialog ကို စနစ်တကျ ပြသပေးပါသည်။

---

### Platform Setup (မဖြစ်မနေ လုပ်ဆောင်ရန်)

#### ၁။ Android Configuration
- **`android/app/src/main/AndroidManifest.xml`** တွင် အောက်ပါ permission ကို ထည့်သွင်းထားရပါမည်။
  ```xml
  <uses-permission android:name="android.permission.USE_BIOMETRIC" />
  ```
- Android biometrics dialog ကို native ခေါ်ယူရန် **`MainActivity.kt`** သည် standard `FlutterActivity` အစား `FlutterFragmentActivity` ကို မဖြစ်မနေ extend လုပ်ထားရပါမည်။
  ```kotlin
  import io.flutter.embedding.android.FlutterFragmentActivity

  class MainActivity: FlutterFragmentActivity() {
  }
  ```

#### ၂။ iOS Configuration
- **`ios/Runner/Info.plist`** တွင် Face ID အသုံးပြုခွင့် တောင်းခံစာသားကို ထည့်သွင်းပေးရပါမည်။
  ```xml
  <key>NSFaceIDUsageDescription</key>
  <string>Please authenticate to sign in using Face ID.</string>
  ```

---

### UI နှင့် State စီမံခန့်ခွဲမှု (Riverpod Providers)

- **`biometricsServiceProvider`** (`core/services/biometrics_service.dart`): `local_auth` API wrapper ဖြစ်ပြီး scan ဖတ်ခြင်း၊ devices settings စစ်ဆေးခြင်းများကို လုပ်ဆောင်ပေးသည်။
- **`biometricSupportProvider`** (`features/auth/presentation/providers/biometric_provider.dart`): စက်ပစ္စည်းသည် biometric scan ဖတ်ရန် အဆင်သင့်ဖြစ်မဖြစ် စစ်ဆေးပေးသော `FutureProvider<bool>` ဖြစ်သည်။
- **`biometricEnabledProvider`** (`features/auth/presentation/providers/biometric_provider.dart`): User မှ ဆက်တင်တွင် biometric သုံးရန် ဖွင့်ထားခြင်း ရှိမရှိကို `SharedPreferences` မှတစ်ဆင့် reactive စီမံပေးသော `NotifierProvider<bool>` ဖြစ်သည်။
- **`activeBiometricTypeProvider`** (`features/auth/presentation/providers/biometric_provider.dart`): လက်ရှိစက်၏ biometric အမျိုးအစား (face, fingerprint, strong, weak) ကို ရှာဖွေပေးသော `FutureProvider<BiometricType?>` ဖြစ်သည်။

---

### UI တွင် အသုံးပြုပုံ (Usage Examples)

#### ၁။ Login Screen တွင် Biometric Button ပြသခြင်း
```dart
if (isBiometricEnabled && isBiometricSupported) ...[
  ref.watch(activeBiometricTypeProvider).when(
    data: (type) {
      final icon = type == BiometricType.face ? Icons.face_rounded : Icons.fingerprint_rounded;
      final label = type == BiometricType.face ? t.setting.faceId : t.setting.fingerprint;
      return OutlinedButton.icon(
        onPressed: () async {
          final success = await ref.read(biometricsServiceProvider).authenticate(
            reason: t.auth.biometricReason,
          );
          if (success) context.go(RouteNames.homePath);
        },
        icon: Icon(icon),
        label: Text(label),
      );
    },
    loading: () => const SizedBox.shrink(),
    error: (_, __) => const SizedBox.shrink(),
  ),
]
```

#### ၂။ ဆက်တင်တွင် password fallback ဖြင့် biometric toggling ပြုလုပ်ခြင်း
```dart
onChanged: (value) async {
  final biometrics = ref.read(biometricsServiceProvider);
  final success = await biometrics.authenticate(
    reason: t.auth.biometricReason,
  );
  if (success) {
    await ref.read(biometricEnabledProvider.notifier).toggleBiometric(value);
  } else {
    // Biometric မအောင်မြင်လျှင် Password BottomSheet သို့ fallback လုပ်ပါမည်
    final passwordVerified = await _showPasswordVerificationBottomSheet(context);
    if (passwordVerified == true) {
      await ref.read(biometricEnabledProvider.notifier).toggleBiometric(value);
    }
  }
}
```
---

## Offline-First Architecture & Outbox Pattern

အင်တာနက် မရှိသည့် အချိန်များတွင်လည်း ရေးသားချက်များကို Local Drift Database တွင် အရင်ဆုံး သိမ်းဆည်းပြီး၊ အင်တာနက် ပြန်ရသည့်အခါမှ Server သို့ Asynchronous Sync ပြုလုပ်ပေးသော **Offline-First Outbox System** ပါဝင်ပါသည်။

- **အသေးစိတ် လမ်းညွှန်ချက် (Full Documentation):** [lib/core/offline/README.md](file:///d:/Projects/clean_archi_frame/lib/core/offline/README.md)
- **အဓိက အင်္ဂါရပ်များ:**
  - **Atomic Local Writes:** `OfflineWriteCoordinator` ဖြင့် Local Mutation + Outbox Enqueue ကို Drift Transaction တစ်ခုတည်းဖြင့် ရေးသားခြင်း။
  - **Dual-ID Strategy:** Local Entities များတွင် Client UUID + Server ID ဖြင့် သိမ်းဆည်းခြင်း။
  - **Exponential Backoff & Crash Recovery:** Sync မအောင်မြင်ပါက Exponential Backoff အချိန်သတ်မှတ်ပြီး App Crash ဖြစ်ပါက Stuck Syncing Items များကို အလိုအလျောက် ဆယ်ယူပေးခြင်း။
  - **Auto-Registered Processors:** Feature အလိုက် `OutboxActionProcessor` ရေးသား၍ `outboxProcessorsProvider` တွင် ချိတ်ဆက်ရုံဖြင့် အလိုအလျောက် Sync လုပ်ပေးခြင်း။
  - **Outbox UI Management:** [OutboxListScreen](file:///d:/Projects/clean_archi_frame/lib/core/offline/screens/outbox_list_screen.dart) ဖြင့် Outbox အခြေအနေများကို ကြည့်ရှု၍ Retry / Discard ပြုလုပ်နိုင်ခြင်း။

