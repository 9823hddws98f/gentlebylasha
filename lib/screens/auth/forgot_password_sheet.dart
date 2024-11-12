import 'package:flutter/material.dart';

import '/domain/blocs/authentication/auth_repository.dart';
import '/domain/services/language_cubit.dart';
import '/helper/validators.dart';
import '/utils/app_theme.dart';
import '/utils/command_trigger.dart';
import '/utils/get.dart';
import '/utils/global_functions.dart';
import '/utils/modals.dart';
import '/utils/tx_button.dart';

class ForgotPasswordSheet extends StatefulWidget {
  final ScrollController controller;

  const ForgotPasswordSheet(this.controller, {super.key});

  static Future<void> show(BuildContext context) => Modals.show(
        context,
        initialSize: 0.7,
        minSize: 0.5,
        maxSize: 0.9,
        builder: (context, controller) => ForgotPasswordSheet(controller),
      );

  @override
  State<ForgotPasswordSheet> createState() => ForgotPasswordState();
}

class ForgotPasswordState extends State<ForgotPasswordSheet> with Translation {
  static final _formKey = GlobalKey<FormState>();

  final _trigger = ActionTrigger();

  String? _email;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppTheme.sidePadding),
          child: CustomScrollView(
            controller: widget.controller,
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      tr.forgotYourPassword,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 24),
                    Text('Enter your email we will send a link to reset your password'),
                    SizedBox(height: 24),
                    TextFormField(
                      validator: AppValidators.emailValidator,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(hintText: tr.email),
                      onFieldSubmitted: (value) => _trigger.trigger(),
                      onSaved: (value) => setState(() => _email = value),
                    ),
                  ],
                ),
              ),
              SliverFillRemaining(
                hasScrollBody: false,
                child: Container(
                  padding: EdgeInsets.only(bottom: 16),
                  alignment: Alignment.bottomCenter,
                  width: double.infinity,
                  child: TxButton.filled(
                    label: Text('Send Password Reset Email'),
                    trigger: _trigger,
                    onSuccess: () => Navigator.pop(context),
                    onPress: () async {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        if (_email != null) {
                          try {
                            final auth = Get.the<AuthRepository>();
                            await auth.resetPassword(_email!);
                            return true;
                          } catch (e) {
                            showToast(e.toString());
                            return false;
                          }
                        } else {
                          return false;
                        }
                      } else {
                        return false;
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
