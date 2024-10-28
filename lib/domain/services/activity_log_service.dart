import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '/domain/blocs/activity_log/activity_log.dart';
import '/domain/services/crud_service.dart';

enum ActivityType {
  subscription,
  favorite,
  user;

  String get displayName => switch (this) {
        subscription => 'Subscription',
        favorite => 'Favorite',
        user => 'User',
      };
}

mixin ActivityLogger {
  final _activityLogService = ActivityLogService();

  Future<void> logActivity(
    ActivityType type,
    String title, {
    String? subtitle,
    String? extra,
  }) {
    return _activityLogService.create(ActivityLog(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: FirebaseAuth.instance.currentUser!.uid,
      title: title,
      subtitle: subtitle,
      timestamp: DateTime.now(),
      activityType: type,
      extra: extra,
    ));
  }
}

class ActivityLogService implements CrudService<ActivityLog> {
  final CollectionReference<Map<String, dynamic>> _collectionReference =
      FirebaseFirestore.instance.collection('activity_log');

  @override
  Future<void> create(ActivityLog log) => _collectionReference.add(log.toMap());

  @override
  Future<List<ActivityLog>> getAll() {
    return _collectionReference.get().then((snapshot) {
      return snapshot.docs.map((doc) {
        return ActivityLog.fromMap(doc.data());
      }).toList();
    });
  }

  @override
  Stream<List<ActivityLog>> watchAll() =>
      _collectionReference.snapshots().map((snapshot) {
        return snapshot.docs.map((doc) {
          return ActivityLog.fromMap(doc.data());
        }).toList();
      });

  Stream<List<ActivityLog>> watchAllUser(String userId) {
    return _collectionReference
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return ActivityLog.fromMap(doc.data());
      }).toList();
    });
  }

  @override
  Future<void> delete(String id) => throw UnimplementedError();

  @override
  Future<ActivityLog> getById(String id) => throw UnimplementedError();

  @override
  Future<void> update(ActivityLog log) => throw UnimplementedError();

  @override
  Stream<ActivityLog> watchById(String id) => throw UnimplementedError();
}
