import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sleeptales/constants/assets.dart';

import '/screens/reminder_setup.dart';
import '/utils/global_functions.dart';
import '/widgets/topbar_widget.dart';
import '../constants/language_constants.dart';

class RemindersScreen extends StatefulWidget {
  final String? email;
  const RemindersScreen({super.key, this.email});

  @override
  State<RemindersScreen> createState() => _RemindersScreen();
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
                  padding: EdgeInsets.all(10),
                  child: Column(
                    children: [
                      TopBar(
                          heading: translation().reminders,
                          onPress: () {
                            Navigator.pop(context);
                          }),
                      SizedBox(
                        height: 20,
                      ),
                      ListTile(
                        leading: SvgPicture.asset(Assets.spaBlack),
                        title: Text(translation().mindfulnessAndMeditation),
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
                        title: Text(translation().bedtime),
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
                        title: Text(translation().moodCheckIn),
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
                        leading: SvgPicture.asset(Assets.localFloristBlack),
                        title: Text(translation().gratitudeCheckIn),
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
                        leading: SvgPicture.asset(Assets.menuBookBlack),
                        title: Text(translation().dailyReflection),
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
                        title: Text(translation().sleepCheckIn),
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
