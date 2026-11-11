import 'package:flutter_test/flutter_test.dart';
import 'package:shopvanta/main.dart';

void main() {
  testWidgets('demo shopper can open the catalog', (tester) async {
    await tester.pumpWidget(const ShopVantaApp());
    await tester.tap(find.text('Enter the shop'));
    await tester.pumpAndSettle();
    expect(find.text('Ivory linen shirt'), findsOneWidget);
  });
}
