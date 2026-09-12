import '../../../utils/parse_util.dart';

/// 검색 자동완성 결과 한 건.
class StockSearchItem {
  const StockSearchItem({
    required this.symbol,
    required this.name,
    required this.marketName,
  });

  factory StockSearchItem.fromJson(Map<String, dynamic> json) {
    return StockSearchItem(
      symbol: ParseUtil.parse<String>(json, 'code'),
      name: ParseUtil.parse<String>(json, 'name'),
      marketName: ParseUtil.parse<String>(json, 'typeName'),
    );
  }

  /// 국내 주식만 남기는 기준.
  static const String _domesticNation = 'KOR';
  static const String _stockCategory = 'stock';

  /// 국내 종목코드는 6자리 숫자다.
  static final RegExp _symbolPattern = RegExp(r'^\d{6}$');

  final String symbol;
  final String name;

  /// `코스피` / `코스닥`
  final String marketName;

  /// 앱 내부에서 종목을 가리키는 canonical id.
  String get canonicalId => 'domestic:$symbol';

  String get symbolWithMarket => '$symbol · $marketName';

  /// 국내 주식이면서 6자리 종목코드인 항목만 통과시킨다.
  ///
  /// 자동완성은 지수·ETF·해외 종목도 함께 내려준다.
  static bool isDomesticStock(Map<String, dynamic> json) {
    return ParseUtil.parse<String>(json, 'nationCode') == _domesticNation &&
        ParseUtil.parse<String>(json, 'category') == _stockCategory &&
        _symbolPattern.hasMatch(ParseUtil.parse<String>(json, 'code'));
  }
}
