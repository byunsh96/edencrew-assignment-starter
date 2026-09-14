import 'package:flutter/foundation.dart';

import '../../../models/stock_model.dart';
import '../../../models/stock_quote_model.dart';
import '../../../repository/stock_repository.dart';
import '../enums/favorite_list_sort.dart';
import '../models/favorite_list_item_model.dart';
import 'favorite_controller.dart';

/// 관심 화면 상태.
class FavoriteListController extends ChangeNotifier {
  FavoriteListController({required FavoriteController favoriteController})
    : _favoriteController = favoriteController {
    _favoriteController.addListener(_onFavoritesChanged);
    fetchQuotes();
  }

  final StockRepository _stockRepository = StockRepository();
  final FavoriteController _favoriteController;

  /// symbol로 바로 찾을 수 있게 Map으로 들고 있는다.
  final Map<String, StockQuoteModel> _quotes = <String, StockQuoteModel>{};

  bool _isLoading = true;
  bool _hasError = false;
  FavoriteListSort _sort = FavoriteListSort.price;

  bool get isLoading => _isLoading;

  bool get hasError => _hasError;

  bool get isEmpty => _favoriteController.isEmpty;

  FavoriteListSort get sort => _sort;

  /// 관심 목록에 현재 시세를 붙이고 정렬해서 돌려준다.
  List<FavoriteListItemModel> get items {
    final List<FavoriteListItemModel> result = _favoriteController.items
        .map(
          (StockModel stock) => FavoriteListItemModel(stock: stock, quote: _quotes[stock.symbol]),
        )
        .toList();

    result.sort(_compare);
    return result;
  }

  /// 관심종목 시세 조회
  Future<void> fetchQuotes() async {
    final List<String> symbols = _favoriteController.symbols;
    if (symbols.isEmpty) {
      _quotes.clear();
      _isLoading = false;
      _hasError = false;
      notifyListeners();
      return;
    }

    _isLoading = true;
    _hasError = false;
    notifyListeners();

    final List<StockQuoteModel> quotes = await _stockRepository.getRealtimeQuotes(symbols);

    // 관심 목록에서 빠진 종목의 시세가 남지 않도록 통째로 갈아끼운다.
    _quotes
      ..clear()
      ..addEntries(
        quotes.map((StockQuoteModel e) => MapEntry<String, StockQuoteModel>(e.symbol, e)),
      );

    // 요청은 했는데 한 건도 못 받았다면 네트워크 문제로 본다.
    _hasError = quotes.isEmpty;
    _isLoading = false;
    notifyListeners();
  }

  void changeSort(FavoriteListSort next) {
    if (_sort == next) return;
    _sort = next;
    notifyListeners();
  }

  /// 관심 목록이 바뀌면 시세 재조회
  void _onFavoritesChanged() => fetchQuotes();

  //compare
  int _compare(FavoriteListItemModel a, FavoriteListItemModel b) {
    final StockQuoteModel? left = a.quote;
    final StockQuoteModel? right = b.quote;

    if (left == null && right == null) {
      return a.stock.name.compareTo(b.stock.name);
    }
    if (left == null) return 1;
    if (right == null) return -1;

    return switch (_sort) {
      FavoriteListSort.price => right.currentPrice.compareTo(left.currentPrice),
      FavoriteListSort.changeRate => right.changeRate.compareTo(left.changeRate),
      FavoriteListSort.name => a.stock.name.compareTo(b.stock.name),
    };
  }

  @override
  void dispose() {
    _favoriteController.removeListener(_onFavoritesChanged);
    super.dispose();
  }
}
