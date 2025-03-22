import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:clean_provider_architecture/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('App Flow Integration Test', () {
    testWidgets('Clock In/Out flow and navigation to Summary Screen', (tester) async {
      // Start the app.
      app.main();
      await tester.pumpAndSettle();

      // Verify that MainScreen loads with the Clock In and Clock Out buttons.
      expect(find.text('Clock In'), findsOneWidget);
      expect(find.text('Clock Out'), findsOneWidget);

      // Tap the Clock In button.
      final clockInButton = find.widgetWithText(ElevatedButton, 'Clock In');
      await tester.tap(clockInButton);
      await tester.pumpAndSettle();

      // Simulate waiting time for tracking (this may vary based on your implementation).
      await tester.pump(const Duration(seconds: 2));

      // Tap the Clock Out button.
      final clockOutButton = find.widgetWithText(ElevatedButton, 'Clock Out');
      await tester.tap(clockOutButton);
      await tester.pumpAndSettle();

      // Tap the Summary Screen icon.
      final summaryIcon = find.byIcon(Icons.summarize);
      await tester.tap(summaryIcon);
      await tester.pumpAndSettle();

      // Verify the Summary Screen is shown.
      expect(find.text('Daily Summaries'), findsOneWidget);
    });
  });
}
