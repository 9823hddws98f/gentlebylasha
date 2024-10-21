import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '/widgets/custom_btn.dart';
import '/widgets/topbar_widget.dart';

class ManageSubscriptionScreen extends StatefulWidget {
  final String? email;
  const ManageSubscriptionScreen({super.key, this.email});

  @override
  State<ManageSubscriptionScreen> createState() {
    return _ManageSubscriptionScreen();
  }
}

class _ManageSubscriptionScreen extends State<ManageSubscriptionScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: SingleChildScrollView(
              child: Padding(
                  padding: EdgeInsets.all(10.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TopBar(
                          heading: "Manage Subscription",
                          onPress: () {
                            Navigator.pop(context);
                          }),
                      SizedBox(
                        height: 20.h,
                      ),
                      Center(
                        child: Text(
                          "You subscribed on IOS",
                          style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(
                        height: 20.h,
                      ),
                      Text(
                        "Your free trial began on August 9, 2021.\nYour yearly subscription will begin on August 16, 2021.\n\nHowever, if you’ve already stopped recurring payments through iTunes, then your access will lapse at that time, and you won’t be charged.\n\nIf you would like to stop recurring payments, you can do so here.Unfortunately, we’re unable to do so on your behalf.",
                        style: TextStyle(fontSize: 16.sp, height: 1.5),
                      ),
                      SizedBox(
                        height: 20.h,
                      ),
                      Center(
                        child: Text(
                          "Questions?",
                          style: TextStyle(fontSize: 16.sp),
                        ),
                      ),
                      SizedBox(
                        height: 5.h,
                      ),
                      CustomButton(
                          title: "Visit help center",
                          onPress: () {},
                          color: Colors.white,
                          textColor: Colors.black)
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
