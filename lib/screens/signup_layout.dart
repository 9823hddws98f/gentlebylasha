import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sleeptales/language_constants.dart';
import 'package:sleeptales/screens/authentication.dart';
import 'package:sleeptales/utils/global_functions.dart';
import 'package:sleeptales/widgets/custom_btn.dart';
import 'package:sleeptales/widgets/login_footer.dart';
import '../widgets/widget_email_textField.dart';

class SignupScreen extends StatefulWidget {


  static final _formKey = GlobalKey<FormState>();

  Function() callback;
  Function()? callbackSignUp;
  Function(UserCredential user,String name) setUser;
  SignupScreen(this.callback,this.setUser,this.callbackSignUp);
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
      body:SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
        child:SizedBox(
          height: MediaQuery.of(context).size.height * 0.95,
          child:Padding(
          padding: EdgeInsets.symmetric(vertical: 16.h,horizontal: 16.w),
          child: Form(

            key: SignupScreen._formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.max,
              children: [

                Padding(padding: EdgeInsets.only(top: 14.h),
                  child:Stack(
                    alignment: Alignment.center,
                    children: [
                      Align(
                        alignment: Alignment.topRight,
                        child: Padding(padding: EdgeInsets.fromLTRB(10.w,0.h,0.w,0.h),
                          child: IconButton(iconSize: 22, icon: Icon(Icons.close,color: Colors.white,), onPressed: (){
                            Navigator.pop(context);
                          },),
                        ),
                      ),
                      Align(
                        alignment: Alignment.center,
                        child:    Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(padding:  EdgeInsets.fromLTRB(20.w,5.h,20.w,5.h),
                              child: Text(translation(context).joinSleepytales,textAlign: TextAlign.center,style: TextStyle(fontSize: 24.sp,fontWeight: FontWeight.bold),),
                            ),

                          ],
                        ),
                      )

                    ],
                  ),
                ),

                Padding(padding: EdgeInsets.fromLTRB(0.w,30.h,0.w,10.h),
                  child:Align(
                    alignment: Alignment.centerLeft,
                    child: Text("${translation(context).yourName}:",style: TextStyle(fontSize: 16.sp)),
                  ),
                ),

                CustomeEditTextFullName(
                  hint: translation(context).name,
                  validator: (value) {
                    if (value.isEmpty) {
                      return translation(context).name;
                    }
                    return null;
                  },
                  inputType: TextInputType.name,
                  onchange: (String value) {
                    _name = value;
                  },
                ),
                SizedBox(
                  height: 5.h,
                ),
                Padding(padding: EdgeInsets.fromLTRB(0.w,10.h,0.w,10.h),
                  child:   Align(
                    alignment: Alignment.centerLeft,
                    child: Text("${translation(context).email}:",style: TextStyle(fontSize: 16.sp)),
                  ),
                ),

                CustomeEditText(
                  hint: "example@gmail.com",
                  validator: (value) {
                    if (value.isEmpty) {
                      return translation(context).enterEmail;
                    } else if (!(RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                        .hasMatch(value))) {
                      return translation(context).enterValidEmail;
                    }
                    return null;
                  },
                  inputType: TextInputType.emailAddress,
                  // controller: provider.email,
                  onchange: (String value) {
                    _email = value;
                  },
                ),

                SizedBox(
                  height: 5.h,
                ),
                Padding(padding: EdgeInsets.fromLTRB(0.w,10.h,0.w,10.h),
                  child:   Align(
                    alignment: Alignment.centerLeft,
                    child: Text("${translation(context).password}:",style: TextStyle(fontSize: 16.sp)),
                  ),
                ),
                PasswordEditText(
                  isHide: hide,
                  //controller: provider.password,
                  onTap: () {
                    setState(() {
                      hide = !hide;
                    });
                  },
                  validator: (value) {
                    if (value.isEmpty) {
                      return translation(context).enterPassword;
                    } else if (value.length < 6) {
                      return translation(context).passwordCaracterLimit;
                    }
                    return null;
                  },
                  onchange: (String value) {

                    _password = value;
                  },
                ),


                SizedBox(
                  height: 40.h,
                ),


                LoginFotter(alignment: MainAxisAlignment.start,sentenceText: "${translation(context).alreadyHaveAnAccount}?", loginSingUpText:translation(context).login, onPress: (){
                  Navigator.pop(context);
                  widget.callbackSignUp!();
                }),

                SizedBox(
                  height: 20.h,
                ),

                CustomButton(
                  title: translation(context).signUp,
                  onPress: () async {
                    if (SignupScreen._formKey.currentState!.validate()) {
                      SignupScreen._formKey.currentState!.save();
                      // TODO: call backend API to register user with provided information
                      showLoaderDialog(context, "${translation(context).authenticationEmail}...");
                      Auth auth = Auth();
                      UserCredential? userC = await auth.signUpWithEmail(_name!, _email!, _password!);
                      if(userC != null) {
                        setState(() {
                          widget.setUser(userC,_name!);
                          Navigator.pop(context);
                          widget.callback();
                        });
                      }else{
                        Navigator.pop(context);
                      }



                    }else{
                      showToast(translation(context).pleaseFillForm);
                    }
                  }, color: Colors.white, textColor: Colors.black,
                ),
              ],
            ),
          ),
        ),
      )));
  }
}