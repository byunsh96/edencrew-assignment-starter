import '../../utils/parse_util.dart';

/// 리스트가 특정 키 안에 담겨 오는 응답을 공통으로 푼다.
///
/// 항목 하나가 깨져도 나머지는 살린다. ([ParseUtil.parseList])
class ResponseList<T> {
  const ResponseList(this.items);

  factory ResponseList.fromJson(
    Map<String, dynamic> json,
    String key,
    T Function(Map<String, dynamic> json) fromJson,
  ) {
    return ResponseList<T>(ParseUtil.parseList<T>(json, key, fromJson));
  }

  final List<T> items;

  bool get isEmpty => items.isEmpty;

  bool get isNotEmpty => items.isNotEmpty;

  int get length => items.length;
}
