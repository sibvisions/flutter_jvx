extension MyIterable<T> on Iterable<T> {
  /// Returns the first element.
  ///
  /// Returns `null` if `this` is empty.
  /// Otherwise returns the first element in the iteration order,
  /// equivalent to `this.elementAt(0)`.
  T? get firstOrNull => isEmpty ? null : first;

  /// Returns the first element that satisfies the given predicate [test].
  ///
  /// Iterates through elements and returns the first to satisfy [test].
  ///
  /// If no element satisfies [test], returns `null`;
  T? firstWhereOrNull(bool Function(T element) test) {
    final list = where(test);
    return list.isEmpty ? null : list.first;
  }
}
