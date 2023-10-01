import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sleeptales/models/user_model.dart';
import 'package:sleeptales/screens/authentication.dart';
import 'package:sleeptales/screens/home_screen.dart';
import 'package:sleeptales/utils/colors.dart';
import 'package:sleeptales/utils/global_functions.dart';
import 'package:sleeptales/widgets/custom_btn.dart';

class SubscriptionScreen extends StatefulWidget {

  Function() callback;
  UserCredential userCredentials;
  List<int> _selectedGoalsOptions;
  int? _selectedOption;
  String name ;
  SubscriptionScreen(this.callback,this.name,this.userCredentials,this._selectedGoalsOptions,this._selectedOption);

  @override
  _SubscriptionScreenState createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  bool _isAnnuallySelected = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16.h,horizontal: 16.w),
              child: Text(
                'Unlock Sleeptales',
                style: TextStyle(fontSize: 32.0.sp),
              ),
            ),
            _buildBenefitItem('Every week new content'),
            _buildBenefitItem('More then 100 + sleep stories & guided meditations'),
            _buildBenefitItem('Cancel anytime without questions'),

            Padding(padding: EdgeInsets.symmetric(horizontal: 10.w,vertical: 20.h),
             child:  Column(
               crossAxisAlignment: CrossAxisAlignment.stretch,
               children: [


                 _buildSubscriptionButton(
                     'Annually', '47,00,- \$ per month', _isAnnuallySelected,
                         () => setState(() => _isAnnuallySelected = true)),
                 SizedBox(height: 16.0.h),
                 _buildSubscriptionButton(
                     'Monthly', '11,99,-\$ per month', !_isAnnuallySelected,
                         () => setState(() => _isAnnuallySelected = false)),
               ],
             ),
            ),


            Padding(
              padding:EdgeInsets.all(16.0.h),
              child: CustomButton(title: "Try for free and subscribe", onPress: () async {

                showLoaderDialog(context, "Signing up...");
                Auth auth = Auth();
                UserModel?  user = await auth.addUserToServer(widget.userCredentials,widget.name,widget._selectedGoalsOptions,widget._selectedOption!,_isAnnuallySelected);
                if(user == null){
                  showToast("Unable to sign up");
                  Navigator.pop(context);
                  //Navigator.pop(context);
                }else{
                  if(!(widget.userCredentials.user!.emailVerified))
                  auth.sendEmailVerification();
                  //showToast("We have sent email verification link on your provided email. kindly verify your email");
                  await saveUser(user);
                  Navigator.pop(context);
                  pushRemoveAll(context, HomeScreen());

                }
                // pushRemoveAll(context, HomeScreen());
              }, color: Colors.white, textColor: Colors.black)
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitItem(String text) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blue,
            ),
            child: Padding(
              padding:EdgeInsets.all(2.w),
              child: Icon(Icons.check, size:15.h,color: Colors.white),
            ),
          ),
        ),
    Expanded(
     child:
        Text(text,style: TextStyle(fontSize: 18.sp),),
    )
    ],
    );
  }

  Widget _buildSubscriptionButton(String buttonText, String priceText,
      bool isSelected, VoidCallback onPressed) {
    return Column(
      children: [
        TextButton(
          child: Padding(padding: EdgeInsets.symmetric(horizontal: 10.w,vertical: 15.h),
        child:  Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              buttonText,
              style: TextStyle(
                fontSize: 18.0.sp,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              priceText,
              style: TextStyle(
                fontSize: 16.0.sp,
                color: Colors.white,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
           ),

          style: TextButton.styleFrom(
            backgroundColor: isSelected ? blueAccentColor : lightBlueWithOpacity,
            foregroundColor: isSelected ? Colors.white : lightBlueColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.h),
            ),
          ),
          onPressed: onPressed,
        ),
      ],
    );
  }
}
