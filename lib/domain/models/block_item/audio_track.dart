import 'dart:convert';
import 'dart:ui';

import '/utils/tx_image.dart';

class AudioTrack {
  final String id;
  final String title;
  final String writer;
  final String speaker;
  final String trackUrl;
  final String description;
  final TxImage imageBackground;
  final TxImage thumbnail;
  final bool hasTimer;
  final Duration duration;
  final Color? dominantColor;

  String get durationString =>
      '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';

  AudioTrack({
    required this.id,
    required this.title,
    required this.writer,
    required this.speaker,
    required this.trackUrl,
    required this.description,
    required this.imageBackground,
    required this.thumbnail,
    required this.hasTimer,
    required this.duration,
    this.dominantColor,
  });

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
  }) {
    return AudioTrack(
      id: id ?? this.id,
      title: title ?? this.title,
      writer: writer ?? this.writer,
      speaker: speaker ?? this.speaker,
      trackUrl: trackUrl ?? this.trackUrl,
      description: description ?? this.description,
      imageBackground: imageBackground ?? this.imageBackground,
      thumbnail: thumbnail ?? this.thumbnail,
      hasTimer: hasTimer ?? this.hasTimer,
      duration: duration ?? this.duration,
      dominantColor: dominantColor ?? this.dominantColor,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'writer': writer,
      'speaker': speaker,
      'trackUrl': trackUrl,
      'description': description,
      'imageBackground': imageBackground.toMap(),
      'thumbnail': thumbnail.toMap(),
      'hasTimer': hasTimer,
      'duration': duration.inMilliseconds,
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
        other.title == title &&
        other.writer == writer &&
        other.speaker == speaker &&
        other.trackUrl == trackUrl &&
        other.description == description &&
        other.imageBackground == imageBackground &&
        other.thumbnail == thumbnail &&
        other.duration == duration &&
        other.hasTimer == hasTimer &&
        other.dominantColor == dominantColor;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        writer.hashCode ^
        speaker.hashCode ^
        trackUrl.hashCode ^
        description.hashCode ^
        imageBackground.hashCode ^
        thumbnail.hashCode ^
        duration.hashCode ^
        hasTimer.hashCode ^
        dominantColor.hashCode;
  }
}
