extension JVxListExtension on List {
  /// Uses [List.removeRange] to remove all objects starting from [start] in this list except the last one.
  void removeAllExceptLast([int start = 0]) {
    if (length > 1) {
      removeRange(start, length - 1);
    }
  }
}
