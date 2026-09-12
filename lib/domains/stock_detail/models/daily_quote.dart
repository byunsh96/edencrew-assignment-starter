import '../../../enums/price_direction.dart';

/// 일별 시세 한 행. 차트 캔들과 일별 시세 표에 함께 쓴다.
class DailyQuote {
  const DailyQuote({
    required this.date,
    required this.closePrice,
    required this.openPrice,
    required this.highPrice,
    required this.lowPrice,
    required this.accumulatedTradingVolume,
    required this.change,
  });

  /// `yyyyMMdd`로 정규화한 날짜.
  final String date;

  final int closePrice;
  final int openPrice;
  final int highPrice;
  final int lowPrice;
  final int accumulatedTradingVolume;

  /// 전일 대비 등락액. 부호까지 포함한다.
  final int change;

  PriceDirection get direction => PriceDirection.of(change);

  /// 캔들 몸통의 방향. 시가보다 종가가 높으면 상승 캔들이다.
  PriceDirection get candleDirection =>
      PriceDirection.of(closePrice - openPrice);
}
