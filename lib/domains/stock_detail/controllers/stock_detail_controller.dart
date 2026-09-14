import 'package:flutter/foundation.dart';

import '../../../models/stock_model.dart';
import '../../../models/stock_quote_model.dart';
import '../../../repository/daily_quote_cache_manager.dart';
import '../../../repository/stock_repository.dart';
import '../../favorite_list/controllers/favorite_controller.dart';
import '../enums/chart_period.dart';
import '../models/daily_quote_model.dart';
import '../models/daily_quote_page_model.dart';

/// 종목 상세 화면 상태.
class StockDetailController extends ChangeNotifier {
  StockDetailController({required FavoriteController favoriteController, required StockModel stock})
    : _favoriteController = favoriteController,
      _stock = stock {
    _load();
  }

  final StockRepository _stockRepository = StockRepository();
  final FavoriteController _favoriteController;

  /// 목록에서 받은 종목 정보. 메타 endpoint 응답이 오면 그 값으로 갈아끼운다.
  StockModel _stock;

  /// 일별 시세 페이지 캐시. 보관·상한 계산은 이쪽이 맡는다.
  final DailyQuoteCacheManager _cacheManager = DailyQuoteCacheManager();

  StockQuoteModel? _quote;
  ChartPeriod _period = ChartPeriod.oneMonth;
  bool _isLoading = true;
  bool _isPeriodLoading = false;

  StockModel get stock => _stock;

  StockQuoteModel? get quote => _quote;

  ChartPeriod get period => _period;

  bool get isLoading => _isLoading;

  bool get isPeriodLoading => _isPeriodLoading;

  bool get isFavorite => _favoriteController.contains(_stock.symbol);

  /// 선택한 기간에 해당하는 일별 시세. 최신 날짜가 앞이다.
  List<DailyQuoteModel> get dailyQuotes =>
      _cacheManager.take(pageCount: _period.pageCount);

  bool toggleFavorite() => _favoriteController.toggle(_stock);

  Future<void> changePeriod(ChartPeriod next) async {
    if (_period == next) return;
    _period = next;

    _isPeriodLoading = true;
    notifyListeners();

    await _ensureDailyQuotes(next.pageCount);

    _isPeriodLoading = false;
    notifyListeners();
  }

  Future<void> _load() async {
    _isLoading = true;
    notifyListeners();

    await Future.wait(<Future<void>>[
      _fetchRealtimeQuote(),
      _fetchStockMeta(),
      _ensureDailyQuotes(_period.pageCount),
    ]);

    _isLoading = false;
    notifyListeners();
  }

  //
  Future<void> _fetchRealtimeQuote() async {
    final List<StockQuoteModel> quotes = await _stockRepository.getRealtimeQuotes(<String>[
      _stock.symbol,
    ]);
    _quote = quotes.isEmpty ? null : quotes.first;
  }

  /// 종목명과 거래소명을 메타 endpoint에서 받아 갱신한다.
  ///
  /// 목록에서 넘어온 값이 이미 있으므로 실패해도 화면은 그대로 그려진다.
  /// 상세는 한 종목만 보므로 요청이 1건이다. 검색·관심 목록에서 종목마다 부르면
  /// 목록 크기만큼 요청이 늘어나므로 그쪽은 자동완성이 준 값을 그대로 쓴다.
  Future<void> _fetchStockMeta() async {
    final StockModel? meta = await _stockRepository.getStockMeta(_stock.symbol);
    if (meta != null) _stock = meta;
  }

  /// [pageCount] 페이지까지 확보한다. 이미 받은 페이지는 건너뛴다.
  Future<void> _ensureDailyQuotes(int pageCount) async {
    // lastPage를 알아야 그보다 큰 페이지를 거를 수 있으므로 1페이지를 먼저 받는다.
    if (_cacheManager.isEmpty) {
      _cacheManager.save(
        page: 1,
        result: await _stockRepository.getDailyQuotes(_stock.symbol, page: 1),
      );
      if (_cacheManager.isEmpty) return;
    }

    final List<int> missing = _cacheManager.missingPages(pageCount: pageCount);
    if (missing.isEmpty) return;

    // 남은 페이지는 한꺼번에 받는다. 1년(25페이지)을 순차로 받으면 너무 느리다.
    final List<DailyQuotePageModel> results = await Future.wait(
      missing.map((int page) => _stockRepository.getDailyQuotes(_stock.symbol, page: page)),
    );

    for (int i = 0; i < missing.length; i++) {
      _cacheManager.save(page: missing[i], result: results[i]);
    }
  }
}
