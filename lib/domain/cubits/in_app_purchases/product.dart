import 'package:in_app_purchase/in_app_purchase.dart';

class PurchasableProduct {
  final ProductDetails productDetails;

  PurchasableProduct(this.productDetails);

  String get id => productDetails.id;
  String get title => productDetails.title;
  String get description => productDetails.description;

  /// Already formatted with currency by the store, e.g. "€ 4,99".
  String get price => productDetails.price;

  bool get isYearly => id.contains('yearly');
}
