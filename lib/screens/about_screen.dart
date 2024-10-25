import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sleeptales/constants/assets.dart';

import '/widgets/topbar_widget.dart';
import '../constants/language_constants.dart';

class AboutScreen extends StatefulWidget {
  final String? email;
  const AboutScreen({super.key, this.email});

  @override
  State<AboutScreen> createState() {
    return _AboutScreen();
  }
}

class _AboutScreen extends State<AboutScreen> {
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
                          heading: translation(context).about,
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
                        title: Text(translation(context).workWithUs),
                        onTap: () {},
                      ),
                      ListTile(
                        leading: SvgPicture.asset(
                          Assets.articleIcon,
                          width: 20,
                          height: 20,
                        ),
                        title: Text(translation(context).termsOfService),
                        onTap: () {},
                      ),
                      ListTile(
                        leading: SvgPicture.asset(
                          Assets.verifiedUserIcon,
                          width: 20,
                          height: 20,
                        ),
                        title: Text(translation(context).privacyPolicy),
                        onTap: () {},
                      ),
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
