import 'package:flutter/material.dart';
import 'package:sleeptales/widgets/app_scaffold/adaptive_app_bar.dart';
import 'package:sleeptales/widgets/app_scaffold/app_scaffold.dart';

import '/widgets/custom_btn.dart';

class ManageSubscriptionScreen extends StatefulWidget {
  final String? email;
  const ManageSubscriptionScreen({super.key, this.email});

  @override
  State<ManageSubscriptionScreen> createState() => _ManageSubscriptionScreen();
}

class _ManageSubscriptionScreen extends State<ManageSubscriptionScreen> {
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: (text, isMobile) => AdaptiveAppBar(
        title: 'Manage Subscription',
      ),
      body: (context, isMobile) => ListView(
        children: [
          SizedBox(
            height: 20,
          ),
          Center(
            child: Text(
              "You subscribed on IOS",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Text(
            "Your free trial began on August 9, 2021.\nYour yearly subscription will begin on August 16, 2021.\n\nHowever, if you’ve already stopped recurring payments through iTunes, then your access will lapse at that time, and you won’t be charged.\n\nIf you would like to stop recurring payments, you can do so here.Unfortunately, we’re unable to do so on your behalf.",
            style: TextStyle(fontSize: 16, height: 1.5),
          ),
          SizedBox(
            height: 20,
          ),
          Center(
            child: Text(
              "Questions?",
              style: TextStyle(fontSize: 16),
            ),
          ),
          SizedBox(
            height: 5,
          ),
          CustomButton(
              title: "Visit help center",
              onPress: () {},
              color: Colors.white,
              textColor: Colors.black)
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }
}
