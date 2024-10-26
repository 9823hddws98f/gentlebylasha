import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

extension ListExt<E> on List<E> {
  List<E> interleaveWith(E separator, {bool trailing = false}) {
    final result = <E>[];
    for (var i = 0; i < length; i++) {
      result.add(this[i]);
      result.add(separator);
    }
    if (!trailing && result.isNotEmpty) result.removeLast();
    return result;
  }
}

extension ResponsiveHelper on BuildContext {
  static const mobileWidth = 700.0;
  static const desktopContentWidth = 500.0;

  bool get isMobile {
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) return true;
    return MediaQuery.sizeOf(this).width < mobileWidth;
  }
}
