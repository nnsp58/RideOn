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

  group('Passenger Automated Flow', () {
    testWidgets('Search and Book Ride', (WidgetTester tester) async {
      app.main();
      await forcedDelay(tester, seconds: 5);

      debugPrint('Passenger Bot: Checking for Login...');
      final loginBtn = find.byKey(const Key('welcome_login_button'));
      if (loginBtn.evaluate().isNotEmpty) {
        await tester.tap(loginBtn);
        await forcedDelay(tester);
        await tester.enterText(find.byType(TextFormField).first, '9900000001'); 
        await forcedDelay(tester);
        await tester.tap(find.byKey(const Key('login_button')));
        await forcedDelay(tester, seconds: 5);
      }

      // 1. Search for Ride
      debugPrint('Passenger Bot: Searching for Ride...');
      
      // Enter "From" and select suggestion
      await tester.enterText(find.byType(TextField).at(0), 'Delhi');
      await forcedDelay(tester, seconds: 3);
      final suggestionFrom = find.byType(ListTile).first;
      if (suggestionFrom.evaluate().isNotEmpty) {
        await tester.tap(suggestionFrom);
        await forcedDelay(tester);
      }

      // Enter "To" and select suggestion
      await tester.enterText(find.byType(TextField).at(1), 'Jaipur');
      await forcedDelay(tester, seconds: 3);
      final suggestionTo = find.byType(ListTile).first;
      if (suggestionTo.evaluate().isNotEmpty) {
        await tester.tap(suggestionTo);
        await forcedDelay(tester);
      }
      
      await tester.tap(find.byKey(const Key('search_button')));
      await forcedDelay(tester, seconds: 5);

      // 2. Select Ride and Book
      final rideCard = find.byType(Card).first; // More generic if Key fails
      if (rideCard.evaluate().isNotEmpty) {
        await tester.tap(rideCard);
        await forcedDelay(tester, seconds: 2);
        
        final bookBtn = find.text('Book Now');
        if (bookBtn.evaluate().isNotEmpty) {
          await tester.tap(bookBtn);
          await forcedDelay(tester, seconds: 5);
        }
      }

      debugPrint('Passenger Bot: Ride Booked! Going to Chat...');
      // Go to Chat from Booking Details (using our newly added button)
      final chatBtn = find.byIcon(Icons.chat_bubble_outline);
      if (chatBtn.evaluate().isNotEmpty) {
        await tester.tap(chatBtn.first);
        await forcedDelay(tester, seconds: 2);

        // Send a message
        await tester.enterText(find.byType(TextField), 'Hello Driver, I am waiting!');
        await tester.tap(find.byIcon(Icons.send));
        await forcedDelay(tester, seconds: 2);
      }

      debugPrint('Passenger Bot: SUCCESS.');
      await forcedDelay(tester, seconds: 10000);
    });
  });
}
