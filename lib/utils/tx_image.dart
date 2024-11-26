import 'dart:ui';

class TxImage {
  final String url;
  final String blurhash;
  final Color? dominantColor;
  final int width;
  final int height;

  TxImage({
    required this.url,
    required this.blurhash,
    required this.dominantColor,
    required this.width,
    required this.height,
  });

  Map<String, dynamic> toMap() => {
        'url': url,
        'blurhash': blurhash,
        // ignore: deprecated_member_use
        'dominantColor': dominantColor?.value,
        'width': width,
        'height': height,
      };

  factory TxImage.fromMap(Map<String, dynamic> map) => TxImage(
        url: map['url'] as String,
        blurhash: map['blurhash'] as String,
        dominantColor:
            map['dominantColor'] != null ? Color(map['dominantColor'] as int) : null,
        width: map['width'] as int,
        height: map['height'] as int,
      );

  @override
  bool operator ==(Object other) =>
      other is TxImage &&
      url == other.url &&
      blurhash == other.blurhash &&
      dominantColor == other.dominantColor &&
      width == other.width &&
      height == other.height;

  @override
  int get hashCode =>
      url.hashCode ^
      blurhash.hashCode ^
      dominantColor.hashCode ^
      width.hashCode ^
      height.hashCode;
}
