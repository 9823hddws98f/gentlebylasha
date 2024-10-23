import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '/helper/validators.dart';
import '/language_constants.dart';
import '/models/user_model.dart';
import '/screens/forgot_password_screen.dart';
import '/screens/home_screen.dart';
import '/screens/my_bottom_sheet.dart';
import '/utils/colors.dart';
import '/utils/enums.dart';
import '/utils/global_functions.dart';
import '/utils/tx_button.dart';
import '/widgets/app_scaffold/app_scaffold.dart';
import '/widgets/input/password_edit_text.dart';
import '../authentication.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final _auth = Auth();
  final _formKey = GlobalKey<FormState>();
  bool _dirty = false;

  String? _email;
  String? _password;

  @override
  Widget build(BuildContext context) => AppScaffold(
        body: SafeArea(
          child: Form(
            key: _formKey,
            autovalidateMode:
                _dirty ? AutovalidateMode.onUserInteraction : AutovalidateMode.disabled,
            child: SingleChildScrollView(
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
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      hintText: translation(context).email,
                    ),
                    onSaved: (value) => _email = value,
                  ),
                  SizedBox(height: 8),
                  PasswordEditText(
                    onFieldSubmitted: (value) => _loginWithEmail(),
                    onSaved: (value) => _password = value,
                  ),
                  SizedBox(height: 16),
                  Center(child: _buildForgotPasswordButton()),
                  SizedBox(height: 24),
                  TxButton.filled(
                    onPressVoid: _loginWithEmail,
                    showSuccess: false,
                    label: Text(translation(context).login),
                  ),
                  SizedBox(height: 24),
                  _buildDivider(),
                  SizedBox(height: 24),
                  _buildGoogleLoginButton(),
                  SizedBox(height: 16),
                  _buildAppleLoginButton(),
                  SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      );

  // TODO: add forgot password
  Widget _buildForgotPasswordButton() => TextButton(
        child: Text(translation(context).forgotYourPassword),
        onPressed: () => showModalBottomSheet(
          context: context,
          showDragHandle: true,
          isScrollControlled: true,
          useSafeArea: true,
          builder: (context) => ForgotPasswordModal(),
        ),
      );

  Widget _buildDivider() => Row(
        children: [
          Expanded(child: Divider()),
          SizedBox(width: 8),
          Text('Or'),
          SizedBox(width: 8),
          Expanded(child: Divider()),
        ],
      );

  // TODO: add google login
  Widget _buildGoogleLoginButton() => TxButton.filled(
        color: RoleColor.mono,
        label: Text(translation(context).continueWithGoogle),
        onPressVoid: () async {
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
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  context: context,
                  builder: (BuildContext context) {
                    return OnboardingBottomSheet(userCredential);
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

  Widget _buildAppleLoginButton() => TxButton.filled(
        color: RoleColor.mono,
        label: Text(translation(context).continueWithApple),
        onPress: _loginWithApple,
      );

  void _loginWithEmail() async {
    if (!_dirty) setState(() => _dirty = true);

    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      try {
        final user = await _auth.signInWithEmail(_email!, _password!);
        if (user != null) {
          // Get user details from server
          final userModel = await _auth.getUserFromServer(user);
          if (!mounted) return;
          if (userModel == null) {
            showToast(translation(context).unableToSignIn);
          } else {
            // Save user to local storage
            await saveUser(userModel);
            if (mounted) pushRemoveAll(context, HomeScreen());
          }
        } else {
          if (mounted) showToast(translation(context).unableToSignIn);
        }
      } catch (e) {
        showToast(e.toString());
      }
    }
  }

  Future<bool> _loginWithApple() async {
    bool success = false;
    final userCredential = await _auth.signInWithApple();
    if (!mounted) return success;

    if (userCredential == null) {
      showToast('${translation(context).unableToAuth} Apple');
      return success;
    }

    if (userCredential.additionalUserInfo!.isNewUser) {
      showModalBottomSheet(
        context: context,
        enableDrag: false,
        isScrollControlled: true,
        builder: (context) => OnboardingBottomSheet(userCredential),
      );
    } else {
      final user = await _auth.getUserFromServer(userCredential);
      if (!mounted) return success;
      if (user == null) {
        showToast(translation(context).unableToSignIn);
        return success;
      }
      await saveUser(user);
      if (!mounted) return success;
      success = true;
      pushRemoveAll(context, HomeScreen());
    }
    return success;
  }
}
