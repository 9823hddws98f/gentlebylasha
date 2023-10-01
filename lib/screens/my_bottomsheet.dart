import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sleeptales/screens/onboarding01.dart';
import 'package:sleeptales/screens/onboarding02.dart';
import 'package:sleeptales/screens/signup_layout.dart';
import 'package:sleeptales/screens/subscription.dart';

class MyBottomSheet extends StatefulWidget {

  int currentPage;
  UserCredential? userCredential;
  Function()? callBackLogin;
  Function()? isDissmisableBottomSheet;
  MyBottomSheet({Key? key, required this.currentPage,this.userCredential,this.callBackLogin,this.isDissmisableBottomSheet}) : super(key: key);

   @override
  _MyBottomSheetState createState() => _MyBottomSheetState();

}

class _MyBottomSheetState extends State<MyBottomSheet> {

  String name = "";

  List<int> _selectedGoalsOptions = [];
  int? _selectedOption;
   UserCredential? userCredential;


  void nextPage() {
    setState(() {
      //currentPage++;
      widget.currentPage++;
    });
  }
  callback() {

    setState(() {
      widget.currentPage++;
     // currentPage++;
    });

  }

  setSelectedGoalsOptions(List<int> _selectedGoalsOptions) {

    setState(() {
      this._selectedGoalsOptions = _selectedGoalsOptions;
    });

  }

  setSelectedOptions(int _selectedOption) {

    setState(() {
      this._selectedOption = _selectedOption;
    });

  }

  setUserCredentials(UserCredential userCredential,String name) {

    setState(() {
      this.userCredential = userCredential;
      this.name = name;
    });

  }


  void previousPage() {
    setState(() {
      widget.currentPage--;
     // currentPage--;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.89,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.h),
          topRight: Radius.circular(24.h),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if(widget.currentPage == 0)...[
            Expanded(child:
            SignupScreen(callback,setUserCredentials,widget.callBackLogin)
            )

          ]else if(widget.currentPage == 1)...[
            if (widget.userCredential != null) ...[
              Expanded(
                child: OnBoarding01Screen(
                  callback,
                  widget.userCredential!,
                  setSelectedGoalsOptions,
                ),
              ),
            ] else ...[
              Expanded(child: OnBoarding01Screen(
                  callback, userCredential!, setSelectedGoalsOptions))
            ],
          ]else if(widget.currentPage == 2)...[
            if (widget.userCredential != null) ...[
            Expanded(child:OnBoarding02Screen(callback,widget.userCredential!,setSelectedOptions))
            ]else...[
              Expanded(child:OnBoarding02Screen(callback,userCredential!,setSelectedOptions))
            ]

          ]else...[
           if (widget.userCredential != null) ...[
            Expanded(child:SubscriptionScreen(callback,name,widget.userCredential!,_selectedGoalsOptions,_selectedOption))
    ]else...[
             Expanded(child:SubscriptionScreen(callback,name,userCredential!,_selectedGoalsOptions,_selectedOption))
           ]
          ]
        ],
      ),
    );
  }
}
