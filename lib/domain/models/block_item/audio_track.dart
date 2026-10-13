import 'dart:convert';
import 'dart:ui';

import '/utils/localized_content.dart';
import '/utils/tx_image.dart';

class AudioTrack {
  final String id;
  final String _title;
  final String writer;
  final String speaker;
  final String trackUrl;
  final String _description;

  /// Dutch title/description; shown when the app is in Dutch and they are filled in.
  final String? titleNl;
  final String? descriptionNl;
  final TxImage imageBackground;
  final TxImage thumbnail;
  final bool hasTimer;
  final Duration duration;
  final Color? dominantColor;

  /// Only playable with an active entitlement (subscription or access code).
  final bool premium;

  /// Title in the app language.
  String get title => localizedContent(_title, titleNl);

  /// Description in the app language.
  String get description => localizedContent(_description, descriptionNl);

  String get durationString =>
      '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';

  AudioTrack({
    required this.id,
    required String title,
    required this.writer,
    required this.speaker,
    required this.trackUrl,
    required String description,
    required this.imageBackground,
    required this.thumbnail,
    required this.hasTimer,
    required this.duration,
    this.dominantColor,
    this.premium = false,
    this.titleNl,
    this.descriptionNl,
  })  : _title = title,
        _description = description;

  AudioTrack copyWith({
    String? id,
    String? title,
    String? writer,
    String? speaker,
    String? trackUrl,
    String? description,
    TxImage? imageBackground,
    TxImage? thumbnail,
    bool? hasTimer,
    Duration? duration,
    Color? dominantColor,
    bool? premium,
    String? titleNl,
    String? descriptionNl,
  }) {
    return AudioTrack(
      id: id ?? this.id,
      title: title ?? _title,
      writer: writer ?? this.writer,
      speaker: speaker ?? this.speaker,
      trackUrl: trackUrl ?? this.trackUrl,
      description: description ?? _description,
      imageBackground: imageBackground ?? this.imageBackground,
      thumbnail: thumbnail ?? this.thumbnail,
      hasTimer: hasTimer ?? this.hasTimer,
      duration: duration ?? this.duration,
      dominantColor: dominantColor ?? this.dominantColor,
      premium: premium ?? this.premium,
      titleNl: titleNl ?? this.titleNl,
      descriptionNl: descriptionNl ?? this.descriptionNl,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'title': _title,
      'writer': writer,
      'speaker': speaker,
      'trackUrl': trackUrl,
      'description': _description,
      if (titleNl != null) 'titleNl': titleNl,
      if (descriptionNl != null) 'descriptionNl': descriptionNl,
      'imageBackground': imageBackground.toMap(),
      'thumbnail': thumbnail.toMap(),
      'hasTimer': hasTimer,
      'duration': duration.inMilliseconds,
      'premium': premium,
      // ignore: deprecated_member_use
      if (dominantColor != null) 'dominantColor': dominantColor!.value,
    };
  }

  factory AudioTrack.fromMap(Map<String, dynamic> map) {
    return AudioTrack(
      id: map['id'] as String,
      title: map['title'] as String,
      writer: map['writer'] as String,
      speaker: map['speaker'] as String,
      trackUrl: map['trackUrl'] as String,
      description: map['description'] as String,
      imageBackground: TxImage.fromMap(map['imageBackground'] as Map<String, dynamic>),
      thumbnail: TxImage.fromMap(map['thumbnail'] as Map<String, dynamic>),
      hasTimer: map['hasTimer'] ?? false,
      duration: Duration(milliseconds: map['duration'] as int),
      dominantColor:
          map['dominantColor'] != null ? Color(map['dominantColor'] as int) : null,
      premium: map['premium'] == true,
      titleNl: optionalString(map['titleNl']),
      descriptionNl: optionalString(map['descriptionNl']),
    );
  }

  String toJson() => json.encode(toMap());

  factory AudioTrack.fromJson(String source) =>
      AudioTrack.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'AudioTrack(id: $id, title: $title, writer: $writer, speaker: $speaker, trackUrl: $trackUrl, description: $description, imageBackground: $imageBackground, thumbnail: $thumbnail, duration: $duration, hasTimer: $hasTimer, dominantColor: $dominantColor)';
  }

  @override
  bool operator ==(covariant AudioTrack other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other._title == _title &&
        other.titleNl == titleNl &&
        other.writer == writer &&
        other.speaker == speaker &&
        other.trackUrl == trackUrl &&
        other._description == _description &&
        other.descriptionNl == descriptionNl &&
        other.imageBackground == imageBackground &&
        other.thumbnail == thumbnail &&
        other.duration == duration &&
        other.hasTimer == hasTimer &&
        other.dominantColor == dominantColor &&
        other.premium == premium;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        _title.hashCode ^
        writer.hashCode ^
        speaker.hashCode ^
        trackUrl.hashCode ^
        _description.hashCode ^
        imageBackground.hashCode ^
        thumbnail.hashCode ^
        duration.hashCode ^
        hasTimer.hashCode ^
        dominantColor.hashCode;
  }
}
