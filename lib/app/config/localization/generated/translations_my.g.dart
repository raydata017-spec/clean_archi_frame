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
	@override late final _TranslationsSettingMy setting = _TranslationsSettingMy._(_root);
	@override late final _TranslationsKDynamicMy kDynamic = _TranslationsKDynamicMy._(_root);
}

// Path: setting
class _TranslationsSettingMy extends TranslationsSettingEn {
	_TranslationsSettingMy._(TranslationsMy root) : this._root = root, super.internal(root);

	final TranslationsMy _root; // ignore: unused_field

	// Translations
	@override String get hello => 'မင်္ဂလာပါ';
	@override String get changeTheme => 'အလင်း/အမှောင် ပြောင်းရန်';
	@override String get changeLanguage => 'ဘာသာစကား ပြောင်းရန်';
}

// Path: kDynamic
class _TranslationsKDynamicMy extends TranslationsKDynamicEn {
	_TranslationsKDynamicMy._(TranslationsMy root) : this._root = root, super.internal(root);

	final TranslationsMy _root; // ignore: unused_field

	// Translations
	@override String welcomeMessage({required Object name, required Object point}) => 'ပြန်လည်ကြိုဆိုပါတယ် ${name}! သင့်မှာ အမှတ် ${point} မှတ် ရှိပါတယ်။';
	@override String inboxCount({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('my'))(n,
		zero: 'မက်ဆေ့ချ် အသစ်မရှိပါ။',
		other: 'မက်ဆေ့ချ် အသစ် ${n} စောင် ရှိပါတယ်။',
	);
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
			'setting.changeTheme' => 'အလင်း/အမှောင် ပြောင်းရန်',
			'setting.changeLanguage' => 'ဘာသာစကား ပြောင်းရန်',
			'kDynamic.welcomeMessage' => ({required Object name, required Object point}) => 'ပြန်လည်ကြိုဆိုပါတယ် ${name}! သင့်မှာ အမှတ် ${point} မှတ် ရှိပါတယ်။',
			'kDynamic.inboxCount' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('my'))(n, zero: 'မက်ဆေ့ချ် အသစ်မရှိပါ။', other: 'မက်ဆေ့ချ် အသစ် ${n} စောင် ရှိပါတယ်။', ), 
			_ => null,
		};
	}
}
