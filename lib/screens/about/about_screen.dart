import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '/constants/assets.dart';
import '/domain/services/language_cubit.dart';
import '/utils/app_theme.dart';
import '/utils/common_extensions.dart';
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
        body: (context, isMobile) {
          final colorFilter = ColorFilter.mode(
            Theme.of(context).colorScheme.onSurface,
            BlendMode.srcIn,
          );
          return ListView(
            padding: EdgeInsets.symmetric(vertical: AppTheme.sidePadding),
            children: <Widget>[
              ListTile(
                leading: SvgPicture.asset(
                  Assets.thumbIcon,
                  colorFilter: colorFilter,
                ),
                title: Text(tr.workWithUs),
                onTap: () {},
              ),
              ListTile(
                leading: SvgPicture.asset(
                  Assets.articleIcon,
                  colorFilter: colorFilter,
                ),
                title: Text(tr.termsOfService),
                onTap: () {},
              ),
              ListTile(
                leading: SvgPicture.asset(
                  Assets.verifiedUserIcon,
                  colorFilter: colorFilter,
                ),
                title: Text(tr.privacyPolicy),
                onTap: () {},
              ),
            ].interleaveWith(SizedBox(height: 8)),
          );
        },
      );
}
