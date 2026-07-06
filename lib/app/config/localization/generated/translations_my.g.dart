///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import
// dart format off

import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:slang/generated.dart';
import 'translations.g.dart';

// Path: <root>
class TranslationsMy extends Translations with BaseTranslations<AppLocale, Translations> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	TranslationsMy({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = meta ?? TranslationMetadata(
		    locale: AppLocale.my,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		super.$meta.setFlatMapFunction($meta.getTranslation); // copy base translations to super.$meta
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <my>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	@override dynamic operator[](String key) => $meta.getTranslation(key) ?? super.$meta.getTranslation(key);

	late final TranslationsMy _root = this; // ignore: unused_field

	@override 
	TranslationsMy $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => TranslationsMy(meta: meta ?? this.$meta);

	// Translations
	@override late final _Translations$setting$my setting = _Translations$setting$my._(_root);
	@override late final _Translations$kDynamic$my kDynamic = _Translations$kDynamic$my._(_root);
	@override late final _Translations$common$my common = _Translations$common$my._(_root);
	@override late final _Translations$validation$my validation = _Translations$validation$my._(_root);
	@override late final _Translations$auth$my auth = _Translations$auth$my._(_root);
	@override late final _Translations$notification$my notification = _Translations$notification$my._(_root);
}

// Path: setting
class _Translations$setting$my extends Translations$setting$en {
	_Translations$setting$my._(TranslationsMy root) : this._root = root, super.internal(root);

	final TranslationsMy _root; // ignore: unused_field

	// Translations
	@override String get hello => 'မင်္ဂလာပါ';
	@override String get title => 'ဆက်တင်များ';
	@override String get changeTheme => 'အပြင်အဆင်';
	@override String get changeLanguage => 'ဘာသာစကား ပြောင်းရန်';
	@override String get darkMode => 'အမှောင် မုဒ်';
	@override String get lightMode => 'အလင်း မုဒ်';
	@override String get systemTheme => 'စနစ်သတ်မှတ်ချက်အတိုင်း';
	@override String get selectTheme => 'အလင်း/အမှောင် ရွေးချယ်ရန်';
	@override String get selectLanguage => 'ဘာသာစကား ရွေးချယ်ရန်';
	@override String get offlineSync => 'အော့ဖ်လိုင်း ထပ်တူပြုခြင်း';
	@override String get offlineSyncSubtitle => 'အော့ဖ်လိုင်း အောက်ဘောက်ဖွင့်ရန်';
	@override String get notificationSetting => 'အကြောင်းကြားချက် ဆက်တင်များ';
	@override String get general => 'အထွေထွေ';
	@override String get notifications => 'အကြောင်းကြားချက်များ';
	@override String get advanced => 'အဆင့်မြင့်';
}

// Path: kDynamic
class _Translations$kDynamic$my extends Translations$kDynamic$en {
	_Translations$kDynamic$my._(TranslationsMy root) : this._root = root, super.internal(root);

	final TranslationsMy _root; // ignore: unused_field

	// Translations
	@override String welcomeMessage({required Object name, required Object point}) => 'ပြန်လည်ကြိုဆိုပါတယ် ${name}! သင့်မှာ အမှတ် ${point} မှတ် ရှိပါတယ်။';
	@override String get defaultErrorText => 'တစ်စုံတစ်ခုမှားယွင်းနေသည်';
	@override String inboxCount({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('my'))(n,
		zero: 'မက်ဆေ့ချ် အသစ်မရှိပါ။',
		other: 'မက်ဆေ့ချ် အသစ် ${n} စောင် ရှိပါတယ်။',
	);
}

// Path: common
class _Translations$common$my extends Translations$common$en {
	_Translations$common$my._(TranslationsMy root) : this._root = root, super.internal(root);

	final TranslationsMy _root; // ignore: unused_field

	// Translations
	@override String get somethingWentWrong => 'တစ်စုံတစ်ခု မှားယွင်းနေပါသည်';
	@override String get retry => 'ထပ်ကြိုးစားရန်';
	@override String get exitAppTitle => 'အက်ပ်မှ ထွက်ရန်';
	@override String get exitAppConfirm => 'အက်ပ်မှ ထွက်ရန် သေချာပါသလား?';
	@override String get exit => 'ထွက်မည်';
	@override String get cancel => 'မလုပ်တော့ပါ';
}

// Path: validation
class _Translations$validation$my extends Translations$validation$en {
	_Translations$validation$my._(TranslationsMy root) : this._root = root, super.internal(root);

	final TranslationsMy _root; // ignore: unused_field

	// Translations
	@override String get emailRequired => 'အီးမေးလ် လိုအပ်ပါတယ်';
	@override String get emailInvalid => 'အီးမေးလ် လိပ်စာ အမှန် ထည့်ပါ';
	@override String get phoneRequired => 'ဖုန်းနံပါတ် လိုအပ်ပါတယ်';
	@override String get phoneInvalid => 'မှန်ကန်သော ဖုန်းနံပါတ် ဖြည့်စွက်ပါ';
	@override String get phoneStartWith => 'ဖုန်းနံပါတ်သည် +959 ဖြင့် စတင်ရပါမည်';
	@override String get phoneCountryCode => '+959';
	@override String get passwordRequired => 'စကားဝှက် လိုအပ်ပါတယ်';
	@override String get passwordTooShort => 'စကားဝှက်သည် အနည်းဆုံး ၈ လုံး ရှိရပါမည်';
	@override String get passwordWeakText => 'စကားဝှက်တွင် အနည်းဆုံး စာလုံးကြီးတစ်လုံးနှင့် ကိန်းဂဏန်းတစ်ခု ပါဝင်ရပါမည်';
	@override String get passwordsDoNotMatch => 'စကားဝှက်များ ကိုက်ညီမှုမရှိပါ';
	@override String get confirmPasswordRequired => 'စကားဝှက် အတည်ပြုချက် လိုအပ်ပါတယ်';
	@override String get otpRequired => 'OTP လိုအပ်ပါသည်';
	@override String get otpInvalid => 'OTP သည် ၆ လုံး ဖြစ်ရပါမည်';
	@override String get nameRequired => 'အမည် လိုအပ်ပါတယ်';
	@override String get newPasswordSameAsOld => 'စကားဝှက်အသစ်သည် စကားဝှက်ဟောင်းနှင့် တူညီ၍မရပါ';
	@override String fieldRequired({required Object name}) => '${name} လိုအပ်ပါသည်';
	@override String get cardNumberRequired => 'ကတ်နံပါတ် လိုအပ်ပါသည်';
	@override String get cardNumberInvalid => 'မှန်ကန်သော ကတ်နံပါတ် ထည့်ပါ';
	@override String get cvvRequired => 'CVV လိုအပ်ပါသည်';
	@override String get cvvInvalid => 'မှန်ကန်သော CVV ထည့်ပါ';
	@override String get dateRequired => 'ရက်စွဲ လိုအပ်ပါသည်';
	@override String get licenseNumberRequired => 'လိုင်စင်နံပါတ် လိုအပ်ပါသည်';
	@override String get licenseNumberInvalid => 'မှန်ကန်သော လိုင်စင်နံပါတ် ထည့်ပါ';
	@override String get cityRequired => 'မြို့ အမည် လိုအပ်ပါသည်';
	@override String get townshipRequired => 'မြို့နယ် အမည် လိုအပ်ပါသည်';
}

// Path: auth
class _Translations$auth$my extends Translations$auth$en {
	_Translations$auth$my._(TranslationsMy root) : this._root = root, super.internal(root);

	final TranslationsMy _root; // ignore: unused_field

	// Translations
	@override String get signInToConsole => 'Console သို့ ဝင်ရန်';
	@override String get createAccount => 'အကောင့်သစ်ဖွင့်ရန်';
	@override String get emailSubtitle => 'သင့်အကောင့်သို့ ဝင်ရောက်ရန် အီးမေးလ်အချက်အလက်များကို ဖြည့်စွက်ပေးပါ။';
	@override String get phoneSubtitle => 'သင့်အကောင့်သို့ ဝင်ရောက်ရန် ဖုန်းနံပါတ်အချက်အလက်များကို ဖြည့်စွက်ပေးပါ။';
	@override String get bothSubtitle => 'သင့်အကောင့်သို့ ဝင်ရောက်ရန် ကြိုက်နှစ်သက်ရာ နည်းလမ်းကို ရွေးချယ်ပါ။';
	@override String get emailRegisterSubtitle => 'စတင်ရန် အီးမေးလ်ဖြင့် အကောင့်သစ်ဖွင့်ပါ။';
	@override String get phoneRegisterSubtitle => 'စတင်ရန် ဖုန်းနံပါတ်ဖြင့် အကောင့်သစ်ဖွင့်ပါ။';
	@override String get bothRegisterSubtitle => 'စတင်ရန် အကောင့်သစ်ဖွင့်မည့် နည်းလမ်းကို ရွေးချယ်ပါ။';
	@override String get fullName => 'အမည်အပြည့်အစုံ';
	@override String get emailAddress => 'အီးမေးလ်လိပ်စာ';
	@override String get phoneNumber => 'ဖုန်းနံပါတ်';
	@override String get password => 'စကားဝှက်';
	@override String get confirmPassword => 'စကားဝှက် အတည်ပြုရန်';
	@override String get forgotPassword => 'စကားဝှက်မေ့နေပါသလား?';
	@override String get keepMeSignedIn => 'အကောင့်ဝင်ထားလျက်ထားရန်';
	@override String get signIn => 'အကောင့်ဝင်ရန်';
	@override String get signUp => 'အကောင့်ဖွင့်ရန်';
	@override String get dontHaveAccount => 'အကောင့်မရှိသေးဘူးလား?';
	@override String get alreadyHaveAccount => 'အကောင့်ရှိပြီးသားလား?';
	@override String get step1Subtitle => 'အဆင့် ၁ (၂ အနက်) - သင့်အခြေခံအချက်အလက်များကို ဖြည့်စွက်ပါ။';
	@override String get step2Subtitle => 'အဆင့် ၂ (၂ အနက်) - စကားဝှက်အသစ်သတ်မှတ်ပါ။';
	@override String get continueText => 'ဆက်လက်လုပ်ဆောင်ရန်';
	@override String get termsOfService => 'ဝန်ဆောင်မှု သဘောတူညီချက်နှင့် ကိုယ်ရေးအချက်အလက် ထိန်းသိမ်းမှု မူဝါဒကို သဘောတူပါသည်။';
	@override String get termsError => 'ဆက်လက်လုပ်ဆောင်ရန် စည်းမျဉ်းများကို သဘောတူရပါမည်';
	@override String get emailRequired => 'အီးမေးလ် လိုအပ်ပါတယ်';
	@override String get emailInvalid => 'အမှန်တကယ် အီးမေးလ် လိပ်စာ တစ်ခု ထည့်ပါ';
	@override String get passwordRequired => 'စကားဝှက် လိုအပ်ပါတယ်';
	@override String get passwordLengthError => 'စကားဝှက်သည် အနည်းဆုံး ၆ လုံး ရှိရပါမည်';
	@override String get confirmPasswordRequired => 'စကားဝှက် အတည်ပြုချက် လိုအပ်ပါတယ်';
	@override String get passwordsDoNotMatch => 'စကားဝှက်များ ကိုက်ညီမှုမရှိပါ';
	@override String get nameRequired => 'အမည် လိုအပ်ပါတယ်';
	@override String get phoneRequired => 'ဖုန်းနံပါတ် လိုအပ်ပါတယ်';
	@override String get phoneInvalid => 'မှန်ကန်သော ဖုန်းနံပါတ် ဖြည့်စွက်ပါ';
	@override String get email => 'အီးမေးလ်';
	@override String get phone => 'ဖုန်း';
	@override String get logout => 'အကောင့်မှ ထွက်ရန်';
}

// Path: notification
class _Translations$notification$my extends Translations$notification$en {
	_Translations$notification$my._(TranslationsMy root) : this._root = root, super.internal(root);

	final TranslationsMy _root; // ignore: unused_field

	// Translations
	@override String get title => 'အကြောင်းကြားချက်များ';
	@override String get markAllRead => 'အားလုံးဖတ်ပြီးသားမှတ်သားရန်';
	@override String unread({required Object count}) => 'မဖတ်ရသေးသော (${count})';
	@override String total({required Object count}) => 'စုစုပေါင်း (${count})';
	@override String get emptyState => 'အကြောင်းကြားချက်များ မရှိသေးပါ';
	@override String get allMarkedRead => 'အကြောင်းကြားချက် အားလုံးအား ဖတ်ပြီးသားအဖြစ် မှတ်သားပြီးပါပြီ';
	@override String get deleted => 'အကြောင်းကြားချက် ဖျက်ပြီးပါပြီ';
	@override String get actionsTitle => 'အကြောင်းကြားချက် လုပ်ဆောင်ချက်များ';
	@override String get markRead => 'ဖတ်ပြီးသားအဖြစ် သတ်မှတ်ရန်';
	@override String get markUnread => 'မဖတ်ရသေးသော အဖြစ် သတ်မှတ်ရန်';
	@override String get delete => 'ဖျက်ရန်';
	@override String get undo => 'ပြန်ပြင်ရန်';
	@override String get deleteTitle => 'အကြောင်းကြားချက် ဖျက်ရန်';
	@override String get deleteConfirm => 'ဤအကြောင်းကြားချက်ကို ဖျက်လိုကြောင်း သေချာပါသလား?';
	@override String get cancel => 'မလုပ်တော့ပါ';
	@override String get confirm => 'ဖျက်မည်';
	@override String minutesAgo({required Object minutes}) => 'လွန်ခဲ့သော ${minutes} မိနစ်က';
	@override String hoursAgo({required Object hours}) => 'လွန်ခဲ့သော ${hours} နာရီက';
	@override String daysAgo({required Object days}) => 'လွန်ခဲ့သော ${days} ရက်က';
}

/// The flat map containing all translations for locale <my>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on TranslationsMy {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'setting.hello' => 'မင်္ဂလာပါ',
			'setting.title' => 'ဆက်တင်များ',
			'setting.changeTheme' => 'အပြင်အဆင်',
			'setting.changeLanguage' => 'ဘာသာစကား ပြောင်းရန်',
			'setting.darkMode' => 'အမှောင် မုဒ်',
			'setting.lightMode' => 'အလင်း မုဒ်',
			'setting.systemTheme' => 'စနစ်သတ်မှတ်ချက်အတိုင်း',
			'setting.selectTheme' => 'အလင်း/အမှောင် ရွေးချယ်ရန်',
			'setting.selectLanguage' => 'ဘာသာစကား ရွေးချယ်ရန်',
			'setting.offlineSync' => 'အော့ဖ်လိုင်း ထပ်တူပြုခြင်း',
			'setting.offlineSyncSubtitle' => 'အော့ဖ်လိုင်း အောက်ဘောက်ဖွင့်ရန်',
			'setting.notificationSetting' => 'အကြောင်းကြားချက် ဆက်တင်များ',
			'setting.general' => 'အထွေထွေ',
			'setting.notifications' => 'အကြောင်းကြားချက်များ',
			'setting.advanced' => 'အဆင့်မြင့်',
			'kDynamic.welcomeMessage' => ({required Object name, required Object point}) => 'ပြန်လည်ကြိုဆိုပါတယ် ${name}! သင့်မှာ အမှတ် ${point} မှတ် ရှိပါတယ်။',
			'kDynamic.defaultErrorText' => 'တစ်စုံတစ်ခုမှားယွင်းနေသည်',
			'kDynamic.inboxCount' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('my'))(n, zero: 'မက်ဆေ့ချ် အသစ်မရှိပါ။', other: 'မက်ဆေ့ချ် အသစ် ${n} စောင် ရှိပါတယ်။', ), 
			'common.somethingWentWrong' => 'တစ်စုံတစ်ခု မှားယွင်းနေပါသည်',
			'common.retry' => 'ထပ်ကြိုးစားရန်',
			'common.exitAppTitle' => 'အက်ပ်မှ ထွက်ရန်',
			'common.exitAppConfirm' => 'အက်ပ်မှ ထွက်ရန် သေချာပါသလား?',
			'common.exit' => 'ထွက်မည်',
			'common.cancel' => 'မလုပ်တော့ပါ',
			'validation.emailRequired' => 'အီးမေးလ် လိုအပ်ပါတယ်',
			'validation.emailInvalid' => 'အီးမေးလ် လိပ်စာ အမှန် ထည့်ပါ',
			'validation.phoneRequired' => 'ဖုန်းနံပါတ် လိုအပ်ပါတယ်',
			'validation.phoneInvalid' => 'မှန်ကန်သော ဖုန်းနံပါတ် ဖြည့်စွက်ပါ',
			'validation.phoneStartWith' => 'ဖုန်းနံပါတ်သည် +959 ဖြင့် စတင်ရပါမည်',
			'validation.phoneCountryCode' => '+959',
			'validation.passwordRequired' => 'စကားဝှက် လိုအပ်ပါတယ်',
			'validation.passwordTooShort' => 'စကားဝှက်သည် အနည်းဆုံး ၈ လုံး ရှိရပါမည်',
			'validation.passwordWeakText' => 'စကားဝှက်တွင် အနည်းဆုံး စာလုံးကြီးတစ်လုံးနှင့် ကိန်းဂဏန်းတစ်ခု ပါဝင်ရပါမည်',
			'validation.passwordsDoNotMatch' => 'စကားဝှက်များ ကိုက်ညီမှုမရှိပါ',
			'validation.confirmPasswordRequired' => 'စကားဝှက် အတည်ပြုချက် လိုအပ်ပါတယ်',
			'validation.otpRequired' => 'OTP လိုအပ်ပါသည်',
			'validation.otpInvalid' => 'OTP သည် ၆ လုံး ဖြစ်ရပါမည်',
			'validation.nameRequired' => 'အမည် လိုအပ်ပါတယ်',
			'validation.newPasswordSameAsOld' => 'စကားဝှက်အသစ်သည် စကားဝှက်ဟောင်းနှင့် တူညီ၍မရပါ',
			'validation.fieldRequired' => ({required Object name}) => '${name} လိုအပ်ပါသည်',
			'validation.cardNumberRequired' => 'ကတ်နံပါတ် လိုအပ်ပါသည်',
			'validation.cardNumberInvalid' => 'မှန်ကန်သော ကတ်နံပါတ် ထည့်ပါ',
			'validation.cvvRequired' => 'CVV လိုအပ်ပါသည်',
			'validation.cvvInvalid' => 'မှန်ကန်သော CVV ထည့်ပါ',
			'validation.dateRequired' => 'ရက်စွဲ လိုအပ်ပါသည်',
			'validation.licenseNumberRequired' => 'လိုင်စင်နံပါတ် လိုအပ်ပါသည်',
			'validation.licenseNumberInvalid' => 'မှန်ကန်သော လိုင်စင်နံပါတ် ထည့်ပါ',
			'validation.cityRequired' => 'မြို့ အမည် လိုအပ်ပါသည်',
			'validation.townshipRequired' => 'မြို့နယ် အမည် လိုအပ်ပါသည်',
			'auth.signInToConsole' => 'Console သို့ ဝင်ရန်',
			'auth.createAccount' => 'အကောင့်သစ်ဖွင့်ရန်',
			'auth.emailSubtitle' => 'သင့်အကောင့်သို့ ဝင်ရောက်ရန် အီးမေးလ်အချက်အလက်များကို ဖြည့်စွက်ပေးပါ။',
			'auth.phoneSubtitle' => 'သင့်အကောင့်သို့ ဝင်ရောက်ရန် ဖုန်းနံပါတ်အချက်အလက်များကို ဖြည့်စွက်ပေးပါ။',
			'auth.bothSubtitle' => 'သင့်အကောင့်သို့ ဝင်ရောက်ရန် ကြိုက်နှစ်သက်ရာ နည်းလမ်းကို ရွေးချယ်ပါ။',
			'auth.emailRegisterSubtitle' => 'စတင်ရန် အီးမေးလ်ဖြင့် အကောင့်သစ်ဖွင့်ပါ။',
			'auth.phoneRegisterSubtitle' => 'စတင်ရန် ဖုန်းနံပါတ်ဖြင့် အကောင့်သစ်ဖွင့်ပါ။',
			'auth.bothRegisterSubtitle' => 'စတင်ရန် အကောင့်သစ်ဖွင့်မည့် နည်းလမ်းကို ရွေးချယ်ပါ။',
			'auth.fullName' => 'အမည်အပြည့်အစုံ',
			'auth.emailAddress' => 'အီးမေးလ်လိပ်စာ',
			'auth.phoneNumber' => 'ဖုန်းနံပါတ်',
			'auth.password' => 'စကားဝှက်',
			'auth.confirmPassword' => 'စကားဝှက် အတည်ပြုရန်',
			'auth.forgotPassword' => 'စကားဝှက်မေ့နေပါသလား?',
			'auth.keepMeSignedIn' => 'အကောင့်ဝင်ထားလျက်ထားရန်',
			'auth.signIn' => 'အကောင့်ဝင်ရန်',
			'auth.signUp' => 'အကောင့်ဖွင့်ရန်',
			'auth.dontHaveAccount' => 'အကောင့်မရှိသေးဘူးလား?',
			'auth.alreadyHaveAccount' => 'အကောင့်ရှိပြီးသားလား?',
			'auth.step1Subtitle' => 'အဆင့် ၁ (၂ အနက်) - သင့်အခြေခံအချက်အလက်များကို ဖြည့်စွက်ပါ။',
			'auth.step2Subtitle' => 'အဆင့် ၂ (၂ အနက်) - စကားဝှက်အသစ်သတ်မှတ်ပါ။',
			'auth.continueText' => 'ဆက်လက်လုပ်ဆောင်ရန်',
			'auth.termsOfService' => 'ဝန်ဆောင်မှု သဘောတူညီချက်နှင့် ကိုယ်ရေးအချက်အလက် ထိန်းသိမ်းမှု မူဝါဒကို သဘောတူပါသည်။',
			'auth.termsError' => 'ဆက်လက်လုပ်ဆောင်ရန် စည်းမျဉ်းများကို သဘောတူရပါမည်',
			'auth.emailRequired' => 'အီးမေးလ် လိုအပ်ပါတယ်',
			'auth.emailInvalid' => 'အမှန်တကယ် အီးမေးလ် လိပ်စာ တစ်ခု ထည့်ပါ',
			'auth.passwordRequired' => 'စကားဝှက် လိုအပ်ပါတယ်',
			'auth.passwordLengthError' => 'စကားဝှက်သည် အနည်းဆုံး ၆ လုံး ရှိရပါမည်',
			'auth.confirmPasswordRequired' => 'စကားဝှက် အတည်ပြုချက် လိုအပ်ပါတယ်',
			'auth.passwordsDoNotMatch' => 'စကားဝှက်များ ကိုက်ညီမှုမရှိပါ',
			'auth.nameRequired' => 'အမည် လိုအပ်ပါတယ်',
			'auth.phoneRequired' => 'ဖုန်းနံပါတ် လိုအပ်ပါတယ်',
			'auth.phoneInvalid' => 'မှန်ကန်သော ဖုန်းနံပါတ် ဖြည့်စွက်ပါ',
			'auth.email' => 'အီးမေးလ်',
			'auth.phone' => 'ဖုန်း',
			'auth.logout' => 'အကောင့်မှ ထွက်ရန်',
			'notification.title' => 'အကြောင်းကြားချက်များ',
			'notification.markAllRead' => 'အားလုံးဖတ်ပြီးသားမှတ်သားရန်',
			'notification.unread' => ({required Object count}) => 'မဖတ်ရသေးသော (${count})',
			'notification.total' => ({required Object count}) => 'စုစုပေါင်း (${count})',
			'notification.emptyState' => 'အကြောင်းကြားချက်များ မရှိသေးပါ',
			'notification.allMarkedRead' => 'အကြောင်းကြားချက် အားလုံးအား ဖတ်ပြီးသားအဖြစ် မှတ်သားပြီးပါပြီ',
			'notification.deleted' => 'အကြောင်းကြားချက် ဖျက်ပြီးပါပြီ',
			'notification.actionsTitle' => 'အကြောင်းကြားချက် လုပ်ဆောင်ချက်များ',
			'notification.markRead' => 'ဖတ်ပြီးသားအဖြစ် သတ်မှတ်ရန်',
			'notification.markUnread' => 'မဖတ်ရသေးသော အဖြစ် သတ်မှတ်ရန်',
			'notification.delete' => 'ဖျက်ရန်',
			'notification.undo' => 'ပြန်ပြင်ရန်',
			'notification.deleteTitle' => 'အကြောင်းကြားချက် ဖျက်ရန်',
			'notification.deleteConfirm' => 'ဤအကြောင်းကြားချက်ကို ဖျက်လိုကြောင်း သေချာပါသလား?',
			'notification.cancel' => 'မလုပ်တော့ပါ',
			'notification.confirm' => 'ဖျက်မည်',
			'notification.minutesAgo' => ({required Object minutes}) => 'လွန်ခဲ့သော ${minutes} မိနစ်က',
			'notification.hoursAgo' => ({required Object hours}) => 'လွန်ခဲ့သော ${hours} နာရီက',
			'notification.daysAgo' => ({required Object days}) => 'လွန်ခဲ့သော ${days} ရက်က',
			_ => null,
		};
	}
}
