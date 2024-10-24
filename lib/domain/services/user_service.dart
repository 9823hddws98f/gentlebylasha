import 'package:cloud_firestore/cloud_firestore.dart';

import '/domain/blocs/user/app_user.dart';
import '/domain/services/crud_service.dart';
import 'activity_log_service.dart';

class UsersService with ActivityLogger implements CrudService<AppUser> {
  final CollectionReference<Map<String, dynamic>> _collectionReference =
      FirebaseFirestore.instance.collection('users');

  @override
  Future<void> create(AppUser user) {
    return _collectionReference.add(user.toMap()).then((_) {
      logActivity(
        ActivityType.user,
        'User created',
        subtitle: user.email,
        extra: user.id,
      );
    });
  }

  @override
  Future<void> delete(String id) {
    return _collectionReference.doc(id).delete().then((_) {
      logActivity(
        ActivityType.user,
        'User deleted',
        extra: id,
      );
    });
  }

  @override
  Future<List<AppUser>> getAll() {
    return _collectionReference.get().then((snapshot) {
      return snapshot.docs.map((doc) {
        return AppUser.fromMap(doc.data());
      }).toList();
    });
  }

  @override
  Future<AppUser> getById(String id) =>
      _collectionReference.doc(id).get().then((doc) => doc.data() != null
          ? AppUser.fromMap(doc.data()!)
          : throw Exception('User not found'));

  @override
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

  @override
  Stream<List<AppUser>> watchAll() {
    return _collectionReference.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return AppUser.fromMap(doc.data());
      }).toList();
    });
  }

  @override
  Stream<AppUser> watchById(String id) {
    return _collectionReference.doc(id).snapshots().map((doc) => doc.data() != null
        ? AppUser.fromMap(doc.data()!)
        : throw Exception('User not found'));
  }

  Future<String> getLocaleByEmail(String email) async {
    final user = await _collectionReference.where('email', isEqualTo: email).get().then(
        (snapshot) => snapshot.docs.map((doc) => AppUser.fromMap(doc.data())).toList());
    return user[0].language ?? 'en';
  }
}
