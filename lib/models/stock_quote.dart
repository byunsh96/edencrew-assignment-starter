import '../enums/price_direction.dart';
import '../utils/parse_util.dart';

/// 실시간 시세 한 건.
///
/// 응답에 등락액(`cv`)과 등락률(`cr`)이 있지만 둘 다 절댓값이고 방향은 별도 코드(`rf`)로
/// 온다. 코드 해석에 기대는 대신 `nv - pcv`로 직접 계산한다.
class StockQuote {
  const StockQuote({
    required this.symbol,
    required this.name,
    required this.currentPrice,
    required this.previousClose,
    required this.openPrice,
    required this.highPrice,
    required this.lowPrice,
    required this.accumulatedTradingVolume,
    required this.listedShareCount,
  });

  factory StockQuote.fromJson(Map<String, dynamic> json) {
    return StockQuote(
      symbol: ParseUtil.parse<String>(json, 'cd'),
      name: ParseUtil.parse<String>(json, 'nm'),
      currentPrice: ParseUtil.parse<int>(json, 'nv'),
      previousClose: ParseUtil.parse<int>(json, 'pcv'),
      openPrice: ParseUtil.parse<int>(json, 'ov'),
      highPrice: ParseUtil.parse<int>(json, 'hv'),
      lowPrice: ParseUtil.parse<int>(json, 'lv'),
      accumulatedTradingVolume: ParseUtil.parse<int>(json, 'aq'),
      listedShareCount: ParseUtil.parse<int>(json, 'countOfListedStock'),
    );
  }

  final String symbol;
  final String name;
  final int currentPrice;
  final int previousClose;
  final int openPrice;
  final int highPrice;
  final int lowPrice;
  final int accumulatedTradingVolume;
  final int listedShareCount;

  int get change => currentPrice - previousClose;

  double get changeRate => previousClose == 0 ? 0 : change / previousClose;

  PriceDirection get direction => PriceDirection.of(change);

  /// 시가총액. 현재가 × 상장 주식 수.
  int get marketCap => currentPrice * listedShareCount;
}
