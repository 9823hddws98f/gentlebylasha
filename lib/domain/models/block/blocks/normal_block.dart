part of '../block.dart';

class NormalBlock extends Block {
  final List<String> trackIds;

  const NormalBlock({
    required this.trackIds,
    required super.id,
    required super.pageId,
    required super.title,
    required super.type,
    required super.sequence,
  });

  factory NormalBlock.fromMap(Map<String, dynamic> map) => NormalBlock(
        id: map['id'] as String,
        pageId: map['pageId'] as String,
        title: map['title'] as String,
        sequence: map['sequence'] as int,
        type: BlockType.values.firstWhere(
          (e) => e.name == map['type'],
          orElse: () => BlockType.normal,
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
  NormalBlock copyWith({
    String? id,
    String? pageId,
    String? title,
    BlockType? type,
    int? sequence,
    List<String>? trackIds,
  }) =>
      NormalBlock(
        id: id ?? this.id,
        pageId: pageId ?? this.pageId,
        title: title ?? this.title,
        type: type ?? this.type,
        sequence: sequence ?? this.sequence,
        trackIds: trackIds ?? this.trackIds,
      );
}
