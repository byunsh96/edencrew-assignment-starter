import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../../../models/stock_model.dart';
import '../../../models/stock_quote_model.dart';
import '../../../repository/stock_repository.dart';
import '../../favorite_list/controllers/favorite_controller.dart';
import '../enums/chart_period.dart';
import '../models/daily_quote_model.dart';
import '../models/daily_quote_page_model.dart';

//TODO 리뷰 확인

/// 종목 상세 화면 상태.
class StockDetailController extends ChangeNotifier {
  StockDetailController({
    required FavoriteController favoriteController,
    required StockModel stock,
  })  : _favoriteController = favoriteController,
        _stock = stock {
    _load();
  }

  final StockRepository _stockRepository = StockRepository();
  final FavoriteController _favoriteController;

  /// 목록에서 받은 종목 정보. 메타 endpoint 응답이 오면 그 값으로 갈아끼운다.
  StockModel _stock;

  /// 페이지 번호 -> 그 페이지의 일별 시세.
  ///
  /// 기간 탭을 오갈 때 이미 받은 페이지를 다시 요청하지 않기 위한 캐시다.
  /// 1년을 본 뒤 1개월로 돌아오면 요청이 한 건도 나가지 않는다.
  final Map<int, List<DailyQuoteModel>> _pageCache = <int, List<DailyQuoteModel>>{};

  /// 응답에서 읽은 마지막 페이지. 이 값을 넘는 페이지는 요청하지 않는다.
  int? _lastPage;

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
  List<DailyQuoteModel> get dailyQuotes {
    final int target = math.min(_period.pageCount, _lastPage ?? _period.pageCount);

    final List<DailyQuoteModel> result = <DailyQuoteModel>[];
    for (int page = 1; page <= target; page++) {
      result.addAll(_pageCache[page] ?? const []);
    }
    return result;
  }

  bool toggleFavorite() => _favoriteController.toggle(_stock);

  Future<void> changePeriod(ChartPeriod next) async {
    if (_period == next) return;
    _period = next;

    _isPeriodLoading = true;
    notifyListeners();

    await _ensurePages(next.pageCount);

    _isPeriodLoading = false;
    notifyListeners();
  }

  Future<void> _load() async {
    _isLoading = true;
    notifyListeners();

    await Future.wait(<Future<void>>[
      _fetchQuote(),
      _fetchMeta(),
      _ensurePages(_period.pageCount),
    ]);

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _fetchQuote() async {
    final List<StockQuoteModel> quotes =
        await _stockRepository.getRealtimeQuotes(<String>[_stock.symbol]);
    _quote = quotes.isEmpty ? null : quotes.first;
  }

  /// 종목명과 거래소명을 메타 endpoint에서 받아 갱신한다.
  ///
  /// 목록에서 넘어온 값이 이미 있으므로 실패해도 화면은 그대로 그려진다.
  /// 상세는 한 종목만 보므로 요청이 1건이다. 검색·관심 목록에서 종목마다 부르면
  /// 목록 크기만큼 요청이 늘어나므로 그쪽은 자동완성이 준 값을 그대로 쓴다.
  Future<void> _fetchMeta() async {
    final StockModel? meta = await _stockRepository.getStockMeta(_stock.symbol);
    if (meta != null) _stock = meta;
  }

  /// [required] 페이지까지 확보한다. 이미 받은 페이지는 건너뛴다.
  Future<void> _ensurePages(int required) async {
    // lastPage를 알아야 그보다 큰 페이지를 거를 수 있으므로 1페이지를 먼저 받는다.
    if (_lastPage == null) {
      final DailyQuotePageModel first =
          await _stockRepository.getDailyQuotes(_stock.symbol, page: 1);
      if (first.isEmpty) return;

      _pageCache[1] = first.quotes;
      _lastPage = first.lastPage;
    }

    final int target = math.min(required, _lastPage!);
    final List<int> missing = <int>[
      for (int page = 2; page <= target; page++)
        if (!_pageCache.containsKey(page)) page,
    ];
    if (missing.isEmpty) return;

    // 남은 페이지는 한꺼번에 받는다. 1년(25페이지)을 순차로 받으면 너무 느리다.
    final List<DailyQuotePageModel> results = await Future.wait(
      missing.map(
        (int page) =>
            _stockRepository.getDailyQuotes(_stock.symbol, page: page),
      ),
    );

    for (int i = 0; i < missing.length; i++) {
      if (results[i].isEmpty) continue;
      _pageCache[missing[i]] = results[i].quotes;
    }
  }
}
