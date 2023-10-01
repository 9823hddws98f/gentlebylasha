import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sleeptales/main.dart';
import 'package:sleeptales/page_manager.dart';
import 'package:sleeptales/utils/colors.dart';
import 'package:sleeptales/widgets/custom_btn.dart';

import '../services/service_locator.dart';

class SleepTimerScreen extends StatefulWidget {
  @override
  _SleepTimerScreenState createState() => _SleepTimerScreenState();
}

class _SleepTimerScreenState extends State<SleepTimerScreen> {
  Duration _duration = Duration(hours: 1); // Default duration of 1 hour

  bool timerSet = false;
  // Method to handle setting the sleep timer
  void _setSleepTimer() {
    getIt<PageManager>().stopTrackAfter(_duration);
    setState(() {
      timerSet = true;
    });

    // Code to handle setting the sleep timer
    // You can use the '_duration' variable to get the selected duration
  }

  // Method to handle cancelling the sleep timer
  void _cancelSleepTimer() {
    setState(() {
      timerSet = false;
    });

    // Code to handle cancelling the sleep timer
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () {
            Navigator.of(context).pop(); // Pop the screen when the cross button is pressed
          },
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
           Text('Sleep Timer',style: TextStyle(fontSize: 24.sp),),

          SizedBox(height: 20.h,),

          if(timerSet)
          if (_duration != Duration(hours: 0))...[ // Only show the scheduled timer if the duration is not 0
            Text(
              'Scheduled Timer',
              style: TextStyle(fontSize: 18),
            ),

          SizedBox(
            height: 20.h,
          ),
          Text(
            formatDuration(_duration.inMinutes),
            style: TextStyle(fontSize: 18),
          ),
  ],

          SizedBox(height: 92.h),
          Text(
            'How long do you want this playlist to play for?',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20),
          ),
          SizedBox(height: 10.h),

    CupertinoTheme(
    data: CupertinoThemeData(
    brightness: Brightness.dark,
    ),
     child: CupertinoTimerPicker(
          mode: CupertinoTimerPickerMode.hm,
          onTimerDurationChanged: (Duration duration) {
            setState(() {
              _duration = duration;
            });
          },
          initialTimerDuration: _duration,
        ),
    ),

          SizedBox(height: 30.h),

              Padding(padding: EdgeInsets.symmetric(horizontal: 16.h),
              child:  CustomButton(title: "Set Time", onPress:(){
                _setSleepTimer();
              }, color: Colors.white, textColor: textColor),
              ),


              SizedBox(height: 20.h,),
              TextButton(
                onPressed: _cancelSleepTimer,
                child: Text('Cancel Timer',style: TextStyle(color: Colors.white),),
              ),

          SizedBox(height: 20),

        ],
      ),
    );
  }

  String formatDuration(int minutes) {
    final Duration duration = Duration(minutes: minutes);
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String hours = (duration.inMinutes / 60).floor().toString();
    return "$hours hour $twoDigitMinutes minutes";
  }
}
