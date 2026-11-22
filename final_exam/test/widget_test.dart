import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:final_exam/main.dart';
import 'package:final_exam/providers/supabase_provider.dart';
import 'package:final_exam/services/supabase_service.dart';

void main() {
  testWidgets('Unauthenticated user is gated to Sign In screen', (tester) async {
    tester.view.physicalSize = const Size(1200, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final mockService = SupabaseService(forceLocal: true);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          supabaseServiceProvider.overrideWithValue(mockService),
        ],
        child: const FinalExamEcommerceApp(),
      ),
    );

    await tester.pumpAndSettle();

    // Verify Auth Gate presents Sign In
    expect(find.text("PAIMON'S BARGAINS"), findsWidgets);
    expect(find.text('Sign In'), findsWidgets);
    expect(find.text('Create Account'), findsWidgets);
    expect(find.text('Continue with Google'), findsOneWidget);
  });

  testWidgets('Authenticated customer views Product Catalog without Admin FAB', (tester) async {
    tester.view.physicalSize = const Size(1200, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final mockService = SupabaseService(forceLocal: true);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          supabaseServiceProvider.overrideWithValue(mockService),
        ],
        child: const FinalExamEcommerceApp(),
      ),
    );

    await tester.pumpAndSettle();

    // Tap quick switch to Customer
    final customerBtn = find.text('Customer');
    await tester.ensureVisible(customerBtn);
    await tester.tap(customerBtn);
    await tester.pumpAndSettle();

    // Verify Home screen shows customer role and no admin add product FAB
    expect(find.text('CUSTOMER'), findsOneWidget);
    expect(find.text('Price Range Filter'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsNothing);
  });

  testWidgets('Authenticated admin views Add Product Floating Action Button', (tester) async {
    tester.view.physicalSize = const Size(1200, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final mockService = SupabaseService(forceLocal: true);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          supabaseServiceProvider.overrideWithValue(mockService),
        ],
        child: const FinalExamEcommerceApp(),
      ),
    );

    await tester.pumpAndSettle();

    // Tap quick switch to Admin
    final adminBtn = find.text('Admin');
    await tester.ensureVisible(adminBtn);
    await tester.tap(adminBtn);
    await tester.pumpAndSettle();

    // Verify Admin view shows ADMIN badge and Add Product FAB
    expect(find.text('ADMIN'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
    expect(find.text('Add Product'), findsOneWidget);
  });
}
