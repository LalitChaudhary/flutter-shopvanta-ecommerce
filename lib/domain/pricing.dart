class Product {
  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.priceMinor,
    required this.colors,
    required this.sizes,
  });

  final String id;
  final String name;
  final String category;
  final int priceMinor;
  final List<String> colors;
  final List<String> sizes;
}

class CartLine {
  const CartLine({
    required this.product,
    required this.qty,
    required this.color,
    required this.size,
  });

  final Product product;
  final int qty;
  final String color;
  final String size;

  int get lineMinor => product.priceMinor * qty;

  CartLine copyWith({int? qty}) => CartLine(
        product: product,
        qty: qty ?? this.qty,
        color: color,
        size: size,
      );
}

class PriceQuote {
  const PriceQuote({
    required this.subtotalMinor,
    required this.discountMinor,
    required this.taxMinor,
    required this.totalMinor,
    required this.couponMessage,
  });

  final int subtotalMinor;
  final int discountMinor;
  final int taxMinor;
  final int totalMinor;
  final String couponMessage;
}

class CheckoutRules {
  const CheckoutRules();

  static const taxBps = 800;

  PriceQuote quote(List<CartLine> lines, String coupon) {
    final subtotal = lines.fold<int>(0, (sum, line) => sum + line.lineMinor);
    var discount = 0;
    var message = 'No coupon applied.';
    final code = coupon.trim().toUpperCase();
    if (code.isEmpty) {
      message = 'Enter a code or continue without one.';
    } else if (code == 'CORAL10' && subtotal > 0) {
      discount = (subtotal * 10) ~/ 100;
      message = 'CORAL10 applied: 10% off merchandise.';
    } else if (code == 'FREESHIP') {
      message = 'FREESHIP noted. This demo has no separate shipping charge.';
    } else {
      message = 'Unknown code. Totals are unchanged.';
    }
    final taxable = subtotal - discount;
    final tax = (taxable * taxBps) ~/ 10000;
    return PriceQuote(
      subtotalMinor: subtotal,
      discountMinor: discount,
      taxMinor: tax,
      totalMinor: taxable + tax,
      couponMessage: message,
    );
  }

  String? validateQty(int qty) {
    if (qty < 1) return 'Quantity must be at least 1.';
    if (qty > 8) return 'Demo limit is 8 of one variant.';
    return null;
  }
}

String money(int minor) => '\$${(minor / 100).toStringAsFixed(2)}';
