import 'package:in_app_purchase/in_app_purchase.dart';

import '/domain/services/interfaces/in_app_purchases.dart';

class MobileIapService implements InAppPurchases {
  MobileIapService._();

  static final MobileIapService instance = MobileIapService._();

  final _inAppPurchase = InAppPurchase.instance;

  @override
  Stream<List<PurchaseDetails>> get purchaseStream => _inAppPurchase.purchaseStream;

  @override
  Future<bool> isAvailable() => _inAppPurchase.isAvailable();

  @override
  Future<ProductDetailsResponse> queryProductDetails(Set<String> identifiers) =>
      _inAppPurchase.queryProductDetails(identifiers);

  @override
  Future<bool> buyNonConsumable(PurchaseParam purchaseParam) =>
      _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);

  @override
  Future<void> completePurchase(PurchaseDetails purchaseDetails) =>
      _inAppPurchase.completePurchase(purchaseDetails);
}
