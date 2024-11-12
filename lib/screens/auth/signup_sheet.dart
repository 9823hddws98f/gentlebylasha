import 'package:flutter/material.dart';

import '/domain/blocs/authentication/auth_repository.dart';
import '/domain/services/language_cubit.dart';
import '/helper/validators.dart';
import '/screens/app_container/app_container.dart';
import '/utils/app_theme.dart';
import '/utils/command_trigger.dart';
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
  final _trigger = ActionTrigger();

  String? _name;
  String? _email;
  String? _password;

  bool _dirty = false;

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
                onFieldSubmitted: (_) => _trigger.trigger(),
                textInputAction: TextInputAction.done,
                onSaved: (value) => setState(() => _password = value),
              ),
              SizedBox(height: 48),
              TxButton.filled(
                label: Text(tr.signUp),
                onPress: _signUp,
                trigger: _trigger,
                onSuccess: () => Navigator.of(context).pushNamedAndRemoveUntil(
                  AppContainer.routeName,
                  (route) => false,
                ),
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
      return credentials != null;
    } else {
      return false;
    }
  }
}
