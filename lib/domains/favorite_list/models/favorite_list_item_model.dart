import '../../../models/stock_model.dart';
import '../../../models/stock_quote_model.dart';

/// 관심 목록 한 행.
///
/// [quote]가 `null`이면 아직 시세를 받지 못한 상태다. 행을 스켈레톤으로 그린다.
class FavoriteListItemModel {
  const FavoriteListItemModel({required this.stock, this.quote});

  final StockModel stock;
  final StockQuoteModel? quote;

  bool get hasQuote => quote != null;
}
