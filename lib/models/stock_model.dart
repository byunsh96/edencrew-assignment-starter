import '../utils/parse_util.dart';

/// 종목 기본 정보. 검색 결과와 관심 목록이 같은 모델을 쓴다.
/// 
class StockModel {
  const StockModel({required this.symbol, required this.name, required this.marketName});

  /// 검색 자동완성(`ac.stock.naver.com`) 응답에서 만든다.
  factory StockModel.fromJson(Map<String, dynamic> json) {
    return StockModel(
      symbol: ParseUtil.parse<String>(json, 'code'),
      name: ParseUtil.parse<String>(json, 'name'),
      marketName: ParseUtil.parse<String>(json, 'typeName'),
    );
  }

  /// 종목 메타(`stock.naver.com`) 응답에서 만든다.
  factory StockModel.fromMetaJson(Map<String, dynamic> json) {
    return StockModel(
      symbol: ParseUtil.parse<String>(json, 'symbolCode'),
      name: ParseUtil.parse<String>(json, 'stockName'),
      marketName: ParseUtil.parse<String>(json, 'stockExchangeNameKor'),
    );
  }

  /// 6자리 종목코드. `005930` / `000660`
  final String symbol;

  /// `삼성전자` / `SK하이닉스`
  final String name;

  /// `코스피` / `코스닥`
  final String marketName;

  String get symbolWithMarket => '$symbol · $marketName';

  /// canonicalId 어떻게 사용해야할지 몰라 operator에 연결해서 관심 등록·해제·중복 방지함
  String get canonicalId => 'domestic:$symbol';

  /// 국내 주식만 남기는 기준.
  static const String _domesticNation = 'KOR';
  static const String _stockCategory = 'stock';

  /// 국내 종목코드는 6자리 숫자다.
  static final RegExp _symbolPattern = RegExp(r'^\d{6}$');

  /// 국내 주식이면서 6자리 종목코드인 항목만 통과시킨다.
  /// 자동완성은 지수·ETF·해외 종목도 함께 내려준다.
  static bool isDomesticStock(Map<String, dynamic> json) {
    return ParseUtil.parse<String>(json, 'nationCode') == _domesticNation &&
        ParseUtil.parse<String>(json, 'category') == _stockCategory &&
        _symbolPattern.hasMatch(ParseUtil.parse<String>(json, 'code'));
  }

  //- operator
  @override
  bool operator ==(Object other) => other is StockModel && other.canonicalId == canonicalId;

  @override
  int get hashCode => canonicalId.hashCode;
}
