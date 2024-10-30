import 'package:flutter/material.dart';

import '/screens/app_container/app_container.dart';
import '/utils/app_theme.dart';
import '/utils/global_functions.dart';
import '/utils/tx_button.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  bool _isAnnuallySelected = true;

  late ColorScheme _colors;

  @override
  Widget build(BuildContext context) {
    _colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: CustomScrollView(slivers: [
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16),
              Text(
                'Unlock Sleeptales',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                ),
              ),
              _buildBenefitItem('Every week new content'),
              _buildBenefitItem('More then 100 + sleep stories & guided meditations'),
              _buildBenefitItem('Cancel anytime without questions'),
              SizedBox(height: 16.0),
              _buildSubscriptionButton(
                'Annually',
                47,
                _isAnnuallySelected,
                () => setState(() => _isAnnuallySelected = true),
              ),
              SizedBox(height: 16.0),
              _buildSubscriptionButton(
                'Monthly',
                60,
                !_isAnnuallySelected,
                () => setState(() => _isAnnuallySelected = false),
              ),
            ],
          ),
        ),
        SliverFillRemaining(
          hasScrollBody: false,
          child: Container(
            margin: EdgeInsets.only(bottom: 16),
            alignment: Alignment.bottomCenter,
            child: TxButton.filled(
              label: Text('Try for free and subscribe'),
              onPressVoid: () {
                // TODO: Implement subscription
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
                pushRemoveAll(context, AppContainer());
                // }
                // // pushRemoveAll(context, HomeScreen());
              },
            ),
          ),
        )
      ]),
    );
  }

  Widget _buildBenefitItem(String text) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _colors.primary,
              ),
              child: Icon(Icons.check, size: 18, color: Colors.white),
            ),
            SizedBox(width: 16),
            Expanded(child: Text(text))
          ],
        ),
      );

  Widget _buildSubscriptionButton(
    String buttonText,
    double price,
    bool isSelected,
    VoidCallback onPressed,
  ) =>
      TextButton(
        style: TextButton.styleFrom(
          backgroundColor: isSelected ? _colors.primary : _colors.surfaceContainerLowest,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: AppTheme.smallBorderRadius,
          ),
        ),
        onPressed: onPressed,
        child: Padding(
          padding: EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(buttonText),
              Row(
                children: [
                  Text(
                    '\$${price.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 20),
                  ),
                  Text(' / Month'),
                ],
              ),
            ],
          ),
        ),
      );
}
