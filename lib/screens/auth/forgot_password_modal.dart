import 'package:flutter/material.dart';
import 'package:sleeptales/domain/blocs/authentication/auth_repository.dart';
import 'package:sleeptales/utils/command_trigger.dart';
import 'package:sleeptales/utils/get.dart';
import 'package:sleeptales/utils/global_functions.dart';
import 'package:sleeptales/utils/tx_button.dart';

import '/constants/language_constants.dart';
import '/helper/validators.dart';
import '/utils/modals.dart';

class ForgotPasswordModal extends StatefulWidget {
  final ScrollController controller;

  const ForgotPasswordModal(this.controller, {super.key});

  static Future<void> show(BuildContext context) => Modals.show(
        context,
        initialSize: 0.5,
        minSize: 0.5,
        maxSize: 0.6,
        builder: (context, controller) => ForgotPasswordModal(controller),
      );

  @override
  State<ForgotPasswordModal> createState() => ForgotPasswordState();
}

class ForgotPasswordState extends State<ForgotPasswordModal> {
  static final _formKey = GlobalKey<FormState>();

  final _trigger = ActionTrigger();

  String? _email;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: CustomScrollView(
          controller: widget.controller,
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    translation().forgotYourPassword,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 24),
                  Text(
                    "Enter your email we will send a link to reset your password",
                  ),
                  SizedBox(height: 24),
                  TextFormField(
                    validator: AppValidators.emailValidator(context),
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: translation().email,
                    ),
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
                  onSuccess: () {
                    Navigator.pop(context);
                    showToast('Password reset email sent');
                  },
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
                        showToast('Please enter your email');
                        return false;
                      }
                    } else {
                      showToast('wrong input');
                      return false;
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
