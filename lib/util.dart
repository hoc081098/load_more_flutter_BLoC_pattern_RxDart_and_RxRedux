extension LastOrNullExt<T> on Iterable<T> {
  ///
  /// Returns the last element if [list] is not empty, otherwise return null
  ///
  T get lastOrNull => isNotEmpty ? last : null;
}
