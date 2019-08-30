///
/// Returns the last element if [list] is not empty, otherwise return null
///
T lastOrNull<T>(Iterable<T> list) => list.isNotEmpty ? list.last : null;
