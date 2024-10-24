import 'dart:convert';

import '/domain/services/activity_log_service.dart';

class ActivityLog {
  final String id;
  final String title;
  final String userId;
  final String? subtitle;
  final ActivityType activityType;
  final DateTime timestamp;
  final String? extra;

  ActivityLog({
    required this.id,
    required this.title,
    required this.userId,
    this.subtitle,
    required this.activityType,
    required this.timestamp,
    this.extra,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'userId': userId,
      'subtitle': subtitle,
      'activityType': activityType.name,
      'timestamp': timestamp.toUtc().millisecondsSinceEpoch,
      'extra': extra,
    };
  }

  factory ActivityLog.fromMap(Map<String, dynamic> map) {
    return ActivityLog(
      id: map['id'] as String,
      title: map['title'] as String,
      userId: map['userId'] as String,
      subtitle: map['subtitle'] != null ? map['subtitle'] as String : null,
      activityType: ActivityType.values.byName(map['activityType'] as String),
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int, isUtc: true)
          .toLocal(),
      extra: map['extra'] != null ? map['extra'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory ActivityLog.fromJson(String source) =>
      ActivityLog.fromMap(json.decode(source) as Map<String, dynamic>);
}
