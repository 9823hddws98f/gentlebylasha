import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '/utils/colors.dart';
import '/widgets/topbar_widget.dart';
import '../models/user_model.dart';
import '../utils/firestore_helper.dart';
import '../utils/global_functions.dart';
import '../widgets/custom_btn.dart';
import '../widgets/widget_email_textField.dart';
import 'authentication.dart';

class EditProfileScreen extends StatefulWidget {
  final String? email;
  const EditProfileScreen({super.key, this.email});

  @override
  State<EditProfileScreen> createState() {
    return _EditProfileScreen();
  }
}

class _EditProfileScreen extends State<EditProfileScreen> {
  late String email;
  late String name;
  bool curPassShow = true;
  final formKey = GlobalKey<FormState>();
  void toggleCurPassVisibility() {
    setState(() {
      curPassShow = false;
    });
  }

  @override
  void dispose() {
    email = "";
    name = "";
    super.dispose();
  }

  void showDialogPass() {
    String currentPass = "";
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              backgroundColor: colorBackground,
              title: Text(
                'Enter your current password',
                style: TextStyle(color: Colors.white),
              ),
              content: StatefulBuilder(// You need this, notice the parameters below:
                  builder: (BuildContext context, StateSetter setState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    PasswordEditText(
                      isHide: curPassShow,
                      onTap: () {
                        setState(() => curPassShow = !curPassShow);
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
                          currentPass = value;
                        });
                      },
                    ),
                    TextButton(
                      child: Text(
                        'Submit',
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () async {
                        if (currentPass.isNotEmpty) {
                          showLoaderDialog(context, "Updating email");
                          bool authCheck =
                              await updateUserEmailAndData(email, name, currentPass);
                          if (authCheck) {
                            try {
                              Auth auth = Auth();

                              UserCredential? user =
                                  await auth.signInWithEmail(email, currentPass);
                              if (user != null) {
                                UserModel? userModel = await auth.getUserFromServer(user);
                                if (userModel == null) {
                                  showToast("Unable to sign in");
                                  //  Navigator.pop(context);
                                } else {
                                  await saveUser(userModel);
                                  showToast("Email and name updated succesfully");
                                  email = '';
                                  name = '';
                                  setState(() {});
                                  valueNotifierName.value = name;
                                  // Navigator.pop(context);
                                  //pushRemoveAll(context, HomeScreen());
                                }
                              } else {
                                //Navigator.pop(context);
                              }
                            } catch (e) {
                              showToast(e.toString());
                              //Navigator.pop(context);
                            }
                          }
                          Navigator.pop(context);
                          Navigator.pop(context);
                        } else {
                          showToast("Please enter your current password");
                        }
                      },
                    ),
                  ],
                );
              }));
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: SingleChildScrollView(
              child: Padding(
                  padding: EdgeInsets.all(20.w),
                  child: Column(
                    children: [
                      TopBar(
                          heading: "Edit profile",
                          onPress: () {
                            Navigator.pop(context);
                          }),
                      Form(
                          key: formKey,
                          child: Column(
                            children: [
                              Padding(
                                padding: EdgeInsets.fromLTRB(0.w, 30.h, 0.w, 10.h),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text("Your Name:",
                                      style: TextStyle(fontSize: 16.sp)),
                                ),
                              ),
                              CustomeEditTextFullName(
                                hint: "",
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return "Please enter your name";
                                  }
                                  return null;
                                },
                                inputType: TextInputType.name,
                                onchange: (String value) {
                                  setState(() {
                                    name = value;
                                  });
                                },
                              ),
                              SizedBox(
                                height: 5.h,
                              ),
                              Padding(
                                padding: EdgeInsets.fromLTRB(0.w, 10.h, 0.w, 10.h),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child:
                                      Text("Email:", style: TextStyle(fontSize: 16.sp)),
                                ),
                              ),
                              CustomeEditText(
                                hint: "",
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return "Please enter email";
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
                                    email = value;
                                  });
                                },
                              ),
                              SizedBox(
                                height: 5.h,
                              ),
                            ],
                          )),
                      Padding(
                          padding: EdgeInsets.only(top: 50.h),
                          child: CustomButton(
                            onPress: () async {
                              if (formKey.currentState!.validate()) {
                                bool aa = await isEmailAndPasswordUserLoggedIn();
                                if (aa) {
                                  showDialogPass();
                                } else {
                                  showToast(
                                      "Only users signed up with email and password can update email");
                                }
                              } else {
                                showToast("Invalid input");
                              }
                            },
                            title: "Update",
                            color: Colors.white,
                            textColor: Colors.black,
                          ))
                    ],
                  ))),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }
}

class MyDialog extends StatefulWidget {
  const MyDialog({super.key});

  @override
  _MyDialogState createState() => _MyDialogState();
}

class _MyDialogState extends State<MyDialog> {
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Enter current password'),
      content: TextFormField(
        controller: _passwordController,
        obscureText: true,
        decoration: InputDecoration(
          hintText: 'Password',
        ),
      ),
      actions: [
        TextButton(
          child: Text('Submit'),
          onPressed: () {
            // Do something with the password value
            String password = _passwordController.text;
            debugPrint('Password entered: $password');

            // Close the dialog
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}
