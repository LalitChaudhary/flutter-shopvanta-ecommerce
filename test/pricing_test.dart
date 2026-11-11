import 'package:flutter_test/flutter_test.dart';
import 'package:shopvanta/data/catalog.dart';
import 'package:shopvanta/domain/pricing.dart';

void main() {
  const rules = CheckoutRules();
  final shirt = catalog.first;

  test('CORAL10 discounts ten percent before tax', () {
    final quote = rules.quote(
      [CartLine(product: shirt, qty: 2, color: 'Ivory', size: 'M')],
      'coral10',
    );
    expect(quote.subtotalMinor, 17800);
    expect(quote.discountMinor, 1780);
    expect(quote.taxMinor, ((17800 - 1780) * 800) ~/ 10000);
    expect(quote.totalMinor,
        quote.subtotalMinor - quote.discountMinor + quote.taxMinor);
  });

  test('unknown coupon does not change merchandise', () {
    final quote = rules.quote(
      [CartLine(product: shirt, qty: 1, color: 'Ivory', size: 'S')],
      'NOPE',
    );
    expect(quote.discountMinor, 0);
    expect(quote.couponMessage, contains('Unknown'));
  });

  test('quantity guard rejects zero and nine', () {
    expect(rules.validateQty(0), isNotNull);
    expect(rules.validateQty(9), isNotNull);
    expect(rules.validateQty(2), isNull);
  });
}
