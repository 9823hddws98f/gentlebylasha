import 'dart:math';

import '/domain/models/account_deletion_model.dart';
import '/utils/get.dart';
import 'account_deletion_service.dart';
import 'cloud_functions_service.dart';
import 'mailing_service.dart';

class SendGridMailingService implements MailingService {
  SendGridMailingService._();

  static final instance = SendGridMailingService._();

  final _accountDeletionService = Get.the<AccountDeletionService>();

  @override
  Future<void> sendAccountDeletionMail(String email, String userId) async {
    const title = 'Account Deletion';
    const message =
        'You have requested to delete your account. Please use the following code to verify your account deletion:';

    // Generate a random 6-digit code
    final code = (Random().nextInt(900000) + 100000).toString();

    // Save the code to Firebase
    final accountDeletionModel = AccountDeletionModel(
      id: DateTime.now().toUtc().millisecondsSinceEpoch.toString(),
      userId: userId,
      email: email,
      code: code,
      createdAt: DateTime.now(),
    );
    await _accountDeletionService.create(accountDeletionModel);

    await CloudFunctionsService.sendEmail(
      email,
      title,
      '''<h1 style="font-size: 24px; font-weight: bold;">$title</h1>
          <p style="font-size: 16px;">$message</p>
          <p style="font-size: 14px; font-weight: bold;">
            $code
          </p>''',
    );
  }
}
