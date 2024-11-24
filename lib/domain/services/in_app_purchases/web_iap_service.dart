import 'package:in_app_purchase/in_app_purchase.dart';

import '/domain/services/interfaces/in_app_purchases.dart';

class WebIapService implements InAppPurchases {
  WebIapService._();

  static final WebIapService instance = WebIapService._();

  // TODO: Implement Stripe IAP

  @override
  Stream<List<PurchaseDetails>> get purchaseStream => Stream.empty();

  @override
  Future<bool> isAvailable() => Future.value(false);

  @override
  Future<ProductDetailsResponse> queryProductDetails(Set<String> identifiers) =>
      Future.value(ProductDetailsResponse(
        productDetails: [],
        notFoundIDs: identifiers.toList(),
      ));

  @override
  Future<bool> buyNonConsumable(PurchaseParam purchaseParam) => Future.value(false);

  @override
  Future<void> completePurchase(PurchaseDetails purchaseDetails) => Future.value();
}
