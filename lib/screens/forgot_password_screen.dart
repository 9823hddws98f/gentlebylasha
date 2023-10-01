import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sleeptales/utils/global_functions.dart';
import 'package:sleeptales/widgets/custom_btn.dart';
import '../widgets/widget_email_textField.dart';
import 'authentication.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);
  @override
  State<ForgotPasswordScreen> createState() {
    return ForgotPasswordState();
  }
}

class ForgotPasswordState extends State<ForgotPasswordScreen>{
  static final _formKey = GlobalKey<FormState>();
  String? _email;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset:false,
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: 16.h,horizontal: 16.w),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              Padding(padding: EdgeInsets.only(top: 10.h),
                child:   Stack(
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
                            child: Text("Login to Sleeptales",textAlign: TextAlign.center,style: TextStyle(fontSize: 24.sp,fontWeight: FontWeight.bold),),
                          ),

                        ],
                      ),
                    )

                  ],
                ),
              ),




              Padding(padding: EdgeInsets.fromLTRB(0.w,20.h,0.w,20.h),
                child:Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Enter your email we will send a link to reset your password",style: TextStyle(fontSize: 16.sp)),
                ),
              ),

              Padding(padding: EdgeInsets.fromLTRB(0.w,10.h,0.w,10.h),
                child:Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Email:",style: TextStyle(fontSize: 16.sp)),
                ),
              ),
              CustomeEditText(
                hint: "",
                validator: (value) {
                  if (value.isEmpty) {
                    return "Please enter your email";
                  } else if (!(RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
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
                height: 40.h,
              ),





              SizedBox(
                height: 20.h,
              ),

              CustomButton(
                title: "Send Password Reset Email",
                onPress: () async {
                  if (_formKey.currentState!.validate()) {
                    //showLoaderDialog(context, "Logging in...");
                    // _formKey.currentState!.save();
                    // TODO: call backend API to register user with provided information

                    if(_email != null){
                      showLoaderDialog(context, "Sending password reset email...");
                      try {
                        Auth auth = Auth();
                        await auth.sendPasswordResetEmail(_email!);
                        Navigator.pop(context);
                        Navigator.pop(context);
                      }catch(e){
                        showToast(e.toString());
                        Navigator.pop(context);
                      }
                    }else{
                      showToast("Please enter your email");
                    }
                  }else{
                    showToast("wrong input");
                  }
                }, color: Colors.white, textColor: Colors.black,
              ),
            ],
          ),
        ),
      ),
    );
  }
}