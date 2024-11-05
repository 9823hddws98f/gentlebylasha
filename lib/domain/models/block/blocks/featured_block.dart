part of '../block.dart';

class FeaturedBlock extends Block {
  final List<String> trackIds;

  const FeaturedBlock({
    required this.trackIds,
    required super.id,
    required super.pageId,
    required super.title,
    required super.type,
    required super.sequence,
  });

  factory FeaturedBlock.fromMap(Map<String, dynamic> map) => FeaturedBlock(
        id: map['id'] as String,
        pageId: map['pageId'] as String,
        title: map['title'] as String,
        sequence: map['sequence'] as int,
        type: BlockType.values.firstWhere(
          (e) => e.name == map['type'],
          orElse: () => BlockType.featured,
        ),
        trackIds: map['trackIds'] != null
            ? List<String>.from(map['trackIds'] as List<dynamic>).toList()
            : [],
      );

  @override
  Map<String, dynamic> toMap() => {
        ...super.toMap(),
        'trackIds': trackIds,
      };

  @override
  FeaturedBlock copyWith({
    String? id,
    String? pageId,
    String? title,
    BlockType? type,
    int? sequence,
    List<String>? trackIds,
  }) =>
      FeaturedBlock(
        id: id ?? this.id,
        pageId: pageId ?? this.pageId,
        title: title ?? this.title,
        type: type ?? this.type,
        sequence: sequence ?? this.sequence,
        trackIds: trackIds ?? this.trackIds,
      );
}
