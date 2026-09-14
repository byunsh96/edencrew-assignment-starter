import '../utils/parse_util.dart';

//TODO 리뷰 확인

/// 종목 기본 정보. 검색 결과와 관심 목록이 같은 모델을 쓴다.
///
/// 이름과 거래소명을 함께 들고 있는다. 실시간 시세 응답에는 거래소명이 없어서
/// 매번 메타 endpoint를 종목마다 부르지 않으려면 등록 시점에 저장해 둬야 한다.
class StockModel {
  const StockModel({
    required this.symbol,
    required this.name,
    required this.marketName,
  });

  /// 검색 자동완성(`ac.stock.naver.com`) 응답에서 만든다.
  factory StockModel.fromJson(Map<String, dynamic> json) {
    return StockModel(
      symbol: ParseUtil.parse<String>(json, 'code'),
      name: ParseUtil.parse<String>(json, 'name'),
      marketName: ParseUtil.parse<String>(json, 'typeName'),
    );
  }

  /// 종목 메타(`stock.naver.com`) 응답에서 만든다.
  ///
  /// 같은 정보인데 endpoint마다 키 이름이 달라 생성자를 나눈다.
  factory StockModel.fromMetaJson(Map<String, dynamic> json) {
    return StockModel(
      symbol: ParseUtil.parse<String>(json, 'symbolCode'),
      name: ParseUtil.parse<String>(json, 'stockName'),
      marketName: ParseUtil.parse<String>(json, 'stockExchangeNameKor'),
    );
  }

  /// 국내 주식만 남기는 기준.
  static const String _domesticNation = 'KOR';
  static const String _stockCategory = 'stock';

  /// 국내 종목코드는 6자리 숫자다.
  static final RegExp _symbolPattern = RegExp(r'^\d{6}$');

  /// 6자리 종목코드. `005930` / `000660`
  /// 앞자리 0이 의미를 가지므로 int로 다루지 않는다.
  final String symbol;

  /// `삼성전자` / `SK하이닉스`
  final String name;

  /// `코스피` / `코스닥`
  final String marketName;

  String get symbolWithMarket => '$symbol · $marketName';

  /// 앱 내부에서 종목을 가리키는 canonical id.
  ///
  /// 해외 종목이 들어와도 구분되도록 국가 접두사를 붙인다.
  /// (`docs/NAVER_API.md` 1번 - `domestic:{symbol}`)
  String get canonicalId => 'domestic:$symbol';

  /// 국내 주식이면서 6자리 종목코드인 항목만 통과시킨다.
  ///
  /// 자동완성은 지수·ETF·해외 종목도 함께 내려준다.
  static bool isDomesticStock(Map<String, dynamic> json) {
    return ParseUtil.parse<String>(json, 'nationCode') == _domesticNation &&
        ParseUtil.parse<String>(json, 'category') == _stockCategory &&
        _symbolPattern.hasMatch(ParseUtil.parse<String>(json, 'code'));
  }

  /// 관심 목록 중복 등록을 막는다. [canonicalId]가 같으면 같은 종목이다.
  ///
  /// 종목코드만 비교하면 해외 종목이 추가됐을 때 같은 번호끼리 충돌한다.
  @override
  bool operator ==(Object other) =>
      other is StockModel && other.canonicalId == canonicalId;

  @override
  int get hashCode => canonicalId.hashCode;
}
