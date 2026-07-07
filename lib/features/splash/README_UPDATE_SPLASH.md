# Guidelines: Flexible In-App Update & Splash Screen Customization

ဤ Framework (base template) တွင် မည်သည့် target project တွင်မဆို in-app updates configuration နှင့် splash screen layout ကို လိုက်လျောညီထွေရှိစွာ customize ပြုလုပ်ပြီး ပြန်လည်အသုံးပြုနိုင်ရန် လမ်းညွှန်ချက် ဖြစ်ပါသည်။

ပရောဂျက်ကို configure လုပ်ရန် config ဖိုင် (၂) ခုကိုသာ ပြင်ဆင်ရန် လိုအပ်ပြီး `lib/main.dart` အား ပြင်ဆင်ရန် မလိုပါ။

---

## ၁။ In-App Update Service Customization

[in_app_update_config.dart](file:///d:/Projects/clean_archi_frame/lib/app/config/in_app_update_config.dart) ဖိုင်တွင် Firebase Remote Config keys များနှင့် local update apk configs များကို static instance custom parameters အဖြစ် configure လုပ်နိုင်ပါသည်။

### How to use / Configuration:
[in_app_update_config.dart](file:///d:/Projects/clean_archi_frame/lib/app/config/in_app_update_config.dart) ရှိ `InAppUpdateConfig.current` dynamic variables များကို လိုအပ်သလို ပြောင်းလဲသတ်မှတ်ပါ-

```dart
// lib/app/config/in_app_update_config.dart

class InAppUpdateConfig {
  // ...
  
  static const InAppUpdateConfig current = InAppUpdateConfig(
    remoteApkLinkKey: 'custom_project_apk_link',     // Remote Config key
    remoteVersionKey: 'custom_project_app_version',   // Remote Config key 
    remoteWhatsNewKey: 'custom_project_whats_new',    // Remote Config key
    destinationFilename: 'my_project_update.apk',     // Apk Name on Android
    androidProviderAuthority: 'com.myproject.app.ota_update_provider', // Auth authority
  );
}
```

---

## ၂။ Flexible Splash Screen Customization

Splash screen ၏ branding layouts, colors, animations များနှင့် app updates background startup checks trigger logic များကို [splash_config.dart](file:///d:/Projects/clean_archi_frame/lib/app/config/splash_config.dart) တွင် configure လုပ်နိုင်ပါသည်။

### How to use / Configuration:
[splash_config.dart](file:///d:/Projects/clean_archi_frame/lib/app/config/splash_config.dart) ရှိ `SplashConfig.current` variables များကို ပြင်ဆင်ပါ-

```dart
// lib/app/config/splash_config.dart

class SplashConfig {
  // ...

  static final SplashConfig current = SplashConfig(
    logoPath: 'assets/images/app_images/my_brand_logo.svg', // SVG or PNG logo path
    backgroundColor: const Color(0xFF0F172A), // Dark slate corporate layout style
    versionText: 'Build V 1.0.0(12)',
    minDuration: const Duration(seconds: 3),
    onInitialize: (context) async {
      // 1. Run global update checks as startup logic
      final updateService = InAppUpdateService();
      final hasUpdate = await updateService.checkRemoteConfigForUpdate(context: context);
      if (hasUpdate) {
        // Automatically holds execution flow and redirects to update screen
        return;
      }
      
      // 2. Perform other initialization tasks if needed
    },
    nextRoute: RouteNames.homePath,
  );
}
```

---

## ၃။ strict Styling rules compliance (GEMINI.md)

1. **Colors flat aesthetic**: simple flat colors `#FAFAFA` (light mode) and `#0F172A` (dark slate mode) setup controls.
2. **Spacing limits**: No manual raw integers. uses layout space values constants parameters mapping details:
   - `AppSizes.paddingMarginLg` -> `24.0` padding/margins checks.
   - `AppSizes.spaceBtwTexts` -> `10.0` space keys.
   - `AppSizes.spaceBtwSections` -> `40.0` loader top spacing configurations.
3. **Deprecated opacity limits**: uses standard `.withValues(alpha: .x)` mappings.
4. **Border-radius**: flat sharp borders (`AppSizes.borderRadiusMd` which matches `8.0`).
