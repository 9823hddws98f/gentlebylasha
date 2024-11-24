part of 'iap_cubit.dart';

@immutable
class IAPState {
  final List<PurchaseDetails> purchases;
  final List<PurchasableProduct> products;
  final String? errorMessage;

  bool get loaded => products.isNotEmpty;

  const IAPState({
    this.purchases = const [],
    this.products = const [],
    this.errorMessage,
  });

  IAPState copyWith({
    List<PurchaseDetails>? purchases,
    List<PurchasableProduct>? products,
    String? errorMessage,
  }) {
    return IAPState(
      purchases: purchases ?? this.purchases,
      products: products ?? this.products,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
