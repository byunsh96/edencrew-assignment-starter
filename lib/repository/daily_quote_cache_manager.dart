import 'dart:math' as math;

import '../domains/stock_detail/models/daily_quote_model.dart';
import '../domains/stock_detail/models/daily_quote_page_model.dart';

/// 일별 시세 페이지 캐시를 관리한다.
///
/// 기간 탭을 오갈 때 이미 받은 페이지를 다시 요청하지 않도록 페이지 단위로 보관한다.
/// `lastPage`를 함께 들고 있어야 존재하지 않는 페이지를 거를 수 있다.
/// (`docs/NAVER_API.md` 4번 — 「필요한 만큼만 받고 이미 받은 페이지는 재사용」)
class DailyQuoteCacheManager {
  /// 페이지 번호 -> 그 페이지의 일별 시세.
  final Map<int, List<DailyQuoteModel>> _pages = <int, List<DailyQuoteModel>>{};

  /// 응답에서 읽은 마지막 페이지. 아직 한 번도 받지 못했으면 `null`이다.
  int? _lastPage;

  int? get lastPage => _lastPage;

  bool get isEmpty => _pages.isEmpty;

  /// 받은 페이지를 보관한다. 빈 응답은 캐시하지 않는다.
  ///
  /// 빈 응답까지 저장하면 다음 호출에서 "이미 받았다"고 판단해 영영 재시도하지 않는다.
  void save({required int page, required DailyQuotePageModel result}) {
    if (result.quotes.isEmpty) return;

    _pages[page] = result.quotes;
    // lastPage는 종목마다 고정이라 처음 받은 값을 유지한다.
    _lastPage ??= result.lastPage;
  }

  /// [pageCount]페이지까지 채우는 데 아직 없는 페이지 번호.
  ///
  /// [pageCount]는 기간 탭이 요구하는 페이지 개수(`ChartPeriod.pageCount`)
  /// `lastPage`를 넘는 번호는 응답이 없으므로 애초에 목록에 넣지 않는다.
  List<int> missingPages({required int pageCount}) {
    return <int>[
      for (int page = 1; page <= _targetOf(pageCount); page++)
        if (!_pages.containsKey(page)) page,
    ];
  }

  /// [pageCount]페이지 분량을 페이지 순서대로 이어 붙인다.
  ///
  /// [pageCount]는 기간 탭이 요구하는 페이지 개수(`ChartPeriod.pageCount`)
  /// 네이버 응답이 최신 날짜부터라 결과도 최신순이다.
  /// 아직 받지 못한 페이지는 건너뛰므로, 일부만 받은 상태에서도 화면을 그릴 수 있다.
  List<DailyQuoteModel> take({required int pageCount}) {
    final List<DailyQuoteModel> result = <DailyQuoteModel>[];
    for (int page = 1; page <= _targetOf(pageCount); page++) {
      result.addAll(_pages[page] ?? const <DailyQuoteModel>[]);
    }
    return result;
  }

  /// 실제로 다룰 페이지 수. `lastPage`를 모르는 동안에는 요청받은 값을 그대로 쓴다.
  int _targetOf(int pageCount) => math.min(pageCount, _lastPage ?? pageCount);
}
