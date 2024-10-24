import 'package:flutter/material.dart';

import '/screens/home_screen.dart';
import '/utils/colors.dart';
import '/utils/global_functions.dart';
import '/utils/tx_button.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  bool _isAnnuallySelected = true;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Unlock Sleeptales',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w500,
              ),
            ),
            _buildBenefitItem('Every week new content'),
            _buildBenefitItem('More then 100 + sleep stories & guided meditations'),
            _buildBenefitItem('Cancel anytime without questions'),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildSubscriptionButton(
                      'Annually',
                      '47,00,- \$ per month',
                      _isAnnuallySelected,
                      () => setState(() => _isAnnuallySelected = true)),
                  SizedBox(height: 16.0),
                  _buildSubscriptionButton(
                      'Monthly',
                      '11,99,-\$ per month',
                      !_isAnnuallySelected,
                      () => setState(() => _isAnnuallySelected = false)),
                ],
              ),
            ),
            Spacer(),
            TxButton.filled(
              label: Text('Try for free and subscribe'),
              onPressVoid: () {
                // TODO: Implement
                // showLoaderDialog(context, 'Signing up...');
                // Auth auth = Auth();
                // // TODO: This should happen right after oauth sign in.
                // // Here we only need to save selected goals and options.
                // AppUser? user = await auth.saveUserOboardingInfo(
                //   widget.userCredentials,
                //   widget.userCredentials.user!.displayName ?? '',
                //   widget._selectedGoalsOptions,
                //   widget._selectedOption!,
                //   _isAnnuallySelected,
                // );
                // if (user == null) {
                //   showToast("Unable to sign up");
                //   Navigator.pop(context);
                //   //Navigator.pop(context);
                // } else {
                //   if (!(widget.userCredentials.user!.emailVerified)) {
                //     auth.sendEmailVerification();
                //   }
                //   //showToast("We have sent email verification link on your provided email. kindly verify your email");
                //   await saveUser(user);
                //   Navigator.pop(context);
                pushRemoveAll(context, HomeScreen());
                // }
                // // pushRemoveAll(context, HomeScreen());
              },
            ),
            SizedBox(height: 48),
          ],
        ),
      );

  Widget _buildBenefitItem(String text) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blue,
            ),
            child: Padding(
              padding: EdgeInsets.all(2),
              child: Icon(Icons.check, size: 15, color: Colors.white),
            ),
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 18),
          ),
        )
      ],
    );
  }

  Widget _buildSubscriptionButton(
      String buttonText, String priceText, bool isSelected, VoidCallback onPressed) {
    return Column(
      children: [
        TextButton(
          style: TextButton.styleFrom(
            backgroundColor: isSelected ? blueAccentColor : lightBlueWithOpacity,
            foregroundColor: isSelected ? Colors.white : lightBlueColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: onPressed,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  buttonText,
                  style: TextStyle(
                    fontSize: 18.0,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  priceText,
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.white,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
