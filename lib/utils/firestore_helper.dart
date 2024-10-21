import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '/models/audiofile_model.dart';
import '/models/category_block.dart';
import '/models/user_model.dart';
import '../models/block.dart';
import '../models/category_model.dart';
import '../models/collection_model.dart';
import '../models/sub_categories.dart';
import 'global_functions.dart';

final FirebaseFirestore firestore = FirebaseFirestore.instance;

Future<List<Block>> getBlockOfSubCategory(String pageID) async {
  final publishedBlocksRef = FirebaseFirestore.instance.collection('published_blocks');
  final publishedBlocksSnapshot =
      await publishedBlocksRef.where("sub_cat_id", isEqualTo: pageID).get();

  List<Block> blocks = [];

  for (var doc in publishedBlocksSnapshot.docs) {
    Map<String, dynamic> data = doc.data();
    String id = doc.id;
    Block block = Block.fromMap(id, data);
    blocks.add(block);
  }

  debugPrint("Sub category blocks ${blocks.length}");
  return blocks;
}

Future<List<Block>> getBlockOfCategory(String pageID) async {
  final publishedBlocksRef = FirebaseFirestore.instance.collection('published_blocks');
  final publishedBlocksSnapshot = await publishedBlocksRef
      .where("page_id", isEqualTo: pageID)
      .where("sub_cat_id", isEqualTo: null)
      .get();

  List<Block> blocks = [];

  for (var doc in publishedBlocksSnapshot.docs) {
    Map<String, dynamic> data = doc.data();
    String id = doc.id;
    Block block = Block.fromMap(id, data);
    blocks.add(block);
  }

  return blocks;
}

Future<List<Block>> getHomePageBlocks() async {
  final pageRef = FirebaseFirestore.instance.collection('published_categories');
  final snapshots = await pageRef.where("sequence", isEqualTo: 1).get();
  final List<String> trackIds = snapshots.docs.map((doc) => doc.id).toList();
  final publishedBlocksRef = FirebaseFirestore.instance.collection('published_blocks');
  final publishedBlocksSnapshot = await publishedBlocksRef
      .where("page_id", isEqualTo: trackIds[0])
      .orderBy("sequence")
      .get();
  //final List<String> blocksList = publishedBlocksSnapshot.docs.map((doc) => doc.id).toList();

  List<Block> blocks = [];

  for (var doc in publishedBlocksSnapshot.docs) {
    Map<String, dynamic> data = doc.data();
    String id = doc.id;
    Block block = Block.fromMap(id, data);
    blocks.add(block);
  }

  return blocks;
}

Future<List<AudioTrack>> fetchTracksForBlock(String blockId) async {
  List<AudioTrack> tracks = [];

  // Reference to your Firestore collection for track_block (change 'track_block' to your collection name)
  CollectionReference trackBlockCollection =
      FirebaseFirestore.instance.collection('published_block_tracks');

  // Query the collection to get documents with block_id and track_id
  QuerySnapshot<Object?> querySnapshot = await trackBlockCollection
      .where("block_id", isEqualTo: blockId)
      .orderBy("sequence")
      .get();

  for (var document in querySnapshot.docs) {
    String trackId = document['track_id'] as String;
    // Reference to your Firestore collection for tracks (change 'tracks' to your collection name)
    CollectionReference tracksCollection =
        FirebaseFirestore.instance.collection('Tracks');

    // Query the collection to get the track with the specified track_id
    final trackSnapshot =
        await tracksCollection.where(FieldPath.documentId, isEqualTo: trackId).get();

    tracks += trackSnapshot.docs.map((doc) {
      return AudioTrack.fromFirestore(doc);
    }).toList();
  }
  return tracks;
}

Future<void> addToRecentlyPlayed(String trackId) async {
  if (trackId != "") {
    UserModel user = await getUser();
    debugPrint("recently played $trackId");

    try {
      final recentlyPlayedRef = firestore
          .collection("recently_played")
          .doc(user.id)
          .collection("Tracks")
          .doc(trackId);

      // Check if the track is already in the user's "recently played" collection
      final doc = await recentlyPlayedRef.get();

      if (doc.exists) {
        // If the track is already in the collection, update its "lastPlayed" field
        await recentlyPlayedRef.update({"datetime": FieldValue.serverTimestamp()});
      } else {
        // If the track is not in the collection, add it with a "lastPlayed" field of the current time
        await recentlyPlayedRef.set({"datetime": FieldValue.serverTimestamp()});
      }
    } catch (error) {
      debugPrint("Error adding track to recently played collection: $error");
    }
  }
}

Future<void> incrementPlayCount(String trackId) async {
  debugPrint("document id $trackId");
  if (trackId != "") {
    try {
      final trackRef = FirebaseFirestore.instance.collection('Tracks').doc(trackId);

      await trackRef.update({'play_count': FieldValue.increment(1)});
      debugPrint('Play count incremented for track $trackId');
    } catch (e) {
      debugPrint('Failed to increment play count for track $trackId: $e');
    }
  }
}

void addAirTime(String trackId, int airTimeInSeconds) {
  final trackRef = FirebaseFirestore.instance.collection('Tracks').doc(trackId);
  trackRef.update({
    'air_time': FieldValue.increment(airTimeInSeconds),
  });
}

final FirebaseAuth _auth = FirebaseAuth.instance;
final FirebaseFirestore _firestore = FirebaseFirestore.instance;

// Method to fetch the list of recently played tracks for the current user
// Future<List<AudioTrack>> fetchTracksForBlock(String id) async {
//   try {
//     // // Get the currently logged-in user
//     // final User? user = _auth.currentUser;
//     // if (user == null) {
//     //   throw Exception("No user is currently signed in.");
//     // }
//
//     // Get the "recently_played" collection for the current user
//     final recentlyPlayedRef = _firestore
//         .collection("published_block_tracks");
//     // Query the "recently_played" collection to get the list of recently played track IDs
//     final querySnapshot = await recentlyPlayedRef.where("block_id",isEqualTo: id).orderBy("sequence").get();
//     // Create a list of track IDs from the query snapshot
//     final List<String> trackIds = querySnapshot.docs.map((doc) => doc.id).toList();
//     // Get the details of each track from the "Tracks" collection
//     final List<AudioTrack?> tracks = await Future.wait(trackIds.map((trackId) async {
//       final trackRef = _firestore.collection("Tracks").doc(trackId);
//       final trackDoc = await trackRef.get();
//       if (trackDoc.exists) {
//         return AudioTrack.fromFirestore(trackDoc);
//       } else {
//         // If the track doesn't exist in the "Tracks" collection, return null
//         return null;
//       }
//     }));
//
//     // Filter out any null values from the tracks list
//     return tracks.where((track) => track != null).cast<AudioTrack>().toList();
//   } catch (error) {
//     debugPrint("Error getting recently played tracks: $error");
//     return [];
//   }
// }

Future<List<AudioTrack>> getRecentlyPlayedTracks() async {
  // Get the currently logged-in user
  final User? user = _auth.currentUser;
  if (user == null) {
    throw Exception("No user is currently signed in.");
  }

  final recentlyPlayedRef =
      _firestore.collection("recently_played").doc(user.uid).collection("Tracks");
  // Query the "recently_played" collection to get the list of recently played track IDs
  final querySnapshot1 =
      await recentlyPlayedRef.orderBy("datetime", descending: true).get();
  final List<String> trackIds = querySnapshot1.docs.map((doc) => doc.id).toList();

  final tracksRef = FirebaseFirestore.instance.collection('Tracks');
  final List<AudioTrack> recentlyPlayedTracks = [];
  for (int i = 0; i < trackIds.length; i += 10) {
    final batchIds =
        trackIds.sublist(i, i + 10 > trackIds.length ? trackIds.length : i + 10);

    final querySnapshot =
        await tracksRef.where(FieldPath.documentId, whereIn: batchIds).get();

    recentlyPlayedTracks.addAll(querySnapshot.docs.map((doc) {
      return AudioTrack.fromFirestore(doc);
    }));
  }

  return recentlyPlayedTracks;
}

Future<List<AudioTrack>> getRecentlyPlayedTracksByCategory(String category) async {
  // Get the currently logged-in user
  final User? user = _auth.currentUser;
  if (user == null) {
    throw Exception("No user is currently signed in.");
  }

  final recentlyPlayedRef =
      _firestore.collection("recently_played").doc(user.uid).collection("Tracks");
  // Query the "recently_played" collection to get the list of recently played track IDs
  final querySnapshot1 =
      await recentlyPlayedRef.orderBy("datetime", descending: true).get();
  //debugPrint(querySnapshot1.docs[0].id);
  // Create a list of track IDs from the query snapshot
  final List<String> trackIds = querySnapshot1.docs.map((doc) => doc.id).toList();
  // debugPrint(trackIds);

  final tracksRef = FirebaseFirestore.instance.collection('Tracks');
  final List<AudioTrack> recentlyPlayedTracks = [];
// Query Firestore in batches of 10
  for (int i = 0; i < trackIds.length; i += 10) {
    final batchIds =
        trackIds.sublist(i, i + 10 > trackIds.length ? trackIds.length : i + 10);

    final querySnapshot = await tracksRef
        .where('categories', arrayContains: category)
        .where(FieldPath.documentId, whereIn: batchIds)
        .get();

    recentlyPlayedTracks.addAll(querySnapshot.docs.map((doc) {
      //debugPrint(doc.id);
      return AudioTrack.fromFirestore(doc);
    }));
  }

  // final sortedArray = trackIds.map((id) {
  //   final track = recentlyPlayedTracks.firstWhere((element) => element?.trackId == id, orElse: () => null);
  //   return track;
  // }).whereType<AudioTrack>().toList();

  return recentlyPlayedTracks;
}

Future<List<AudioTrack>> getFeaturedByCategory(String category) async {
  final tracksRef = FirebaseFirestore.instance.collection('Tracks');
  final querySnapshot = await tracksRef
      .where('categories', arrayContains: category)
      .where('featured', isEqualTo: true)
      .orderBy("updated_on", descending: true)
      .get();

  final featuredTracks = querySnapshot.docs.map((doc) {
    return AudioTrack.fromFirestore(doc);
  }).toList();

  return featuredTracks;
}

Future<List<CategoryBlock>> getCategoryBlocks() async {
  final tracksRef = FirebaseFirestore.instance.collection('published_categories');
  final querySnapshot =
      await tracksRef.where('sequence', isGreaterThan: 1).orderBy("sequence").get();

  final featuredTracks = querySnapshot.docs.map((doc) {
    return CategoryBlock.fromMap(doc);
  }).toList();

  debugPrint("category length ${featuredTracks.length}");
  return featuredTracks;
}

Future<List<CategoryBlock>> getDataFromFirestore() async {
  try {
    QuerySnapshot querySnapshot = await firestore.collection('categories').get();

    return querySnapshot.docs.map((doc) {
      return CategoryBlock.fromMap(doc);
    }).toList();
  } catch (e) {
    debugPrint('Error fetching data: $e');
    return [];
  }
}

Future<List<AudioTrack>> getRecommendedTracks() async {
  final tracksRef = FirebaseFirestore.instance.collection('Tracks');
  final querySnapshot = await tracksRef
      .where('featured', isEqualTo: true)
      .where('highlighted', isEqualTo: true)
      .orderBy("updated_on", descending: true)
      .get();

  final featuredTracks = querySnapshot.docs.map((doc) {
    return AudioTrack.fromFirestore(doc);
  }).toList();

  return featuredTracks;
}

Future<List<AudioTrack>> getNewAndWorthyByCategory(String category) async {
  final tracksRef = FirebaseFirestore.instance.collection('Tracks');
  final querySnapshot = await tracksRef
      .where('categories', arrayContains: category)
      .where('highlighted', isEqualTo: true)
      .orderBy("date", descending: true)
      .get();

  final featuredTracks = querySnapshot.docs.map((doc) {
    return AudioTrack.fromFirestore(doc);
  }).toList();

  return featuredTracks;
}

Future<List<AudioTrack>> getPopularTracksByCategory(String category) async {
  final tracksRef = FirebaseFirestore.instance.collection('Tracks');
  final querySnapshot = await tracksRef
      .where('categories', arrayContains: category)
      .orderBy('play_count', descending: true)
      .get();

  final popularTracks = querySnapshot.docs.map((doc) {
    return AudioTrack.fromFirestore(doc);
  }).toList();

  return popularTracks;
}

Future<List<Collection>> getCollections() async {
  final collectionRef = FirebaseFirestore.instance.collection('collections');
  final snapshots = await collectionRef.get();

// Create a list of track IDs from the query snapshot

  final collections = <Collection>[];
  for (final doc in snapshots.docs) {
    final collection = Collection.fromFirestore(doc);
    List<AudioTrack> collectionTracks = [];

    // final tracksRef = do.get();
    List<String> tracks = List.from(doc.data()['collection_tracks']);
    final tracksCollection = FirebaseFirestore.instance.collection('Tracks');
    final tracksQuerySnapshot =
        await tracksCollection.where(FieldPath.documentId, whereIn: tracks).get();
    for (var doc in tracksQuerySnapshot.docs) {
      AudioTrack track = AudioTrack.fromFirestore(doc);
      collectionTracks.add(track);
    }
    // final tracks = tracksSnapshots.docs.map((doc) => AudioTrack.fromFirestore(doc)).toList();
    collection.collectionTracks = collectionTracks;

    collections.add(collection);
  }

  return collections;
}

Future<List<Collection>> fetchCollectionsBySubcategory(String category) async {
  final collectionRef = FirebaseFirestore.instance
      .collection('collections')
      .where('sub_category', isEqualTo: category)
      .limit(3);
  final snapshots = await collectionRef.get();

// Create a list of track IDs from the query snapshot

  final collections = <Collection>[];
  for (final doc in snapshots.docs) {
    final collection = Collection.fromFirestore(doc);
    List<AudioTrack> collectionTracks = [];

    // final tracksRef = do.get();
    List<String> tracks = List.from(doc.data()['collection_tracks']);
    final tracksCollection = FirebaseFirestore.instance.collection('Tracks');
    final tracksQuerySnapshot =
        await tracksCollection.where(FieldPath.documentId, whereIn: tracks).get();
    for (var doc in tracksQuerySnapshot.docs) {
      AudioTrack track = AudioTrack.fromFirestore(doc);
      collectionTracks.add(track);
    }
    // final tracks = tracksSnapshots.docs.map((doc) => AudioTrack.fromFirestore(doc)).toList();
    collection.collectionTracks = collectionTracks;

    collections.add(collection);
  }

  return collections;
}

Future<List<Collection>> getTopCollections(String category) async {
  final collectionRef = FirebaseFirestore.instance
      .collection('collections')
      .where('category', isEqualTo: category)
      .limit(6);
  final snapshots = await collectionRef.get();

// Create a list of track IDs from the query snapshot

  final collections = <Collection>[];
  for (final doc in snapshots.docs) {
    final collection = Collection.fromFirestore(doc);
    List<AudioTrack> collectionTracks = [];

    // final tracksRef = do.get();
    List<String> tracks = List.from(doc.data()['collection_tracks']);
    final tracksCollection = FirebaseFirestore.instance.collection('Tracks');
    final tracksQuerySnapshot =
        await tracksCollection.where(FieldPath.documentId, whereIn: tracks).get();
    for (var doc in tracksQuerySnapshot.docs) {
      AudioTrack track = AudioTrack.fromFirestore(doc);
      collectionTracks.add(track);
    }
    // final tracks = tracksSnapshots.docs.map((doc) => AudioTrack.fromFirestore(doc)).toList();
    collection.collectionTracks = collectionTracks;

    collections.add(collection);
  }

  return collections;
}

Future<bool> isEmailAndPasswordUserLoggedIn() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    final userInfo = await user.getIdTokenResult();
    return userInfo.signInProvider == "password";
  }
  return false;
}

Future<bool> updateUserEmailAndData(
    String newEmail, String newName, String password) async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    try {
      // Reauthenticate the user
      AuthCredential credential =
          EmailAuthProvider.credential(email: user.email!, password: password);
      await user.reauthenticateWithCredential(credential);

      // Update user email in Firebase Auth
      await user.updateEmail(newEmail);

      // Update user data in Firestore
      DocumentReference userRef =
          FirebaseFirestore.instance.collection('User').doc(user.uid);
      await userRef.update({
        'email': newEmail,
        'name': newName,
      });

      debugPrint('User email and data updated successfully.');
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        showToast('Wrong password provided.');
        return false;
      } else {
        debugPrint("Error auth $e");
        return false;
      }
    } catch (e) {
      debugPrint("Error auth $e");
      return false;
    }
  } else {
    showToast('User is not logged in.');
    return false;
  }
}

Future<void> downloadTrack(String trackId, String trackName, String trackUrl) async {
  final directory = await getApplicationDocumentsDirectory();
  final path = '${directory.path}/$trackName.mp3';

  // Download the track file
  final HttpClient httpClient = HttpClient();
  final Uri uri = Uri.parse(trackUrl);
  final HttpClientRequest request = await httpClient.getUrl(uri);
  final HttpClientResponse response = await request.close();
  final File file = File(path);
  await file.writeAsBytes(await consolidateHttpClientResponseBytes(response));

  // Save the downloaded track in your app's storage or database
  // Here, you can store the track metadata (e.g., trackName, trackId, path) for later retrieval

  // Close the HttpClient
  httpClient.close();
  showToast("track downloaded");
}

Future<void> fetchCategories() async {
  try {
    final categoriesCollection =
        FirebaseFirestore.instance.collection('published_categories');
    final categoriesSnapshot =
        await categoriesCollection.orderBy('sequence', descending: false).get();
    List<Categories> categories = [];
    for (var doc in categoriesSnapshot.docs) {
      String categoryId = doc.id;
      String fieldName = doc.get('name');
      Categories category = Categories(id: categoryId, categoryName: fieldName);
      categories.add(category);
    }
    if (categories.isNotEmpty) {
      await saveCategories(categories);
    }
  } catch (e) {
    debugPrint('Error fetching categories: $e');
  }
}

Future<List<SubCategory>> fetchSubcategoriesBlocks(String categoryID) async {
  QuerySnapshot querySnapshot = await FirebaseFirestore.instance
      .collection('published_sub_categories')
      .where('category_id', isEqualTo: categoryID)
      .get();

  List<SubCategory> subcategories =
      querySnapshot.docs.map((document) => SubCategory.fromFirestore(document)).toList();

  return subcategories;
}

Future<List<SubCategory>> fetchSubcategories(String categoryID) async {
  QuerySnapshot querySnapshot = await FirebaseFirestore.instance
      .collection('sub_categories')
      .where('category_id', isEqualTo: categoryID)
      .get();

  List<SubCategory> subcategories =
      querySnapshot.docs.map((document) => SubCategory.fromFirestore(document)).toList();

  return subcategories;
}

Future<bool> deleteUserAccount() async {
  try {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      showToast(user.displayName.toString());
      final uid = user.uid;

      // Delete user from Firebase Authentication
      await user.delete();

      // Delete user document from the Users collection
      await FirebaseFirestore.instance.collection('User').doc(uid).delete();

      await FirebaseFirestore.instance.collection('favorites').doc(uid).delete();

      await FirebaseFirestore.instance.collection('recently_played').doc(uid).delete();
      return true;
    } else {
      showToast("Something went wrong");
      return false;
    }
  } catch (e) {
    showToast("Something went wrong");
    return false;
  }
}
