import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/utils/extensions/context_extension.dart';
import 'config/theme/theme.dart';
import 'config/theme/theme_provider.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeControllerProvider);
    return MaterialApp(
      title: 'BDATA Core Template',
      themeMode: themeMode,
      theme: lightThemeData,
      darkTheme: darkThemeData,
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        return MediaQuery(
          data: mediaQuery.copyWith(
            textScaler: const TextScaler.linear(1.0),
          ),
          child: SafeArea(
            top: false,
            bottom: Platform.isAndroid ? true : false,
            child: GestureDetector(
              onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
              child: child ?? const SizedBox(),
            ),
          ),
        );
      },
      home: const DummyHomeScreen(),
    );
  }
}

class DummyHomeScreen extends ConsumerWidget {
  const DummyHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      // context.colors (Custom extension)
      backgroundColor: context.colors.customBackground,
      appBar: AppBar(title: const Text('Theme Architecture')),
      body: Center(
        child: ElevatedButton(
          // context.colorScheme (Material default)
          style: ElevatedButton.styleFrom(
            backgroundColor: context.colorScheme.primary,
          ),
          onPressed: () {
            ref.read(themeControllerProvider.notifier).toggleTheme();
          },
          child: Text(
            'Toggle Theme',
            style: TextStyle(color: context.colorScheme.onPrimary),
          ),
        ),
      ),
    );
  }
}
