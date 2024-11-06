import 'dart:convert';
import 'dart:ui';

import 'package:flutter/foundation.dart';

class AudioPlaylist {
  final String id;
  final String title;
  final String author;
  final String profession;
  final String description;
  final String thumbnail;
  final String authorImage;
  final Color? dominantColor;
  final bool showAudioThumbnails;
  final List<String> trackIds;

  AudioPlaylist({
    required this.id,
    required this.title,
    required this.author,
    required this.profession,
    required this.description,
    required this.thumbnail,
    required this.authorImage,
    required this.showAudioThumbnails,
    required this.dominantColor,
    required this.trackIds,
  });

  AudioPlaylist copyWith({
    String? id,
    String? title,
    String? author,
    String? profession,
    String? description,
    String? thumbnail,
    String? authorImage,
    Color? dominantColor,
    bool? showAudioThumbnails,
    List<String>? trackIds,
  }) {
    return AudioPlaylist(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      profession: profession ?? this.profession,
      description: description ?? this.description,
      thumbnail: thumbnail ?? this.thumbnail,
      authorImage: authorImage ?? this.authorImage,
      showAudioThumbnails: showAudioThumbnails ?? this.showAudioThumbnails,
      dominantColor: dominantColor ?? this.dominantColor,
      trackIds: trackIds ?? this.trackIds,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'author': author,
        'profession': profession,
        'description': description,
        'thumbnail': thumbnail,
        'authorImage': authorImage,
        'showAudioThumbnails': showAudioThumbnails,
        if (trackIds.isNotEmpty) 'trackIds': trackIds,
        if (dominantColor != null) 'dominantColor': dominantColor!.value,
      };

  factory AudioPlaylist.fromMap(Map<String, dynamic> map) => AudioPlaylist(
        id: map['id'] as String,
        title: map['title'] as String,
        author: map['author'] as String,
        profession: map['profession'] as String,
        description: map['description'] as String,
        thumbnail: map['thumbnail'] as String,
        authorImage: map['authorImage'] as String,
        showAudioThumbnails: map['showAudioThumbnails'] as bool,
        dominantColor:
            map['dominantColor'] != null ? Color(map['dominantColor'] as int) : null,
        trackIds: map['trackIds'] != null
            ? List<String>.from(map['trackIds'] as List<dynamic>)
            : [],
      );

  String toJson() => json.encode(toMap());

  factory AudioPlaylist.fromJson(String source) =>
      AudioPlaylist.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'AudioPlaylist(id: $id, title: $title, author: $author, profession: $profession, description: $description, thumbnail: $thumbnail, showAudioThumbnails: $showAudioThumbnails, trackIds: $trackIds, dominantColor: $dominantColor)';
  }

  @override
  bool operator ==(covariant AudioPlaylist other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.title == title &&
        other.author == author &&
        other.profession == profession &&
        other.description == description &&
        other.thumbnail == thumbnail &&
        other.authorImage == authorImage &&
        other.showAudioThumbnails == showAudioThumbnails &&
        listEquals(other.trackIds, trackIds) &&
        other.dominantColor == dominantColor;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        author.hashCode ^
        profession.hashCode ^
        description.hashCode ^
        thumbnail.hashCode ^
        authorImage.hashCode ^
        showAudioThumbnails.hashCode ^
        trackIds.hashCode ^
        dominantColor.hashCode;
  }
}
