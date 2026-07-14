// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'locale_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(LocaleController)
final localeControllerProvider = LocaleControllerProvider._();

final class LocaleControllerProvider
    extends $NotifierProvider<LocaleController, AppLocaleMode> {
  LocaleControllerProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'localeControllerProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$localeControllerHash();

  @$internal
  @override
  LocaleController create() => LocaleController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppLocaleMode value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppLocaleMode>(value),
    );
  }
}

String _$localeControllerHash() => r'45b501a2a94d823efc6454f2bb912efb819bf021';

abstract class _$LocaleController extends $Notifier<AppLocaleMode> {
  AppLocaleMode build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AppLocaleMode, AppLocaleMode>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AppLocaleMode, AppLocaleMode>,
        AppLocaleMode,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}
