import '/utils/localized_content.dart';

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
  final String _title;

  /// Dutch title; shown when the app is in Dutch and it is filled in.
  final String? titleNl;
  final BlockType type;
  final int sequence;

  /// Title in the app language.
  String get title => localizedContent(_title, titleNl);

  const Block({
    required this.id,
    required this.pageId,
    required String title,
    this.titleNl,
    required this.type,
    required this.sequence,
  }) : _title = title;

  Map<String, dynamic> toMap() => {
        'id': id,
        'pageId': pageId,
        'title': _title,
        if (titleNl != null) 'titleNl': titleNl,
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
    String? titleNl,
    BlockType? type,
    int? sequence,
  });
}
