import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class ReminderModel {
  final Object icon;
  final bool everyday;
  final String heading;
  final int reminderID;
  final String description;
  final String description2;
  final String notificationDescription;

  const ReminderModel({
    required this.icon,
    this.everyday = false,
    required this.heading,
    required this.reminderID,
    required this.description,
    required this.description2,
    required this.notificationDescription,
  }) : assert(icon is String || icon is IconData, 'icon must be a String or IconData');

  Widget buildIcon(ColorScheme colors) => icon is String
      ? SvgPicture.asset(
          icon as String,
          colorFilter: ColorFilter.mode(colors.onSurfaceVariant, BlendMode.srcIn),
        )
      : Icon(icon as IconData);
}
