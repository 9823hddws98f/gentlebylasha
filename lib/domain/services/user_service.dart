import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '/domain/blocs/user/app_user.dart';
import '/utils/get.dart';
import 'activity_log_service.dart';
import 'language_cubit.dart';

/// The profile of the signed-in user in `users/{uid}`. Listing, creating and
/// deleting profiles happens on the server (admin, Cloud Functions).
class UsersService with ActivityLogger {
  final CollectionReference<Map<String, dynamic>> _collectionReference =
      FirebaseFirestore.instance.collection('users');

  Future<void> update(AppUser user) {
    return _collectionReference.doc(user.id).update(user.toMap()).then((_) {
      logActivity(
        ActivityType.user,
        'User updated',
        subtitle: user.email,
        extra: user.id,
      );
    });
  }

  Stream<AppUser> watchById(String id) {
    return _collectionReference.doc(id).snapshots().map((doc) => doc.data() != null
        ? AppUser.fromMap(doc.data()!)
        : throw Exception('User not found'));
  }

  /// Waits briefly for the profile written at sign-up; creates it from the
  /// auth account if it never shows up (e.g. sign-up was interrupted).
  Future<AppUser> getOrCreate(User authUser) async {
    final ref = _collectionReference.doc(authUser.uid);
    try {
      final snap = await ref
          .snapshots()
          .firstWhere((doc) => doc.exists)
          .timeout(const Duration(seconds: 5));
      return AppUser.fromMap(snap.data()!);
    } on TimeoutException {
      final user = AppUser(
        id: authUser.uid,
        email: authUser.email ?? '',
        name: authUser.displayName ?? '',
        photoURL: authUser.photoURL ?? '',
        language: Get.the<LanguageCubit>().languageCode,
        createdAt: DateTime.now(),
        role: UserRole.client,
      );
      await ref.set(user.toMap(), SetOptions(merge: true));
      return user;
    }
  }
}
