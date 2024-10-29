import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '/constants/assets.dart';
import '/domain/services/language_constants.dart';
import '/widgets/app_scaffold/adaptive_app_bar.dart';
import '/widgets/app_scaffold/app_scaffold.dart';

class AboutScreen extends StatelessWidget with Translation {
  final String? email;

  AboutScreen({super.key, this.email});

  @override
  Widget build(BuildContext context) => AppScaffold(
        appBar: (context, isMobile) => AdaptiveAppBar(
          title: tr.about,
        ),
        bodyPadding: EdgeInsets.symmetric(),
        body: (context, isMobile) => ListView(
          children: [
            ListTile(
              leading: SvgPicture.asset(Assets.thumbIcon),
              title: Text(tr.workWithUs),
              onTap: () {},
            ),
            ListTile(
              leading: SvgPicture.asset(Assets.articleIcon),
              title: Text(tr.termsOfService),
              onTap: () {},
            ),
            ListTile(
              leading: SvgPicture.asset(Assets.verifiedUserIcon),
              title: Text(tr.privacyPolicy),
              onTap: () {},
            ),
          ],
        ),
      );
}
