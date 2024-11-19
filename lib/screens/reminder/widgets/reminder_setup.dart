import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '/domain/services/reminder_service.dart';
import '/helper/global_functions.dart';
import '/utils/app_theme.dart';
import '/utils/common_extensions.dart';
import '/utils/enums.dart';
import '/utils/get.dart';
import '/utils/modals.dart';
import '/utils/tx_button.dart';
import '/widgets/app_scaffold/adaptive_app_bar.dart';
import '/widgets/app_scaffold/app_scaffold.dart';
import '/widgets/app_scaffold/bottom_panel_spacer.dart';
import '../reminder_model.dart';
import 'day_selector.dart';

class ReminderSetupScreen extends StatefulWidget {
  final ReminderModel item;

  const ReminderSetupScreen(this.item, {super.key});

  @override
  State<ReminderSetupScreen> createState() => _ReminderSetupScreen();
}

class _ReminderSetupScreen extends State<ReminderSetupScreen> {
  final _reminderService = Get.the<ReminderService>();

  TimeOfDay _selectedTime = TimeOfDay.now();
  List<bool> _selectedDays = List.filled(7, false);
  bool _getReminders = false;

  ReminderModel get _item => widget.item;

  @override
  Widget build(BuildContext context) => AppScaffold(
        appBar: (_, __) => AdaptiveAppBar(title: _item.heading),
        body: (context, _) => DefaultTextStyle.merge(
          style: TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
          child: _buildContent(),
        ),
      );

  @override
  void initState() {
    super.initState();
    _loadSavedSettings();
  }

  Widget _buildContent() => BottomPanelSpacer.padding(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: _buildReminderList()),
            _buildGetRemindersRow(),
            SizedBox(height: 24),
            _buildSaveButton(),
            SizedBox(height: AppTheme.sidePadding),
          ],
        ),
      );

  Widget _buildGetRemindersRow() => Row(
        children: [
          Expanded(
            child: Text(
              'Get reminders',
              textAlign: TextAlign.left,
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          CupertinoSwitch(
            value: _getReminders,
            onChanged: _handleGetReminders,
          )
        ],
      );

  Widget _buildReminderList() => ListView(
        children: [
          SizedBox.shrink(),
          Text(_item.description),
          Text(_item.description2),
          _buildTimeSelector(),
          if (_item.everyday) _buildWeekdays(),
        ].interleaveWith(SizedBox(height: 24)),
      );

  Widget _buildSaveButton() => TxButton.filled(
        label: Text('Save'),
        color: RoleColor.secondary,
        onPressVoid: _saveSettings,
        onSuccess: () => Navigator.pop(context),
      );

  Widget _buildTimeSelector() => Center(
        child: TxButton.filled(
          icon: Icons.access_alarm,
          label: Text(_selectedTime.format(context)),
          color: RoleColor.secondary,
          dense: true,
          showSuccess: false,
          onPressVoid: () => _selectTime(context),
        ),
      );

  Widget _buildWeekdays() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(7, (i) => i)
            .map((i) => DaySelector(
                  dayInitial: ['S', 'M', 'T', 'W', 'T', 'F', 'S'][i],
                  isSelected: _selectedDays[(i + 6) % 7],
                  onSelected: (selected) => _handleWeekdayChoose((i + 6) % 7, selected),
                ))
            .toList(),
      );

  Future<void> _handleGetReminders(bool value) async {
    setState(() => _getReminders = value);
  }

  // Helper Methods
  void _handleWeekdayChoose(int index, bool selected) {
    setState(() => _selectedDays[index] = selected);
  }

  Future<void> _loadSavedSettings() async {
    final time = await _reminderService.getTimeOfDay(_item.heading);
    final enabled = await _reminderService.isReminderEnabled(_item.heading);

    if (_item.everyday) {
      final days = await _reminderService.getSelectedDays();
      if (mounted) {
        setState(() {
          _selectedDays = days;
          _selectedTime = time;
          _getReminders = enabled;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _selectedTime = time;
          _getReminders = enabled;
        });
      }
    }
  }

  Future<void> _saveSettings() async {
    if (!_getReminders) {
      await _reminderService.cancelReminder(_item.reminderID);
    } else {
      if (_item.everyday && _selectedDays.every((day) => !day)) {
        showToast('Please select at least 1 day');
        return;
      }

      if (_item.everyday) {
        await _reminderService.setWeeklyReminder(
          id: _item.reminderID,
          title: _item.heading,
          description: _item.notificationDescription,
          time: _selectedTime,
          days: _selectedDays,
        );
      } else {
        await _reminderService.setDailyReminder(
          id: _item.reminderID,
          title: _item.heading,
          description: _item.notificationDescription,
          time: _selectedTime,
        );
      }
    }

    if (_item.everyday) {
      await _reminderService.saveDaysOfWeek(_selectedDays);
    }
    await _reminderService.saveTimeOfDay(_item.heading, _selectedTime);
    await _reminderService.saveReminderEnabled(_item.heading, _getReminders);
  }

  Future<void> _selectTime(BuildContext context) async {
    final selectedTime = await Modals.showTimeOfDayPicker(
      context,
      initialTime: _selectedTime,
    );
    if (selectedTime != null) {
      setState(() => _selectedTime = selectedTime);
    }
  }
}
