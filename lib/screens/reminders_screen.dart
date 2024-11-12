import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sleeptales/utils/app_theme.dart';

import '/constants/assets.dart';
import '/domain/services/language_cubit.dart';
import '/screens/reminder_setup.dart';
import '/utils/global_functions.dart';
import '/widgets/app_scaffold/adaptive_app_bar.dart';
import '/widgets/app_scaffold/app_scaffold.dart';

class RemindersScreen extends StatelessWidget with Translation {
  final String? email;

  RemindersScreen({super.key, this.email});

  final _reminderItems = [
    {
      'icon': Assets.spaBlack,
      'isSvg': true,
      'heading': 'Mindfulness and Meditation',
      'reminderID': 11,
      'description':
          'Improve your sleep, enhance your focus, and boost your quality of life by practicing mindfulness or meditation on a daily basis.',
      'description2': 'When would you like to set a mindfulness or meditation reminder?',
      'notification':
          'Take a moment to pause, breathe, and reconnect with the present moment.',
    },
    {
      'icon': Icons.alarm,
      'isSvg': false,
      'heading': 'Bedtime',
      'reminderID': 12,
      'description': 'Going to bed at the same time each night is key to healthy sleep.',
      'description2': 'What time would you like to get ready for bed?',
      'notification':
          'Time to rest and recharge. Enjoy a peaceful bedtime routine for a rejuvenating sleep.',
    },
    {
      'icon': Icons.mood,
      'isSvg': false,
      'heading': 'Mood check-in',
      'reminderID': 13,
      'description': 'Description required from client',
      'description2': 'When would you like to set a mood check-in reminder?',
      'notification':
          'Take a moment to check in with yourself. Reflect on your mood and embrace positivity.',
    },
    {
      'icon': Assets.localFloristBlack,
      'isSvg': true,
      'heading': 'Grattitude check-in',
      'reminderID': 14,
      'description': 'Description required from client',
      'description2': 'When would you like to set a gratitude check-in reminder?',
      'notification': 'Reflect on blessings. Embrace gratitude.',
    },
    {
      'icon': Assets.menuBookBlack,
      'isSvg': true,
      'heading': 'Daily reflection',
      'reminderID': 15,
      'description': 'Description required from client',
      'description2': 'When would you like to set a daily reflection reminder?',
      'notification': 'Pause. Reflect. Find meaning.',
    },
    {
      'icon': Icons.dark_mode,
      'isSvg': false,
      'heading': 'Sleep check-in',
      'reminderID': 16,
      'description': 'Description required from client',
      'description2': 'When would you like to set a sleep check-in reminder?',
      'notification': 'Check in on your sleep',
    },
  ];

  @override
  Widget build(BuildContext context) => AppScaffold(
        appBar: (_, __) => const AdaptiveAppBar(title: 'Reminders'),
        body: (context, _) => ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: AppTheme.sidePadding),
          itemCount: _reminderItems.length,
          itemBuilder: (context, index) => _buildReminderTile(
            context,
            _reminderItems[index],
          ),
        ),
      );

  Widget _buildReminderTile(BuildContext context, Map<String, dynamic> item) => ListTile(
        leading: item['isSvg'] == true
            ? SvgPicture.asset(
                item['icon'],
                colorFilter: ColorFilter.mode(
                  Theme.of(context).colorScheme.onSurfaceVariant,
                  BlendMode.srcIn,
                ),
              )
            : Icon(item['icon']),
        title: Text(item['heading']),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () => pushName(
          context,
          ReminderSetupScreen(
            heading: item['heading'],
            type: 0,
            reminderID: item['reminderID'],
            description: item['description'],
            description2: item['description2'],
            notificationDescription: item['notification'],
          ),
        ),
      );
}
