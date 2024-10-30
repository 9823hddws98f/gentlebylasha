import 'package:cloud_firestore/cloud_firestore.dart';

import '/utils/global_functions.dart';
import 'audiofile_model.dart';
import 'category_model.dart';

class Collection {
  final String collectionId;
  final String collectionTitle;
  final String collectionThumbnail;
  final List<Categories> collectionCategory;
  List<AudioTrack> collectionTracks;

  Collection(
      {required this.collectionId,
      required this.collectionTitle,
      required this.collectionThumbnail,
      required this.collectionTracks,
      required this.collectionCategory});

  factory Collection.fromMap(Map<String, dynamic> map) {
    return Collection(
      collectionId: map['id'],
      collectionTitle: map['title'],
      collectionThumbnail: map['thumbnail'],
      collectionCategory: map['category'],
      collectionTracks: [], // we'll fill this in later
    );
  }

  factory Collection.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    List<Categories> matchingCategories = categroiesArray
        .where((categories) => data['category'].contains(categories.id))
        .toList();

    return Collection(
      collectionId: doc.id,
      collectionTitle: data['title'] ?? '',
      collectionThumbnail: data['thumbnail'] ?? '',
      collectionCategory: matchingCategories,
      collectionTracks: [],
    );
  }

  Future<List<Categories>> getListCategories() async {
    List<Categories> list = await getCategories();
    return list;
  }
}
