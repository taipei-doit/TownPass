extension ListExt<T> on List<T> {
  List<T> joined(T separator) {
    if (isEmpty) {
      return [];
    }
    return [
      removeAt(0),
      for (T t in this) ...[separator, t],
    ];
  }

  List<T> joinedAround(T separator) {
    if (isEmpty) {
      return [];
    }
    return [
      for (T t in this) ...[separator, t],
      separator,
    ];
  }
}
