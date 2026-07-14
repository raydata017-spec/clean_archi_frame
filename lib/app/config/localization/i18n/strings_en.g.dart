///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import
// dart format off

part of 'strings.g.dart';

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
	late final Translations$setting$en setting = Translations$setting$en._(_root);
	late final Translations$kDynamic$en kDynamic = Translations$kDynamic$en._(_root);
	late final Translations$common$en common = Translations$common$en._(_root);
	late final Translations$validation$en validation = Translations$validation$en._(_root);
	late final Translations$auth$en auth = Translations$auth$en._(_root);
	late final Translations$notification$en notification = Translations$notification$en._(_root);
	late final Translations$permission$en permission = Translations$permission$en._(_root);
}

// Path: setting
class Translations$setting$en {
	Translations$setting$en._(this._root);

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

	/// en: 'System'
	String get systemLanguage => 'System';

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

	/// en: 'Manage system notification permissions'
	String get manageSystemNotificationPermissions => 'Manage system notification permissions';

	/// en: 'Location Permission'
	String get locationSetting => 'Location Permission';

	/// en: 'Manage system location permissions'
	String get manageSystemLocationPermissions => 'Manage system location permissions';

	/// en: 'Sign out of current account'
	String get signOutOfCurrentAccount => 'Sign out of current account';

	/// en: 'Do you want to logout?'
	String get doYouWantToLogout => 'Do you want to logout?';

	/// en: 'Are you sure you want to log out?'
	String get areYouSureYouWantToLogout => 'Are you sure you want to log out?';

	/// en: 'Yes, Log out'
	String get yesLogout => 'Yes, Log out';
}

// Path: kDynamic
class Translations$kDynamic$en {
	Translations$kDynamic$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Welcome back, $name! You have $point points.'
	String welcomeMessage({required Object name, required Object point}) => 'Welcome back, ${name}! You have ${point} points.';

	/// en: 'Something went wrong'
	String get defaultErrorText => 'Something went wrong';

	/// en: '(zero) {You have no new messages.} (one) {You have 1 new message.} (other) {You have $n new messages.}'
	String inboxCount({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n,
		zero: 'You have no new messages.',
		one: 'You have 1 new message.',
		other: 'You have ${n} new messages.',
	);
}

// Path: common
class Translations$common$en {
	Translations$common$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Something went wrong'
	String get somethingWentWrong => 'Something went wrong';

	/// en: 'Retry'
	String get retry => 'Retry';

	/// en: 'Exit App'
	String get exitAppTitle => 'Exit App';

	/// en: 'Are you sure you want to exit?'
	String get exitAppConfirm => 'Are you sure you want to exit?';

	/// en: 'Exit'
	String get exit => 'Exit';

	/// en: 'Cancel'
	String get cancel => 'Cancel';

	/// en: 'No internet connection. Please check your network.'
	String get noInternet => 'No internet connection. Please check your network.';

	/// en: 'Internet connection restored.'
	String get internetRestored => 'Internet connection restored.';
}

// Path: validation
class Translations$validation$en {
	Translations$validation$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Email is required'
	String get emailRequired => 'Email is required';

	/// en: 'Please enter a valid email address'
	String get emailInvalid => 'Please enter a valid email address';

	/// en: 'Phone number is required'
	String get phoneRequired => 'Phone number is required';

	/// en: 'Please enter a valid phone number'
	String get phoneInvalid => 'Please enter a valid phone number';

	/// en: 'Phone number must start with +959'
	String get phoneStartWith => 'Phone number must start with +959';

	/// en: '+959'
	String get phoneCountryCode => '+959';

	/// en: 'Password is required'
	String get passwordRequired => 'Password is required';

	/// en: 'Password must be at least 8 characters'
	String get passwordTooShort => 'Password must be at least 8 characters';

	/// en: 'Password must contain at least one uppercase letter and one number'
	String get passwordWeakText => 'Password must contain at least one uppercase letter and one number';

	/// en: 'Passwords do not match'
	String get passwordsDoNotMatch => 'Passwords do not match';

	/// en: 'Confirm password is required'
	String get confirmPasswordRequired => 'Confirm password is required';

	/// en: 'OTP is required'
	String get otpRequired => 'OTP is required';

	/// en: 'OTP must be 6 digits'
	String get otpInvalid => 'OTP must be 6 digits';

	/// en: 'Name is required'
	String get nameRequired => 'Name is required';

	/// en: 'New password cannot be the same as old password'
	String get newPasswordSameAsOld => 'New password cannot be the same as old password';

	/// en: '$name is required'
	String fieldRequired({required Object name}) => '${name} is required';

	/// en: 'Card number is required'
	String get cardNumberRequired => 'Card number is required';

	/// en: 'Please enter a valid card number'
	String get cardNumberInvalid => 'Please enter a valid card number';

	/// en: 'CVV is required'
	String get cvvRequired => 'CVV is required';

	/// en: 'Please enter a valid CVV'
	String get cvvInvalid => 'Please enter a valid CVV';

	/// en: 'Date is required'
	String get dateRequired => 'Date is required';

	/// en: 'License plate number is required'
	String get licenseNumberRequired => 'License plate number is required';

	/// en: 'Please enter a valid license plate number'
	String get licenseNumberInvalid => 'Please enter a valid license plate number';

	/// en: 'City is required'
	String get cityRequired => 'City is required';

	/// en: 'Township is required'
	String get townshipRequired => 'Township is required';
}

// Path: auth
class Translations$auth$en {
	Translations$auth$en._(this._root);

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

	/// en: 'Enter your email or phone number to reset your password.'
	String get forgotPasswordSubtitle => 'Enter your email or phone number to reset your password.';

	/// en: 'Send Code'
	String get sendCode => 'Send Code';

	/// en: 'Enter OTP Code'
	String get enterOtpCode => 'Enter OTP Code';

	/// en: 'Enter the verification code sent to your device.'
	String get otpSubtitle => 'Enter the verification code sent to your device.';

	/// en: 'Reset Password'
	String get resetPassword => 'Reset Password';

	/// en: 'Set your new password below.'
	String get resetPasswordSubtitle => 'Set your new password below.';

	/// en: 'OTP'
	String get otp => 'OTP';
}

// Path: notification
class Translations$notification$en {
	Translations$notification$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Notifications'
	String get title => 'Notifications';

	/// en: 'Mark all read'
	String get markAllRead => 'Mark all read';

	/// en: 'Unread ($count)'
	String unread({required Object count}) => 'Unread (${count})';

	/// en: 'Total ($count)'
	String total({required Object count}) => 'Total (${count})';

	/// en: 'No notifications yet'
	String get emptyState => 'No notifications yet';

	/// en: 'All notifications marked as read'
	String get allMarkedRead => 'All notifications marked as read';

	/// en: 'Notification deleted'
	String get deleted => 'Notification deleted';

	/// en: 'Notification Actions'
	String get actionsTitle => 'Notification Actions';

	/// en: 'Mark as read'
	String get markRead => 'Mark as read';

	/// en: 'Mark as unread'
	String get markUnread => 'Mark as unread';

	/// en: 'Delete'
	String get delete => 'Delete';

	/// en: 'Undo'
	String get undo => 'Undo';

	/// en: 'Delete Notification'
	String get deleteTitle => 'Delete Notification';

	/// en: 'Are you sure you want to delete this notification?'
	String get deleteConfirm => 'Are you sure you want to delete this notification?';

	/// en: 'Cancel'
	String get cancel => 'Cancel';

	/// en: 'Delete'
	String get confirm => 'Delete';

	/// en: '${minutes}m ago'
	String minutesAgo({required Object minutes}) => '${minutes}m ago';

	/// en: '${hours}h ago'
	String hoursAgo({required Object hours}) => '${hours}h ago';

	/// en: '${days}d ago'
	String daysAgo({required Object days}) => '${days}d ago';
}

// Path: permission
class Translations$permission$en {
	Translations$permission$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Permission Required'
	String get requiredTitle => 'Permission Required';

	/// en: '$permissionName is currently disabled. Please enable it in your device settings to continue.'
	String disabledMessage({required Object permissionName}) => '${permissionName} is currently disabled. Please enable it in your device settings to continue.';

	/// en: 'Open Settings'
	String get openSettings => 'Open Settings';

	/// en: 'Cancel'
	String get cancel => 'Cancel';
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
			'setting.systemLanguage' => 'System',
			'setting.offlineSync' => 'Offline Sync',
			'setting.offlineSyncSubtitle' => 'Open offline outbox',
			'setting.notificationSetting' => 'Notification Settings',
			'setting.general' => 'General',
			'setting.notifications' => 'Notifications',
			'setting.advanced' => 'Advanced',
			'setting.manageSystemNotificationPermissions' => 'Manage system notification permissions',
			'setting.locationSetting' => 'Location Permission',
			'setting.manageSystemLocationPermissions' => 'Manage system location permissions',
			'setting.signOutOfCurrentAccount' => 'Sign out of current account',
			'setting.doYouWantToLogout' => 'Do you want to logout?',
			'setting.areYouSureYouWantToLogout' => 'Are you sure you want to log out?',
			'setting.yesLogout' => 'Yes, Log out',
			'kDynamic.welcomeMessage' => ({required Object name, required Object point}) => 'Welcome back, ${name}! You have ${point} points.',
			'kDynamic.defaultErrorText' => 'Something went wrong',
			'kDynamic.inboxCount' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n, zero: 'You have no new messages.', one: 'You have 1 new message.', other: 'You have ${n} new messages.', ), 
			'common.somethingWentWrong' => 'Something went wrong',
			'common.retry' => 'Retry',
			'common.exitAppTitle' => 'Exit App',
			'common.exitAppConfirm' => 'Are you sure you want to exit?',
			'common.exit' => 'Exit',
			'common.cancel' => 'Cancel',
			'common.noInternet' => 'No internet connection. Please check your network.',
			'common.internetRestored' => 'Internet connection restored.',
			'validation.emailRequired' => 'Email is required',
			'validation.emailInvalid' => 'Please enter a valid email address',
			'validation.phoneRequired' => 'Phone number is required',
			'validation.phoneInvalid' => 'Please enter a valid phone number',
			'validation.phoneStartWith' => 'Phone number must start with +959',
			'validation.phoneCountryCode' => '+959',
			'validation.passwordRequired' => 'Password is required',
			'validation.passwordTooShort' => 'Password must be at least 8 characters',
			'validation.passwordWeakText' => 'Password must contain at least one uppercase letter and one number',
			'validation.passwordsDoNotMatch' => 'Passwords do not match',
			'validation.confirmPasswordRequired' => 'Confirm password is required',
			'validation.otpRequired' => 'OTP is required',
			'validation.otpInvalid' => 'OTP must be 6 digits',
			'validation.nameRequired' => 'Name is required',
			'validation.newPasswordSameAsOld' => 'New password cannot be the same as old password',
			'validation.fieldRequired' => ({required Object name}) => '${name} is required',
			'validation.cardNumberRequired' => 'Card number is required',
			'validation.cardNumberInvalid' => 'Please enter a valid card number',
			'validation.cvvRequired' => 'CVV is required',
			'validation.cvvInvalid' => 'Please enter a valid CVV',
			'validation.dateRequired' => 'Date is required',
			'validation.licenseNumberRequired' => 'License plate number is required',
			'validation.licenseNumberInvalid' => 'Please enter a valid license plate number',
			'validation.cityRequired' => 'City is required',
			'validation.townshipRequired' => 'Township is required',
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
			'auth.forgotPasswordSubtitle' => 'Enter your email or phone number to reset your password.',
			'auth.sendCode' => 'Send Code',
			'auth.enterOtpCode' => 'Enter OTP Code',
			'auth.otpSubtitle' => 'Enter the verification code sent to your device.',
			'auth.resetPassword' => 'Reset Password',
			'auth.resetPasswordSubtitle' => 'Set your new password below.',
			'auth.otp' => 'OTP',
			'notification.title' => 'Notifications',
			'notification.markAllRead' => 'Mark all read',
			'notification.unread' => ({required Object count}) => 'Unread (${count})',
			'notification.total' => ({required Object count}) => 'Total (${count})',
			'notification.emptyState' => 'No notifications yet',
			'notification.allMarkedRead' => 'All notifications marked as read',
			'notification.deleted' => 'Notification deleted',
			'notification.actionsTitle' => 'Notification Actions',
			'notification.markRead' => 'Mark as read',
			'notification.markUnread' => 'Mark as unread',
			'notification.delete' => 'Delete',
			'notification.undo' => 'Undo',
			'notification.deleteTitle' => 'Delete Notification',
			'notification.deleteConfirm' => 'Are you sure you want to delete this notification?',
			'notification.cancel' => 'Cancel',
			'notification.confirm' => 'Delete',
			'notification.minutesAgo' => ({required Object minutes}) => '${minutes}m ago',
			'notification.hoursAgo' => ({required Object hours}) => '${hours}h ago',
			'notification.daysAgo' => ({required Object days}) => '${days}d ago',
			'permission.requiredTitle' => 'Permission Required',
			'permission.disabledMessage' => ({required Object permissionName}) => '${permissionName} is currently disabled. Please enable it in your device settings to continue.',
			'permission.openSettings' => 'Open Settings',
			'permission.cancel' => 'Cancel',
			_ => null,
		};
	}
}
