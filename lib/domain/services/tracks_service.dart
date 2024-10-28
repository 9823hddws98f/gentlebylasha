import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '/domain/models/audiofile_model.dart';

class TracksService {
  TracksService._();
  static TracksService instance = TracksService._();

  final tracksCollection = FirebaseFirestore.instance.collection('Tracks');

  Future<List<AudioTrack>> searchTracks(String query) async {
    final normalizedQuery = query.toLowerCase();
    List<DocumentSnapshot> documents = [];

    // Get title matches
    final titleSnapshot = await tracksCollection
        .where('title', isGreaterThanOrEqualTo: query.substring(0, 1).toUpperCase())
        .where('title',
            isLessThanOrEqualTo: '${query.substring(0, 1).toUpperCase()}\uf8ff')
        .get();

    // Filter documents locally for case-insensitive matching
    final filteredDocs = titleSnapshot.docs.where((doc) {
      final title = doc.data()['title']?.toString().toLowerCase() ?? '';
      return title.contains(normalizedQuery);
    }).toList();

    if (filteredDocs.isNotEmpty) {
      documents = filteredDocs;
    } else {
      // If no title matches, perform the speaker query
      final speakerSnapshot = await tracksCollection
          .where('speaker', isGreaterThanOrEqualTo: query.substring(0, 1).toUpperCase())
          .where('speaker',
              isLessThanOrEqualTo: '${query.substring(0, 1).toUpperCase()}\uf8ff')
          .get();

      documents = speakerSnapshot.docs;
    }

    return documents.map((doc) => AudioTrack.fromFirestore(doc)).toList();
  }
}
