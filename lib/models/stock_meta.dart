import '../utils/parse_util.dart';

/// 종목의 기본 정보. 화면에 `005930 · 코스피` 로 보이는 부분이다.
class StockMeta {
  const StockMeta({
    required this.symbol,
    required this.name,
    required this.marketName,
  });

  factory StockMeta.fromJson(Map<String, dynamic> json) {
    return StockMeta(
      symbol: ParseUtil.parse<String>(json, 'symbolCode'),
      name: ParseUtil.parse<String>(json, 'stockName'),
      marketName: ParseUtil.parse<String>(json, 'stockExchangeNameKor'),
    );
  }

  final String symbol;
  final String name;

  /// `코스피` / `코스닥`
  final String marketName;

  /// 목록 행의 보조 문구.
  String get symbolWithMarket => '$symbol · $marketName';
}
