import 'package:flutter/material.dart';

import '/helper/validators.dart';
import '/widgets/app_scaffold/app_scaffold.dart';
import '/widgets/custom_btn.dart';
import '../constants/language_constants.dart';

class ForgotPasswordModal extends StatefulWidget {
  const ForgotPasswordModal({super.key});
  @override
  State<ForgotPasswordModal> createState() => ForgotPasswordState();
}

class ForgotPasswordState extends State<ForgotPasswordModal> {
  static final _formKey = GlobalKey<FormState>();
  String? _email;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: Form(
        key: _formKey,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    translation(context).forgotYourPassword,
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
                      hintText: translation(context).email,
                    ),
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
                child: CustomButton(
                  title: "Send Password Reset Email",
                  onPress: () async {
                    // TODO: Implement
                    // if (_formKey.currentState!.validate()) {
                    //   //showLoaderDialog(context, "Logging in...");
                    //   // _formKey.currentState!.save();
                    //   // TODO: call backend API to register user with provided information

                    //   if (_email != null) {
                    //     showLoaderDialog(context, "Sending password reset email...");
                    //     try {
                    //       Auth auth = Auth();
                    //       await auth.sendPasswordResetEmail(_email!);
                    //       Navigator.pop(context);
                    //       Navigator.pop(context);
                    //     } catch (e) {
                    //       showToast(e.toString());
                    //       Navigator.pop(context);
                    //     }
                    //   } else {
                    //     showToast("Please enter your email");
                    //   }
                    // } else {
                    //   showToast("wrong input");
                    // }
                  },
                  color: Colors.white,
                  textColor: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
