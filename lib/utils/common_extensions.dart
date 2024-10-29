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
