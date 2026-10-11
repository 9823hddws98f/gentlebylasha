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
  /// **'Are you sure, you want to delete you account?'**
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

  /// No description provided for @workWithUs.
  ///
  /// In en, this message translates to:
  /// **'Work with us'**
  String get workWithUs;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of service'**
  String get termsOfService;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get privacyPolicy;

  /// No description provided for @mindfulnessAndMeditation.
  ///
  /// In en, this message translates to:
  /// **'Mindfulness and Meditation'**
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

  /// No description provided for @welcomeToSleepytales.
  ///
  /// In en, this message translates to:
  /// **'Welcome to gentle'**
  String get welcomeToSleepytales;

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

  /// No description provided for @continueWithFacebook.
  ///
  /// In en, this message translates to:
  /// **'Continue with Facebook'**
  String get continueWithFacebook;

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

  /// No description provided for @joinSleepytales.
  ///
  /// In en, this message translates to:
  /// **'Join Gentle'**
  String get joinSleepytales;

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

  /// No description provided for @loginToSleepytales.
  ///
  /// In en, this message translates to:
  /// **'Login to Gentle'**
  String get loginToSleepytales;

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

  /// No description provided for @whatBringsYouToSleepytales.
  ///
  /// In en, this message translates to:
  /// **'What brings you to Gentle'**
  String get whatBringsYouToSleepytales;

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
