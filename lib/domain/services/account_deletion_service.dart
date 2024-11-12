import 'package:cloud_firestore/cloud_firestore.dart';

import '/domain/models/account_deletion_model.dart';
import '/domain/services/crud_service.dart';

class AccountDeletionService extends CrudService<AccountDeletionModel> {
  AccountDeletionService._();

  static final AccountDeletionService instance = AccountDeletionService._();

  final CollectionReference<Map<String, dynamic>> _collectionReference =
      FirebaseFirestore.instance.collection('account_deletion');

  @override
  Future<void> create(AccountDeletionModel entity) {
    return _collectionReference.add(entity.toMap());
  }

  @override
  Future<void> delete(String id) {
    return _collectionReference.doc(id).delete();
  }

  @override
  Future<List<AccountDeletionModel>> getAll() {
    return _collectionReference.get().then((snapshot) {
      return snapshot.docs.map((doc) {
        return AccountDeletionModel.fromMap(doc.data());
      }).toList();
    });
  }

  @override
  Future<AccountDeletionModel> getById(String id) {
    return _collectionReference.doc(id).get().then((doc) {
      return AccountDeletionModel.fromMap(doc.data()!);
    });
  }

  @override
  Future<void> update(AccountDeletionModel entity) {
    return _collectionReference.doc(entity.id).update(entity.toMap());
  }

  @override
  Stream<List<AccountDeletionModel>> watchAll() {
    var map = _collectionReference.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return AccountDeletionModel.fromMap(doc.data());
      }).toList();
    });
    return map;
  }

  @override
  Stream<AccountDeletionModel> watchById(String id) {
    return _collectionReference.doc(id).snapshots().map((doc) {
      return AccountDeletionModel.fromMap(doc.data()!);
    });
  }

  Future<bool> verifyDeletionCode(String email, String code) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('account_deletion')
        .where('email', isEqualTo: email)
        .orderBy('createdAt', descending: true)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty && querySnapshot.docs.first['code'] == code) {
      // Code is valid, delete the user account and account deletion record
      await delete(querySnapshot.docs.first.id);
      // Add user account deletion logic here
      return true;
    } else {
      // Code is invalid
      return false;
    }
  }
}
