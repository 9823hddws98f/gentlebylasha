import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '/models/user_model.dart';
import '/utils/global_functions.dart';

class Auth {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FacebookAuth _facebookAuth = FacebookAuth.instance;

  Future<UserCredential?> signInWithEmail(String email, String password) async {
    try {
      // Sign in the user with the provided email and password
      final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Return the user credential if sign-in was successful
      return userCredential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        // Handle user not found error
        showToast('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        // Handle wrong password error
        showToast('Wrong password provided for that user.');
      } else {
        // Handle other errors
        showToast('Error during sign-in: ${e.message}');
      }
    } catch (e) {
      // Handle any other unexpected errors
      showToast('Unexpected error during sign-in: $e');
    }

    // Return null if sign-in was not successful
    return null;
  }

// Sign up with email and password
  Future<UserCredential?> signUpWithEmail(
      String name, String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      if (e is FirebaseAuthException) {
        if (e.code == 'email-already-in-use') {
          showToast('This email is already registered.');
        } else {
          showToast('An error occurred while signing up. Please try again later.');
        }
      } else {
        showToast('An error occurred while signing up. Please try again later.');
      }
      return null;
    }
  }

  // Sign in with Facebook
  Future<UserCredential?> signInWithFacebook() async {
    try {
      // Log in with Facebook
      final LoginResult result = await _facebookAuth.login();

      // Authenticate with Firebase using the credentials
      final OAuthCredential credential =
          FacebookAuthProvider.credential(result.accessToken!.tokenString);
      return _auth.signInWithCredential(credential);
    } catch (e) {
      // Handle errors
      return null;
    }
  }

  // Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Log in with Google
      final GoogleSignInAccount? googleSignInAccount = await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth =
          await googleSignInAccount!.authentication;

      // Authenticate with Firebase using the credentials
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      // Sign in with Firebase
      final UserCredential userCredential = await _auth.signInWithCredential(credential);

      return userCredential;
    } catch (e) {
      showToast("$e error");
      debugPrint('google error: $e');
      return null;
    }
  }

// Sign in with Apple
  Future<UserCredential?> signInWithApple() async {
    try {
      // Request credentials from Apple
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [AppleIDAuthorizationScopes.email, AppleIDAuthorizationScopes.fullName],
      );

      // Authenticate with Firebase using the credentials
      final credential = OAuthProvider('apple.com').credential(
        idToken: String.fromCharCodes(appleCredential.identityToken!.codeUnits),
        accessToken: String.fromCharCodes(appleCredential.authorizationCode.codeUnits),
      );
      // Sign in with Firebase
      final userCredential = await _auth.signInWithCredential(credential);
      debugPrint('name ${userCredential.user!.displayName}');
      return userCredential;
    } catch (e) {
      debugPrint('error in apple sign in $e');
      return null;
    }
  }

  // Link a user's account with their email and password
  Future<UserCredential?> linkWithEmail(String email, String password) async {
    try {
      // Get the current user
      User? user = _auth.currentUser;

      // Create credentials using the email and password
      final credentials = EmailAuthProvider.credential(email: email, password: password);

      // Link the credentials to the current user
      return user?.linkWithCredential(credentials);
    } catch (e) {
      // Handle errors
      return null;
    }
  }

  Future<UserModel?> addUserToServer(UserCredential userCredential, String nameC,
      List<int> selectedGoalsOptions, int selectedOption, bool anually) async {
    UserModel? userModel;

    final List<String> options = [
      'Reduce Anxiety',
      'Improve Performance',
      'Build Self Esteem',
      'Reduce Stress',
      'Better Sleep',
      'Increase Happiness',
      'Develop Gratitude',
    ];

    final List<String> selectedOptions =
        selectedGoalsOptions.map((index) => options[index]).toList();

    final List<String> optionsString = [
      'Billboard',
      'App Store or Google',
      'TV Ad',
      'Therapist or health professional',
      'My employer',
      'Social media or online Ad',
      'Friend or family',
      'Article or blog',
      'Podcast Ad',
      'Other'
    ];

    // Get the user's name and email
    final User? user = userCredential.user;
    String? name;
    if (user!.displayName != null) {
      name = user.displayName;
    } else {
      name = nameC;
    }

    final String? email = user.email;
    final String? photoURL = user.photoURL;
    String subscriptionType;
    if (anually) {
      subscriptionType = "Anually";
    } else {
      subscriptionType = "Monthly";
    }

    userModel = UserModel(
        id: user.uid,
        email: email,
        language: "en",
        photoURL: photoURL,
        name: name,
        goals: selectedOptions,
        heardFrom: optionsString[selectedOption]);

    // Add the user's name and email to the Firestore database
    await FirebaseFirestore.instance.collection('User').doc(user.uid).set({
      'name': name,
      'email': email,
      'photo_url': user.photoURL,
      "language": "en",
      "heard_from": optionsString[selectedOption],
      "goals": selectedOptions,
      "subscription_type": subscriptionType,
      "is_active": true,
      "is_premium": false,
      "is_admin": false
    });

    return userModel;
  }

  // Future<UserModel?> addgetUserFromServer(UserCredential userCredential) async {
  //   UserModel? userModel;
  //
  //     // Check if the user is signing up for the first time
  //     if (userCredential.additionalUserInfo!.isNewUser) {
  //       // This is a new user
  //       // Add the user to your Firestore database or perform any other necessary actions
  //       // ...
  //
  //       // Get the user's name and email
  //       final User? user = userCredential.user;
  //       final String? name = user?.displayName;
  //       final String? email = user?.email;
  //       final String? photoURL = user?.photoURL;
  //
  //       userModel = UserModel(id: user?.uid, email: email, language: "en", photoURL:photoURL,name: name, goals: [], heardFrom: "");
  //       // Add the user's name and email to the Firestore database
  //       await FirebaseFirestore.instance
  //           .collection('User')
  //           .doc(user?.uid)
  //           .set({'name': name, 'email': email,"email_verification":true,'photo_url':user!.photoURL,"language":"en","heard_from":"","goals":[""],"is_active":true,"is_premium":false,"is_admin":false});
  //
  //
  //     }else{
  //       // Get the user information from the Firestore database
  //       final User? user = userCredential.user;
  //       final DocumentSnapshot snapshot = await FirebaseFirestore.instance
  //           .collection('User')
  //           .doc(user?.uid)
  //           .get();
  //
  //       final String? name = snapshot.get('name');
  //       final String? email = snapshot.get('email');
  //       final String? language = snapshot.get('language');
  //       final List<dynamic>? goals = snapshot.get('goals');
  //       final String? heardFrom = snapshot.get('heard_from');
  //       final String? photoURL = snapshot.get('photo_url');
  //       userModel = UserModel(id: user!.uid,name:name,email: email,photoURL:photoURL,language: language ,heardFrom: heardFrom,goals: goals);
  //
  //     }
  //
  //
  //   return userModel;
  // }

  Future<UserModel?> getUserFromServer(UserCredential userCredential) async {
    UserModel? userModel;

    // Get the user information from the Firestore database
    final User? user = userCredential.user;
    final DocumentSnapshot snapshot =
        await FirebaseFirestore.instance.collection('User').doc(user?.uid).get();

    final String? name = snapshot.get('name');
    final String? email = snapshot.get('email');
    final String? language = snapshot.get('language');
    final List<dynamic>? goals = snapshot.get('goals');
    final String? heardFrom = snapshot.get('heard_from');
    final String? photoURL = snapshot.get('photo_url');
    userModel = UserModel(
        id: user!.uid,
        name: name,
        email: email,
        photoURL: photoURL,
        language: language,
        heardFrom: heardFrom,
        goals: goals);

    return userModel;
  }

  void sendEmailVerification() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await user.sendEmailVerification();
      showToast("Verification email sent to ${user.email}");
    }
  }

  // Function to send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      showToast('Password reset email sent successfully');
      // You can show a success message to the user or navigate to a screen indicating that a password reset email has been sent
    } catch (e) {
      showToast('Error sending password reset email: $e');
      // You can display an error message to the user indicating that the password reset email could not be sent
    }
  }
}
