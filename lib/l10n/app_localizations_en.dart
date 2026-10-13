// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get countryCode => 'US';

  @override
  String get myProfile => 'My Profile';

  @override
  String get changeLanguage => 'Change language';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get favoriteList => 'Favorite List';

  @override
  String get downloads => 'Downloads';

  @override
  String get changePassword => 'Change Password';

  @override
  String get reminders => 'Reminders';

  @override
  String get manageSubscription => 'Manage Subscription';

  @override
  String get helpSupport => 'Help & Support';

  @override
  String get about => 'About';

  @override
  String get logout => 'Logout';

  @override
  String get favorites => 'Favorites';

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String get deleteAccountMessage =>
      'Are you sure you want to delete your account?';

  @override
  String get deleteAccountDescription =>
      'Your profile and whole data will be removed and you will not be able to login again.';

  @override
  String get home => 'Home';

  @override
  String get forMe => 'For me';

  @override
  String get explore => 'Explore';

  @override
  String get profile => 'Profile';

  @override
  String get goodMorning => 'Good morning';

  @override
  String get goodAfternoon => 'Good afternoon';

  @override
  String get goodEvening => 'Good evening';

  @override
  String get goodNight => 'Good night';

  @override
  String get privacyPolicy => 'Privacy policy';

  @override
  String get mindfulnessAndMeditation => 'Mindfulness and meditation';

  @override
  String get bedtime => 'Bedtime';

  @override
  String get moodCheckIn => 'Mood check-in';

  @override
  String get gratitudeCheckIn => 'Gratitude check-in';

  @override
  String get dailyReflection => 'Daily reflection';

  @override
  String get sleepCheckIn => 'Sleep check-in';

  @override
  String get launchScreenMessage => 'just close your eyes and listen';

  @override
  String get createYourAccount => 'Create your account';

  @override
  String get signupWithEmail => 'Sign Up with Email';

  @override
  String get continueWithApple => 'Continue with Apple';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get authThrough => 'Authenticating through';

  @override
  String get unableToAuth => 'Unable to authenticate through';

  @override
  String get signingIn => 'Signing in';

  @override
  String get unableToSignIn => 'Unable to sign in';

  @override
  String get signInSuccess => 'Sign in Successful';

  @override
  String get haveAnAccount => 'Have an account';

  @override
  String get login => 'Login';

  @override
  String get joinGentle => 'Join Gentle';

  @override
  String get yourName => 'Your name';

  @override
  String get email => 'Email';

  @override
  String get name => 'Name';

  @override
  String get password => 'Password';

  @override
  String get alreadyHaveAnAccount => 'Already have an account';

  @override
  String get enterName => 'Please enter your name';

  @override
  String get enterEmail => 'Please enter your email';

  @override
  String get enterValidEmail => 'Please enter a valid email';

  @override
  String get enterPassword => 'Please enter password';

  @override
  String get passwordCaracterLimit =>
      'Password must contain minimum of 6 characters';

  @override
  String get authenticationEmail => 'Authenticating with email';

  @override
  String get pleaseFillForm => 'Please fill the form';

  @override
  String get signUp => 'Sign Up';

  @override
  String get notMember => 'Not a member';

  @override
  String get forgotYourPassword => 'Forgot your password';

  @override
  String get reset => 'Reset';

  @override
  String get whatBringsYouToGentle => 'What brings you to Gentle';

  @override
  String get personalizeRecMessage =>
      'We’ll personalize recommendations based on your goals.';

  @override
  String get continueText => 'Continue';

  @override
  String get favoritePlaylist => 'Favorite Playlist';

  @override
  String get redeemCode => 'Redeem code';

  @override
  String get redeemCodeDescription =>
      'Got a code with your Artazest artwork? Enter it here to unlock Gentle.';

  @override
  String get redeem => 'Redeem';

  @override
  String get codeRedeemedLifetime =>
      'Done! You now have unlimited access to Gentle.';

  @override
  String codeRedeemedUntil(String date) {
    return 'Done! You have access to Gentle until $date.';
  }

  @override
  String get codeNotFound => 'This code does not exist. Check it for typos.';

  @override
  String get codeAlreadyRedeemed => 'This code has already been used.';

  @override
  String get codeDisabled => 'This code is no longer valid.';

  @override
  String get codeTooManyAttempts => 'Too many attempts. Try again in an hour.';

  @override
  String get somethingWentWrong => 'Something went wrong. Please try again.';

  @override
  String get premiumLifetime => 'Premium – unlimited access';

  @override
  String premiumUntil(String date) {
    return 'Premium until $date';
  }

  @override
  String get noSubscription => 'No active subscription';

  @override
  String get haveACode => 'Have a code?';

  @override
  String get unlockGentle => 'Unlock Gentle';

  @override
  String get benefitAllContent => 'Every sleep story, meditation and sound';

  @override
  String get benefitNewContent => 'New stories and meditations every week';

  @override
  String get benefitCancel => 'Cancel anytime';

  @override
  String get planMonthly => 'Monthly';

  @override
  String get planYearly => 'Yearly';

  @override
  String get perMonth => '/ month';

  @override
  String get perYear => '/ year';

  @override
  String get subscribe => 'Subscribe';

  @override
  String get restorePurchases => 'Restore purchases';

  @override
  String get purchaseFailed =>
      'The purchase did not go through. Please try again.';

  @override
  String get verificationFailed =>
      'We could not confirm your purchase. Tap Restore purchases to try again.';

  @override
  String get storeUnavailable =>
      'The store is not available right now. Please try again later.';

  @override
  String get premiumWelcome => 'You have Premium. Sleep well.';

  @override
  String get manageInStore => 'Manage or cancel your subscription';

  @override
  String get purchaseOtherAccount =>
      'This purchase belongs to another Gentle account. Sign in with that account to use it.';

  @override
  String get website => 'Website';

  @override
  String get termsOfUse => 'Terms of use';

  @override
  String get linkOpenFailed =>
      'This page could not be opened. Please try again later.';

  @override
  String get logoutConfirm => 'Do you want to log out?';

  @override
  String get nameDialogTitle => 'What should we call you?';

  @override
  String get notNow => 'Not now';

  @override
  String get save => 'Save';

  @override
  String confirmNewEmail(String email) {
    return 'We sent a link to $email. Open it to confirm your new email address. Until then, keep signing in with your current one.';
  }

  @override
  String get authInvalidCredential =>
      'The email address or password is not correct. Please check them and try again.';

  @override
  String get authUserDisabled =>
      'This account has been turned off. Please contact us through Help & Support.';

  @override
  String get authTooManyRequests =>
      'Too many attempts. Please wait a moment and try again.';

  @override
  String get authNetworkError =>
      'No connection. Please check your internet and try again.';

  @override
  String get authEmailInUse =>
      'There is already an account with this email address. Please log in instead.';

  @override
  String get authOtherSignInMethod =>
      'This email address is linked to another way of signing in. Please sign in the way you did before.';

  @override
  String get authRecentLogin =>
      'For your security, please log in again and then try once more.';

  @override
  String get authPopupBlocked =>
      'Your browser blocked the sign-in window. Please allow pop-ups for this site and try again.';

  @override
  String get authFailed => 'Signing in didn\'t work. Please try again.';

  @override
  String alreadySubscribedStore(String store) {
    return 'You already have a subscription through $store. You can manage it there.';
  }

  @override
  String get alreadySubscribedWeb =>
      'You already have a subscription. You can manage it under Manage Subscription.';

  @override
  String get checkoutSuccess =>
      'Thank you. Your Premium will be ready in a moment.';

  @override
  String get checkoutCancelled =>
      'Checkout was cancelled. Nothing has been charged.';

  @override
  String get reminderMindfulnessDescription =>
      'A few quiet minutes of mindfulness or meditation each day can help you sleep better and feel more at ease.';

  @override
  String get reminderMindfulnessQuestion =>
      'When would you like a mindfulness or meditation reminder?';

  @override
  String get reminderMindfulnessNotification =>
      'Take a moment to pause, breathe and be in the present.';

  @override
  String get reminderBedtimeDescription =>
      'Going to bed at the same time each night helps your body settle into a calm rhythm.';

  @override
  String get reminderBedtimeQuestion =>
      'What time would you like to get ready for bed?';

  @override
  String get reminderBedtimeNotification =>
      'Time to wind down. Enjoy a peaceful bedtime routine.';

  @override
  String get reminderMoodDescription =>
      'Noticing how you feel, without judging it, is a gentle way to take care of yourself.';

  @override
  String get reminderMoodQuestion =>
      'When would you like a reminder to check in with your mood?';

  @override
  String get reminderMoodNotification =>
      'Take a moment for yourself. How are you feeling?';

  @override
  String get reminderGratitudeDescription =>
      'Pausing to notice what went well today helps you end the day with a calmer mind.';

  @override
  String get reminderGratitudeQuestion =>
      'When would you like a gratitude reminder?';

  @override
  String get reminderGratitudeNotification =>
      'What are you grateful for today?';

  @override
  String get reminderReflectionDescription =>
      'A short moment of reflection helps you let go of the day and make room for rest.';

  @override
  String get reminderReflectionQuestion =>
      'When would you like a daily reflection reminder?';

  @override
  String get reminderReflectionNotification =>
      'Pause for a moment and look back on your day.';

  @override
  String get reminderSleepDescription =>
      'Looking back on how you slept helps you notice what gives you a good night\'s rest.';

  @override
  String get reminderSleepQuestion =>
      'When would you like a sleep check-in reminder?';

  @override
  String get reminderSleepNotification =>
      'How did you sleep? Take a moment to check in.';

  @override
  String get currentPasswordWrong =>
      'Your current password is not correct. Please try again.';
}
