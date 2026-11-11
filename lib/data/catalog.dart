import '../domain/pricing.dart';

const catalog = <Product>[
  Product(
    id: 'linen-shirt',
    name: 'Ivory linen shirt',
    category: 'Apparel',
    priceMinor: 8900,
    colors: ['Ivory', 'Charcoal'],
    sizes: ['S', 'M', 'L'],
  ),
  Product(
    id: 'coral-tote',
    name: 'Coral market tote',
    category: 'Bags',
    priceMinor: 6400,
    colors: ['Coral', 'Sand'],
    sizes: ['One'],
  ),
  Product(
    id: 'stone-lamp',
    name: 'Stone desk lamp',
    category: 'Home',
    priceMinor: 12800,
    colors: ['Stone'],
    sizes: ['One'],
  ),
  Product(
    id: 'ink-notebook',
    name: 'Inkcloth notebook',
    category: 'Stationery',
    priceMinor: 2400,
    colors: ['Charcoal', 'Ivory'],
    sizes: ['A5'],
  ),
];
