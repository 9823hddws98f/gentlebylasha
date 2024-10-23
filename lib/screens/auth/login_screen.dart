import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '/language_constants.dart';
import '/models/user_model.dart';
import '/screens/forgot_password_screen.dart';
import '/screens/home_screen.dart';
import '/screens/my_bottom_sheet.dart';
import '/utils/global_functions.dart';
import '/widgets/app_scaffold/app_scaffold.dart';
import '/widgets/custom_socialmedia_btn.dart';
import '/widgets/input/password_edit_text.dart';
import '../../helper/validators.dart';
import '../../utils/colors.dart';
import '../authentication.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _email;
  String? _password;

  @override
  Widget build(BuildContext context) => AppScaffold(
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  translation(context).login,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 24),
                TextFormField(
                  validator: AppValidators.emailValidator(context),
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: translation(context).email,
                  ),
                  onSaved: (value) => setState(() => _email = value),
                ),
                SizedBox(height: 8),
                PasswordEditText(
                  onSaved: (value) => setState(() => _password = value),
                ),
                SizedBox(height: 16),
                Center(
                  child: TextButton(
                    child: Text(translation(context).forgotYourPassword),
                    onPressed: () => showModalBottomSheet(
                      context: context,
                      showDragHandle: true,
                      isScrollControlled: true,
                      useSafeArea: true,
                      builder: (context) => ForgotPasswordModal(),
                    ),
                  ),
                ),
                SizedBox(height: 24),
                FilledButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      showLoaderDialog(context, "Logging in...");
                      // _formKey.currentState!.save();
                      // TODO: call backend API to register user with provided information

                      if (_email != null) {
                        try {
                          Auth auth = Auth();
                          UserCredential? user =
                              await auth.signInWithEmail(_email!, _password!);
                          if (user != null) {
                            UserModel? userModel = await auth.getUserFromServer(user);
                            if (userModel == null) {
                              showToast(translation(context).unableToSignIn);
                              Navigator.pop(context);
                            } else {
                              await saveUser(userModel);
                              Navigator.pop(context);
                              pushRemoveAll(context, HomeScreen());
                            }
                          } else {
                            Navigator.pop(context);
                          }
                        } catch (e) {
                          showToast(e.toString());
                          Navigator.pop(context);
                        }
                      } else {
                        showToast("email is null");
                      }
                    } else {
                      showToast("wrong input");
                    }
                  },
                  child: Text(translation(context).login),
                ),
                SizedBox(height: 24),
                _buildDivider(),
                SizedBox(height: 24),
                _buildGoogleLoginButton(),
                SizedBox(height: 16),
                _buildAppleLoginButton(),
              ],
            ),
          ),
        ),
      );

  Row _buildDivider() {
    return Row(
      children: [
        Expanded(child: Divider()),
        SizedBox(width: 8),
        Text('Or'),
        SizedBox(width: 8),
        Expanded(child: Divider()),
      ],
    );
  }

  Widget _buildEmailLoginButton(BuildContext context) => CustomSocialButton(
        title: translation(context).signupWithEmail,
        onPress: () => showModalBottomSheet<void>(
          enableDrag: false,
          isScrollControlled: true,
          backgroundColor: colorBackground,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20), topRight: Radius.circular(20))),
          context: context,
          builder: (context) => MyBottomSheet(
            currentPage: 0,
            // callBackLogin: callbackLogin,
          ),
        ),
        color: Colors.white,
        textColor: Colors.black,
        icon: Icon(
          Icons.email_outlined,
          size: 24,
        ),
      );

  Widget _buildGoogleLoginButton() => FilledButton.icon(
        icon: Icon(Icons.g_mobiledata, // TODO: change to google icon
            size: 24),
        label: Text(translation(context).continueWithGoogle),
        style: FilledButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          iconColor: Colors.black,
        ),
        onPressed: () async {
          showLoaderDialog(context, "${translation(context).authThrough} Google");
          Auth auth = Auth();
          UserCredential? userCredential = await auth.signInWithGoogle();
          if (userCredential == null) {
            showToast("${translation(context).unableToAuth} Google");
            Navigator.pop(context);
          } else {
            Navigator.pop(context);
            if (userCredential.additionalUserInfo!.isNewUser) {
              Navigator.pop(context);
              showModalBottomSheet<void>(
                  enableDrag: false,
                  isScrollControlled: true,
                  backgroundColor: colorBackground,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20), topRight: Radius.circular(20))),
                  context: context,
                  builder: (BuildContext context) {
                    return MyBottomSheet(
                      currentPage: 1,
                      userCredential: userCredential,
                    );
                  });
            } else {
              showLoaderDialog(context, "${translation(context).signingIn}...");
              UserModel? user = await auth.getUserFromServer(userCredential);
              if (user == null) {
                showToast(translation(context).unableToSignIn);
                Navigator.pop(context);
              } else {
                await saveUser(user);
                showToast(translation(context).signInSuccess);
                Navigator.pop(context);
                pushRemoveAll(context, HomeScreen());
              }
            }
            // showLoaderDialog(context, "Siggning in...");
          }
        },
      );

  Widget _buildAppleLoginButton() => FilledButton.icon(
        icon: Icon(Icons.apple, size: 24),
        label: Text(translation(context).continueWithApple),
        style: FilledButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          iconColor: Colors.black,
        ),
        onPressed: () async {
          showLoaderDialog(context, "${translation(context).authThrough} Apple");
          Auth auth = Auth();
          UserCredential? userCredential = await auth.signInWithApple();
          if (userCredential == null) {
            showToast("${translation(context).unableToAuth} Apple");
            Navigator.pop(context);
          } else {
            if (userCredential.additionalUserInfo!.isNewUser) {
              Navigator.pop(context);
              showModalBottomSheet<void>(
                  enableDrag: false,
                  isScrollControlled: true,
                  backgroundColor: colorBackground,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                  ),
                  context: context,
                  builder: (BuildContext context) {
                    return MyBottomSheet(
                      currentPage: 1,
                      userCredential: userCredential,
                    );
                  });
            } else {
              showLoaderDialog(context, "${translation(context).signingIn}...");
              UserModel? user = await auth.getUserFromServer(userCredential);
              if (user == null) {
                showToast(translation(context).unableToSignIn);
                Navigator.pop(context);
              } else {
                await saveUser(user);
                showToast(translation(context).signInSuccess);
                Navigator.pop(context);
                pushRemoveAll(context, HomeScreen());
              }
            }
          }
        },
      );
}
