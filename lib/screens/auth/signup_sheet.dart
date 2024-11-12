import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '/domain/blocs/authentication/auth_repository.dart';
import '/domain/services/language_cubit.dart';
import '/helper/validators.dart';
import '/utils/app_theme.dart';
import '/utils/get.dart';
import '/utils/tx_button.dart';
import '/widgets/input/password_edit_text.dart';

class SignupSheet extends StatefulWidget {
  const SignupSheet({super.key});

  @override
  State<SignupSheet> createState() => _SignupSheetState();
}

class _SignupSheetState extends State<SignupSheet> with Translation {
  final _auth = Get.the<AuthRepository>();
  final _formKey = GlobalKey<FormState>();

  String? _name;
  String? _email;
  String? _password;

  bool _dirty = false;
  UserCredential? _credentials;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.sidePadding),
        child: Form(
          key: _formKey,
          autovalidateMode:
              _dirty ? AutovalidateMode.onUserInteraction : AutovalidateMode.disabled,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                tr.joinSleepytales,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16, bottom: 8),
                child: Text('${tr.name}:', style: TextStyle(fontSize: 16)),
              ),
              TextFormField(
                decoration: InputDecoration(hintText: tr.name),
                validator: (value) => value?.isEmpty ?? true ? tr.enterName : null,
                onSaved: (value) => setState(() => _name = value),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16, bottom: 8),
                child: Text('${tr.email}:', style: TextStyle(fontSize: 16)),
              ),
              TextFormField(
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(hintText: tr.email),
                validator: AppValidators.emailValidator,
                onSaved: (value) => setState(() => _email = value),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16, bottom: 8),
                child: Text(
                  '${tr.password}:',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              PasswordEditText(
                onFieldSubmitted: (_) => _signUp(),
                onSaved: (value) => setState(() => _password = value),
              ),
              SizedBox(height: 48),
              TxButton.filled(
                label: Text(tr.signUp),
                onPress: _signUp,
              ),
              SizedBox(height: 16),
            ],
          ),
        ),
      );

  Future<bool> _signUp() async {
    setState(() => _dirty = true);
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final credentials = await _auth.signUpWithEmail(_name!, _email!, _password!);
      // This will trigger userbloc to navigate to [AppContainer]
      if (!mounted) return false;
      _credentials = credentials;
      return credentials != null;
    } else {
      return false;
    }
  }
}
