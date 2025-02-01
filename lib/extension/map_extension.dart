extension MapExtension on Map {
  T? filterByKey<T>(String key) {
    if (containsKey(key)) {
      return this[key] as T;
    } else {
      return null;
    }
  }
}
