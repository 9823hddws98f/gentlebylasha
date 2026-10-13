import 'dart:convert';

import 'package:flutter/foundation.dart';

import '/utils/localized_content.dart';
import '/utils/tx_image.dart';

class AudioPlaylist {
  final String id;
  final String _title;
  final String author;
  final String profession;
  final String _description;
  final TxImage thumbnail;
  final TxImage authorImage;
  final bool showAudioThumbnails;
  final List<String> trackIds;

  /// Dutch title/description; shown when the app is in Dutch and they are filled in.
  final String? titleNl;
  final String? descriptionNl;

  /// Title in the app language.
  String get title => localizedContent(_title, titleNl);

  /// Description in the app language.
  String get description => localizedContent(_description, descriptionNl);

  AudioPlaylist({
    required this.id,
    required String title,
    required this.author,
    required this.profession,
    required String description,
    required this.thumbnail,
    required this.authorImage,
    required this.showAudioThumbnails,
    required this.trackIds,
    this.titleNl,
    this.descriptionNl,
  })  : _title = title,
        _description = description;

  AudioPlaylist copyWith({
    String? id,
    String? title,
    String? author,
    String? profession,
    String? description,
    TxImage? thumbnail,
    TxImage? authorImage,
    bool? showAudioThumbnails,
    List<String>? trackIds,
    String? titleNl,
    String? descriptionNl,
  }) {
    return AudioPlaylist(
      id: id ?? this.id,
      title: title ?? _title,
      author: author ?? this.author,
      profession: profession ?? this.profession,
      description: description ?? _description,
      thumbnail: thumbnail ?? this.thumbnail,
      authorImage: authorImage ?? this.authorImage,
      showAudioThumbnails: showAudioThumbnails ?? this.showAudioThumbnails,
      trackIds: trackIds ?? this.trackIds,
      titleNl: titleNl ?? this.titleNl,
      descriptionNl: descriptionNl ?? this.descriptionNl,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': _title,
        'author': author,
        'profession': profession,
        'description': _description,
        if (titleNl != null) 'titleNl': titleNl,
        if (descriptionNl != null) 'descriptionNl': descriptionNl,
        'thumbnail': thumbnail,
        'authorImage': authorImage,
        'showAudioThumbnails': showAudioThumbnails,
        if (trackIds.isNotEmpty) 'trackIds': trackIds,
      };

  factory AudioPlaylist.fromMap(Map<String, dynamic> map) => AudioPlaylist(
        id: map['id'] as String,
        title: map['title'] as String,
        author: map['author'] as String,
        profession: map['profession'] as String,
        description: map['description'] as String,
        thumbnail: TxImage.fromMap(map['thumbnail'] as Map<String, dynamic>),
        authorImage: TxImage.fromMap(map['authorImage'] as Map<String, dynamic>),
        showAudioThumbnails: map['showAudioThumbnails'] as bool,
        trackIds: map['trackIds'] != null
            ? List<String>.from(map['trackIds'] as List<dynamic>)
            : [],
        titleNl: optionalString(map['titleNl']),
        descriptionNl: optionalString(map['descriptionNl']),
      );

  String toJson() => json.encode(toMap());

  factory AudioPlaylist.fromJson(String source) =>
      AudioPlaylist.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'AudioPlaylist(id: $id, title: $title, author: $author, profession: $profession, description: $description, thumbnail: $thumbnail, showAudioThumbnails: $showAudioThumbnails, trackIds: $trackIds)';
  }

  @override
  bool operator ==(covariant AudioPlaylist other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other._title == _title &&
        other.titleNl == titleNl &&
        other.author == author &&
        other.profession == profession &&
        other._description == _description &&
        other.descriptionNl == descriptionNl &&
        other.thumbnail == thumbnail &&
        other.authorImage == authorImage &&
        other.showAudioThumbnails == showAudioThumbnails &&
        listEquals(other.trackIds, trackIds);
  }

  @override
  int get hashCode {
    return id.hashCode ^
        _title.hashCode ^
        author.hashCode ^
        profession.hashCode ^
        _description.hashCode ^
        thumbnail.hashCode ^
        authorImage.hashCode ^
        showAudioThumbnails.hashCode ^
        trackIds.hashCode;
  }
}
