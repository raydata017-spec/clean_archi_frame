///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import
// dart format off

part of 'translations.g.dart';

// Path: <root>
typedef TranslationsEn = Translations; // ignore: unused_element
class Translations with BaseTranslations<AppLocale, Translations> {
	/// Returns the current translations of the given [context].
	///
	/// Usage:
	/// final t = Translations.of(context);
	static Translations of(BuildContext context) => InheritedLocaleData.of<AppLocale, Translations>(context).translations;

	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	Translations({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = meta ?? TranslationMetadata(
		    locale: AppLocale.en,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ) {
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <en>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	dynamic operator[](String key) => $meta.getTranslation(key);

	late final Translations _root = this; // ignore: unused_field

	Translations $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => Translations(meta: meta ?? this.$meta);

	// Translations
	late final TranslationsSettingEn setting = TranslationsSettingEn.internal(_root);
	late final TranslationsKDynamicEn kDynamic = TranslationsKDynamicEn.internal(_root);
	late final TranslationsValidationEn validation = TranslationsValidationEn.internal(_root);
}

// Path: setting
class TranslationsSettingEn {
	TranslationsSettingEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Hello'
	String get hello => 'Hello';

	/// en: 'Toggle Theme'
	String get changeTheme => 'Toggle Theme';

	/// en: 'Change Language'
	String get changeLanguage => 'Change Language';
}

// Path: kDynamic
class TranslationsKDynamicEn {
	TranslationsKDynamicEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Welcome back, $name! You have $point points.'
	String welcomeMessage({required Object name, required Object point}) => 'Welcome back, ${name}! You have ${point} points.';

	/// en: '(zero) {You have no new messages.} (one) {You have 1 new message.} (other) {You have $n new messages.}'
	String inboxCount({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n,
		zero: 'You have no new messages.',
		one: 'You have 1 new message.',
		other: 'You have ${n} new messages.',
	);
}

// Path: validation
class TranslationsValidationEn {
	TranslationsValidationEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Email is required'
	String get emailRequired => 'Email is required';

	/// en: 'Please enter a valid email address'
	String get emailInvalid => 'Please enter a valid email address';
}

/// The flat map containing all translations for locale <en>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on Translations {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'setting.hello' => 'Hello',
			'setting.changeTheme' => 'Toggle Theme',
			'setting.changeLanguage' => 'Change Language',
			'kDynamic.welcomeMessage' => ({required Object name, required Object point}) => 'Welcome back, ${name}! You have ${point} points.',
			'kDynamic.inboxCount' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n, zero: 'You have no new messages.', one: 'You have 1 new message.', other: 'You have ${n} new messages.', ), 
			'validation.emailRequired' => 'Email is required',
			'validation.emailInvalid' => 'Please enter a valid email address',
			_ => null,
		};
	}
}
