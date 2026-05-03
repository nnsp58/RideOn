import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:rideon/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<void> forcedDelay(WidgetTester tester, {int seconds = 2}) async {
    await Future.delayed(Duration(seconds: seconds));
    await tester.pumpAndSettle();
  }

  group('Driver Automated Flow', () {
    testWidgets('Publish Ride and Manage Passengers', (WidgetTester tester) async {
      app.main();
      await forcedDelay(tester, seconds: 5);

      debugPrint('Driver Bot: Checking for Login...');
      final loginBtn = find.byKey(const Key('welcome_login_button'));
      if (loginBtn.evaluate().isNotEmpty) {
        await tester.tap(loginBtn);
        await forcedDelay(tester);
        await tester.enterText(find.byType(TextFormField).first, '8800000001'); 
        await forcedDelay(tester);
        await tester.tap(find.byKey(const Key('login_button')));
        await forcedDelay(tester, seconds: 5);
      }

      // 1. Go to Publish Ride
      debugPrint('Driver Bot: Publishing Ride...');
      final publishTab = find.byIcon(Icons.add_circle_outline);
      if (publishTab.evaluate().isNotEmpty) {
        await tester.tap(publishTab);
        await forcedDelay(tester);

        // Fill "From" Location and Select Suggestion
        await tester.enterText(find.byType(TextField).at(0), 'Delhi');
        await forcedDelay(tester, seconds: 3); // Wait for suggestions
        final suggestionFrom = find.byType(ListTile).first;
        if (suggestionFrom.evaluate().isNotEmpty) {
          await tester.tap(suggestionFrom);
          await forcedDelay(tester);
        }

        // Fill "To" Location and Select Suggestion
        await tester.enterText(find.byType(TextField).at(1), 'Jaipur');
        await forcedDelay(tester, seconds: 3); // Wait for suggestions
        final suggestionTo = find.byType(ListTile).first;
        if (suggestionTo.evaluate().isNotEmpty) {
          await tester.tap(suggestionTo);
          await forcedDelay(tester);
        }
        
        // Find Best Routes
        final findRoutesBtn = find.text('Find Best Routes');
        if (findRoutesBtn.evaluate().isNotEmpty) {
          await tester.tap(findRoutesBtn);
          await forcedDelay(tester, seconds: 5);
        }

        await tester.tap(find.text('Next'));
        await forcedDelay(tester);
        
        // Set Seats and Price
        await tester.tap(find.byIcon(Icons.add).first); 
        await forcedDelay(tester);
        
        await tester.tap(find.text('Next'));
        await forcedDelay(tester);

        final publishFinal = find.text('Publish Ride');
        await tester.tap(publishFinal);
        await forcedDelay(tester, seconds: 5);
      }

      debugPrint('Driver Bot: Ride Published! Waiting for passengers...');
      final myRidesTab = find.byIcon(Icons.directions_car);
      await tester.tap(myRidesTab);
      await forcedDelay(tester, seconds: 10); // Wait for passenger to book

      debugPrint('Driver Bot: Checking for messages...');
      final inboxTab = find.byIcon(Icons.chat_bubble_outline);
      await tester.tap(inboxTab);
      await forcedDelay(tester, seconds: 3);

      debugPrint('Driver Bot: SUCCESS.');
      await forcedDelay(tester, seconds: 10000);
    });
  });
}
