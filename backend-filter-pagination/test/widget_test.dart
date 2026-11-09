import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:backend_filter_pagination/main.dart';
import 'package:backend_filter_pagination/services/supabase_service.dart';
import 'package:backend_filter_pagination/state/product_provider.dart';

void main() {
  testWidgets('App renders Home Screen with store title and price slider',
      (WidgetTester tester) async {
    final service = SupabaseService();
    final provider = ProductProvider(service: service);
    await provider.initialize();

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: const MyApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text("Paimon's Bargains"), findsOneWidget);
    expect(find.text('Price Range Filter'), findsOneWidget);
  });
}
