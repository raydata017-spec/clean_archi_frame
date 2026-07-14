# Router Module

This module provides the navigation and routing setup for the application using [GoRouter](https://pub.dev/packages/go_router) and [Flutter Riverpod](https://pub.dev/packages/flutter_riverpod).

---

## Directory Structure

```
lib/
├── app/
│   ├── config/
│   │   └── router_redirect_config.dart # Redirect behavior configurations
│   └── router/
│       ├── README.md                   # This documentation file
│       ├── app_router.dart             # Main GoRouter configuration & providers
│       ├── navigator_keys.dart         # Global Navigator Keys for nested/shell routes
│       └── route_names.dart            # Route path and name constants
└── core/
    └── utils/
        └── enums/
            └── app_auth_state_enum.dart # [NEW] Authentication state enum mapping
```

---

## Key Components

### 1. `appRouterProvider`
A global Riverpod `Provider` that exposes the `GoRouter` instance configuration, containing the nested shell routes (`MainWrapperScreen`) and standalone auth routes.

### 2. Navigator Keys (`NavigatorKeys`)
Provides `GlobalKey<NavigatorState>` references to control navigation stacks for shell routes (Home, Profile, Settings) and root navigation.

### 3. Route Names (`RouteNames`)
Defines static constants for route paths and names to ensure type-safe navigation and prevent hardcoding string routes throughout the features.

---

## Flexible Redirection Configuration

The router includes a project-independent redirection system that allows developers to toggle and customize login flows, branch selection steps, and splash check sequences.

### Local Variables Settings
Customize redirects inside [router_redirect_config.dart](file:///d:/Projects/clean_archi_frame/lib/app/config/router_redirect_config.dart) by adjusting `RouterRedirectConfig`:

```dart
class RouterRedirectConfig {
  static const bool enableRedirect = false;       // Set true to activate redirect checks
  static const bool enableBranchSelection = false; // Set true if app uses branch selection
  static const bool enableSplash = false;          // Set true to require splash checks

  static const String splashPath = '/splash';
  static const String selectBranchPath = '/select-branch';
  static const String loginPath = RouteNames.loginPath;
  static const String homePath = RouteNames.homePath;
}
```

### Overriding State Providers
If you want to plug in your project's custom Authentication state or Initialization state provider, you can modify the fallback providers inside [app_router.dart](file:///d:/Projects/clean_archi_frame/lib/app/router/app_router.dart):

```dart
/// Maps to target project auth state stream/notifier
final appAuthStateProvider = Provider<AsyncValue<AppAuthState>>((ref) {
  // Replace with target project's auth provider (e.g. ref.watch(authProvider))
  return const AsyncValue.data(AppAuthState.authenticatedWithBranch);
});

/// Maps to target project system initialization status
final appInitializedStateProvider = Provider<bool>((ref) {
  // Replace with target initialization state provider
  return true;
});
```

---

## How to Use

ဤ routing package ကို မိမိတို့ project လိုအပ်ချက်အလိုက် လွယ်ကူစွာ config ပြုလုပ်နိုင်ရန် အပိုင်း (၂) ပိုင်းကို ပြင်ဆင်ပေးရပါမည်။

### ၁။ Redirection Behavior များကို ချိန်ညှိခြင်း (Configuring Redirection)
[router_redirect_config.dart](file:///d:/Projects/clean_archi_frame/lib/app/config/router_redirect_config.dart) အတွင်းရှိ `RouterRedirectConfig` class တွင် static variables များကို ချိန်ညှိနိုင်ပါသည်-

```dart
class RouterRedirectConfig {
  static const bool enableRedirect = true;        // Redirection စနစ်တစ်ခုလုံးကို အသုံးပြုရန် true သတ်မှတ်ပါ
  static const bool enableBranchSelection = true; // Branch selection flow ပါဝင်ပါက true သတ်မှတ်ပါ
  static const bool enableSplash = false;          // Splash screen logic မလိုပါက false သတ်မှတ်ပါ

  // Paths mapping settings
  static const String splashPath = '/splash';
  static const String selectBranchPath = '/select-branch';
  static const String loginPath = RouteNames.loginPath;
  static const String homePath = RouteNames.homePath;
}
```

### ၂။ Project ၏ Authentication State နှင့် ချိတ်ဆက်ခြင်း (Mapping States)
အခြား project ရှိ Authentication Provider များနှင့် redirection flow ကို အလိုအလျောက် ချိတ်ဆက်နိုင်ရန် `appAuthStateProvider` နှင့် `appInitializedStateProvider` တို့တွင် မိမိတို့၏ provider တန်ဖိုးများကို ချိန်ညှိပေးရန် လိုအပ်ပါသည်-

```dart
// ဥပမာ - မိမိ project ၏ လက်ရှိ auth state နှင့် ချိတ်ဆက်အသုံးပြုပုံ
final appAuthStateProvider = Provider<AsyncValue<AppAuthState>>((ref) {
  // မိမိ project ရှိ real auth state provider အား read/watch လုပ်ပါ
  final authState = ref.watch(projectAuthProvider); 
  
  return authState.when(
    data: (user) {
      if (user == null) {
        return const AsyncValue.data(AppAuthState.unauthenticated);
      }
      if (user.branchId == null) {
        return const AsyncValue.data(AppAuthState.authenticatedNoBranch);
      }
      return const AsyncValue.data(AppAuthState.authenticatedWithBranch);
    },
    loading: () => const AsyncValue.loading(),
    error: (e, st) => AsyncValue.error(e, st),
  );
});
```

---

## Page Transitions & iOS Back Gesture (Page Transition နှင့် iOS Back Gesture ဆိုင်ရာ သတ်မှတ်ချက်များ)

ဤ framework တွင် စာမျက်နှာတစ်ခုမှတစ်ခုသို့ ကူးပြောင်းရာတွင် လှပပြီး ချောမွေ့သော transition effects များကို အသုံးပြုနိုင်ရန်နှင့် iOS device များအတွက် swipe-to-go-back gesture ကို မိမိစိတ်ကြိုက် width သတ်မှတ်နိုင်ရန် [cupertino_back_gesture](https://pub.dev/packages/cupertino_back_gesture) ကို အသုံးပြုထားပါသည်။

### ၁။ Page Transitions အသုံးပြုပုံ (Using Page Transitions)

စာမျက်နှာတစ်ခုချင်းစီတွင် transition effect ပြောင်းလဲရန် `app_router.dart` ရှိ `GoRoute` ၏ `pageBuilder` တွင် `.customTransition` extension method ကို တွဲဖက်အသုံးပြုရပါမည်-

```dart
GoRoute(
  path: RouteNames.loginPath,
  name: RouteNames.loginName,
  pageBuilder: (context, state) => const LoginScreen().customTransition(
    state,
    transitionTypeIndex: 0, // Transition ပုံစံ သတ်မှတ်ရန်
    disableSwipeBack: false,  // iOS back swipe gesture ပိတ်ရန် (true)
  ),
)
```

#### Transition Type Index များ (Supported Transition Types)
* `0`: **Slide from Right (Default)** - ညာဘက်မှ slide တိုက်ဝင်လာခြင်း (iOS/Android platform transition settings အတိုင်း အလုပ်လုပ်မည်ဖြစ်ပြီး iOS gesture width customize ကို ဤနေရာတွင် အထောက်အပံ့ပေးသည်)
* `1`: **Fade Transition** - Fade out/in ပုံစံဖြင့် ကူးပြောင်းခြင်း
* `2`: **Slide from Bottom** - အောက်ခြေမှ slide တိုက်တက်လာခြင်း (Dialog presentation style)
* `3`: **Scale Transition** - ပုံရိပ်အကျုံ့အချဲ့စနစ်ဖြင့် ကူးပြောင်းခြင်း

---

### ၂။ iOS Back Gesture Width ကို စိတ်ကြိုက်ပြင်ဆင်ခြင်း (Customizing iOS Back Gesture Width)

iOS transition များတွင် swipe gesture လုပ်ဆောင်နိုင်သော screen width ဧရိယာကို ချိန်ညှိရန် [app.dart](file:///d:/Projects/clean_archi_frame/lib/app/app.dart) တွင် `BackGestureWidthTheme` ကို အသုံးပြုထားပါသည်-

```dart
BackGestureWidthTheme(
  backGestureWidth: BackGestureWidth.fraction(0.5), // Screen ၏ ၅၀% အထိ swipe ဆွဲ၍ back သွားနိုင်ရန် သတ်မှတ်ခြင်း
  child: StyledToast(
    child: MaterialApp.router(...),
  ),
)
```

**Gesture Width Options:**
* `BackGestureWidth.fraction(double fraction)`: Screen width ၏ ရာခိုင်နှုန်းဖြင့် သတ်မှတ်ရန် (ဥပမာ- `0.5` သည် ၅၀%)
* `BackGestureWidth.fixed(double width)`: Logical pixels တန်ဖိုး တိုက်ရိုက်သတ်မှတ်ရန်

---

### ၃။ Android ပေါ်တွင် iOS Back Gesture အား စမ်းသပ်ခြင်း (Testing iOS Back Gesture on Android)

သင်သည် Android device သို့မဟုတ် emulator ပေါ်တွင် iOS back swipe gesture အလုပ်လုပ်ပုံကို စမ်းသပ်လိုပါက [light_theme.dart](file:///d:/Projects/clean_archi_frame/lib/app/config/theme/light_theme.dart) နှင့် [dark_theme.dart](file:///d:/Projects/clean_archi_frame/lib/app/config/theme/dark_theme.dart) တို့တွင် `platform` property ကို ယာယီထည့်သွင်း၍ စမ်းသပ်နိုင်ပါသည်-

```dart
final ThemeData lightThemeData = ThemeData(
  useMaterial3: true,
  platform: TargetPlatform.iOS, // Android ပေါ်တွင် iOS gesture စမ်းသပ်ရန် ယာယီထည့်သွင်းခြင်း
  brightness: Brightness.light,
  ...
);
```
