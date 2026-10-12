import 'package:flutter_test/flutter_test.dart';
import 'package:gentle/helper/account_token.dart';

void main() {
  test('matches the server for a known uid', () {
    // Same expectation as functions/test/entitlement.test.ts.
    expect(accountToken('abc'), 'ba7816bf-8f01-cfea-4141-40de5dae2223');
  });
}
