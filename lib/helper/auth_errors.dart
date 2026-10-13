import 'package:gentle/l10n/app_localizations.dart';

/// Error codes that mean the user closed the sign-in themselves.
const _cancelled = {
  // Firebase Auth (web popups, Apple/Google web flows)
  'popup-closed-by-user',
  'cancelled-popup-request',
  'web-context-canceled',
  'web-context-cancelled',
  'user-cancelled',
  // google_sign_in
  'sign_in_canceled',
  'canceled',
};

/// Whether [code] means the user cancelled the sign-in (no message then).
bool isSignInCancelled(String code) => _cancelled.contains(code);

/// A calm, translated message for an auth error [code]; null when the user
/// cancelled. Unknown codes get [fallback] (or a general sign-in message).
String? authErrorMessage(String code, AppLocalizations tr, {String? fallback}) {
  if (isSignInCancelled(code)) return null;
  return switch (code) {
    // Since email enumeration protection, Firebase answers a wrong password
    // and an unknown address both with invalid-credential.
    'invalid-credential' ||
    'INVALID_LOGIN_CREDENTIALS' ||
    'wrong-password' ||
    'user-not-found' =>
      tr.authInvalidCredential,
    'invalid-email' => tr.enterValidEmail,
    'user-disabled' => tr.authUserDisabled,
    'too-many-requests' => tr.authTooManyRequests,
    'network-request-failed' || 'network_error' => tr.authNetworkError,
    'email-already-in-use' => tr.authEmailInUse,
    'weak-password' => tr.passwordCaracterLimit,
    'account-exists-with-different-credential' => tr.authOtherSignInMethod,
    'requires-recent-login' => tr.authRecentLogin,
    'popup-blocked' => tr.authPopupBlocked,
    _ => fallback ?? tr.authFailed,
  };
}
