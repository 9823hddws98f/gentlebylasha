import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';

class CloudFunctionsService {
  /// Must match `setGlobalOptions({region})` in functions/src/index.ts.
  static final _functions = FirebaseFunctions.instanceFor(region: 'us-central1');

  /// Deletes the signed-in user's own account. The server ignores any uid.
  static Future<dynamic> deleteUser() async {
    return await _functions.httpsCallable('deleteUser').call();
  }

  /// Redeems an access code. Throws [FirebaseFunctionsException] whose
  /// `message` is one of: not-found, disabled, already-redeemed, too-many-attempts.
  static Future<DateTime?> redeemCode(String code) async {
    final result = await _functions.httpsCallable('redeemCode').call({'code': code});
    final expiresAt = result.data['expiresAt'] as String?;
    return expiresAt == null ? null : DateTime.parse(expiresAt);
  }

  static Future<dynamic> sendEmail(String to, String subject, String htmlContent) async {
    try {
      HttpsCallable callable = _functions.httpsCallable('sendEmail');
      final response = await callable.call(<String, dynamic>{
        'to': to,
        'subject': subject,
        'htmlContent': htmlContent,
      });

      if (response.data['success']) {
        debugPrint('Email sent successfully');
      } else {
        debugPrint('Failed to send email');
      }
    } catch (e) {
      debugPrint('Error: $e');
    }
  }
}
