class CollectionUtil {
  static bool isListEmpty(List list) {
    return list == null || list.length == 0;
  }

  static bool isMapEmpty(Map map) {
    return map == null || map.isEmpty;
  }
}
