import 'dart:convert';

class AudioTrack {
  final String id;
  final String title;
  final String writer;
  final String speaker;
  final String trackUrl;
  final String description;
  final String imageBackground;
  final String thumbnail;
  final Duration duration;

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
    required this.duration,
  });

  AudioTrack copyWith({
    String? id,
    String? title,
    String? writer,
    String? speaker,
    String? trackUrl,
    String? description,
    String? imageBackground,
    String? thumbnail,
    Duration? duration,
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
      duration: duration ?? this.duration,
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
      'imageBackground': imageBackground,
      'thumbnail': thumbnail,
      'duration': duration.inMilliseconds,
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
      imageBackground: map['imageBackground'] as String,
      thumbnail: map['thumbnail'] as String,
      duration: Duration(milliseconds: map['duration'] as int),
    );
  }

  String toJson() => json.encode(toMap());

  factory AudioTrack.fromJson(String source) =>
      AudioTrack.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'AudioTrack(id: $id, title: $title, writer: $writer, speaker: $speaker, trackUrl: $trackUrl, description: $description, imageBackground: $imageBackground, thumbnail: $thumbnail, duration: $duration)';
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
        other.duration == duration;
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
        duration.hashCode;
  }
}
