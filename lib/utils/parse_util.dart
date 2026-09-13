import 'log_util.dart';

//TODO 리뷰 확인

/// JSON 필드를 타입 안전하게 꺼낸다.
///
/// 네이버 응답은 같은 자리에 숫자가 오기도 하고 `"1,234"` 같은 문자열이 오기도 한다.
/// 키 누락이나 타입 불일치로 `fromJson` 전체가 터지지 않도록 값을 보정한다.
abstract final class ParseUtil {
  static const String _file = 'ParseUtil';

  /// [json]의 [key]를 [T]로 변환한다.
  ///
  /// 변환에 실패하면 [fallback], 그마저 없으면 [T]의 빈 값을 돌려준다.
  static T parse<T>(Map<String, dynamic> json, String key, {T? fallback}) {
    final T? parsed = _convert<T>(json[key]);
    if (parsed != null) return parsed;
    if (fallback != null) return fallback;
    return _emptyOf<T>(key);
  }

  /// 중첩 리스트를 파싱한다. 항목 하나가 깨져도 나머지는 살린다.
  static List<E> parseList<E>(
    Map<String, dynamic> json,
    String key,
    E Function(Map<String, dynamic> json) fromJson,
  ) {
    final Object? raw = json[key];
    if (raw is! List) return <E>[];

    final List<E> result = <E>[];
    for (final Object? item in raw) {
      if (item is! Map) continue;
      try {
        result.add(fromJson(Map<String, dynamic>.from(item)));
      } catch (e) {
        LogUtil().logError('parseList($key): $e', module: _file);
      }
    }
    return result;
  }

  static T? _convert<T>(Object? value) {
    if (value == null) return null;
    if (value is T) return value as T;

    if (T == String) return value.toString() as T;
    if (T == int) return _toInt(value) as T?;
    if (T == double) return _toDouble(value) as T?;
    if (T == bool) return _toBool(value) as T?;
    return null;
  }

  static int? _toInt(Object value) {
    if (value is num) return value.toInt();
    if (value is String) {
      final String cleaned = _stripNumberNoise(value);
      return int.tryParse(cleaned) ?? double.tryParse(cleaned)?.toInt();
    }
    return null;
  }

  static double? _toDouble(Object value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(_stripNumberNoise(value));
    return null;
  }

  static bool? _toBool(Object value) {
    if (value is num) return value != 0;
    if (value is String) {
      switch (value.trim().toLowerCase()) {
        case 'true':
        case 'y':
        case '1':
          return true;
        case 'false':
        case 'n':
        case '0':
          return false;
      }
    }
    return null;
  }

  /// 일별 시세 HTML의 숫자에는 쉼표와 개행, non-breaking space(`\u00A0`)가 섞여 있다.
  static String _stripNumberNoise(String raw) => raw
      .replaceAll(RegExp(r'[,\s\u00A0]'), '')
      .replaceFirst(RegExp(r'^\+'), '');

  static T _emptyOf<T>(String key) {
    if (T == String) return '' as T;
    if (T == int) return 0 as T;
    if (T == double) return 0.0 as T;
    if (T == bool) return false as T;
    throw ArgumentError('ParseUtil: $T의 빈 값이 없다. fallback을 넘겨라. (key: $key)');
  }
}
