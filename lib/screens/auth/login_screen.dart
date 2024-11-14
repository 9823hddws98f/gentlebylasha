import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '/constants/assets.dart';
import '/domain/blocs/authentication/auth_repository.dart';
import '/domain/services/language_cubit.dart';
import '/helper/validators.dart';
import '/main.dart';
import '/screens/app_container/app_container.dart';
import '/screens/auth/signup_sheet.dart';
import '/utils/app_theme.dart';
import '/utils/command_trigger.dart';
import '/utils/enums.dart';
import '/utils/get.dart';
import '/utils/global_functions.dart';
import '/utils/modals.dart';
import '/utils/tx_button.dart';
import '/widgets/app_scaffold/adaptive_app_bar.dart';
import '/widgets/app_scaffold/app_scaffold.dart';
import '/widgets/input/password_edit_text.dart';
import 'forgot_password_sheet.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = '/login';

  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> with Translation {
  final _auth = Get.the<AuthRepository>();

  final _formKey = GlobalKey<FormState>();
  final _trigger = ActionTrigger();
  bool _dirty = false;

  String? _email;
  String? _password;

  @override
  Widget build(BuildContext context) => AppScaffold(
        appBar: (context, isMobile) => isMobile
            ? AdaptiveAppBar(
                title: tr.login,
                centerTitle: true,
                hasBottomLine: false,
              )
            : null,
        bodyPadding: EdgeInsets.zero,
        body: (context, isMobile) {
          final theme = Theme.of(context);
          final onSurfaceVariant = theme.colorScheme.onSurfaceVariant;
          return Form(
            key: _formKey,
            autovalidateMode:
                _dirty ? AutovalidateMode.onUserInteraction : AutovalidateMode.disabled,
            child: isMobile
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppTheme.sidePadding),
                    child: _buildContent(onSurfaceVariant),
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const NeverScrollableScrollPhysics(),
                          reverse: true,
                          child: FittedBox(
                            fit: BoxFit.fitWidth,
                            child: Container(
                              padding: EdgeInsets.all(100),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                                color: theme.colorScheme.surface,
                              ),
                              child: Image.asset(
                                Assets.loginDesktopBackground,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(32, 64, 32, 32),
                            width: MyApp.desktopContentWidth,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SvgPicture.asset(Assets.logo),
                                SizedBox(height: 64),
                                Text(
                                  'Welcome back!\nLog in to your account',
                                  style: theme.textTheme.headlineLarge,
                                ),
                                SizedBox(height: 32),
                                Expanded(
                                  child: _buildContent(onSurfaceVariant),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
          );
        },
      );

  Widget _buildContent(Color outlineColor) => CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 24),
                TextFormField(
                  validator: AppValidators.emailValidator,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    hintText: tr.email,
                  ),
                  onSaved: (value) => _email = value,
                ),
                SizedBox(height: 8),
                PasswordEditText(
                  onFieldSubmitted: (_) => _trigger.trigger(),
                  onSaved: (value) => _password = value,
                ),
                SizedBox(height: 16),
                Center(child: _buildForgotPasswordButton()),
                SizedBox(height: 24),
                TxButton.filled(
                  onPressVoid: _loginWithEmail,
                  showSuccess: false,
                  trigger: _trigger,
                  label: Text(tr.login),
                ),
                SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(child: Divider()),
                    SizedBox(width: 8),
                    Text(
                      'or',
                      style: TextStyle(color: outlineColor),
                    ),
                    SizedBox(width: 8),
                    Expanded(child: Divider()),
                  ],
                ),
                SizedBox(height: 24),
                if (!kIsWeb && TargetPlatform.iOS == defaultTargetPlatform) ...[
                  _buildAppleLoginButton(),
                  SizedBox(height: 16),
                ],
                _buildGoogleLoginButton(),
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
                label: Text(tr.signUp),
                showSuccess: false,
                onPressVoid: () => Modals.showModal(
                  context,
                  showDragHandle: true,
                  useSafeArea: true,
                  scrollable: true,
                  initialSize: 0.9,
                  builder: (context, controller) => SignupSheet(),
                ),
              ),
            ),
          ),
        ],
      );

  Widget _buildForgotPasswordButton() => TxButton.text(
        label: Text(tr.forgotYourPassword),
        color: RoleColor.mono,
        showSuccess: false,
        onPressVoid: () => ForgotPasswordSheet.show(context),
      );

  Widget _buildGoogleLoginButton() => TxButton.filled(
        color: RoleColor.mono,
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(Assets.googleIcon, height: 20),
            SizedBox(width: 12),
            Text(tr.continueWithGoogle),
          ],
        ),
        onPress: () => _login(
          signIn: _auth.signInWithGoogle,
          authProvider: 'Google',
        ),
      );

  Widget _buildAppleLoginButton() => TxButton.filled(
        color: RoleColor.mono,
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(Assets.appleIcon, height: 20),
            SizedBox(width: 12),
            Text(tr.continueWithApple),
          ],
        ),
        onPress: () => _login(
          signIn: _auth.signInWithApple,
          authProvider: 'Apple',
        ),
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
    final userCredential = await signIn();
    if (!mounted) return false;

    if (userCredential == null) {
      showToast('${tr.unableToAuth} $authProvider');
      return false;
    }

    Navigator.of(context).pushNamedAndRemoveUntil(
      AppContainer.routeName,
      (route) => false,
    );
    return true;
  }
}
