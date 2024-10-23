import 'package:flutter/material.dart';
import 'package:sleeptales/screens/auth/login_screen.dart';

import '/screens/home_screen.dart';
import '/utils/firestore_helper.dart';
import '../utils/global_functions.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    goToMainScreen();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: Text(
            "Gentle",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 45),
          ),
        ),
      );

  void goToMainScreen() async {
    var user = await getUser();
    await fetchCategories();
    fetchCategoriesArrayAndSave();
    if (user.email != "null" && user.email != null) {
      Navigator.pushAndRemoveUntil(context,
          MaterialPageRoute(builder: (context) => HomeScreen()), (route) => false);
    } else {
      Navigator.pushAndRemoveUntil(context,
          MaterialPageRoute(builder: (context) => LoginScreen()), (route) => false);
    }
  }
}
