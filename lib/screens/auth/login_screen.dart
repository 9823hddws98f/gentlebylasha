import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '/domain/blocs/authentication/auth_repository.dart';
import '/helper/validators.dart';
import '/language_constants.dart';
import '/screens/auth/signup_sheet.dart';
import '/screens/forgot_password_screen.dart';
import '/screens/home_screen.dart';
import '/utils/enums.dart';
import '/utils/get.dart';
import '/utils/global_functions.dart';
import '/utils/modals.dart';
import '/utils/tx_button.dart';
import '/widgets/app_scaffold/app_scaffold.dart';
import '/widgets/input/password_edit_text.dart';
import 'onboarding_bottom_sheet.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = '/login';

  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final _auth = Get.the<AuthRepository>();

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
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
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
                      Row(
                        children: [
                          Expanded(child: Divider()),
                          SizedBox(width: 8),
                          Text('Or'),
                          SizedBox(width: 8),
                          Expanded(child: Divider()),
                        ],
                      ),
                      SizedBox(height: 24),
                      _buildGoogleLoginButton(),
                      SizedBox(height: 16),
                      _buildAppleLoginButton(),
                      SizedBox(height: 16),
                    ],
                  ),
                ),
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Container(
                    alignment: Alignment.bottomCenter,
                    margin: EdgeInsets.only(bottom: 24),
                    child: TxButton.text(
                        label: Text(translation(context).signUp),
                        showSuccess: false,
                        onPressVoid: () => Modals.show(
                              context,
                              showDragHandle: true,
                              useSafeArea: true,
                              scrollable: true,
                              initialSize: 0.9,
                              builder: (context, controller) => SignupSheet(
                                onSignup: _showNewUserSheet,
                              ),
                            )),
                  ),
                ),
              ],
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

  Widget _buildGoogleLoginButton() => TxButton.filled(
        color: RoleColor.mono,
        label: Text(translation(context).continueWithGoogle),
        onPressVoid: () => _login(
          signIn: _auth.signInWithGoogle,
          authProvider: 'Google',
        ),
      );

  Widget _buildAppleLoginButton() => TxButton.filled(
        color: RoleColor.mono,
        label: Text(translation(context).continueWithApple),
        onPress: () => _login(
          signIn: _auth.signInWithApple,
          authProvider: 'Apple',
        ),
      );

  Future<void> _showNewUserSheet(UserCredential userCredential) => showModalBottomSheet(
        context: context,
        enableDrag: false,
        isScrollControlled: true,
        builder: (context) => OnboardingBottomSheet(userCredential),
      );

  Future<bool> _loginWithEmail() async {
    setState(() => _dirty = true);
    if (!_formKey.currentState!.validate()) return false;
    _formKey.currentState!.save();
    return _login(
      signIn: () => _auth.signInWithEmail(_email!, _password!),
      authProvider: 'Email',
    );
  }

  Future<bool> _login({
    required Future<UserCredential?> Function() signIn,
    String? authProvider,
  }) async {
    bool success = false;
    final userCredential = await signIn();
    if (!mounted) return success;

    if (userCredential == null) {
      showToast('${translation(context).unableToAuth} $authProvider');
      return success;
    }

    if (userCredential.additionalUserInfo!.isNewUser) {
      _showNewUserSheet(userCredential);
    } else {
      pushRemoveAll(context, HomeScreen());
    }
    return success;
  }
}