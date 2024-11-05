part 'blocks/featured_block.dart';
part 'blocks/hero_block.dart';
part 'blocks/normal_block.dart';
part 'blocks/series_block.dart';

enum BlockType {
  normal,
  featured,
  series,
  hero;

  String get name => switch (this) {
        normal => 'Normal',
        featured => 'Featured',
        series => 'Series',
        hero => 'Hero',
      };
}

abstract class Block {
  final String id;
  final String pageId;
  final String title;
  final BlockType type;
  final int sequence;

  const Block({
    required this.id,
    required this.pageId,
    required this.title,
    required this.type,
    required this.sequence,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'pageId': pageId,
        'title': title,
        'type': type.name,
        'sequence': sequence,
      };

  static Block fromMap(Map<String, dynamic> map) {
    final type = BlockType.values.firstWhere(
      (e) => e.name == map['type'],
      orElse: () => throw 'block type not found',
    );

    return switch (type) {
      BlockType.normal => NormalBlock.fromMap(map),
      BlockType.featured => FeaturedBlock.fromMap(map),
      BlockType.series => SeriesBlock.fromMap(map),
      BlockType.hero => HeroBlock.fromMap(map)
    };
  }

  Block copyWith({
    String? id,
    String? pageId,
    String? title,
    BlockType? type,
    int? sequence,
  });
}
