import 'package:flutter_test/flutter_test.dart';
import 'package:gentle/domain/cubits/in_app_purchases/play_plans.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/billing_client_wrappers.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';

const _monthly = 'gentle_premium_monthly';
const _yearly = 'gentle_premium_yearly';
const _plans = [_monthly, _yearly];

PricingPhaseWrapper _phase(String price, int micros) => PricingPhaseWrapper(
      billingCycleCount: 0,
      billingPeriod: 'P1M',
      formattedPrice: price,
      priceAmountMicros: micros,
      priceCurrencyCode: 'EUR',
      recurrenceMode: RecurrenceMode.infiniteRecurring,
    );

SubscriptionOfferDetailsWrapper _offer(String? offerId, List<PricingPhaseWrapper> phases) =>
    SubscriptionOfferDetailsWrapper(
      basePlanId: 'base',
      offerId: offerId,
      offerTags: const [],
      offerIdToken: 'token-${offerId ?? 'base'}',
      pricingPhases: phases,
    );

/// What Google Play returns for one subscription: one entry per offer.
List<GooglePlayProductDetails> _playProduct(
  String id,
  List<SubscriptionOfferDetailsWrapper> offers,
) =>
    GooglePlayProductDetails.fromProductDetails(ProductDetailsWrapper(
      description: '',
      name: id,
      productId: id,
      productType: ProductType.subs,
      title: id,
      subscriptionOfferDetails: offers,
    ));

GooglePlayPurchaseDetails _owned(
  String productId, {
  String? account,
  PurchaseStateWrapper state = PurchaseStateWrapper.purchased,
}) =>
    GooglePlayPurchaseDetails.fromPurchase(PurchaseWrapper(
      orderId: 'order-$productId',
      packageName: 'com.mezz.gentle',
      purchaseTime: 0,
      purchaseToken: 'purchase-$productId',
      signature: '',
      products: [productId],
      isAutoRenewing: true,
      originalJson: '{}',
      isAcknowledged: true,
      purchaseState: state,
      obfuscatedAccountId: account,
    )).single;

void main() {
  group('onePerProduct', () {
    test('keeps the base plan of a subscription with a free trial', () {
      final products = onePerProduct([
        ..._playProduct(_monthly, [
          _offer('free-trial', [_phase('Free', 0), _phase('€ 4,99', 4990000)]),
          _offer(null, [_phase('€ 4,99', 4990000)]),
        ]),
        ..._playProduct(_yearly, [
          _offer(null, [_phase('€ 39,99', 39990000)]),
          _offer('intro', [_phase('€ 19,99', 19990000), _phase('€ 39,99', 39990000)]),
        ]),
      ]);

      expect(products.map((p) => p.id), [_monthly, _yearly]);
      expect(products.map((p) => p.price), ['€ 4,99', '€ 39,99']);
      expect(products.map((p) => (p as GooglePlayProductDetails).offerToken),
          ['token-base', 'token-base']);
    });

    test('keeps the first offer when there is no plain base plan', () {
      final products = onePerProduct(_playProduct(_monthly, [
        _offer('a', [_phase('€ 3,99', 3990000)]),
        _offer('b', [_phase('€ 2,99', 2990000)]),
      ]));
      expect(products.single.price, '€ 3,99');
    });

    test('App Store products pass through', () {
      ProductDetails appStore(String id, String price) => ProductDetails(
          id: id, title: '', description: '', price: price, rawPrice: 1, currencyCode: 'EUR');
      final products = [appStore(_monthly, '€ 4,99'), appStore(_yearly, '€ 39,99')];
      expect(onePerProduct(products), products);
    });
  });

  group('playPurchasePlan', () {
    ({bool restore, GooglePlayPurchaseDetails? replace}) plan(
      List<PurchaseDetails> owned, {
      String productId = _yearly,
    }) =>
        playPurchasePlan(owned, productId: productId, planIds: _plans, accountToken: 'me');

    test('nothing owned: a plain purchase', () {
      final result = plan([]);
      expect(result.restore, isFalse);
      expect(result.replace, isNull);
    });

    test('switching plans replaces the running one of this account', () {
      final monthly = _owned(_monthly, account: 'me');
      final result = plan([monthly]);
      expect(result.restore, isFalse);
      expect(result.replace, same(monthly));
    });

    test('a plan without account id is replaced too', () {
      final monthly = _owned(_monthly);
      expect(plan([monthly]).replace, same(monthly));
    });

    test("another account's plan is left alone", () {
      expect(plan([_owned(_monthly, account: 'someone-else')]).replace, isNull);
    });

    test('pending purchases and other products are ignored', () {
      final result = plan([
        _owned(_monthly, account: 'me', state: PurchaseStateWrapper.pending),
        _owned('something_else', account: 'me'),
      ]);
      expect(result.restore, isFalse);
      expect(result.replace, isNull);
    });

    test('the same plan already owned is restored instead of bought again', () {
      final result = plan([_owned(_yearly, account: 'someone-else')]);
      expect(result.restore, isTrue);
      expect(result.replace, isNull);
    });
  });
}
