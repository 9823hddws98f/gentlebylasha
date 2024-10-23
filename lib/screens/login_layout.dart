import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '/language_constants.dart';
import '/models/user_model.dart';
import '/screens/forgot_password_screen.dart';
import '/screens/home_screen.dart';
import '/utils/global_functions.dart';
import '/widgets/custom_btn.dart';
import '/widgets/login_footer.dart';
import '../utils/colors.dart';
import '../widgets/widget_email_textField.dart';
import 'authentication.dart';

class LoginScreen extends StatefulWidget {
  final Function callback;

  const LoginScreen({super.key, required this.callback});

  @override
  State<LoginScreen> createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  static final _formKey = GlobalKey<FormState>();
  String? _email;
  String? _password;
  bool isHide = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 10),
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
                              translation(context).loginToSleepytales,
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
                  child: Text("${translation(context).email}:",
                      style: TextStyle(fontSize: 16)),
                ),
              ),
              CustomeEditText(
                hint: "",
                validator: (value) {
                  if (value.isEmpty) {
                    return "Please enter your email";
                  } else if (!(RegExp(
                          r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                      .hasMatch(value))) {
                    return "Please enter a valid email";
                  }
                  return null;
                },
                inputType: TextInputType.emailAddress,
                // controller: provider.email,
                onchange: (String value) {
                  setState(() {
                    _email = value;
                  });
                },
              ),
              SizedBox(
                height: 5,
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child:
                      Text(translation(context).password, style: TextStyle(fontSize: 16)),
                ),
              ),
              PasswordEditText(
                isHide: isHide,
                //controller: provider.password,
                onTap: () {
                  setState(() {
                    isHide = !isHide;
                  });
                },
                validator: (value) {
                  if (value.isEmpty) {
                    return "Please enter password";
                  } else if (value.length < 6) {
                    return "Password must contain minimum of 6 characters";
                  }
                  return null;
                },
                onchange: (String value) {
                  setState(() {
                    _password = value;
                  });
                },
              ),
              SizedBox(
                height: 40,
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: LoginFotter(
                    alignment: MainAxisAlignment.start,
                    sentenceText: "${translation(context).notMember}?",
                    loginSingUpText: translation(context).signUp,
                    onPress: () {
                      Navigator.pop(context);
                      widget.callback();
                    }),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: LoginFotter(
                    alignment: MainAxisAlignment.start,
                    sentenceText: "${translation(context).forgotYourPassword}??",
                    loginSingUpText: translation(context).reset,
                    onPress: () {
                      showModalBottomSheet<void>(
                        enableDrag: false,
                        isScrollControlled: true,
                        backgroundColor: colorBackground,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(24),
                                topRight: Radius.circular(24))),
                        context: context,
                        builder: (BuildContext context) {
                          return Form(child: Builder(builder: (cxt) {
                            return Container(
                                height: MediaQuery.of(context).size.height * 0.88,
                                clipBehavior: Clip.hardEdge,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(24),
                                        topRight: Radius.circular(24))),
                                child: ForgotPasswordScreen());
                          }));
                        },
                      );
                    }),
              ),
              SizedBox(
                height: 20,
              ),
              CustomButton(
                title: translation(context).login,
                onPress: () async {
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
                color: Colors.white,
                textColor: Colors.black,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
