import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:app/app.dart';
import 'package:app/core/network/dio_client.dart';

void main() {
  testWidgets('App renders the job search screen on launch', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: const JobTailorApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Jobsuche'), findsOneWidget);
  });
}
