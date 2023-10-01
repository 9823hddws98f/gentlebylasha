import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sleeptales/language_constants.dart';
import 'package:sleeptales/utils/colors.dart';
import 'package:sleeptales/utils/firestore_helper.dart';
import 'package:sleeptales/utils/global_functions.dart';
import 'package:sleeptales/widgets/custom_btn.dart';
import 'package:sleeptales/widgets/topbar_widget.dart';


class DeleteAccountScreen extends StatefulWidget {
  final String? email;
  const DeleteAccountScreen({Key? key,this.email}) : super(key: key);

  @override
  State<DeleteAccountScreen> createState() {
    return _DeleteAccountScreen();
  }
}

class _DeleteAccountScreen extends State<DeleteAccountScreen> {

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: SafeArea(
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child:SingleChildScrollView(
              child: Padding(
                  padding: EdgeInsets.all(10.w),
                  child:Column(
                    children: [
                      TopBar(heading: translation(context).deleteAccount, onPress: (){
                        Navigator.pop(context);
                      }),

                      SizedBox(height: 50.h,),

                      Padding(padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Text(translation(context).deleteAccountMessage,textAlign:TextAlign.start,style: TextStyle(fontSize: 18.sp),),
                      ),

                      Padding(padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: Text(translation(context).deleteAccountDescription,textAlign:TextAlign.start,style: TextStyle(fontSize: 18.sp),),
                      ),



                      SizedBox(height: 10.h,),

                      Padding(padding: EdgeInsets.all(16.w),
                        child: CustomButton(title: translation(context).deleteAccount, onPress: () async {

                          showLoaderDialog(context, "Deleting account...");
                          bool check = await deleteUserAccount();
                          if(check){
                            logout(context);
                          }
                          Navigator.pop(context);

                        }, color: Colors.white, textColor: textColor),

                      )

            


                    ],
                  )
              )


          ),
        ),
      ),
    );


  }
  @override
  void initState() {
    super.initState();
  }
}