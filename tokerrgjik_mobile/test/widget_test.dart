// Tokerrgjik Mobile App Tests

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tokerrgjik_mobile/main.dart';

void main() {
  testWidgets('App starts and shows home screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the app title appears
    expect(find.text('Tokerrgjik'), findsWidgets);
    
    // Verify that at least one game mode button exists
    expect(find.byType(ElevatedButton), findsWidgets);
  });
}
