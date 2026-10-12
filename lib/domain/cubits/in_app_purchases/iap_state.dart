part of 'iap_cubit.dart';

enum IAPError { none, purchaseFailed, verificationFailed, otherAccount }

@immutable
class IAPState {
  final List<PurchasableProduct> products;

  /// null while unknown; false on web and when the store can't be reached.
  final bool? storeAvailable;
  final bool busy;
  final IAPError error;

  bool get loaded => products.isNotEmpty;

  const IAPState({
    this.products = const [],
    this.storeAvailable,
    this.busy = false,
    this.error = IAPError.none,
  });

  IAPState copyWith({
    List<PurchasableProduct>? products,
    bool? storeAvailable,
    bool? busy,
    IAPError? error,
  }) {
    return IAPState(
      products: products ?? this.products,
      storeAvailable: storeAvailable ?? this.storeAvailable,
      busy: busy ?? this.busy,
      error: error ?? this.error,
    );
  }
}
