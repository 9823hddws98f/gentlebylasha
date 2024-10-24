class Block {
  final String id;
  final String author;
  final String blockType;
  final String description;
  final String pageId;
  final String profession;
  final int sequence;
  final String subCatId;
  final String title;
  final String showSeriesImg;
  final String thumbnail;
  final String authorImage;

  Block({
    required this.id,
    required this.author,
    required this.blockType,
    required this.description,
    required this.pageId,
    required this.profession,
    required this.sequence,
    required this.subCatId,
    required this.title,
    required this.showSeriesImg,
    required this.thumbnail,
    required this.authorImage
  });


  factory Block.fromMap(String id, Map<String, dynamic> data) {
    return Block(
      id: id,
      author: data['author'] ?? '',
      blockType: data['block_type'] ?? '',
      description: data['description'] ?? '',
      pageId: data['page_id'] ?? '',
      profession: data['profession'] ?? '',
      sequence: data['sequence'] ?? '',
      subCatId: data['sub_cat_id'] ?? '',
      title: data['title'] ?? '',
      showSeriesImg: data['show_series_img'] ?? '',
      thumbnail: data['thumbnail'] ?? '',
      authorImage: data['author_image'] ?? '',
    );
  }
}