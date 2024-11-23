part of 'subscription_cubit.dart';

@immutable
class SubscriptionState {
  final List<PurchaseDetails> purchases;
  final List<PurchasableProduct> products;
  final String? errorMessage;

  bool get loaded => products.isNotEmpty;

  const SubscriptionState({
    this.purchases = const [],
    this.products = const [],
    this.errorMessage,
  });

  SubscriptionState copyWith({
    List<PurchaseDetails>? purchases,
    List<PurchasableProduct>? products,
    String? errorMessage,
  }) {
    return SubscriptionState(
      purchases: purchases ?? this.purchases,
      products: products ?? this.products,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

final class SubscriptionInitial extends SubscriptionState {
  const SubscriptionInitial() : super();
}
