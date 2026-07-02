# Bottom Navigation Extension

This extension simplifies the usage and swapping of bottom navigation bar designs in different projects. By abstracting the creation of the bottom navigation bar into a `BuildContext` extension method, the application shell remains clean and independent of specific UI styling.

ဒီ extension ကို အသုံးပြုခြင်းအားဖြင့် ပရောဂျက်အသစ်များတွင် bottom navigation bar ဒီဇိုင်းများကို အလွယ်တကူ ပြောင်းလဲအသုံးပြုနိုင်မည်ဖြစ်ပြီး app shell ၏ ကုဒ်များကို ရှုပ်ထွေးမှုမရှိစေရန် သီးခြားခွဲထုတ်ပေးထားပါသည်။

---

## Folder Structure (ဖိုင်တည်ဆောက်ပုံ)

```
lib/
├── core/
│   └── utils/
│       └── extensions/
│           └── bottom_navigation_extension.dart  # BuildContext Extension
└── shared/
    └── widgets/
        └── bottom_nav/
            ├── bottom_navigation_item.dart        # Item Data Model
            ├── standard_bottom_nav_bar.dart       # Widget Implementation
            └── README.md                          # Documentation
```

---

## How to Use (အသုံးပြုပုံ)

### 1. Define Items (Navigation Items များ သတ်မှတ်ခြင်း)
In your main wrapper screen (e.g. `MainWrapperScreen`), import the extension and item model:

```dart
import 'core/utils/extensions/bottom_navigation_extension.dart';
import 'shared/widgets/bottom_nav/bottom_navigation_item.dart';
```

### 2. Build bottom navigation bar using extension (Extension သုံး၍ bottom navigation bar တည်ဆောက်ခြင်း)
Call `context.buildBottomNavigationBar` inside your `Scaffold`'s `bottomNavigationBar` slot:

```dart
Scaffold(
  body: navigationShell,
  bottomNavigationBar: context.buildBottomNavigationBar(
    navigationShell: navigationShell,
    items: const [
      BottomNavigationItem(
        icon: Icons.home_outlined,
        activeIcon: Icons.home_rounded,
        label: 'Home',
      ),
      BottomNavigationItem(
        icon: Icons.person_outline_rounded,
        activeIcon: Icons.person_rounded,
        label: 'Profile',
      ),
      BottomNavigationItem(
        icon: Icons.settings_outlined,
        activeIcon: Icons.settings_rounded,
        label: 'Setting',
      ),
    ],
  ),
);
```

---

## Swapping Bottom Navigation Bar Designs (ဒီဇိုင်းအသစ်ပြောင်းလဲခြင်း)

If a new project requires a different bottom navigation design:
1. Create your custom Bottom Navigation Widget in `lib/shared/widgets/bottom_nav/`.
2. Update the `buildBottomNavigationBar` method in [bottom_navigation_extension.dart](file:///d:/Projects/clean_archi_frame/lib/core/utils/extensions/bottom_navigation_extension.dart) to return your new custom widget.

ဒီဇိုင်းအသစ်ပြောင်းလဲလိုပါက Widget အသစ်တစ်ခုအား `lib/shared/widgets/bottom_nav/` အောက်တွင် ဖန်တီး၍ [bottom_navigation_extension.dart](file:///d:/Projects/clean_archi_frame/lib/core/utils/extensions/bottom_navigation_extension.dart) အတွင်းရှိ return widget အား လဲလှယ်ပေးရုံဖြင့် အလွယ်တကူ ပြောင်းလဲနိုင်ပါသည်။
