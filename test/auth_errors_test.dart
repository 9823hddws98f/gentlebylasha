import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:gentle/domain/blocs/authentication/auth_repository.dart';
import 'package:gentle/helper/auth_errors.dart';
import 'package:gentle/l10n/app_localizations.dart';

void main() {
  final en = lookupAppLocalizations(const Locale('en'));
  final nl = lookupAppLocalizations(const Locale('nl'));

  test('wrong email or password gets one calm message', () {
    for (final code in ['invalid-credential', 'wrong-password', 'user-not-found']) {
      expect(authErrorMessage(code, en), en.authInvalidCredential);
    }
    expect(authErrorMessage('invalid-credential', nl), nl.authInvalidCredential);
  });

  test('cancelling a sign-in shows nothing', () {
    for (final code in [
      'popup-closed-by-user',
      'cancelled-popup-request',
      'canceled',
      'sign_in_canceled'
    ]) {
      expect(authErrorMessage(code, en), isNull);
    }
  });

  test('common codes are translated, unknown ones get the fallback', () {
    expect(authErrorMessage('too-many-requests', en), en.authTooManyRequests);
    expect(authErrorMessage('network-request-failed', en), en.authNetworkError);
    expect(authErrorMessage('email-already-in-use', en), en.authEmailInUse);
    expect(authErrorMessage('something-new', en), en.authFailed);
    expect(authErrorMessage('something-new', en, fallback: 'x'), 'x');
  });

  test('appleFullName', () {
    expect(appleFullName('Anna', 'de Vries'), 'Anna de Vries');
    expect(appleFullName('Anna', null), 'Anna');
    expect(appleFullName(' ', ''), isNull);
    expect(appleFullName(null, null), isNull);
  });
}
