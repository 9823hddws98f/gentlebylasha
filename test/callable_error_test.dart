import 'package:flutter_test/flutter_test.dart';
import 'package:gentle/domain/services/cloud_functions_service.dart';

void main() {
  group('callableErrorReason', () {
    test('keeps the reason on mobile', () {
      expect(callableErrorReason('not-found'), 'not-found');
    });

    test('strips the status the web SDK appends', () {
      expect(callableErrorReason('not-found [400]'), 'not-found');
      expect(callableErrorReason('already-subscribed:apple [409]'), 'already-subscribed:apple');
    });

    test('handles no message', () {
      expect(callableErrorReason(null), isNull);
    });
  });
}
