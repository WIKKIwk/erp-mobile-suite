import 'package:flutter_test/flutter_test.dart';
import 'package:erpnext_stock_mobile/src/app/app.dart';

void main() {
  testWidgets('login screen renders code and secret fields',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ErpnextStockMobileApp());

    expect(find.text('Code'), findsOneWidget);
    expect(find.text('Secret'), findsOneWidget);
  });
}
