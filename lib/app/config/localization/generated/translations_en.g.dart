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
	late final Translations$setting$en setting = Translations$setting$en.internal(_root);
	late final Translations$kDynamic$en kDynamic = Translations$kDynamic$en.internal(_root);
	late final Translations$validation$en validation = Translations$validation$en.internal(_root);
	late final Translations$auth$en auth = Translations$auth$en.internal(_root);
}

// Path: setting
class Translations$setting$en {
	Translations$setting$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Hello'
	String get hello => 'Hello';

	/// en: 'Settings'
	String get title => 'Settings';

	/// en: 'App Theme'
	String get changeTheme => 'App Theme';

	/// en: 'Change Language'
	String get changeLanguage => 'Change Language';

	/// en: 'Dark mode'
	String get darkMode => 'Dark mode';

	/// en: 'Light mode'
	String get lightMode => 'Light mode';

	/// en: 'System default'
	String get systemTheme => 'System default';

	/// en: 'Select Theme'
	String get selectTheme => 'Select Theme';

	/// en: 'Select Language'
	String get selectLanguage => 'Select Language';

	/// en: 'Offline Sync'
	String get offlineSync => 'Offline Sync';

	/// en: 'Open offline outbox'
	String get offlineSyncSubtitle => 'Open offline outbox';

	/// en: 'Notification Settings'
	String get notificationSetting => 'Notification Settings';

	/// en: 'General'
	String get general => 'General';

	/// en: 'Notifications'
	String get notifications => 'Notifications';

	/// en: 'Advanced'
	String get advanced => 'Advanced';
}

// Path: kDynamic
class Translations$kDynamic$en {
	Translations$kDynamic$en.internal(this._root);

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
class Translations$validation$en {
	Translations$validation$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Email is required'
	String get emailRequired => 'Email is required';

	/// en: 'Please enter a valid email address'
	String get emailInvalid => 'Please enter a valid email address';
}

// Path: auth
class Translations$auth$en {
	Translations$auth$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Sign in to Console'
	String get signInToConsole => 'Sign in to Console';

	/// en: 'Create Account'
	String get createAccount => 'Create Account';

	/// en: 'Enter your email details below to access your account.'
	String get emailSubtitle => 'Enter your email details below to access your account.';

	/// en: 'Enter your phone details below to access your account.'
	String get phoneSubtitle => 'Enter your phone details below to access your account.';

	/// en: 'Choose your preferred login option to proceed.'
	String get bothSubtitle => 'Choose your preferred login option to proceed.';

	/// en: 'Register with your email to get started.'
	String get emailRegisterSubtitle => 'Register with your email to get started.';

	/// en: 'Register with your phone number to get started.'
	String get phoneRegisterSubtitle => 'Register with your phone number to get started.';

	/// en: 'Select a registration option below to get started.'
	String get bothRegisterSubtitle => 'Select a registration option below to get started.';

	/// en: 'Full Name'
	String get fullName => 'Full Name';

	/// en: 'Email Address'
	String get emailAddress => 'Email Address';

	/// en: 'Phone Number'
	String get phoneNumber => 'Phone Number';

	/// en: 'Password'
	String get password => 'Password';

	/// en: 'Confirm Password'
	String get confirmPassword => 'Confirm Password';

	/// en: 'Forgot password?'
	String get forgotPassword => 'Forgot password?';

	/// en: 'Keep me signed in'
	String get keepMeSignedIn => 'Keep me signed in';

	/// en: 'Sign In'
	String get signIn => 'Sign In';

	/// en: 'Sign Up'
	String get signUp => 'Sign Up';

	/// en: 'Don't have an account?'
	String get dontHaveAccount => 'Don\'t have an account?';

	/// en: 'Already have an account?'
	String get alreadyHaveAccount => 'Already have an account?';

	/// en: 'Step 1 of 2: Enter your basic profile details.'
	String get step1Subtitle => 'Step 1 of 2: Enter your basic profile details.';

	/// en: 'Step 2 of 2: Secure your new company account.'
	String get step2Subtitle => 'Step 2 of 2: Secure your new company account.';

	/// en: 'Continue'
	String get continueText => 'Continue';

	/// en: 'I agree to the Terms of Service and Privacy Policy'
	String get termsOfService => 'I agree to the Terms of Service and Privacy Policy';

	/// en: 'You must accept the terms to continue'
	String get termsError => 'You must accept the terms to continue';

	/// en: 'Email is required'
	String get emailRequired => 'Email is required';

	/// en: 'Please enter a valid email address'
	String get emailInvalid => 'Please enter a valid email address';

	/// en: 'Password is required'
	String get passwordRequired => 'Password is required';

	/// en: 'Password must be at least 6 characters'
	String get passwordLengthError => 'Password must be at least 6 characters';

	/// en: 'Confirm password is required'
	String get confirmPasswordRequired => 'Confirm password is required';

	/// en: 'Passwords do not match'
	String get passwordsDoNotMatch => 'Passwords do not match';

	/// en: 'Name is required'
	String get nameRequired => 'Name is required';

	/// en: 'Phone number is required'
	String get phoneRequired => 'Phone number is required';

	/// en: 'Please enter a valid phone number'
	String get phoneInvalid => 'Please enter a valid phone number';

	/// en: 'Email'
	String get email => 'Email';

	/// en: 'Phone'
	String get phone => 'Phone';

	/// en: 'Log out'
	String get logout => 'Log out';
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
			'setting.title' => 'Settings',
			'setting.changeTheme' => 'App Theme',
			'setting.changeLanguage' => 'Change Language',
			'setting.darkMode' => 'Dark mode',
			'setting.lightMode' => 'Light mode',
			'setting.systemTheme' => 'System default',
			'setting.selectTheme' => 'Select Theme',
			'setting.selectLanguage' => 'Select Language',
			'setting.offlineSync' => 'Offline Sync',
			'setting.offlineSyncSubtitle' => 'Open offline outbox',
			'setting.notificationSetting' => 'Notification Settings',
			'setting.general' => 'General',
			'setting.notifications' => 'Notifications',
			'setting.advanced' => 'Advanced',
			'kDynamic.welcomeMessage' => ({required Object name, required Object point}) => 'Welcome back, ${name}! You have ${point} points.',
			'kDynamic.inboxCount' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n, zero: 'You have no new messages.', one: 'You have 1 new message.', other: 'You have ${n} new messages.', ), 
			'validation.emailRequired' => 'Email is required',
			'validation.emailInvalid' => 'Please enter a valid email address',
			'auth.signInToConsole' => 'Sign in to Console',
			'auth.createAccount' => 'Create Account',
			'auth.emailSubtitle' => 'Enter your email details below to access your account.',
			'auth.phoneSubtitle' => 'Enter your phone details below to access your account.',
			'auth.bothSubtitle' => 'Choose your preferred login option to proceed.',
			'auth.emailRegisterSubtitle' => 'Register with your email to get started.',
			'auth.phoneRegisterSubtitle' => 'Register with your phone number to get started.',
			'auth.bothRegisterSubtitle' => 'Select a registration option below to get started.',
			'auth.fullName' => 'Full Name',
			'auth.emailAddress' => 'Email Address',
			'auth.phoneNumber' => 'Phone Number',
			'auth.password' => 'Password',
			'auth.confirmPassword' => 'Confirm Password',
			'auth.forgotPassword' => 'Forgot password?',
			'auth.keepMeSignedIn' => 'Keep me signed in',
			'auth.signIn' => 'Sign In',
			'auth.signUp' => 'Sign Up',
			'auth.dontHaveAccount' => 'Don\'t have an account?',
			'auth.alreadyHaveAccount' => 'Already have an account?',
			'auth.step1Subtitle' => 'Step 1 of 2: Enter your basic profile details.',
			'auth.step2Subtitle' => 'Step 2 of 2: Secure your new company account.',
			'auth.continueText' => 'Continue',
			'auth.termsOfService' => 'I agree to the Terms of Service and Privacy Policy',
			'auth.termsError' => 'You must accept the terms to continue',
			'auth.emailRequired' => 'Email is required',
			'auth.emailInvalid' => 'Please enter a valid email address',
			'auth.passwordRequired' => 'Password is required',
			'auth.passwordLengthError' => 'Password must be at least 6 characters',
			'auth.confirmPasswordRequired' => 'Confirm password is required',
			'auth.passwordsDoNotMatch' => 'Passwords do not match',
			'auth.nameRequired' => 'Name is required',
			'auth.phoneRequired' => 'Phone number is required',
			'auth.phoneInvalid' => 'Please enter a valid phone number',
			'auth.email' => 'Email',
			'auth.phone' => 'Phone',
			'auth.logout' => 'Log out',
			_ => null,
		};
	}
}
