import 'package:flutter/material.dart';

import '/domain/services/language_cubit.dart';
import '/helper/global_functions.dart';
import '/utils/app_theme.dart';
import '/widgets/app_scaffold/adaptive_app_bar.dart';
import '/widgets/app_scaffold/app_scaffold.dart';
import 'reminder_model.dart';
import 'widgets/reminder_setup.dart';

class RemindersScreen extends StatelessWidget with Translation {
  final String? email;

  RemindersScreen({super.key, this.email});

  @override
  Widget build(BuildContext context) => AppScaffold(
        appBar: (_, __) => AdaptiveAppBar(title: tr.reminders),
        body: (context, _) {
          final colors = Theme.of(context).colorScheme;
          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: AppTheme.sidePadding),
            itemCount: ReminderModel.all.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) => _buildReminderTile(
              context,
              colors,
              ReminderModel.all[index],
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
        title: Text(item.heading(tr)),
        trailing: const Icon(Icons.arrow_forward),
        onTap: () => pushName(
          context,
          ReminderSetupScreen(item),
        ),
      );
}
