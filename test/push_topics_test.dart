import 'package:flutter_test/flutter_test.dart';
import 'package:gentle/domain/services/push_service.dart';

void main() {
  // Same expectations as topicsFor() in functions/src/push.ts.
  test('Dutch premium device', () {
    final t = PushService.topicsFor('nl', true);
    expect(t.subscribe, ['lang_nl', 'premium']);
    expect(t.unsubscribe, ['lang_en', 'free']);
  });

  test('English free device', () {
    final t = PushService.topicsFor('en', false);
    expect(t.subscribe, ['lang_en', 'free']);
    expect(t.unsubscribe, ['lang_nl', 'premium']);
  });

  test('subscribe and unsubscribe together cover every topic', () {
    for (final language in ['en', 'nl']) {
      for (final premium in [true, false]) {
        final t = PushService.topicsFor(language, premium);
        expect({...t.subscribe, ...t.unsubscribe}, PushService.allTopics.toSet());
      }
    }
  });
}
