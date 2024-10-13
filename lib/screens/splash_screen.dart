import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '/screens/home_screen.dart';
import '/screens/launch_screen.dart';
import '/utils/firestore_helper.dart';
import '../utils/global_functions.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // create an instance
  @override
  void initState() {
    super.initState();

    goToMainScreen();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "Gentle",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 45.sp),
          ),
        ],
      ),
    ));
  }

  void goToMainScreen() async {
    var user = await getUser();
    await fetchCategories();
    fetchCategoriesArrayAndSave();
    if (user.email != "null" && user.email != null) {
      Navigator.pushAndRemoveUntil(context,
          MaterialPageRoute(builder: (context) => HomeScreen()), (route) => false);
    } else {
      Navigator.pushAndRemoveUntil(context,
          MaterialPageRoute(builder: (context) => LaunchScreen()), (route) => false);
    }
  }
}
