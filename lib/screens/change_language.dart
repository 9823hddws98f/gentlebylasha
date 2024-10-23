import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '/widgets/topbar_widget.dart';
import '../language_constants.dart';
import '../languages.dart';
import '../main.dart';

class ChangeLanguageScreen extends StatefulWidget {
  final String? email;
  const ChangeLanguageScreen({super.key, this.email});

  @override
  State<ChangeLanguageScreen> createState() => _ChangeLanguageScreen();
}

class _ChangeLanguageScreen extends State<ChangeLanguageScreen> {
  // default selection
  int languageIndex = 0;

  Future<void> _handleLanguageChange(int index) async {
    final locale = await setLocale(Language.languageList().elementAt(index).languageCode);

    if (!mounted) return;
    MyApp.setLocale(context, locale);

    setState(() => languageIndex = index);
  }

  Future<void> getCurrentLanguageIndex() async {
    String languageCode = await getLanguageCode();
    if (languageCode == "de") {
      languageIndex = 1;
    } else {
      languageIndex = 0;
    }
    setState(() {});
  }

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
                          heading: translation(context).changeLanguage,
                          onPress: () {
                            Navigator.pop(context);
                          }),
                      SizedBox(
                        height: 20.h,
                      ),
                      ListTile(
                        title: const Text('English'),
                        trailing: languageIndex == 0
                            ? const Icon(
                                Icons.check,
                                color: Colors.white,
                              )
                            : null,
                        onTap: () => _handleLanguageChange(0),
                      ),
                      ListTile(
                        title: const Text('Dutch'),
                        trailing: languageIndex == 1
                            ? const Icon(
                                Icons.check,
                                color: Colors.white,
                              )
                            : null,
                        onTap: () => _handleLanguageChange(1),
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
    getCurrentLanguageIndex();
  }
}
