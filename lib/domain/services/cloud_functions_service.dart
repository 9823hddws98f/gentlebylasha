import 'package:cloud_functions/cloud_functions.dart';

/// The reason our functions put in an error's message. On the web the SDK
/// appends the HTTP status to it (`not-found [400]`).
String? callableErrorReason(String? message) =>
    message?.replaceFirst(RegExp(r' \[\d+\]$'), '');

extension CallableErrorReason on FirebaseFunctionsException {
  String? get reason => callableErrorReason(message);
}

class CloudFunctionsService {
  /// Must match `setGlobalOptions({region})` in functions/src/index.ts.
  static final _functions = FirebaseFunctions.instanceFor(region: 'us-central1');

  /// Emails the signed-in user a code that confirms account deletion.
  static Future<void> requestAccountDeletion() =>
      _functions.httpsCallable('requestAccountDeletion').call();

  /// Deletes the signed-in user's account and data. Throws
  /// [FirebaseFunctionsException] whose `message` is one of: no-code, expired,
  /// too-many-attempts, wrong-code.
  static Future<void> deleteUser(String code) =>
      _functions.httpsCallable('deleteUser').call({'code': code});

  /// Redeems an access code. Throws [FirebaseFunctionsException] whose
  /// `message` is one of: not-found, disabled, already-redeemed, too-many-attempts.
  static Future<DateTime?> redeemCode(String code) async {
    final result = await _functions.httpsCallable('redeemCode').call({'code': code});
    final expiresAt = result.data['expiresAt'] as String?;
    return expiresAt == null ? null : DateTime.parse(expiresAt);
  }
}
