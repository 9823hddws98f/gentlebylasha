import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '/language_constants.dart';
import '/screens/reminder_setup.dart';
import '/utils/global_functions.dart';
import '/widgets/topbar_widget.dart';

class RemindersScreen extends StatefulWidget {
  final String? email;
  const RemindersScreen({super.key, this.email});

  @override
  State<RemindersScreen> createState() {
    return _RemindersScreen();
  }
}

class _RemindersScreen extends State<RemindersScreen> {
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
                          heading: translation(context).reminders,
                          onPress: () {
                            Navigator.pop(context);
                          }),
                      SizedBox(
                        height: 20.h,
                      ),
                      ListTile(
                        leading: SvgPicture.asset("assets/spa_black.svg"),
                        title: Text(translation(context).mindfulnessAndMeditation),
                        trailing: Icon(Icons.arrow_forward_ios, color: Colors.white),
                        onTap: () {
                          pushName(
                              context,
                              ReminderSetupScreen(
                                heading: "Mindfulness and Meditation",
                                type: 0,
                                reminderID: 011,
                                description:
                                    "Improve your sleep, enhance your focus, and boost your quality of life by practicing mindfulness or meditation on a daily basis.",
                                description2:
                                    "When would you like to set a mindfulness or meditation reminder?",
                                notificationDescription:
                                    "Take a moment to pause, breathe, and reconnect with the present moment.",
                              ));
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.alarm, color: Colors.white),
                        title: Text(translation(context).bedtime),
                        trailing: Icon(Icons.arrow_forward_ios, color: Colors.white),
                        onTap: () {
                          pushName(
                              context,
                              ReminderSetupScreen(
                                heading: "Bedtime",
                                type: 1,
                                reminderID: 12,
                                description:
                                    "Going to bed at the same time each night is key to healthy sleep.",
                                description2:
                                    "What time would you like to get ready for bed?",
                                notificationDescription:
                                    "Time to rest and recharge. Enjoy a peaceful bedtime routine for a rejuvenating sleep.",
                              ));
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.mood, color: Colors.white),
                        title: Text(translation(context).moodCheckIn),
                        trailing: Icon(Icons.arrow_forward_ios, color: Colors.white),
                        onTap: () {
                          pushName(
                              context,
                              ReminderSetupScreen(
                                heading: "Mood check-in",
                                type: 0,
                                reminderID: 013,
                                description: "Description required from client",
                                description2:
                                    "When would you like to set a mood check-in reminder?",
                                notificationDescription:
                                    "Take a moment to check in with yourself. Reflect on your mood and embrace positivity.",
                              ));
                        },
                      ),
                      ListTile(
                        leading: SvgPicture.asset("assets/local_florist_black.svg"),
                        title: Text(translation(context).gratitudeCheckIn),
                        trailing: Icon(Icons.arrow_forward_ios, color: Colors.white),
                        onTap: () {
                          pushName(
                              context,
                              ReminderSetupScreen(
                                heading: "Grattitude check-in",
                                type: 0,
                                reminderID: 014,
                                description: "Description required from client",
                                description2:
                                    "When would you like to set a gratitude check-in reminder?",
                                notificationDescription:
                                    "Reflect on blessings. Embrace gratitude.",
                              ));
                        },
                      ),
                      ListTile(
                        leading: SvgPicture.asset("assets/menu_book_black.svg"),
                        title: Text(translation(context).dailyReflection),
                        trailing: Icon(Icons.arrow_forward_ios, color: Colors.white),
                        onTap: () {
                          pushName(
                              context,
                              ReminderSetupScreen(
                                heading: "Daily reflection",
                                type: 0,
                                reminderID: 015,
                                description: "Description required from client",
                                description2:
                                    "When would you like to set a daily reflection reminder?",
                                notificationDescription: "Pause. Reflect. Find meaning.",
                              ));
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.dark_mode, color: Colors.white),
                        title: Text(translation(context).sleepCheckIn),
                        trailing: Icon(Icons.arrow_forward_ios, color: Colors.white),
                        onTap: () {
                          pushName(
                              context,
                              ReminderSetupScreen(
                                heading: "Sleep check-in",
                                type: 0,
                                reminderID: 016,
                                description: "Description required from client",
                                description2:
                                    "When would you like to set a sleep check-in reminder?",
                                notificationDescription: "Check in on your sleep",
                              ));
                        },
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
