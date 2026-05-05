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
