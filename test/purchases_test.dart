import 'package:flutter_test/flutter_test.dart';
import 'package:gentle/domain/cubits/in_app_purchases/iap_service.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

PurchaseDetails _details({
  required String source,
  String? purchaseId,
  String local = '',
  String server = '',
  PurchaseStatus status = PurchaseStatus.restored,
}) =>
    PurchaseDetails(
      purchaseID: purchaseId,
      productID: 'gentle_premium_yearly',
      verificationData: PurchaseVerificationData(
        localVerificationData: local,
        serverVerificationData: server,
        source: source,
      ),
      transactionDate: null,
      status: status,
    );

void main() {
  group('StorePurchase.from', () {
    test('Google: the purchase token', () {
      final p = StorePurchase.from(_details(source: 'google_play', server: 'token-1'))!;
      expect(p.platform, 'android');
      expect(p.purchaseId, 'token-1');
      expect(p.subscriptionKey, 'android:token-1');
    });

    test('StoreKit 2: renewals of one subscription share the original transaction id', () {
      final first = StorePurchase.from(_details(
        source: 'app_store',
        purchaseId: '2000000002',
        local: '{"transactionId":"2000000002","originalTransactionId":"2000000001"}',
      ))!;
      final renewal = StorePurchase.from(_details(
        source: 'app_store',
        purchaseId: '2000000003',
        local: '{"transactionId":"2000000003","originalTransactionId":"2000000001"}',
      ))!;
      expect(first.platform, 'ios');
      expect(first.purchaseId, '2000000001');
      expect(first.subscriptionKey, renewal.subscriptionKey);
    });

    test('App Store without readable JSON falls back to the transaction id', () {
      final p = StorePurchase.from(_details(source: 'app_store', purchaseId: '42', local: 'x'))!;
      expect(p.purchaseId, '42');
    });

    test('no id at all', () {
      expect(StorePurchase.from(_details(source: 'app_store')), isNull);
      expect(StorePurchase.from(_details(source: 'google_play')), isNull);
    });
  });

  test('originalTransactionIdFromJson accepts numbers', () {
    expect(StorePurchase.originalTransactionIdFromJson('{"originalTransactionId":123}'), '123');
    expect(StorePurchase.originalTransactionIdFromJson('{}'), isNull);
  });

  test('alreadySubscribedSource', () {
    expect(PurchasesApi.alreadySubscribedSource('already-subscribed:apple'), 'apple');
    expect(PurchasesApi.alreadySubscribedSource('already-subscribed:stripe'), 'stripe');
    expect(PurchasesApi.alreadySubscribedSource('Stripe prices are not configured.'), isNull);
    expect(PurchasesApi.alreadySubscribedSource(null), isNull);
  });
}
