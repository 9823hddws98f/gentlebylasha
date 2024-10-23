import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sleeptales/helper/validators.dart';

import '/language_constants.dart';
import '/screens/authentication.dart';
import '/utils/global_functions.dart';
import '/widgets/custom_btn.dart';
import '/widgets/login_footer.dart';

class SignupScreen extends StatefulWidget {
  static final _formKey = GlobalKey<FormState>();

  Function() callback;
  Function()? callbackSignUp;
  Function(UserCredential user, String name) setUser;
  SignupScreen(this.callback, this.setUser, this.callbackSignUp, {super.key});
  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  String? _name;

  String? _email;

  String? _password;

  bool hide = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.95,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                child: Form(
                  key: SignupScreen._formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 14),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Align(
                              alignment: Alignment.topRight,
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                                child: IconButton(
                                  iconSize: 22,
                                  icon: Icon(
                                    Icons.close,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.center,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
                                    child: Text(
                                      translation(context).joinSleepytales,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 24, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(0, 30, 0, 10),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text("${translation(context).yourName}:",
                              style: TextStyle(fontSize: 16)),
                        ),
                      ),
                      TextFormField(
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return translation(context).enterName;
                          }
                          return null;
                        },
                        onSaved: (value) => setState(() => _name = value),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text("${translation(context).email}:",
                              style: TextStyle(fontSize: 16)),
                        ),
                      ),
                      TextFormField(
                        validator: AppValidators.emailValidator(context),
                        onSaved: (value) => setState(() => _email = value),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text("${translation(context).password}:",
                              style: TextStyle(fontSize: 16)),
                        ),
                      ),
                      // PasswordEditText(
                      //   validator: (value) {
                      //     if (value?.isEmpty ?? true) {
                      //       return translation(context).enterPassword;
                      //     } else if (value!.length < 6) {
                      //       return translation(context).passwordCaracterLimit;
                      //     }
                      //     return null;
                      //   },
                      //   onChanged: (String value) {
                      //     _password = value;
                      //   },
                      // ),
                      SizedBox(
                        height: 40,
                      ),
                      LoginFooter(
                          alignment: MainAxisAlignment.start,
                          sentenceText: "${translation(context).alreadyHaveAnAccount}?",
                          loginSingUpText: translation(context).login,
                          onPress: () {
                            Navigator.pop(context);
                            widget.callbackSignUp!();
                          }),
                      SizedBox(
                        height: 20,
                      ),
                      CustomButton(
                        title: translation(context).signUp,
                        onPress: () async {
                          if (SignupScreen._formKey.currentState!.validate()) {
                            SignupScreen._formKey.currentState!.save();
                            // TODO: call backend API to register user with provided information
                            showLoaderDialog(context,
                                "${translation(context).authenticationEmail}...");
                            Auth auth = Auth();
                            UserCredential? userC =
                                await auth.signUpWithEmail(_name!, _email!, _password!);
                            if (userC != null) {
                              setState(() {
                                widget.setUser(userC, _name!);
                                Navigator.pop(context);
                                widget.callback();
                              });
                            } else {
                              Navigator.pop(context);
                            }
                          } else {
                            showToast(translation(context).pleaseFillForm);
                          }
                        },
                        color: Colors.white,
                        textColor: Colors.black,
                      ),
                    ],
                  ),
                ),
              ),
            )));
  }
}
