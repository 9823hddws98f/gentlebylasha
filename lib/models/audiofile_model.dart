import 'package:cloud_firestore/cloud_firestore.dart';

import '/models/category_model.dart';
import '/utils/global_functions.dart';

class AudioTrack {
  final String trackId;
  final String speaker;
  final String title;
  final String trackUrl;
  final String description;
  final String imageBackground;
  final String length;
  final String thumbnail;
  final String writer;
  final List<Categories> categories;

  AudioTrack({
    required this.trackId,
    required this.speaker,
    required this.title,
    required this.trackUrl,
    required this.description,
    required this.imageBackground,
    required this.length,
    required this.thumbnail,
    required this.writer,
    required this.categories,
  });

  factory AudioTrack.fromMap(Map<String, dynamic> map) {
    return AudioTrack(
        trackId: map['id'],
        speaker: map['Speaker'],
        title: map['title'],
        trackUrl: map['track_url'],
        description: map['description'],
        imageBackground: map['image_background'],
        length: map['length'],
        thumbnail: map['thumbnail'],
        writer: map['writer'],
        categories: map['categories']);
  }

  factory AudioTrack.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    List<Categories> matchingCategories = categroiesArray
        .where((categories) => data['categories'].contains(categories.id))
        .toList();

    return AudioTrack(
        trackId: doc.id,
        speaker: data['speaker'] ?? '',
        title: data['title'] ?? '',
        trackUrl: data['track_url'] ?? '',
        description: data['description'] ?? '',
        imageBackground: data['image_background'] ?? '',
        length: data['length'] ?? '',
        thumbnail: data['thumbnail'] ?? '',
        writer: data['writer'] ?? '',
        categories: matchingCategories.isEmpty
            ? [Categories(id: "0", categoryName: "")]
            : matchingCategories);
  }

  Future<List<Categories>> getListCategories() async {
    List<Categories> list = await getCategories();
    return list;
  }
}
