import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gentle/l10n/app_localizations.dart';

import '/domain/services/language_cubit.dart';
import '/utils/app_theme.dart';
import '/utils/get.dart';
import 'enums.dart';
import 'tx_button.dart';

class Modals {
  static AppLocalizations get _tr => Get.the<LanguageCubit>().translation;

  static Future<bool> confirm(
    BuildContext context, {
    Widget? content,
    String? text,
  }) async =>
      true ==
      await show(
        context,
        builder: (context) => AlertDialog(
          title: Text(_tr.confirm),
          content: content ?? Text(text ?? _tr.confirmQuestion),
          actions: [
            TxButton.text(
              label: Text(_tr.no),
              color: RoleColor.secondary,
              showSuccess: false,
              onPressVoid: () => Navigator.pop(context, false),
            ),
            TxButton.text(
              label: Text(_tr.yes),
              showSuccess: false,
              onPressVoid: () => Navigator.pop(context, true),
            ),
          ],
        ),
      );

  static Future<bool> confirmPop(BuildContext context) => confirm(
        context,
        text: _tr.confirmLeaveUnsaved,
      );

  static Future<bool> confirmDelete(BuildContext context) => confirm(
        context,
        text: _tr.confirmDeleteItem,
      );

  static Future<void> pickDateRange(
    BuildContext context, {
    DateTimeRange? initial,
    required FutureOr<void> Function(DateTimeRange?) onChange,
  }) async {
    DateTimeRange? range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(DateTime.now().year - 1),
      lastDate: DateTime(DateTime.now().year + 1),
      initialDateRange: initial,
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      builder: (context, child) => Dialog(
        child: Container(
          constraints: const BoxConstraints(
            maxWidth: 400,
            maxHeight: 700,
          ),
          padding: const EdgeInsets.all(6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Flexible(child: child!),
              if (initial != null)
                Container(
                  padding: const EdgeInsets.all(6),
                  height: 60,
                  child: TxButton.text(
                    icon: Icons.clear,
                    label: Text(_tr.clear),
                    color: RoleColor.secondary,
                    onPressVoid: () => onChange(null),
                    onSuccess: () {
                      if (context.mounted) Navigator.pop(context);
                    },
                  ),
                )
            ],
          ),
        ),
      ),
    );
    if (range != null) {
      await onChange(range);
    }
  }

  static Future<T?> show<T>(
    BuildContext context, {
    required Widget Function(BuildContext) builder,
    bool useSafeArea = true,
    bool dismissible = true,
  }) =>
      showDialog<T>(
        context: context,
        barrierDismissible: dismissible,
        useSafeArea: useSafeArea,
        builder: (context) => _wrapInTheme(context, builder: builder),
      );

  static Future<T?> showModal<T>(
    BuildContext context, {
    required Widget Function(BuildContext, ScrollController) builder,
    bool enableDrag = true,
    bool isDismissible = true,
    bool showDragHandle = true,
    bool useSafeArea = true,
    bool expand = false,
    bool scrollable = false,
    double initialSize = 0.7,
    double minSize = 0.5,
    double maxSize = 0.9,
  }) =>
      showModalBottomSheet<T>(
        context: context,
        isScrollControlled: true,
        enableDrag: enableDrag,
        isDismissible: isDismissible,
        showDragHandle: showDragHandle,
        useSafeArea: useSafeArea,
        builder: (context) => _wrapInTheme(
          context,
          builder: (context) => Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.viewInsetsOf(context).bottom,
            ),
            child: DraggableScrollableSheet(
              expand: expand,
              initialChildSize: initialSize,
              minChildSize: minSize,
              maxChildSize: maxSize,
              builder: (context, controller) {
                if (scrollable) {
                  return SingleChildScrollView(
                    controller: controller,
                    child: builder(context, controller),
                  );
                }
                return builder(context, controller);
              },
            ),
          ),
        ),
      );

  static Widget _wrapInTheme(BuildContext context, {required WidgetBuilder builder}) {
    final theme = Theme.of(context);
    return Theme(
      data: theme.copyWith(
        inputDecorationTheme: InputDecorationTheme(
          fillColor: theme.colorScheme.surfaceContainerLowest,
          filled: true,
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.transparent),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.transparent),
          ),
        ),
      ),
      child: builder(context),
    );
  }

  static Future<TimeOfDay?> showTimeOfDayPicker(
    BuildContext context, {
    TimeOfDay? initialTime,
  }) async {
    DateTime? selectedDateTime = DateTime.now();
    selectedDateTime = await showModalBottomSheet<DateTime>(
      context: context,
      useRootNavigator: true,
      showDragHandle: true,
      builder: (context) => Container(
        height: 320,
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.sidePadding),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.time,
                  initialDateTime: DateTime.now().copyWith(
                    hour: initialTime?.hour ?? TimeOfDay.now().hour,
                    minute: initialTime?.minute ?? TimeOfDay.now().minute,
                  ),
                  onDateTimeChanged: (dateTime) => selectedDateTime = dateTime,
                ),
              ),
              TxButton.filled(
                label: Text(_tr.setTime),
                color: RoleColor.secondary,
                showSuccess: false,
                onPressVoid: () => Navigator.pop(
                  context,
                  selectedDateTime,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (selectedDateTime == null) return null;
    return TimeOfDay(
      hour: selectedDateTime!.hour,
      minute: selectedDateTime!.minute,
    );
  }
}
