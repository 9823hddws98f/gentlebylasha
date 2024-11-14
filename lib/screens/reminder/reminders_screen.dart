import 'package:flutter/material.dart';

import '/constants/assets.dart';
import '/domain/services/language_cubit.dart';
import '/utils/app_theme.dart';
import '/utils/global_functions.dart';
import '/widgets/app_scaffold/adaptive_app_bar.dart';
import '/widgets/app_scaffold/app_scaffold.dart';
import 'reminder_model.dart';
import 'widgets/reminder_setup.dart';

class RemindersScreen extends StatelessWidget with Translation {
  final String? email;

  RemindersScreen({super.key, this.email});

  static const _reminderItems = [
    ReminderModel(
      icon: Assets.spaBlack,
      heading: 'Mindfulness and Meditation',
      reminderID: 11,
      description:
          'Improve your sleep, enhance your focus, and boost your quality of life by practicing mindfulness or meditation on a daily basis.',
      description2: 'When would you like to set a mindfulness or meditation reminder?',
      notificationDescription:
          'Take a moment to pause, breathe, and reconnect with the present moment.',
    ),
    ReminderModel(
      icon: Icons.alarm,
      everyday: true,
      heading: 'Bedtime',
      reminderID: 12,
      description: 'Going to bed at the same time each night is key to healthy sleep.',
      description2: 'What time would you like to get ready for bed?',
      notificationDescription:
          'Time to rest and recharge. Enjoy a peaceful bedtime routine for a rejuvenating sleep.',
    ),
    ReminderModel(
      icon: Icons.mood,
      heading: 'Mood check-in',
      reminderID: 13,
      description: 'Description required from client',
      description2: 'When would you like to set a mood check-in reminder?',
      notificationDescription:
          'Take a moment to check in with yourself. Reflect on your mood and embrace positivity.',
    ),
    ReminderModel(
      icon: Assets.localFloristBlack,
      heading: 'Grattitude check-in',
      reminderID: 14,
      description: 'Description required from client',
      description2: 'When would you like to set a gratitude check-in reminder?',
      notificationDescription: 'Reflect on blessings. Embrace gratitude.',
    ),
    ReminderModel(
      icon: Assets.menuBookBlack,
      heading: 'Daily reflection',
      reminderID: 15,
      description: 'Description required from client',
      description2: 'When would you like to set a daily reflection reminder?',
      notificationDescription: 'Pause. Reflect. Find meaning.',
    ),
    ReminderModel(
      icon: Icons.dark_mode,
      heading: 'Sleep check-in',
      reminderID: 16,
      description: 'Description required from client',
      description2: 'When would you like to set a sleep check-in reminder?',
      notificationDescription: 'Check in on your sleep',
    ),
  ];

  @override
  Widget build(BuildContext context) => AppScaffold(
        appBar: (_, __) => const AdaptiveAppBar(title: 'Reminders'),
        body: (context, _) {
          final colors = Theme.of(context).colorScheme;
          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: AppTheme.sidePadding),
            itemCount: _reminderItems.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) => _buildReminderTile(
              context,
              colors,
              _reminderItems[index],
            ),
          );
        },
      );

  Widget _buildReminderTile(
    BuildContext context,
    ColorScheme colors,
    ReminderModel item,
  ) =>
      ListTile(
        leading: item.buildIcon(colors),
        title: Text(item.heading),
        trailing: const Icon(Icons.arrow_forward),
        onTap: () => pushName(
          context,
          ReminderSetupScreen(item),
        ),
      );
}
