import '../../../models/favorite_stock.dart';
import '../../../models/stock_quote.dart';

/// 관심 목록 한 행.
///
/// [quote]가 `null`이면 아직 시세를 받지 못한 상태다. 행을 스켈레톤으로 그린다.
class WatchlistItem {
  const WatchlistItem({required this.stock, this.quote});

  final FavoriteStock stock;
  final StockQuote? quote;

  bool get hasQuote => quote != null;
}
