import 'dart:async';

import 'package:flutter/material.dart';

import 'enums.dart';
import 'tx_button.dart';

class Modals {
  static Future<bool> confirm(
    BuildContext context, {
    Widget? content,
    String? text,
  }) async =>
      true ==
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('დაადასტურეთ'),
          content: content ?? Text(text ?? 'გსურთ დაადასტუროთ მოქმედება?'),
          actions: [
            TxButton.text(
              label: const Text('არა'),
              color: RoleColor.secondary,
              showSuccess: false,
              onPressVoid: () => Navigator.pop(context, false),
            ),
            TxButton.text(
              label: const Text('დიახ'),
              showSuccess: false,
              onPressVoid: () => Navigator.pop(context, true),
            ),
          ],
        ),
      );

  static Future<bool> confirmPop(BuildContext context) => confirm(
        context,
        text: 'ცვლილებები არ არის შენახული. ნამდვილად გსურთ გამოსვლა?',
      );

  static Future<bool> confirmDelete(BuildContext context) => confirm(
        context,
        text: 'ნამდვილად გსურთ ჩანაწერის წაშლა?',
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
                    label: const Text('გასუფთავება'),
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
        builder: (context) {
          final theme = Theme.of(context);
          return Theme(
            data: theme.copyWith(
              inputDecorationTheme: InputDecorationTheme(
                fillColor: theme.colorScheme.surfaceContainerHighest,
                filled: true,
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.transparent),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.transparent),
                ),
              ),
            ),
            child: Padding(
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
          );
        },
      );
}
