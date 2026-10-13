import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_nl.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('nl')
  ];

  /// No description provided for @countryCode.
  ///
  /// In en, this message translates to:
  /// **'US'**
  String get countryCode;

  /// No description provided for @myProfile.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get myProfile;

  /// No description provided for @changeLanguage.
  ///
  /// In en, this message translates to:
  /// **'Change language'**
  String get changeLanguage;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @favoriteList.
  ///
  /// In en, this message translates to:
  /// **'Favorite List'**
  String get favoriteList;

  /// No description provided for @downloads.
  ///
  /// In en, this message translates to:
  /// **'Downloads'**
  String get downloads;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @reminders.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get reminders;

  /// No description provided for @manageSubscription.
  ///
  /// In en, this message translates to:
  /// **'Manage Subscription'**
  String get manageSubscription;

  /// No description provided for @helpSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpSupport;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @favorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @deleteAccountMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete your account?'**
  String get deleteAccountMessage;

  /// No description provided for @deleteAccountDescription.
  ///
  /// In en, this message translates to:
  /// **'Your profile and whole data will be removed and you will not be able to login again.'**
  String get deleteAccountDescription;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @forMe.
  ///
  /// In en, this message translates to:
  /// **'For me'**
  String get forMe;

  /// No description provided for @explore.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get explore;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get goodMorning;

  /// No description provided for @goodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get goodAfternoon;

  /// No description provided for @goodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get goodEvening;

  /// No description provided for @goodNight.
  ///
  /// In en, this message translates to:
  /// **'Good night'**
  String get goodNight;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get privacyPolicy;

  /// No description provided for @mindfulnessAndMeditation.
  ///
  /// In en, this message translates to:
  /// **'Mindfulness and meditation'**
  String get mindfulnessAndMeditation;

  /// No description provided for @bedtime.
  ///
  /// In en, this message translates to:
  /// **'Bedtime'**
  String get bedtime;

  /// No description provided for @moodCheckIn.
  ///
  /// In en, this message translates to:
  /// **'Mood check-in'**
  String get moodCheckIn;

  /// No description provided for @gratitudeCheckIn.
  ///
  /// In en, this message translates to:
  /// **'Gratitude check-in'**
  String get gratitudeCheckIn;

  /// No description provided for @dailyReflection.
  ///
  /// In en, this message translates to:
  /// **'Daily reflection'**
  String get dailyReflection;

  /// No description provided for @sleepCheckIn.
  ///
  /// In en, this message translates to:
  /// **'Sleep check-in'**
  String get sleepCheckIn;

  /// No description provided for @launchScreenMessage.
  ///
  /// In en, this message translates to:
  /// **'just close your eyes and listen'**
  String get launchScreenMessage;

  /// No description provided for @createYourAccount.
  ///
  /// In en, this message translates to:
  /// **'Create your account'**
  String get createYourAccount;

  /// No description provided for @signupWithEmail.
  ///
  /// In en, this message translates to:
  /// **'Sign Up with Email'**
  String get signupWithEmail;

  /// No description provided for @continueWithApple.
  ///
  /// In en, this message translates to:
  /// **'Continue with Apple'**
  String get continueWithApple;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @authThrough.
  ///
  /// In en, this message translates to:
  /// **'Authenticating through'**
  String get authThrough;

  /// No description provided for @unableToAuth.
  ///
  /// In en, this message translates to:
  /// **'Unable to authenticate through'**
  String get unableToAuth;

  /// No description provided for @signingIn.
  ///
  /// In en, this message translates to:
  /// **'Signing in'**
  String get signingIn;

  /// No description provided for @unableToSignIn.
  ///
  /// In en, this message translates to:
  /// **'Unable to sign in'**
  String get unableToSignIn;

  /// No description provided for @signInSuccess.
  ///
  /// In en, this message translates to:
  /// **'Sign in Successful'**
  String get signInSuccess;

  /// No description provided for @haveAnAccount.
  ///
  /// In en, this message translates to:
  /// **'Have an account'**
  String get haveAnAccount;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @joinGentle.
  ///
  /// In en, this message translates to:
  /// **'Join Gentle'**
  String get joinGentle;

  /// No description provided for @yourName.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get yourName;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @alreadyHaveAnAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account'**
  String get alreadyHaveAnAccount;

  /// No description provided for @enterName.
  ///
  /// In en, this message translates to:
  /// **'Please enter your name'**
  String get enterName;

  /// No description provided for @enterEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get enterEmail;

  /// No description provided for @enterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get enterValidEmail;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter password'**
  String get enterPassword;

  /// No description provided for @passwordCaracterLimit.
  ///
  /// In en, this message translates to:
  /// **'Password must contain minimum of 6 characters'**
  String get passwordCaracterLimit;

  /// No description provided for @authenticationEmail.
  ///
  /// In en, this message translates to:
  /// **'Authenticating with email'**
  String get authenticationEmail;

  /// No description provided for @pleaseFillForm.
  ///
  /// In en, this message translates to:
  /// **'Please fill the form'**
  String get pleaseFillForm;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @notMember.
  ///
  /// In en, this message translates to:
  /// **'Not a member'**
  String get notMember;

  /// No description provided for @forgotYourPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot your password'**
  String get forgotYourPassword;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @whatBringsYouToGentle.
  ///
  /// In en, this message translates to:
  /// **'What brings you to Gentle'**
  String get whatBringsYouToGentle;

  /// No description provided for @personalizeRecMessage.
  ///
  /// In en, this message translates to:
  /// **'We’ll personalize recommendations based on your goals.'**
  String get personalizeRecMessage;

  /// No description provided for @continueText.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueText;

  /// No description provided for @favoritePlaylist.
  ///
  /// In en, this message translates to:
  /// **'Favorite Playlist'**
  String get favoritePlaylist;

  /// No description provided for @redeemCode.
  ///
  /// In en, this message translates to:
  /// **'Redeem code'**
  String get redeemCode;

  /// No description provided for @redeemCodeDescription.
  ///
  /// In en, this message translates to:
  /// **'Got a code with your Artazest artwork? Enter it here to unlock Gentle.'**
  String get redeemCodeDescription;

  /// No description provided for @redeem.
  ///
  /// In en, this message translates to:
  /// **'Redeem'**
  String get redeem;

  /// No description provided for @codeRedeemedLifetime.
  ///
  /// In en, this message translates to:
  /// **'Done! You now have unlimited access to Gentle.'**
  String get codeRedeemedLifetime;

  /// No description provided for @codeRedeemedUntil.
  ///
  /// In en, this message translates to:
  /// **'Done! You have access to Gentle until {date}.'**
  String codeRedeemedUntil(String date);

  /// No description provided for @codeNotFound.
  ///
  /// In en, this message translates to:
  /// **'This code does not exist. Check it for typos.'**
  String get codeNotFound;

  /// No description provided for @codeAlreadyRedeemed.
  ///
  /// In en, this message translates to:
  /// **'This code has already been used.'**
  String get codeAlreadyRedeemed;

  /// No description provided for @codeDisabled.
  ///
  /// In en, this message translates to:
  /// **'This code is no longer valid.'**
  String get codeDisabled;

  /// No description provided for @codeTooManyAttempts.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Try again in an hour.'**
  String get codeTooManyAttempts;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get somethingWentWrong;

  /// No description provided for @premiumLifetime.
  ///
  /// In en, this message translates to:
  /// **'Premium – unlimited access'**
  String get premiumLifetime;

  /// No description provided for @premiumUntil.
  ///
  /// In en, this message translates to:
  /// **'Premium until {date}'**
  String premiumUntil(String date);

  /// No description provided for @noSubscription.
  ///
  /// In en, this message translates to:
  /// **'No active subscription'**
  String get noSubscription;

  /// No description provided for @haveACode.
  ///
  /// In en, this message translates to:
  /// **'Have a code?'**
  String get haveACode;

  /// No description provided for @unlockGentle.
  ///
  /// In en, this message translates to:
  /// **'Unlock Gentle'**
  String get unlockGentle;

  /// No description provided for @benefitAllContent.
  ///
  /// In en, this message translates to:
  /// **'Every sleep story, meditation and sound'**
  String get benefitAllContent;

  /// No description provided for @benefitNewContent.
  ///
  /// In en, this message translates to:
  /// **'New stories and meditations every week'**
  String get benefitNewContent;

  /// No description provided for @benefitCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel anytime'**
  String get benefitCancel;

  /// No description provided for @planMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get planMonthly;

  /// No description provided for @planYearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get planYearly;

  /// No description provided for @perMonth.
  ///
  /// In en, this message translates to:
  /// **'/ month'**
  String get perMonth;

  /// No description provided for @perYear.
  ///
  /// In en, this message translates to:
  /// **'/ year'**
  String get perYear;

  /// No description provided for @subscribe.
  ///
  /// In en, this message translates to:
  /// **'Subscribe'**
  String get subscribe;

  /// No description provided for @restorePurchases.
  ///
  /// In en, this message translates to:
  /// **'Restore purchases'**
  String get restorePurchases;

  /// No description provided for @purchaseFailed.
  ///
  /// In en, this message translates to:
  /// **'The purchase did not go through. Please try again.'**
  String get purchaseFailed;

  /// No description provided for @verificationFailed.
  ///
  /// In en, this message translates to:
  /// **'We could not confirm your purchase. Tap Restore purchases to try again.'**
  String get verificationFailed;

  /// No description provided for @storeUnavailable.
  ///
  /// In en, this message translates to:
  /// **'The store is not available right now. Please try again later.'**
  String get storeUnavailable;

  /// No description provided for @premiumWelcome.
  ///
  /// In en, this message translates to:
  /// **'You have Premium. Sleep well.'**
  String get premiumWelcome;

  /// No description provided for @manageInStore.
  ///
  /// In en, this message translates to:
  /// **'Manage or cancel your subscription'**
  String get manageInStore;

  /// No description provided for @purchaseOtherAccount.
  ///
  /// In en, this message translates to:
  /// **'This purchase belongs to another Gentle account. Sign in with that account to use it.'**
  String get purchaseOtherAccount;

  /// No description provided for @website.
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get website;

  /// No description provided for @termsOfUse.
  ///
  /// In en, this message translates to:
  /// **'Terms of use'**
  String get termsOfUse;

  /// No description provided for @linkOpenFailed.
  ///
  /// In en, this message translates to:
  /// **'This page could not be opened. Please try again later.'**
  String get linkOpenFailed;

  /// No description provided for @logoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Do you want to log out?'**
  String get logoutConfirm;

  /// No description provided for @nameDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'What should we call you?'**
  String get nameDialogTitle;

  /// No description provided for @notNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get notNow;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @confirmNewEmail.
  ///
  /// In en, this message translates to:
  /// **'We sent a link to {email}. Open it to confirm your new email address. Until then, keep signing in with your current one.'**
  String confirmNewEmail(String email);

  /// No description provided for @authInvalidCredential.
  ///
  /// In en, this message translates to:
  /// **'The email address or password is not correct. Please check them and try again.'**
  String get authInvalidCredential;

  /// No description provided for @authUserDisabled.
  ///
  /// In en, this message translates to:
  /// **'This account has been turned off. Please contact us through Help & Support.'**
  String get authUserDisabled;

  /// No description provided for @authTooManyRequests.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Please wait a moment and try again.'**
  String get authTooManyRequests;

  /// No description provided for @authNetworkError.
  ///
  /// In en, this message translates to:
  /// **'No connection. Please check your internet and try again.'**
  String get authNetworkError;

  /// No description provided for @authEmailInUse.
  ///
  /// In en, this message translates to:
  /// **'There is already an account with this email address. Please log in instead.'**
  String get authEmailInUse;

  /// No description provided for @authOtherSignInMethod.
  ///
  /// In en, this message translates to:
  /// **'This email address is linked to another way of signing in. Please sign in the way you did before.'**
  String get authOtherSignInMethod;

  /// No description provided for @authRecentLogin.
  ///
  /// In en, this message translates to:
  /// **'For your security, please log in again and then try once more.'**
  String get authRecentLogin;

  /// No description provided for @authPopupBlocked.
  ///
  /// In en, this message translates to:
  /// **'Your browser blocked the sign-in window. Please allow pop-ups for this site and try again.'**
  String get authPopupBlocked;

  /// No description provided for @authFailed.
  ///
  /// In en, this message translates to:
  /// **'Signing in didn\'t work. Please try again.'**
  String get authFailed;

  /// No description provided for @alreadySubscribedStore.
  ///
  /// In en, this message translates to:
  /// **'You already have a subscription through {store}. You can manage it there.'**
  String alreadySubscribedStore(String store);

  /// No description provided for @alreadySubscribedWeb.
  ///
  /// In en, this message translates to:
  /// **'You already have a subscription. You can manage it under Manage Subscription.'**
  String get alreadySubscribedWeb;

  /// No description provided for @checkoutSuccess.
  ///
  /// In en, this message translates to:
  /// **'Thank you. Your Premium will be ready in a moment.'**
  String get checkoutSuccess;

  /// No description provided for @checkoutCancelled.
  ///
  /// In en, this message translates to:
  /// **'Checkout was cancelled. Nothing has been charged.'**
  String get checkoutCancelled;

  /// No description provided for @reminderMindfulnessDescription.
  ///
  /// In en, this message translates to:
  /// **'A few quiet minutes of mindfulness or meditation each day can help you sleep better and feel more at ease.'**
  String get reminderMindfulnessDescription;

  /// No description provided for @reminderMindfulnessQuestion.
  ///
  /// In en, this message translates to:
  /// **'When would you like a mindfulness or meditation reminder?'**
  String get reminderMindfulnessQuestion;

  /// No description provided for @reminderMindfulnessNotification.
  ///
  /// In en, this message translates to:
  /// **'Take a moment to pause, breathe and be in the present.'**
  String get reminderMindfulnessNotification;

  /// No description provided for @reminderBedtimeDescription.
  ///
  /// In en, this message translates to:
  /// **'Going to bed at the same time each night helps your body settle into a calm rhythm.'**
  String get reminderBedtimeDescription;

  /// No description provided for @reminderBedtimeQuestion.
  ///
  /// In en, this message translates to:
  /// **'What time would you like to get ready for bed?'**
  String get reminderBedtimeQuestion;

  /// No description provided for @reminderBedtimeNotification.
  ///
  /// In en, this message translates to:
  /// **'Time to wind down. Enjoy a peaceful bedtime routine.'**
  String get reminderBedtimeNotification;

  /// No description provided for @reminderMoodDescription.
  ///
  /// In en, this message translates to:
  /// **'Noticing how you feel, without judging it, is a gentle way to take care of yourself.'**
  String get reminderMoodDescription;

  /// No description provided for @reminderMoodQuestion.
  ///
  /// In en, this message translates to:
  /// **'When would you like a reminder to check in with your mood?'**
  String get reminderMoodQuestion;

  /// No description provided for @reminderMoodNotification.
  ///
  /// In en, this message translates to:
  /// **'Take a moment for yourself. How are you feeling?'**
  String get reminderMoodNotification;

  /// No description provided for @reminderGratitudeDescription.
  ///
  /// In en, this message translates to:
  /// **'Pausing to notice what went well today helps you end the day with a calmer mind.'**
  String get reminderGratitudeDescription;

  /// No description provided for @reminderGratitudeQuestion.
  ///
  /// In en, this message translates to:
  /// **'When would you like a gratitude reminder?'**
  String get reminderGratitudeQuestion;

  /// No description provided for @reminderGratitudeNotification.
  ///
  /// In en, this message translates to:
  /// **'What are you grateful for today?'**
  String get reminderGratitudeNotification;

  /// No description provided for @reminderReflectionDescription.
  ///
  /// In en, this message translates to:
  /// **'A short moment of reflection helps you let go of the day and make room for rest.'**
  String get reminderReflectionDescription;

  /// No description provided for @reminderReflectionQuestion.
  ///
  /// In en, this message translates to:
  /// **'When would you like a daily reflection reminder?'**
  String get reminderReflectionQuestion;

  /// No description provided for @reminderReflectionNotification.
  ///
  /// In en, this message translates to:
  /// **'Pause for a moment and look back on your day.'**
  String get reminderReflectionNotification;

  /// No description provided for @reminderSleepDescription.
  ///
  /// In en, this message translates to:
  /// **'Looking back on how you slept helps you notice what gives you a good night\'s rest.'**
  String get reminderSleepDescription;

  /// No description provided for @reminderSleepQuestion.
  ///
  /// In en, this message translates to:
  /// **'When would you like a sleep check-in reminder?'**
  String get reminderSleepQuestion;

  /// No description provided for @reminderSleepNotification.
  ///
  /// In en, this message translates to:
  /// **'How did you sleep? Take a moment to check in.'**
  String get reminderSleepNotification;

  /// No description provided for @currentPasswordWrong.
  ///
  /// In en, this message translates to:
  /// **'Your current password is not correct. Please try again.'**
  String get currentPasswordWrong;

  /// No description provided for @myLibrary.
  ///
  /// In en, this message translates to:
  /// **'My Library'**
  String get myLibrary;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @confirmQuestion.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to confirm?'**
  String get confirmQuestion;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @setTime.
  ///
  /// In en, this message translates to:
  /// **'Set Time'**
  String get setTime;

  /// No description provided for @confirmLeaveUnsaved.
  ///
  /// In en, this message translates to:
  /// **'Changes are not saved. Are you sure you want to leave?'**
  String get confirmLeaveUnsaved;

  /// No description provided for @confirmDeleteItem.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this item?'**
  String get confirmDeleteItem;

  /// No description provided for @codeSendFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not send the code. Please try again.'**
  String get codeSendFailed;

  /// No description provided for @enterVerificationCode.
  ///
  /// In en, this message translates to:
  /// **'Enter verification code'**
  String get enterVerificationCode;

  /// No description provided for @verificationCodeSent.
  ///
  /// In en, this message translates to:
  /// **'The verification code has been sent to {email}.'**
  String verificationCodeSent(String email);

  /// No description provided for @enterCode.
  ///
  /// In en, this message translates to:
  /// **'Enter code'**
  String get enterCode;

  /// No description provided for @codeNotReceived.
  ///
  /// In en, this message translates to:
  /// **'Did not receive the code?'**
  String get codeNotReceived;

  /// No description provided for @resend.
  ///
  /// In en, this message translates to:
  /// **'Resend'**
  String get resend;

  /// No description provided for @newCodeSent.
  ///
  /// In en, this message translates to:
  /// **'A new code has been sent.'**
  String get newCodeSent;

  /// No description provided for @waitBeforeResend.
  ///
  /// In en, this message translates to:
  /// **'Please wait a minute before requesting a new code.'**
  String get waitBeforeResend;

  /// No description provided for @verificationCodeWrong.
  ///
  /// In en, this message translates to:
  /// **'This code is incorrect.'**
  String get verificationCodeWrong;

  /// No description provided for @verificationCodeExpired.
  ///
  /// In en, this message translates to:
  /// **'This code has expired. Request a new one.'**
  String get verificationCodeExpired;

  /// No description provided for @verificationTooManyAttempts.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Request a new code.'**
  String get verificationTooManyAttempts;

  /// No description provided for @profilePhoto.
  ///
  /// In en, this message translates to:
  /// **'Profile photo'**
  String get profilePhoto;

  /// No description provided for @changeProfilePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change profile photo'**
  String get changeProfilePhoto;

  /// No description provided for @enterYourName.
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get enterYourName;

  /// No description provided for @noChangesMade.
  ///
  /// In en, this message translates to:
  /// **'No changes made'**
  String get noChangesMade;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get currentPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPassword;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get resetPassword;

  /// No description provided for @dropFileHere.
  ///
  /// In en, this message translates to:
  /// **'Drop {name} here'**
  String dropFileHere(String name);

  /// No description provided for @file.
  ///
  /// In en, this message translates to:
  /// **'file'**
  String get file;

  /// No description provided for @displayMode.
  ///
  /// In en, this message translates to:
  /// **'Display mode'**
  String get displayMode;

  /// No description provided for @useDeviceSetting.
  ///
  /// In en, this message translates to:
  /// **'Use Device Setting'**
  String get useDeviceSetting;

  /// No description provided for @lightMode.
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get lightMode;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @loginWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome back!\nLog in to your account'**
  String get loginWelcome;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get or;

  /// No description provided for @forgotPasswordDescription.
  ///
  /// In en, this message translates to:
  /// **'Enter your email and we\'ll send you a link to reset your password.'**
  String get forgotPasswordDescription;

  /// No description provided for @sendPasswordResetEmail.
  ///
  /// In en, this message translates to:
  /// **'Send Password Reset Email'**
  String get sendPasswordResetEmail;

  /// No description provided for @play.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get play;

  /// No description provided for @pause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// No description provided for @playlistLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'This playlist could not be loaded.'**
  String get playlistLoadFailed;

  /// No description provided for @trackLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'This track could not be loaded.'**
  String get trackLoadFailed;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

  /// Length of a track, e.g. 12:30 min.
  ///
  /// In en, this message translates to:
  /// **'{duration} min'**
  String durationMinutes(String duration);

  /// Number of tracks in a playlist.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 Session} other{{count} Sessions}}'**
  String sessionCount(int count);

  /// No description provided for @favoriteUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Your favorites couldn\'t be updated just now. Please try again.'**
  String get favoriteUpdateFailed;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @clearSearch.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get clearSearch;

  /// No description provided for @noResultsFound.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResultsFound;

  /// No description provided for @noCategoriesFound.
  ///
  /// In en, this message translates to:
  /// **'No categories found'**
  String get noCategoriesFound;

  /// The search term is shown in bold.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t find \"{query}\"'**
  String searchNothingFound(String query);

  /// No description provided for @favoritesEmptyTracks.
  ///
  /// In en, this message translates to:
  /// **'Your favorite tracks are empty'**
  String get favoritesEmptyTracks;

  /// No description provided for @favoritesEmptyPlaylists.
  ///
  /// In en, this message translates to:
  /// **'Your favorite playlists are empty'**
  String get favoritesEmptyPlaylists;

  /// {icon} is replaced by a heart icon.
  ///
  /// In en, this message translates to:
  /// **'To save any audio, tap the {icon} icon'**
  String favoritesHintTracks(String icon);

  /// {icon} is replaced by a heart icon.
  ///
  /// In en, this message translates to:
  /// **'To save any series, tap the {icon} icon'**
  String favoritesHintPlaylists(String icon);

  /// No description provided for @confirmDeleteAllDownloads.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete all downloads?'**
  String get confirmDeleteAllDownloads;

  /// No description provided for @noDownloadsYet.
  ///
  /// In en, this message translates to:
  /// **'No downloads yet'**
  String get noDownloadsYet;

  /// No description provided for @downloadFailed.
  ///
  /// In en, this message translates to:
  /// **'Download failed'**
  String get downloadFailed;

  /// No description provided for @getReminders.
  ///
  /// In en, this message translates to:
  /// **'Get reminders'**
  String get getReminders;

  /// No description provided for @selectAtLeastOneDay.
  ///
  /// In en, this message translates to:
  /// **'Please select at least one day'**
  String get selectAtLeastOneDay;

  /// No description provided for @notificationPermissionFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to request notification permissions'**
  String get notificationPermissionFailed;

  /// No description provided for @enableNotificationsInSettings.
  ///
  /// In en, this message translates to:
  /// **'Please enable notifications in phone settings'**
  String get enableNotificationsInSettings;

  /// Android notification channel name, shown in the system settings.
  ///
  /// In en, this message translates to:
  /// **'Daily Reminder'**
  String get reminderChannelName;

  /// Android notification channel name, shown in the system settings.
  ///
  /// In en, this message translates to:
  /// **'News'**
  String get newsChannelName;

  /// Android notification channel description, shown in the system settings.
  ///
  /// In en, this message translates to:
  /// **'New stories and announcements from Gentle'**
  String get newsChannelDescription;

  /// Android notification channel name of the player, shown in the system settings.
  ///
  /// In en, this message translates to:
  /// **'Playback'**
  String get playbackChannelName;

  /// No description provided for @sleepTimer.
  ///
  /// In en, this message translates to:
  /// **'Sleep Timer'**
  String get sleepTimer;

  /// No description provided for @timeRemaining.
  ///
  /// In en, this message translates to:
  /// **'Time Remaining'**
  String get timeRemaining;

  /// No description provided for @playbackStopsAfterTime.
  ///
  /// In en, this message translates to:
  /// **'Playback will stop after this time'**
  String get playbackStopsAfterTime;

  /// No description provided for @setTimer.
  ///
  /// In en, this message translates to:
  /// **'Set Timer'**
  String get setTimer;

  /// No description provided for @updateTimer.
  ///
  /// In en, this message translates to:
  /// **'Update Timer'**
  String get updateTimer;

  /// No description provided for @cancelTimer.
  ///
  /// In en, this message translates to:
  /// **'Cancel Timer'**
  String get cancelTimer;

  /// No description provided for @goalReduceAnxiety.
  ///
  /// In en, this message translates to:
  /// **'Reduce Anxiety'**
  String get goalReduceAnxiety;

  /// No description provided for @goalImprovePerformance.
  ///
  /// In en, this message translates to:
  /// **'Improve Performance'**
  String get goalImprovePerformance;

  /// No description provided for @goalBuildSelfEsteem.
  ///
  /// In en, this message translates to:
  /// **'Build Self Esteem'**
  String get goalBuildSelfEsteem;

  /// No description provided for @goalReduceStress.
  ///
  /// In en, this message translates to:
  /// **'Reduce Stress'**
  String get goalReduceStress;

  /// No description provided for @goalBetterSleep.
  ///
  /// In en, this message translates to:
  /// **'Better Sleep'**
  String get goalBetterSleep;

  /// No description provided for @goalIncreaseHappiness.
  ///
  /// In en, this message translates to:
  /// **'Increase Happiness'**
  String get goalIncreaseHappiness;

  /// No description provided for @goalDevelopGratitude.
  ///
  /// In en, this message translates to:
  /// **'Develop Gratitude'**
  String get goalDevelopGratitude;

  /// No description provided for @selectGoalsFirst.
  ///
  /// In en, this message translates to:
  /// **'Please select goals first'**
  String get selectGoalsFirst;

  /// No description provided for @heardFromQuestion.
  ///
  /// In en, this message translates to:
  /// **'How did you hear about Gentle?'**
  String get heardFromQuestion;

  /// No description provided for @heardFromBillboard.
  ///
  /// In en, this message translates to:
  /// **'Billboard'**
  String get heardFromBillboard;

  /// No description provided for @heardFromAppStore.
  ///
  /// In en, this message translates to:
  /// **'App Store or Google'**
  String get heardFromAppStore;

  /// No description provided for @heardFromTvAd.
  ///
  /// In en, this message translates to:
  /// **'TV Ad'**
  String get heardFromTvAd;

  /// No description provided for @heardFromTherapist.
  ///
  /// In en, this message translates to:
  /// **'Therapist or health professional'**
  String get heardFromTherapist;

  /// No description provided for @heardFromEmployer.
  ///
  /// In en, this message translates to:
  /// **'My employer'**
  String get heardFromEmployer;

  /// No description provided for @heardFromSocialMedia.
  ///
  /// In en, this message translates to:
  /// **'Social media or online Ad'**
  String get heardFromSocialMedia;

  /// No description provided for @heardFromFriend.
  ///
  /// In en, this message translates to:
  /// **'Friend or family'**
  String get heardFromFriend;

  /// No description provided for @heardFromArticle.
  ///
  /// In en, this message translates to:
  /// **'Article or blog'**
  String get heardFromArticle;

  /// No description provided for @heardFromPodcast.
  ///
  /// In en, this message translates to:
  /// **'Podcast Ad'**
  String get heardFromPodcast;

  /// No description provided for @heardFromOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get heardFromOther;

  /// No description provided for @selectOptionFirst.
  ///
  /// In en, this message translates to:
  /// **'Please select an option first'**
  String get selectOptionFirst;

  /// No description provided for @linkInvalid.
  ///
  /// In en, this message translates to:
  /// **'This link could not be opened.'**
  String get linkInvalid;

  /// No description provided for @playingTrack.
  ///
  /// In en, this message translates to:
  /// **'Playing track: {title}'**
  String playingTrack(String title);

  /// No description provided for @trackNotFound.
  ///
  /// In en, this message translates to:
  /// **'Track not found'**
  String get trackNotFound;

  /// No description provided for @playlistNotFound.
  ///
  /// In en, this message translates to:
  /// **'Playlist not found'**
  String get playlistNotFound;

  /// No description provided for @emailManagedByProvider.
  ///
  /// In en, this message translates to:
  /// **'You sign in with Google or Apple, so your email address is managed there.'**
  String get emailManagedByProvider;

  /// No description provided for @currentPasswordForEmail.
  ///
  /// In en, this message translates to:
  /// **'To change your email address, enter your current password.'**
  String get currentPasswordForEmail;

  /// No description provided for @checkYourInbox.
  ///
  /// In en, this message translates to:
  /// **'Check your inbox'**
  String get checkYourInbox;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'nl'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'nl':
      return AppLocalizationsNl();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
