import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sleeptales/constants/assets.dart';
import 'package:sleeptales/widgets/app_scaffold/adaptive_app_bar.dart';
import 'package:sleeptales/widgets/app_scaffold/app_scaffold.dart';

import '/screens/reminder_setup.dart';
import '/utils/global_functions.dart';
import '../domain/services/language_constants.dart';

class RemindersScreen extends StatelessWidget with Translation {
  final String? email;

  RemindersScreen({super.key, this.email});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: (text, isMobile) => AdaptiveAppBar(
        title: 'Reminders',
      ),
      body: (context, isMobile) => ListView(
        children: [
          SizedBox(
            height: 20,
          ),
          ListTile(
            leading: SvgPicture.asset(Assets.spaBlack),
            title: Text(tr.mindfulnessAndMeditation),
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
            title: Text(tr.bedtime),
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
                    description2: "What time would you like to get ready for bed?",
                    notificationDescription:
                        "Time to rest and recharge. Enjoy a peaceful bedtime routine for a rejuvenating sleep.",
                  ));
            },
          ),
          ListTile(
            leading: Icon(Icons.mood, color: Colors.white),
            title: Text(tr.moodCheckIn),
            trailing: Icon(Icons.arrow_forward_ios, color: Colors.white),
            onTap: () {
              pushName(
                  context,
                  ReminderSetupScreen(
                    heading: "Mood check-in",
                    type: 0,
                    reminderID: 013,
                    description: "Description required from client",
                    description2: "When would you like to set a mood check-in reminder?",
                    notificationDescription:
                        "Take a moment to check in with yourself. Reflect on your mood and embrace positivity.",
                  ));
            },
          ),
          ListTile(
            leading: SvgPicture.asset(Assets.localFloristBlack),
            title: Text(tr.gratitudeCheckIn),
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
                    notificationDescription: "Reflect on blessings. Embrace gratitude.",
                  ));
            },
          ),
          ListTile(
            leading: SvgPicture.asset(Assets.menuBookBlack),
            title: Text(tr.dailyReflection),
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
            title: Text(tr.sleepCheckIn),
            trailing: Icon(Icons.arrow_forward_ios, color: Colors.white),
            onTap: () {
              pushName(
                  context,
                  ReminderSetupScreen(
                    heading: "Sleep check-in",
                    type: 0,
                    reminderID: 016,
                    description: "Description required from client",
                    description2: "When would you like to set a sleep check-in reminder?",
                    notificationDescription: "Check in on your sleep",
                  ));
            },
          ),
        ],
      ),
    );
  }
}
