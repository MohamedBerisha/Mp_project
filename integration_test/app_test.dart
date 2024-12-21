import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;

import 'package:project4/main.dart' as app;
import 'package:project4/screens/authentication/login_screen.dart';
import 'package:project4/screens/authentication/signup_screen.dart';
import 'package:project4/screens/home_screen.dart';
import 'package:project4/screens/create_event_screen.dart';
import 'package:project4/screens/gift_list_screen.dart';
import 'package:project4/screens/pledged_gifts_screen.dart';
import 'package:project4/screens/event_list_screen.dart';

void main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  testWidgets('Signup, navigate back to Login, and login', (tester) async {
    // Launch the app and navigate to the Login screen first
    app.main();
    await tester.pumpAndSettle(); // Wait until the app is fully loaded

    // Ensure LoginScreen is rendered first
    expect(find.byType(LoginScreen), findsOneWidget);

    // Tap on the "Don't have an account? Sign up" link to go to Signup
    await tester.tap(find.byKey(Key('signupLink'))); // Tap on the link
    await tester.pumpAndSettle(); // Wait for the navigation to complete

    // Ensure SignupScreen is rendered
    expect(find.byType(SignupScreen), findsOneWidget);

    // Fill in the signup form
    await tester.enterText(find.byKey(Key('nameField')), 'Test User');
    await tester.enterText(
        find.byKey(Key('emailField')), 'testuser@example.com');
    await tester.enterText(find.byKey(Key('passwordField')), 'password123');
    await tester.enterText(
        find.byKey(Key('confirmPasswordField')), 'password123');
    await tester.enterText(find.byKey(Key('phoneField')), '1234567890');
    await tester.enterText(find.byKey(Key('addressField')), '123 Test St');

    // Select Date of Birth
    await tester.tap(find.byKey(Key('dobField')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK')); // Close the date picker
    await tester.pumpAndSettle();

    // Tap on the signup button
    await tester.tap(find.byKey(Key('signupSubmitButton'))); // Submit button
    await tester.pumpAndSettle();

    // Now tap on the "Have an account? Log In" link to go back to Login page
    await tester.tap(find.byKey(Key('loginLink'))); // The login link
    await tester.pumpAndSettle();

    // Ensure we are on the LoginScreen after clicking the link
    expect(find.byType(LoginScreen), findsOneWidget);

    // Now fill in the login form
    await tester.enterText(
        find.byKey(Key('emailField')), 'testuser@example.com');
    await tester.enterText(find.byKey(Key('passwordField')), 'password123');
    await tester.tap(find.byKey(Key('loginButton'))); // Tap on the login button
    await tester.pumpAndSettle();

    // Verify that we are on the HomeScreen after a successful login
    expect(find.byType(HomeScreen), findsOneWidget);

    // Now continue the rest of the tests (e.g., add friend, create event, etc.)

    // Test Add Friend
    await tester.tap(find.byKey(Key('addFriendButton')));
    await tester.pumpAndSettle();

    // Check if the "Add Friend" dialog shows up
    expect(find.byType(AlertDialog), findsOneWidget);

    // Add a friend
    await tester.enterText(find.byKey(Key('friendNameField')), 'Friend 1');
    await tester.enterText(find.byKey(Key('friendPhoneField')), '9876543210');
    await tester.tap(find.byKey(Key('addFriendSubmitButton')));
    await tester.pumpAndSettle();

    // Verify friend is added
    expect(find.text('Friend 1'), findsOneWidget);

    // Test Create Event
    await tester.tap(find.byKey(Key('createEventButton')));
    await tester.pumpAndSettle();

    // Fill in event details
    await tester.enterText(find.byKey(Key('eventNameField')), 'Birthday Party');
    await tester.enterText(
        find.byKey(Key('eventLocationField')), 'Party Venue');
    await tester.enterText(
        find.byKey(Key('eventDescriptionField')), 'Celebrating my birthday!');
    await tester.tap(find.byKey(Key('eventDateField')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK')); // Close the date picker

    // Tap on create event button
    await tester.tap(find.byKey(Key('createEventSubmitButton')));
    await tester.pumpAndSettle();

    // Verify event is created
    expect(find.text('Birthday Party'), findsOneWidget);

    // Test Create Gift
    await tester.tap(find.byKey(Key('createGiftButton')));
    await tester.pumpAndSettle();

    // Fill in gift details
    await tester.enterText(find.byKey(Key('giftNameField')), 'AirPods');
    await tester.enterText(find.byKey(Key('giftCategoryField')), 'Electronics');
    await tester.enterText(find.byKey(Key('giftPriceField')), '150');
    await tester.tap(find.byKey(Key('giftSubmitButton')));
    await tester.pumpAndSettle();

    // Verify gift is added
    expect(find.text('AirPods'), findsOneWidget);

    // Test Pledge Gift
    await tester.tap(find.byKey(Key('pledgeGiftButton')));
    await tester.pumpAndSettle();

    // Verify that the gift has been pledged
    expect(find.text('Gift pledged successfully!'), findsOneWidget);

    // Test View Pledged Gifts
    await tester.tap(find.byKey(Key('viewPledgedGiftsButton')));
    await tester.pumpAndSettle();

    // Verify the pledged gift list screen
    expect(find.byType(PledgedGiftsScreen), findsOneWidget);

    // Test Logout
    await tester.tap(find.byKey(Key('logoutButton')));
    await tester.pumpAndSettle();

    // Verify user is logged out and navigated to LoginScreen
    expect(find.byType(LoginScreen), findsOneWidget);
  });
}
