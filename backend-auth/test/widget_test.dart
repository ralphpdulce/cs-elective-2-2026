import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:backend_auth/main.dart';
import 'package:backend_auth/services/supabase_service.dart';
import 'package:backend_auth/state/auth_provider.dart';
import 'package:backend_auth/state/product_provider.dart';

void main() {
  testWidgets('App renders Home Screen with store title, price slider, and sign in',
      (WidgetTester tester) async {
    final service = SupabaseService();
    final provider = ProductProvider(service: service);
    await provider.initialize(forceLocal: true);
    final auth = AppAuthProvider(client: null);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: provider),
          ChangeNotifierProvider.value(value: auth),
        ],
        child: MyApp(authProvider: auth),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text("Paimon's Bargains"), findsOneWidget);
    expect(find.text('Price Range Filter'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
  });
}
