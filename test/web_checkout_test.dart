import 'package:flutter_test/flutter_test.dart';
import 'package:gentle/domain/services/web_checkout.dart';

void main() {
  test('reads the Stripe return parameter', () {
    expect(checkoutResultFrom(Uri.parse('https://app.test/?checkout=success#/')),
        CheckoutResult.success);
    expect(checkoutResultFrom(Uri.parse('https://app.test/?checkout=cancelled')),
        CheckoutResult.cancelled);
    expect(checkoutResultFrom(Uri.parse('https://app.test/')), isNull);
    expect(checkoutResultFrom(Uri.parse('https://app.test/?checkout=other')), isNull);
  });

  test('withoutQuery keeps the path and the Flutter route', () {
    expect(withoutQuery(Uri.parse('https://app.test/?checkout=success#/')), '/#/');
    expect(withoutQuery(Uri.parse('https://app.test/?checkout=success')), '/');
  });
}
