import 'package:flutter/material.dart';
import '/helper/validators.dart';

import '/utils/colors.dart';
import '/widgets/app_scaffold/adaptive_app_bar.dart';
import '/widgets/app_scaffold/app_scaffold.dart';
import '/widgets/input/password_edit_text.dart';
import '/utils/firestore_helper.dart';
import '/utils/global_functions.dart';
import '/widgets/custom_btn.dart';

class EditProfileScreen extends StatefulWidget {
  final String? email;
  const EditProfileScreen({super.key, this.email});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreen();
}

class _EditProfileScreen extends State<EditProfileScreen> {
  String? _email;
  String? _name;

  final _formKey = GlobalKey<FormState>();

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
                      onSaved: (value) => setState(() => currentPass = value ?? ''),
                    ),
                    TextButton(
                      child: Text(
                        'Submit',
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () async {
                        // TODO: Implement
                        // if (currentPass.isNotEmpty) {
                        //   showLoaderDialog(context, "Updating email");
                        //   bool authCheck =
                        //       await updateUserEmailAndData(email, name, currentPass);
                        //   if (authCheck) {
                        //     try {
                        //       Auth auth = Auth();

                        //       UserCredential? user =
                        //           await auth.signInWithEmail(email, currentPass);
                        //       if (user != null) {
                        //         AppUser? userModel = await auth.getUserFromServer(user);
                        //         if (userModel == null) {
                        //           showToast("Unable to sign in");
                        //           //  Navigator.pop(context);
                        //         } else {
                        //           await saveUser(userModel);
                        //           showToast("Email and name updated succesfully");
                        //           email = '';
                        //           name = '';
                        //           setState(() {});
                        //           valueNotifierName.value = name;
                        //           // Navigator.pop(context);
                        //           //pushRemoveAll(context, HomeScreen());
                        //         }
                        //       } else {
                        //         //Navigator.pop(context);
                        //       }
                        //     } catch (e) {
                        //       showToast(e.toString());
                        //       //Navigator.pop(context);
                        //     }
                        //   }
                        //   Navigator.pop(context);
                        //   Navigator.pop(context);
                        // } else {
                        //   showToast("Please enter your current password");
                        // }
                      },
                    ),
                  ],
                );
              }));
        });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: (context, isMobile) => AdaptiveAppBar(
        title: 'Edit profile',
      ),
      body: (context, isMobile) => ListView(
        children: [
          Form(
              key: _formKey,
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(0, 20, 0, 10),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Your Name:', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      hintText: 'Enter your name',
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                    onSaved: (value) => _name = value ?? '',
                  ),
                  SizedBox(height: 5),
                  Padding(
                    padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Email:', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                  TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    onFieldSubmitted: (_) => _submit(),
                    decoration: InputDecoration(
                      hintText: 'Enter your email',
                    ),
                    validator: AppValidators.emailValidator(context),
                    onSaved: (value) => _email = value ?? '',
                  ),
                  SizedBox(
                    height: 5,
                  ),
                ],
              )),
          Padding(
            padding: EdgeInsets.only(top: 50),
            child: CustomButton(
              onPress: _submit,
              title: 'Update',
              color: Colors.white,
              textColor: Colors.black,
            ),
          )
        ],
      ),
    );
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      bool aa = await isEmailAndPasswordUserLoggedIn();
      if (aa) {
        showDialogPass();
      } else {
        showToast('Only users signed up with email and password can update email');
      }
    } else {
      showToast('Invalid input');
    }
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
