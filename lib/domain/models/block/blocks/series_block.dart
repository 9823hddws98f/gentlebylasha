part of '../block.dart';

class SeriesBlock extends Block {
  final List<String> playlistIds;

  const SeriesBlock({
    required this.playlistIds,
    required super.id,
    required super.pageId,
    required super.title,
    required super.type,
    required super.sequence,
  });

  factory SeriesBlock.fromMap(Map<String, dynamic> map) => SeriesBlock(
        id: map['id'] as String,
        pageId: map['pageId'] as String,
        title: map['title'] as String,
        sequence: map['sequence'] as int,
        type: BlockType.values.firstWhere(
          (e) => e.name == map['type'],
          orElse: () => BlockType.series,
        ),
        playlistIds: map['playlistIds'] != null
            ? List<String>.from(map['playlistIds'] as List<dynamic>)
            : [],
      );

  @override
  Map<String, dynamic> toMap() => {
        ...super.toMap(),
        'playlistIds': playlistIds,
      };

  @override
  SeriesBlock copyWith({
    String? id,
    String? pageId,
    String? title,
    BlockType? type,
    int? sequence,
    List<String>? playlistIds,
  }) =>
      SeriesBlock(
        id: id ?? this.id,
        pageId: pageId ?? this.pageId,
        title: title ?? this.title,
        type: type ?? this.type,
        sequence: sequence ?? this.sequence,
        playlistIds: playlistIds ?? this.playlistIds,
      );
}
