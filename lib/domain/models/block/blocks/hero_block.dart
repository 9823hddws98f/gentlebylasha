part of '../block.dart';

class HeroBlock extends Block {
  final String trackId;

  const HeroBlock({
    required this.trackId,
    required super.id,
    required super.pageId,
    required super.title,
    required super.type,
    required super.sequence,
  });

  factory HeroBlock.fromMap(Map<String, dynamic> map) => HeroBlock(
        id: map['id'] as String,
        pageId: map['pageId'] as String,
        title: map['title'] as String,
        sequence: map['sequence'] as int,
        type: BlockType.values.firstWhere(
          (e) => e.name == map['type'],
          orElse: () => BlockType.hero,
        ),
        trackId: map['trackId'] as String,
      );

  @override
  Map<String, dynamic> toMap() => {
        ...super.toMap(),
        'trackId': trackId,
      };

  @override
  HeroBlock copyWith({
    String? id,
    String? pageId,
    String? title,
    BlockType? type,
    int? sequence,
    String? trackId,
  }) =>
      HeroBlock(
        id: id ?? this.id,
        pageId: pageId ?? this.pageId,
        title: title ?? this.title,
        type: type ?? this.type,
        sequence: sequence ?? this.sequence,
        trackId: trackId ?? this.trackId,
      );
}
