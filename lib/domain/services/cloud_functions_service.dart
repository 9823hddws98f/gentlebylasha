import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';

class CloudFunctionsService {
  static Future<dynamic> deleteUser(String uid) async {
    final functions = FirebaseFunctions.instance;
    final deleteUserFunction = functions.httpsCallable('deleteUser');

    return await deleteUserFunction.call({'uid': uid});
  }

  static Future<dynamic> sendEmail(String to, String subject, String htmlContent) async {
    try {
      HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('sendEmail');
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
