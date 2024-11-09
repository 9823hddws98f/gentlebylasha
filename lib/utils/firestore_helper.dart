import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sleeptales/domain/blocs/user/user_bloc.dart';
import 'package:sleeptales/utils/get.dart';

import '/domain/blocs/user/app_user.dart';
import '/domain/models/block_item/audio_track.dart';
import '/utils/common_extensions.dart';
import 'global_functions.dart';

final FirebaseFirestore firestore = FirebaseFirestore.instance;

Future<void> addToRecentlyPlayed(String trackId) async {
  if (trackId.isNotEmpty) {
    AppUser user = Get.the<UserBloc>().state.user;
    ("recently played $trackId").logDebug();

    try {
      final recentlyPlayedRef = firestore
          .collection("recently_played")
          .doc(user.id)
          .collection("tracks")
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
      final trackRef = FirebaseFirestore.instance.collection('tracks').doc(trackId);
      await trackRef.update({'play_count': FieldValue.increment(1)});
      'Play count incremented for track $trackId'.logDebug();
    } catch (e) {
      'Failed to increment play count for track $trackId: $e'.logDebug();
    }
  }
}

final FirebaseAuth _auth = FirebaseAuth.instance;
final FirebaseFirestore _firestore = FirebaseFirestore.instance;

Future<List<AudioTrack>> getRecentlyPlayedTracks() async {
  // Get the currently logged-in user
  final User? user = _auth.currentUser;
  if (user == null) {
    throw Exception("No user is currently signed in.");
  }

  final recentlyPlayedRef =
      _firestore.collection('recently_played').doc(user.uid).collection('tracks');
  // Query the "recently_played" collection to get the list of recently played track IDs
  final querySnapshot1 =
      await recentlyPlayedRef.orderBy('datetime', descending: true).get();
  final List<String> trackIds = querySnapshot1.docs.map((doc) => doc.id).toList();

  final tracksRef = FirebaseFirestore.instance.collection('tracks');
  final List<AudioTrack> recentlyPlayedTracks = [];
  for (int i = 0; i < trackIds.length; i += 10) {
    final batchIds =
        trackIds.sublist(i, i + 10 > trackIds.length ? trackIds.length : i + 10);

    final querySnapshot =
        await tracksRef.where(FieldPath.documentId, whereIn: batchIds).get();

    recentlyPlayedTracks
        .addAll(querySnapshot.docs.map((doc) => AudioTrack.fromMap(doc.data())));
  }

  return recentlyPlayedTracks;
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
          FirebaseFirestore.instance.collection('users').doc(user.uid);
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

Future<bool> deleteUserAccount() async {
  try {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      showToast(user.displayName.toString());
      final uid = user.uid;

      // Delete user from Firebase Authentication
      await user.delete();

      // Delete user document from the Users collection
      await FirebaseFirestore.instance.collection('users').doc(uid).delete();

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
