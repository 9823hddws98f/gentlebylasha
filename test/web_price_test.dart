import 'package:flutter_test/flutter_test.dart';
import 'package:gentle/domain/cubits/in_app_purchases/iap_service.dart';

void main() {
  group('PurchasesApi.formatPrice', () {
    test('formats cents in the app language', () {
      expect(PurchasesApi.formatPrice(499, 'eur', 'nl'), contains('4,99'));
      expect(PurchasesApi.formatPrice(4999, 'eur', 'en'), contains('49.99'));
      expect(PurchasesApi.formatPrice(499, 'eur', 'nl'), contains('€'));
    });
    test('respects currencies without cents', () {
      expect(PurchasesApi.formatPrice(500, 'jpy', 'en'), contains('500'));
    });
  });
}
