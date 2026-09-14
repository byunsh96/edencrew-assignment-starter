import 'package:flutter/foundation.dart';

import '../../../models/stock.dart';
import '../../../models/stock_quote.dart';
import '../../../repository/stock_repository.dart';
import '../enums/favorite_list_sort.dart';
import '../models/favorite_list_item.dart';
import 'favorite_controller.dart';

//TODO 리뷰 확인

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
  final Map<String, StockQuote> _quotes = <String, StockQuote>{};

  bool _isLoading = true;
  bool _hasError = false;
  FavoriteListSort _sort = FavoriteListSort.price;

  bool get isLoading => _isLoading;

  bool get hasError => _hasError;

  bool get isEmpty => _favoriteController.isEmpty;

  FavoriteListSort get sort => _sort;

  /// 관심 목록에 현재 시세를 붙이고 정렬해서 돌려준다.
  List<FavoriteListItem> get items {
    final List<FavoriteListItem> result = _favoriteController.items
        .map((Stock stock) => FavoriteListItem(stock: stock, quote: _quotes[stock.symbol]))
        .toList();

    result.sort(_compare);
    return result;
  }

  /// 관심종목 시세를 한 번의 요청으로 조회한다. 종목마다 따로 호출하지 않는다.
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

    final List<StockQuote> quotes = await _stockRepository.getRealtimeQuotes(symbols);

    // 관심 목록에서 빠진 종목의 시세가 남지 않도록 통째로 갈아끼운다.
    _quotes
      ..clear()
      ..addEntries(quotes.map((StockQuote e) => MapEntry<String, StockQuote>(e.symbol, e)));

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

  /// 관심 목록이 바뀌면 시세를 다시 받는다.
  ///
  /// 검색 화면에서 등록한 종목이 관심 화면에 바로 반영되어야 한다.
  void _onFavoritesChanged() => fetchQuotes();

  /// 시세를 아직 받지 못한 행은 어떤 정렬에서든 뒤로 보낸다.
  ///
  /// Figma에 정의되지 않은 부분이다. 0으로 취급하면 하락 종목과 섞여
  /// 실제로 떨어진 종목처럼 읽히므로 목록 끝으로 몰았다.
  int _compare(FavoriteListItem a, FavoriteListItem b) {
    final StockQuote? left = a.quote;
    final StockQuote? right = b.quote;

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
