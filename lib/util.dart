extension LastOrNullExt<T> on Iterable<T> {
  ///
  /// Returns the last element if this iterable is not empty, otherwise return null
  ///
  T get lastOrNull => isNotEmpty ? last : null;
}
