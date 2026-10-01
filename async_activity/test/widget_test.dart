import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:async_activity/main.dart';

void main() {
  testWidgets('shows the Pokedex loading state', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Pokedex'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
