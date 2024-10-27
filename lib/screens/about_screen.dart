import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sleeptales/constants/assets.dart';

import '/widgets/topbar_widget.dart';
import '../domain/services/language_constants.dart';

class AboutScreen extends StatelessWidget with Translation {
  final String? email;

  AboutScreen({super.key, this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: SingleChildScrollView(
              child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    children: [
                      TopBar(
                          heading: tr.about,
                          onPress: () {
                            Navigator.pop(context);
                          }),
                      SizedBox(
                        height: 20,
                      ),
                      ListTile(
                        leading: SvgPicture.asset(
                          Assets.thumbIcon,
                          width: 20,
                          height: 20,
                        ),
                        title: Text(tr.workWithUs),
                        onTap: () {},
                      ),
                      ListTile(
                        leading: SvgPicture.asset(
                          Assets.articleIcon,
                          width: 20,
                          height: 20,
                        ),
                        title: Text(tr.termsOfService),
                        onTap: () {},
                      ),
                      ListTile(
                        leading: SvgPicture.asset(
                          Assets.verifiedUserIcon,
                          width: 20,
                          height: 20,
                        ),
                        title: Text(tr.privacyPolicy),
                        onTap: () {},
                      ),
                    ],
                  ))),
        ),
      ),
    );
  }
}
