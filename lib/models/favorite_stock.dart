/// 관심 목록에 담긴 종목.
///
/// 이름과 거래소명을 함께 들고 있는다. 실시간 시세 응답에는 거래소명이 없어서
/// 매번 메타 endpoint를 종목마다 부르지 않으려면 등록 시점에 저장해 둬야 한다.
class FavoriteStock {
  const FavoriteStock({
    required this.symbol,
    required this.name,
    required this.marketName,
  });

  /// 6자리 종목코드. `005930` / `000660`
  /// 앞자리 0이 의미를 가지므로 int로 다루지 않는다.
  final String symbol;

  /// `삼성전자` / `SK하이닉스`
  final String name;

  /// `코스피` / `코스닥`
  final String marketName;

  String get symbolWithMarket => '$symbol · $marketName';

  @override
  bool operator ==(Object other) =>
      other is FavoriteStock && other.symbol == symbol;

  @override
  int get hashCode => symbol.hashCode;
}
