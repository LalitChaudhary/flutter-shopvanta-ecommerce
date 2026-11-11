import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/shop_bloc.dart';
import 'data/catalog.dart';
import 'domain/pricing.dart';

void main() {
  runApp(const ShopVantaApp());
}

class ShopVantaApp extends StatelessWidget {
  const ShopVantaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ShopBloc(),
      child: MaterialApp(
        title: 'ShopVanta',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFE07A5F),
            primary: const Color(0xFF2B2B2B),
            secondary: const Color(0xFFE07A5F),
            background: const Color(0xFFF7F1E8),
          ),
        ),
        home: const ShopGate(),
      ),
    );
  }
}

class ShopGate extends StatelessWidget {
  const ShopGate({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ShopBloc, ShopState>(
      builder: (context, state) {
        if (!state.signedIn) return const SignInPage();
        return const ShopHome();
      },
    );
  }
}

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _email = TextEditingController(text: 'nola@shopvanta.dev');
  final _password = TextEditingController(text: 'demo1234');

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final error = context.watch<ShopBloc>().state.error;
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 48),
            Text('ShopVanta',
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            const Text(
                'Editorial shop demo. Checkout is a sandbox and stores no card data.'),
            const SizedBox(height: 24),
            TextField(
                controller: _email,
                decoration: const InputDecoration(labelText: 'Email')),
            const SizedBox(height: 12),
            TextField(
              controller: _password,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            if (error != null) ...[
              const SizedBox(height: 12),
              Text(error,
                  style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ],
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => context
                  .read<ShopBloc>()
                  .add(SignInDemo(_email.text, _password.text)),
              child: const Text('Enter the shop'),
            ),
          ],
        ),
      ),
    );
  }
}

class ShopHome extends StatefulWidget {
  const ShopHome({super.key});

  @override
  State<ShopHome> createState() => _ShopHomeState();
}

class _ShopHomeState extends State<ShopHome> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    const pages = [CatalogPage(), CartPage(), WishlistPage()];
    return Scaffold(
      body: pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.storefront_outlined), label: 'Shop'),
          NavigationDestination(
              icon: Icon(Icons.shopping_bag_outlined), label: 'Bag'),
          NavigationDestination(
              icon: Icon(Icons.favorite_border), label: 'Saved'),
        ],
      ),
    );
  }
}

class CatalogPage extends StatelessWidget {
  const CatalogPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ShopBloc, ShopState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: const Text('This week')),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  decoration: const InputDecoration(labelText: 'Search'),
                  onChanged: (value) =>
                      context.read<ShopBloc>().add(SearchChanged(value)),
                ),
              ),
              Expanded(
                child: state.visible.isEmpty
                    ? const Center(child: Text('No pieces match that search.'))
                    : ListView.builder(
                        itemCount: state.visible.length,
                        itemBuilder: (context, index) {
                          final product = state.visible[index];
                          return ListTile(
                            title: Text(product.name),
                            subtitle: Text(
                                '${product.category} · ${money(product.priceMinor)}'),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => BlocProvider.value(
                                  value: context.read<ShopBloc>(),
                                  child: ProductPage(product: product),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class ProductPage extends StatelessWidget {
  const ProductPage({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(product.name)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(money(product.priceMinor),
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text('Color ${product.colors.first} · size ${product.sizes.first}'),
            const SizedBox(height: 16),
            const Text(
                'Sample product copy. Inventory and prices are fictional.'),
            const Spacer(),
            FilledButton(
              onPressed: () {
                context.read<ShopBloc>().add(
                      AddToCart(
                          product, product.colors.first, product.sizes.first),
                    );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Added to the demo bag.')),
                );
              },
              child: const Text('Add to bag'),
            ),
            TextButton(
              onPressed: () =>
                  context.read<ShopBloc>().add(ToggleWishlist(product.id)),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final _coupon = TextEditingController();

  @override
  void dispose() {
    _coupon.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ShopBloc, ShopState>(
      builder: (context, state) {
        final quote = state.quote;
        return Scaffold(
          appBar: AppBar(title: const Text('Bag')),
          body: state.lines.isEmpty
              ? Center(
                  child: Text(state.orderId == null
                      ? 'Your bag is empty.'
                      : 'Order ${state.orderId} recorded.'))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    for (final line in state.lines)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(line.product.name),
                        subtitle: Text(
                            '${line.color} / ${line.size} · qty ${line.qty}'),
                        trailing: Text(money(line.lineMinor)),
                      ),
                    TextField(
                      controller: _coupon,
                      decoration:
                          const InputDecoration(labelText: 'Coupon (CORAL10)'),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton(
                      onPressed: () => context
                          .read<ShopBloc>()
                          .add(ApplyCoupon(_coupon.text)),
                      child: const Text('Apply'),
                    ),
                    const SizedBox(height: 12),
                    Text('Subtotal ${money(quote.subtotalMinor)}'),
                    Text('Discount ${money(quote.discountMinor)}'),
                    Text('Tax ${money(quote.taxMinor)}'),
                    Text('Total ${money(quote.totalMinor)}'),
                    Text(state.couponMessage),
                    if (state.error != null) Text(state.error!),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () => context
                          .read<ShopBloc>()
                          .add(const PlaceSandboxOrder()),
                      child: const Text('Place sandbox order'),
                    ),
                  ],
                ),
        );
      },
    );
  }
}

class WishlistPage extends StatelessWidget {
  const WishlistPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ShopBloc, ShopState>(
      builder: (context, state) {
        final saved = catalog
            .where((product) => state.wishlist.contains(product.id))
            .toList();
        return Scaffold(
          appBar: AppBar(title: const Text('Saved')),
          body: saved.isEmpty
              ? const Center(child: Text('Nothing saved yet.'))
              : ListView(
                  children: [
                    for (final product in saved)
                      ListTile(title: Text(product.name)),
                  ],
                ),
        );
      },
    );
  }
}
