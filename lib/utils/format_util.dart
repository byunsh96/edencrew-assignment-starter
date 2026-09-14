/// 화면 표기용 포맷 변환.
///
/// 모델은 계산까지만 책임지고, 문자열 표기는 여기로 모은다.
abstract final class FormatUtil {
  /// 1조. 시가총액 축약 기준.
  static const int _trillion = 1000000000000;

  /// 1억. 시가총액이 조 단위에 못 미칠 때의 기준.
  static const int _hundredMillion = 100000000;

  /// 1천. 거래량 축약 기준.
  static const int _thousand = 1000;

  /// 천 단위 구분 쉼표. `1234567` → `1,234,567`
  static String decimal(num value) {
    final bool isNegative = value < 0;
    final String digits = value.abs().round().toString();

    final StringBuffer buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
      buffer.write(digits[i]);
    }
    return isNegative ? '-$buffer' : buffer.toString();
  }

  /// 부호를 붙인 등락액. `-400`, `+1,200`, `0`
  ///
  /// 보합은 부호를 붙이지 않는다. `+0`은 상승으로 읽힌다.
  static String signedDecimal(num value) {
    if (value == 0) return '0';
    final String body = decimal(value.abs());
    return value > 0 ? '+$body' : '-$body';
  }

  /// 부호를 붙인 등락률. [rate]는 `0.0022` 형태의 비율이다. → `+0.22%`
  static String signedPercent(double rate) {
    final double percent = rate * 100;
    final String body = percent.abs().toStringAsFixed(2);
    if (percent == 0) return '0.00%';
    return percent > 0 ? '+$body%' : '-$body%';
  }

  /// 거래량 축약. 천 주 단위로 끊는다. `29113000` → `29,113천`
  ///
  /// Figma 표기(`29,113천`)를 따랐다. 천 주에 못 미치면 끊을 자리가 없어 원값을 쓴다.
  static String volume(num shares) {
    if (shares < _thousand) return decimal(shares);
    return '${decimal(shares ~/ _thousand)}천';
  }

  /// 시가총액 축약. `1063000000000000` → `1,063조`
  ///
  /// Figma에는 조 단위 예시(`1,063조`)만 있다. 조에 못 미치는 종목은 `0조`가 되어
  /// 의미를 잃으므로 억으로 한 단계 내렸다.
  static String marketCap(num won) {
    if (won >= _trillion) return '${decimal(won ~/ _trillion)}조';
    if (won >= _hundredMillion) return '${decimal(won ~/ _hundredMillion)}억';
    return decimal(won);
  }

  /// 일별 시세 표의 날짜. `20260911` → `09.11`
  static String monthDay(String yyyyMMdd) {
    if (yyyyMMdd.length != 8) return yyyyMMdd;
    return '${yyyyMMdd.substring(4, 6)}.${yyyyMMdd.substring(6, 8)}';
  }

  /// 날짜를 `yyyyMMdd`로 정규화한다. `2026.09.11`, `2026-09-11` 모두 받는다.
  static String normalizeDate(String raw) => raw.replaceAll(RegExp(r'[^0-9]'), '');
}
