import 'package:cloud_functions/cloud_functions.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class SubscriptionService {
  static final SubscriptionService instance = SubscriptionService._();

  SubscriptionService._();

  Future<HttpsCallableResult> verifyPurchase(PurchaseDetails purchaseDetail) =>
      throw UnimplementedError();

  Future<void> completePurchase(PurchaseDetails purchaseDetails) {
    // final purchaseId = Platform.isAndroid
    //     ? purchaseDetails.purchaseID?.split('.')[1]
    //     : purchaseDetails.purchaseID;
    throw UnimplementedError();
  }
}
