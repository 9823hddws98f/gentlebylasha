import 'package:cloud_firestore/cloud_firestore.dart';

import '/domain/models/app_page.dart';
import '/domain/services/crud_service.dart';

class PagesService implements CrudService<AppPage> {
  final CollectionReference<Map<String, dynamic>> _collectionReference =
      FirebaseFirestore.instance.collection('pages');

  @override
  Future<void> create(AppPage page) {
    return _collectionReference.doc(page.id).set(page.toMap());
  }

  @override
  Future<void> delete(String id) {
    return _collectionReference.doc(id).delete();
  }

  @override
  Future<List<AppPage>> getAll() {
    return _collectionReference.get().then((snapshot) {
      return snapshot.docs.map((doc) {
        return AppPage.fromMap(doc.data());
      }).toList();
    });
  }

  @override
  Future<AppPage> getById(String id) =>
      _collectionReference.doc(id).get().then((doc) => doc.data() != null
          ? AppPage.fromMap(doc.data()!)
          : throw Exception('page not found'));

  @override
  Future<void> update(AppPage page) {
    return _collectionReference.doc(page.id).update(page.toMap());
  }

  @override
  Stream<List<AppPage>> watchAll() {
    return _collectionReference.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return AppPage.fromMap(doc.data());
      }).toList();
    });
  }

  @override
  Stream<AppPage> watchById(String id) {
    return _collectionReference.doc(id).snapshots().map((doc) => doc.data() != null
        ? AppPage.fromMap(doc.data()!)
        : throw Exception('page not found'));
  }
}
