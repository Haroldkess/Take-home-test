import 'package:clean_provider_architecture/screens/logged_in/home_tabs/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:clean_provider_architecture/providers/location_tracking_provider.dart';

void main() {
  testWidgets('MainScreen displays Clock In and Clock Out buttons', (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider<LocationTrackingProvider>(
        create: (_) => LocationTrackingProvider(),
        child: const MaterialApp(home: MainScreen()),
      ),
    );

    expect(find.text('Clock In'), findsOneWidget);
    expect(find.text('Clock Out'), findsOneWidget);
  });

  testWidgets('Clock In button is disabled when tracking is active', (tester) async {
    // Create a provider and simulate that tracking is active.
    final provider = LocationTrackingProvider();

    // For testing, we set the internal state directly.
    // Todo (In a real-world test, we might want to mock the location service)
    provider.startTracking();
    await tester.pumpWidget(
      ChangeNotifierProvider<LocationTrackingProvider>.value(
        value: provider,
        child: const MaterialApp(home: MainScreen()),
      ),
    );

    final clockInButtonFinder = find.widgetWithText(ElevatedButton, 'Clock In');
    final ElevatedButton clockInButton = tester.widget(clockInButtonFinder);
    expect(clockInButton.onPressed, isNull);
  });
}
