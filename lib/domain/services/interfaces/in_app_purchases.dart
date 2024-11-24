import 'package:in_app_purchase/in_app_purchase.dart';

abstract class InAppPurchases {
  Stream<List<PurchaseDetails>> get purchaseStream;
  Future<bool> isAvailable();
  Future<ProductDetailsResponse> queryProductDetails(Set<String> identifiers);
  Future<bool> buyNonConsumable(PurchaseParam purchaseParam);
  Future<void> completePurchase(PurchaseDetails purchaseDetails);
}
