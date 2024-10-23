import 'package:flutter/material.dart';

import '../widgets/widget_email_textField.dart';
import '/utils/global_functions.dart';
import '/widgets/custom_btn.dart';
import 'authentication.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});
  @override
  State<ForgotPasswordScreen> createState() {
    return ForgotPasswordState();
  }
}

class ForgotPasswordState extends State<ForgotPasswordScreen> {
  static final _formKey = GlobalKey<FormState>();
  String? _email;

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
                              "Login to Sleeptales",
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
                padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                      "Enter your email we will send a link to reset your password",
                      style: TextStyle(fontSize: 16)),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Email:", style: TextStyle(fontSize: 16)),
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
                height: 40,
              ),
              SizedBox(
                height: 20,
              ),
              CustomButton(
                title: "Send Password Reset Email",
                onPress: () async {
                  if (_formKey.currentState!.validate()) {
                    //showLoaderDialog(context, "Logging in...");
                    // _formKey.currentState!.save();
                    // TODO: call backend API to register user with provided information

                    if (_email != null) {
                      showLoaderDialog(context, "Sending password reset email...");
                      try {
                        Auth auth = Auth();
                        await auth.sendPasswordResetEmail(_email!);
                        Navigator.pop(context);
                        Navigator.pop(context);
                      } catch (e) {
                        showToast(e.toString());
                        Navigator.pop(context);
                      }
                    } else {
                      showToast("Please enter your email");
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
