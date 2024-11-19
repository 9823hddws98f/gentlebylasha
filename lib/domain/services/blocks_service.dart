import 'package:cloud_firestore/cloud_firestore.dart';

import '/domain/models/block/block.dart';
import '/domain/services/crud_service.dart';

class BlocksService implements CrudService<Block> {
  final CollectionReference<Map<String, dynamic>> _collectionReference =
      FirebaseFirestore.instance.collection('blocks');

  @override
  Future<void> create(Block block) {
    return _collectionReference.doc(block.id).set(block.toMap());
  }

  @override
  Future<void> delete(String id) {
    return _collectionReference.doc(id).delete();
  }

  @override
  Future<List<Block>> getAll() {
    return _collectionReference.get().then((snapshot) {
      return snapshot.docs.map((doc) {
        return Block.fromMap(doc.data());
      }).toList();
    });
  }

  @override
  Future<Block> getById(String id) =>
      _collectionReference.doc(id).get().then((doc) => doc.data() != null
          ? Block.fromMap(doc.data()!)
          : throw Exception('block not found'));

  @override
  Future<void> update(Block block) =>
      _collectionReference.doc(block.id).update(block.toMap());

  @override
  Stream<List<Block>> watchAll() {
    return _collectionReference.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Block.fromMap(doc.data());
      }).toList();
    });
  }

  @override
  Stream<Block> watchById(String id) {
    return _collectionReference.doc(id).snapshots().map((doc) => doc.data() != null
        ? Block.fromMap(doc.data()!)
        : throw Exception('block not found'));
  }

  Stream<List<Block>> watchByPage(String pageId) {
    return _collectionReference.where('pageId', isEqualTo: pageId).snapshots().map(
          (snapshot) => snapshot.docs.map((doc) => Block.fromMap(doc.data())).toList(),
        );
  }

  Future<List<Block>> getByPageId(String pageId) async {
    return _collectionReference
        .where('pageId', isEqualTo: pageId)
        .orderBy('sequence')
        .get()
        .then((snapshot) {
      return snapshot.docs.map((doc) => Block.fromMap(doc.data())).toList();
    });
  }

  Future<void> updateSequences({
    required String pageId,
    required List<Block> blocks,
  }) async {
    for (var i = 0; i < blocks.length; i++) {
      await _collectionReference.doc(blocks[i].id).update({'sequence': i});
    }
  }

  Future<List<Block>> getByIds(List<String> ids) => _collectionReference
          .where(FieldPath.documentId, whereIn: ids)
          .get()
          .then((snapshot) {
        return snapshot.docs.map((doc) => Block.fromMap(doc.data())).toList();
      });
}
