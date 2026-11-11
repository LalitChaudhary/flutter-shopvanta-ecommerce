import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/catalog.dart';
import '../domain/pricing.dart';

class ShopState extends Equatable {
  const ShopState({
    this.signedIn = false,
    this.lines = const [],
    this.wishlist = const [],
    this.coupon = '',
    this.couponMessage = '',
    this.orderId,
    this.error,
    this.query = '',
    this.category,
  });

  final bool signedIn;
  final List<CartLine> lines;
  final List<String> wishlist;
  final String coupon;
  final String couponMessage;
  final String? orderId;
  final String? error;
  final String query;
  final String? category;

  PriceQuote get quote => const CheckoutRules().quote(lines, coupon);

  List<Product> get visible => catalog.where((product) {
        final matchesCategory =
            category == null || product.category == category;
        final q = query.trim().toLowerCase();
        final matchesQuery =
            q.isEmpty || product.name.toLowerCase().contains(q);
        return matchesCategory && matchesQuery;
      }).toList();

  ShopState copyWith({
    bool? signedIn,
    List<CartLine>? lines,
    List<String>? wishlist,
    String? coupon,
    String? couponMessage,
    String? orderId,
    String? error,
    bool clearError = false,
    String? query,
    String? category,
    bool clearCategory = false,
  }) {
    return ShopState(
      signedIn: signedIn ?? this.signedIn,
      lines: lines ?? this.lines,
      wishlist: wishlist ?? this.wishlist,
      coupon: coupon ?? this.coupon,
      couponMessage: couponMessage ?? this.couponMessage,
      orderId: orderId ?? this.orderId,
      error: clearError ? null : (error ?? this.error),
      query: query ?? this.query,
      category: clearCategory ? null : (category ?? this.category),
    );
  }

  @override
  List<Object?> get props => [
        signedIn,
        lines,
        wishlist,
        coupon,
        couponMessage,
        orderId,
        error,
        query,
        category
      ];
}

abstract class ShopEvent extends Equatable {
  const ShopEvent();
  @override
  List<Object?> get props => [];
}

class SignInDemo extends ShopEvent {
  const SignInDemo(this.email, this.password);
  final String email;
  final String password;
  @override
  List<Object?> get props => [email, password];
}

class SearchChanged extends ShopEvent {
  const SearchChanged(this.query);
  final String query;
  @override
  List<Object?> get props => [query];
}

class CategorySelected extends ShopEvent {
  const CategorySelected(this.category);
  final String? category;
  @override
  List<Object?> get props => [category];
}

class AddToCart extends ShopEvent {
  const AddToCart(this.product, this.color, this.size);
  final Product product;
  final String color;
  final String size;
  @override
  List<Object?> get props => [product.id, color, size];
}

class ChangeQty extends ShopEvent {
  const ChangeQty(this.productId, this.qty);
  final String productId;
  final int qty;
  @override
  List<Object?> get props => [productId, qty];
}

class ToggleWishlist extends ShopEvent {
  const ToggleWishlist(this.productId);
  final String productId;
  @override
  List<Object?> get props => [productId];
}

class ApplyCoupon extends ShopEvent {
  const ApplyCoupon(this.code);
  final String code;
  @override
  List<Object?> get props => [code];
}

class PlaceSandboxOrder extends ShopEvent {
  const PlaceSandboxOrder();
}

class ShopBloc extends Bloc<ShopEvent, ShopState> {
  ShopBloc() : super(const ShopState()) {
    on<SignInDemo>(_signIn);
    on<SearchChanged>(
        (event, emit) => emit(state.copyWith(query: event.query)));
    on<CategorySelected>((event, emit) {
      emit(state.copyWith(
          category: event.category, clearCategory: event.category == null));
    });
    on<AddToCart>(_add);
    on<ChangeQty>(_qty);
    on<ToggleWishlist>(_wish);
    on<ApplyCoupon>(_coupon);
    on<PlaceSandboxOrder>(_order);
  }

  void _signIn(SignInDemo event, Emitter<ShopState> emit) {
    final ok = event.email.trim() == 'nola@shopvanta.dev' &&
        event.password == 'demo1234';
    if (!ok) {
      emit(state.copyWith(
          error: 'Use the demo account printed on the sign-in screen.'));
      return;
    }
    emit(state.copyWith(signedIn: true, clearError: true));
  }

  void _add(AddToCart event, Emitter<ShopState> emit) {
    final existing = state.lines.where(
      (line) =>
          line.product.id == event.product.id &&
          line.color == event.color &&
          line.size == event.size,
    );
    if (existing.isEmpty) {
      emit(state.copyWith(lines: [
        ...state.lines,
        CartLine(
            product: event.product,
            qty: 1,
            color: event.color,
            size: event.size),
      ]));
      return;
    }
    final updated = [
      for (final line in state.lines)
        if (line.product.id == event.product.id &&
            line.color == event.color &&
            line.size == event.size)
          line.copyWith(qty: line.qty + 1)
        else
          line,
    ];
    final problem = const CheckoutRules().validateQty(
        updated.firstWhere((line) => line.product.id == event.product.id).qty);
    if (problem != null) {
      emit(state.copyWith(error: problem));
      return;
    }
    emit(state.copyWith(lines: updated, clearError: true));
  }

  void _qty(ChangeQty event, Emitter<ShopState> emit) {
    final problem = const CheckoutRules().validateQty(event.qty);
    if (problem != null) {
      emit(state.copyWith(error: problem));
      return;
    }
    emit(state.copyWith(
      lines: [
        for (final line in state.lines)
          if (line.product.id == event.productId)
            line.copyWith(qty: event.qty)
          else
            line,
      ],
      clearError: true,
    ));
  }

  void _wish(ToggleWishlist event, Emitter<ShopState> emit) {
    final ids = [...state.wishlist];
    if (ids.contains(event.productId)) {
      ids.remove(event.productId);
    } else {
      ids.add(event.productId);
    }
    emit(state.copyWith(wishlist: ids));
  }

  void _coupon(ApplyCoupon event, Emitter<ShopState> emit) {
    final next = state.copyWith(coupon: event.code);
    emit(next.copyWith(couponMessage: next.quote.couponMessage));
  }

  void _order(PlaceSandboxOrder event, Emitter<ShopState> emit) {
    if (state.lines.isEmpty) {
      emit(state.copyWith(error: 'Your bag is empty.'));
      return;
    }
    emit(state.copyWith(
      orderId: 'SV${DateTime.now().millisecondsSinceEpoch}',
      lines: const [],
      clearError: true,
      couponMessage: 'Sandbox order recorded. No card was charged.',
    ));
  }
}
