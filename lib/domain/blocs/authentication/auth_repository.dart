import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '/domain/blocs/authentication/appuser_model.dart';
import '/domain/blocs/user/app_user.dart';
import '/utils/global_functions.dart';

class AuthRepository {
  final FirebaseAuth? _firebaseAuth;

  AuthRepository({FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  AuthUser currentUser = AuthUser.empty;

  Stream<AuthUser?> get user => _firebaseAuth!.authStateChanges().map((firebaseUser) {
        final user = firebaseUser == null ? AuthUser.empty : firebaseUser.appUser;
        currentUser = user;
        return user;
      });

  Future<void> logInWithEmailAndPassword(String email, String password, bool rememberMe) {
    if (!kDebugMode) {
      _firebaseAuth!.setPersistence(rememberMe ? Persistence.LOCAL : Persistence.SESSION);
    }
    return _firebaseAuth!.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> logOut() => _firebaseAuth!.signOut();

  Future<UserCredential?> signInWithEmail(String email, String password) async {
    try {
      return await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      showToast(switch (e.code) {
        'user-not-found' => 'No user found for that email.',
        'wrong-password' => 'Wrong password provided for that user.',
        _ => 'Error during sign-in: ${e.message}'
      });
    } catch (e) {
      showToast('Unexpected error during sign-in: $e');
    }
    return null;
  }

  Future<UserCredential?> signUpWithEmail(
      String name, String email, String password) async {
    try {
      final user = await _firebaseAuth!.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _initUserInDBIfNeeded(user, name);
      return user;
    } catch (e) {
      if (e is FirebaseAuthException && e.code == 'email-already-in-use') {
        showToast('This email is already registered.');
      } else {
        showToast('An error occurred while signing up. Please try again later.');
      }
      return null;
    }
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final googleSignInAccount = await GoogleSignIn().signIn();
      final googleAuth = await googleSignInAccount!.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final user = await _firebaseAuth!.signInWithCredential(credential);
      await _initUserInDBIfNeeded(user);
      return user;
    } catch (e) {
      showToast(e.toString());
      return null;
    }
  }

  Future<UserCredential?> signInWithApple() async {
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final credential = OAuthProvider('apple.com').credential(
        idToken: String.fromCharCodes(appleCredential.identityToken!.codeUnits),
        accessToken: String.fromCharCodes(appleCredential.authorizationCode.codeUnits),
      );
      final user = await _firebaseAuth!.signInWithCredential(credential);
      await _initUserInDBIfNeeded(user);
      return user;
    } catch (e) {
      showToast(e.toString());
      return null;
    }
  }

  Future<void> _initUserInDBIfNeeded(UserCredential userCredential,
      [String? name]) async {
    if (userCredential.additionalUserInfo?.isNewUser == false) return;
    final user = userCredential.user!;
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(_firebaseAuth!.currentUser!.uid)
        .set(AppUser(
          id: user.uid,
          email: user.email!,
          name: name ?? user.displayName ?? '',
          photoURL: user.photoURL ?? '',
          language: 'en',
          createdAt: DateTime.now(),
        ).toMap());
  }

  Future<void> resetPassword(String email) async {
    await _firebaseAuth!.sendPasswordResetEmail(email: email);
  }

  Future<void> changePassword(String password) async {
    await _firebaseAuth!.currentUser!.updatePassword(password);
  }

  Future<void> changeEmail(String email) async {
    await _firebaseAuth!.currentUser!.verifyBeforeUpdateEmail(email);
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
    var credential =
        EmailAuthProvider.credential(email: currentUser.email, password: password);
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

extension on User {
  AuthUser get appUser {
    return AuthUser(
      uid,
      email!,
      displayName ?? '',
      photoURL ?? '',
    );
  }
}