import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:gentle/l10n/app_localizations.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '/domain/blocs/authentication/appuser_model.dart';
import '/domain/blocs/user/app_user.dart';
import '/domain/services/language_cubit.dart';
import '/helper/auth_errors.dart';
import '/helper/global_functions.dart';
import '/utils/get.dart';

class AuthRepository {
  final FirebaseAuth? _firebaseAuth;

  AuthRepository({FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  AuthUser? currentUser;

  AppLocalizations get _tr => Get.the<LanguageCubit>().translation;

  Stream<AuthUser?> get user => _firebaseAuth!.authStateChanges().map((firebaseUser) {
        final user = firebaseUser == null ? AuthUser.empty : firebaseUser.appUser;
        currentUser = user;
        return user;
      });

  /// Shows a translated message for a failed sign-in; nothing when the user
  /// cancelled it.
  void _showAuthError(Object error, {String? fallback}) {
    debugPrint('Auth failed: $error');
    final code = switch (error) {
      FirebaseAuthException(:final code) => code,
      SignInWithAppleAuthorizationException(code: AuthorizationErrorCode.canceled) =>
        'canceled',
      PlatformException(:final code) => code,
      _ => 'unknown',
    };
    final message = authErrorMessage(code, _tr, fallback: fallback);
    if (message != null) showToast(message);
  }

  Future<UserCredential?> signInWithEmail(String email, String password) async {
    try {
      return await _firebaseAuth!.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      _showAuthError(e);
      return null;
    }
  }

  Future<UserCredential?> signUpWithEmail(String name, String email, String password) async {
    try {
      final user = await _firebaseAuth!.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _initUserInDBIfNeeded(user, name);
      return user;
    } catch (e) {
      _showAuthError(e, fallback: _tr.somethingWentWrong);
      return null;
    }
  }

  /// Returns null when sign-in failed or the user cancelled it.
  Future<UserCredential?> signInWithGoogle() async {
    try {
      UserCredential? user;
      if (kIsWeb) {
        final provider = GoogleAuthProvider().setCustomParameters({'prompt': 'select_account'});
        user = await _firebaseAuth!.signInWithPopup(provider);
      } else {
        final googleSignInAccount = await GoogleSignIn().signIn();
        // null: the user closed the account picker.
        final googleAuth = await googleSignInAccount?.authentication;
        if (googleAuth == null) return null;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        user = await _firebaseAuth!.signInWithCredential(credential);
      }

      await _initUserInDBIfNeeded(user);
      return user;
    } catch (e) {
      _showAuthError(e);
      return null;
    }
  }

  /// Returns null when sign-in failed or the user cancelled it.
  Future<UserCredential?> signInWithApple() async {
    try {
      // The nonce ties Apple's identity token to this sign-in, so a stolen
      // token can't be replayed (Firebase checks it against rawNonce).
      final rawNonce = _randomNonce();
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: sha256.convert(utf8.encode(rawNonce)).toString(),
      );

      final credential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        rawNonce: rawNonce,
        accessToken: appleCredential.authorizationCode,
      );
      final user = await _firebaseAuth!.signInWithCredential(credential);
      // Apple shares the name only the first time someone signs in to the app.
      final name = appleFullName(appleCredential.givenName, appleCredential.familyName);
      if (name != null) await _saveAppleName(user, name);
      await _initUserInDBIfNeeded(user, name);
      await _linkAppleSignIn(appleCredential.authorizationCode);
      return user;
    } catch (e) {
      _showAuthError(e);
      return null;
    }
  }

  /// Stores the name from Apple on the Auth account, and on an existing
  /// profile that has none yet (new profiles get it in [_initUserInDBIfNeeded]).
  Future<void> _saveAppleName(UserCredential credential, String name) async {
    final user = credential.user;
    if (user == null) return;
    try {
      if (user.displayName?.trim().isEmpty ?? true) await user.updateDisplayName(name);
      if (credential.additionalUserInfo?.isNewUser == false) {
        final ref = FirebaseFirestore.instance.collection('users').doc(user.uid);
        final current = (await ref.get()).data()?['name'];
        if (current is! String || current.trim().isEmpty) await ref.update({'name': name});
      }
    } catch (e) {
      debugPrint('Saving the name from Apple failed: $e');
    }
  }

  /// Lets the server revoke Apple access when the account is deleted (Apple
  /// requires it). A failure is logged but doesn't stop the sign-in; the next
  /// Apple sign-in tries again.
  Future<void> _linkAppleSignIn(String authorizationCode) async {
    try {
      await FirebaseFunctions.instanceFor(region: 'us-central1')
          .httpsCallable('linkAppleSignIn')
          .call({'authorizationCode': authorizationCode}).timeout(const Duration(seconds: 15));
    } catch (e) {
      debugPrint('linkAppleSignIn failed: $e');
    }
  }

  Future<void> _initUserInDBIfNeeded(UserCredential userCredential, [String? name]) async {
    if (userCredential.additionalUserInfo?.isNewUser == false) return;
    final user = userCredential.user!;
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(_firebaseAuth!.currentUser!.uid)
        .set(AppUser(
          id: user.uid,
          email: user.email ?? '',
          name: name ?? user.displayName ?? '',
          photoURL: user.photoURL ?? '',
          language: Get.the<LanguageCubit>().languageCode,
          createdAt: DateTime.now(),
          role: UserRole.client,
        ).toMap());
  }

  /// Whether the user can sign in with a password. Google and Apple accounts
  /// can't: their password and email address are managed there.
  bool get isPasswordAccount =>
      _firebaseAuth!.currentUser?.providerData.any((p) => p.providerId == 'password') ?? false;

  Future<void> resetPassword(String email) async {
    await _firebaseAuth!.sendPasswordResetEmail(email: email);
  }

  Future<void> changePassword(String password) async {
    await _firebaseAuth!.currentUser!.updatePassword(password);
  }

  /// Starts an email change after checking the current [password]. Firebase
  /// mails a link to [newEmail] and switches the sign-in address only once
  /// that link is opened; UserBloc then copies it to the profile. Throws a
  /// FirebaseAuthException (e.g. a wrong password, an address in use).
  Future<void> changeEmail(String newEmail, String password) async {
    final user = _firebaseAuth!.currentUser!;
    await user.reauthenticateWithCredential(
      EmailAuthProvider.credential(email: user.email!, password: password),
    );
    await user.verifyBeforeUpdateEmail(newEmail);
  }

  Future<void> changeName(String name) async {
    await _firebaseAuth!.currentUser!.updateDisplayName(name);
  }

  Future<void> changePhoto(String photo) async {
    await _firebaseAuth!.currentUser!.updatePhotoURL(photo);
  }

  Future<void> deleteAccount() async {
    await _firebaseAuth!.currentUser!.delete();
  }

  Future<void> reauthenticate(String password) async {
    if (currentUser == null) return;
    var credential = EmailAuthProvider.credential(email: currentUser!.email, password: password);
    await _firebaseAuth!.currentUser!.reauthenticateWithCredential(credential);
  }

  Future<void> reload() async {
    await _firebaseAuth!.currentUser!.reload();
  }

  Future<void> sendEmailVerification() async {
    await _firebaseAuth!.currentUser!.sendEmailVerification();
  }

  Future<bool> isEmailVerified() async {
    await _firebaseAuth!.currentUser!.reload();
    return _firebaseAuth!.currentUser!.emailVerified;
  }

  Future<bool> isAnonymous() async {
    await _firebaseAuth!.currentUser!.reload();
    return _firebaseAuth!.currentUser!.isAnonymous;
  }

  Future<String?> getIdToken() async {
    await _firebaseAuth!.currentUser!.reload();
    return await _firebaseAuth!.currentUser!.getIdToken();
  }

  Future<String> getIdTokenResult() async {
    await _firebaseAuth!.currentUser!.reload();
    return (await _firebaseAuth!.currentUser!.getIdTokenResult()).toString();
  }
}

/// "Given Family" from the name Apple shares at the first sign-in; null when empty.
String? appleFullName(String? givenName, String? familyName) {
  final name = [givenName, familyName]
      .map((part) => part?.trim() ?? '')
      .where((part) => part.isNotEmpty)
      .join(' ');
  return name.isEmpty ? null : name;
}

extension on User {
  AuthUser get appUser {
    return AuthUser(
      uid,
      email ?? '',
      displayName ?? '',
      photoURL ?? '',
    );
  }
}

String _randomNonce([int length = 32]) {
  const chars = '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
  final random = Random.secure();
  return List.generate(length, (_) => chars[random.nextInt(chars.length)]).join();
}
