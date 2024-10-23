import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '/language_constants.dart';
import '/widgets/topbar_widget.dart';

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
                  padding: EdgeInsets.all(10.w),
                  child: Column(
                    children: [
                      TopBar(
                          heading: translation(context).about,
                          onPress: () {
                            Navigator.pop(context);
                          }),
                      SizedBox(
                        height: 20.h,
                      ),
                      ListTile(
                        leading: SvgPicture.asset(
                          'assets/thumb_icon.svg',
                          width: 20.h,
                          height: 20.w,
                        ),
                        title: Text(translation(context).workWithUs),
                        onTap: () {},
                      ),
                      ListTile(
                        leading: SvgPicture.asset(
                          'assets/article_icon.svg',
                          width: 20.h,
                          height: 20.w,
                        ),
                        title: Text(translation(context).termsOfService),
                        onTap: () {},
                      ),
                      ListTile(
                        leading: SvgPicture.asset(
                          'assets/verified_user_icon.svg',
                          width: 20.h,
                          height: 20.w,
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
