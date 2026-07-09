import 'package:clean_archi_frame/app/app.dart';
import 'package:clean_archi_frame/core/storage/shared_pref_service.dart';
import 'package:clean_archi_frame/app/config/localization/generated/translations.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('App boots successfully smoke test', (WidgetTester tester) async {
    final sharedPreferences = await SharedPreferences.getInstance();
    
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(sharedPreferences),
        ],
        child: TranslationProvider(
          child: const MyApp(),
        ),
      ),
    );

    // Let the widget render
    await tester.pump();

    // Verify that the app loaded the initial route (which should show MaterialApp.router)
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
