// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:book_search_app/screens/search_screen.dart';

void main() {
  testWidgets('Search screen smoke test', (WidgetTester tester) async {
    // Build our search screen and trigger a frame.
    await tester.pumpWidget(
      const MaterialApp(
        home: SearchScreen(),
      ),
    );

    // Verify that our search screen loads correctly
    expect(find.text('Book Search Engine'), findsOneWidget);
    expect(find.text('Search for books, authors, or topics...'), findsOneWidget);
    expect(find.text('Search Books'), findsOneWidget);
  });
}
