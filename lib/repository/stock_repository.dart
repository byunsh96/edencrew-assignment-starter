import '../constants/naver_api.dart';
import '../core/models/api_response_model.dart';
import '../core/repository/core_repository.dart';
import '../models/stock_model.dart';
import '../domains/stock_detail/models/daily_quote_page_model.dart';
import '../models/stock_quote_model.dart';
import '../utils/log_util.dart';
import 'mock_repository.dart';
import '../utils/parse_util.dart';
import 'dart:convert';

/// 네이버 증권 endpoint 4개를 담당한다.
///
/// 세 화면이 같은 endpoint를 나눠 쓰기 때문에 도메인별로 쪼개지 않고 한 클래스에 모았다.
/// endpoint 하나당 메서드 하나다.
class StockRepository {
  /// 상태가 없어 화면마다 새로 만들어도 비용이 없다.
  /// 인자를 넘기지 않으면 공유 싱글턴을 쓰고, 테스트에서만 교체한다.
  StockRepository([CoreRepository? coreRepository])
    : _coreRepository = coreRepository ?? CoreRepository.instance;

  static const String _file = 'StockRepository';

  final CoreRepository _coreRepository;
  final MockRepository _mockRepository = MockRepository();

  //GET https://ac.stock.naver.com/ac (검색 자동완성)
  Future<List<StockModel>> getAutoComplete(String keyword) async {
    try {
      final ApiResponseModel response = await _coreRepository.getData(
        NaverApi.autoComplete,
        query: <String, dynamic>{'q': keyword, 'target': 'stock,ipo,index,marketindicator'},
      );

      // 차단되거나 5xx면 저장해 둔 응답으로 이어간다.
      final Map<String, dynamic>? json =
          response.asMap ?? await _mockMap('auto_complete.json', source: '검색 자동완성');
      if (json == null) return <StockModel>[];

      // 지수·ETF·해외 종목이 함께 내려오므로 국내 주식만 남긴다.
      return ParseUtil.parseList<Map<String, dynamic>>(
        json,
        'items',
        (Map<String, dynamic> item) => item,
      ).where(StockModel.isDomesticStock).map(StockModel.fromJson).toList();
    } catch (e) {
      LogUtil().logError('getAutoComplete: $e', module: _file);
    }
    return <StockModel>[];
  }

  //GET https://polling.finance.naver.com/api/realtime (실시간 시세)
  ///
  /// 관심종목 전체를 한 번의 요청으로 조회한다. 종목마다 따로 호출하지 않는다.
  Future<List<StockQuoteModel>> getRealtimeQuotes(List<String> symbols) async {
    if (symbols.isEmpty) return <StockQuoteModel>[];

    try {
      final ApiResponseModel response = await _coreRepository.getData(
        NaverApi.realtime,
        query: <String, dynamic>{'query': '${NaverApi.realtimeQueryPrefix}${symbols.join(',')}'},
      );

      final Map<String, dynamic>? json =
          response.asMap ?? await _mockMap('realtime_quote.json', source: '실시간 시세');
      final Object? areas = (json?['result'] as Map<String, dynamic>?)?['areas'];
      if (areas is! List || areas.isEmpty) return <StockQuoteModel>[];

      final Object? first = areas.first;
      if (first is! Map) return <StockQuoteModel>[];

      return ParseUtil.parseList<StockQuoteModel>(
        Map<String, dynamic>.from(first),
        'datas',
        StockQuoteModel.fromJson,
      );
    } catch (e) {
      LogUtil().logError('getRealtimeQuotes: $e', module: _file);
    }
    return <StockQuoteModel>[];
  }

  //GET https://stock.naver.com/api/securityFe/api/fchart/domestic/stock/{symbol} (종목 메타)
  Future<StockModel?> getStockMeta(String symbol) async {
    try {
      final ApiResponseModel response = await _coreRepository.getData(NaverApi.stockMeta(symbol));

      final Map<String, dynamic>? json =
          response.asMap ?? await _mockMap('stock_meta.json', source: '종목 메타');
      if (json == null) return null;

      return StockModel.fromMetaJson(json);
    } catch (e) {
      LogUtil().logError('getStockMeta($symbol): $e', module: _file);
    }
    return null;
  }

  //GET https://finance.naver.com/item/sise_day.naver (일별 시세 HTML)
  ///
  /// 응답이 JSON이 아니라 EUC-KR HTML이다. 파싱 결과와 함께 마지막 페이지 번호를 돌려준다.
  Future<DailyQuotePageModel> getDailyQuotes(String symbol, {required int page}) async {
    try {
      final String? html = await _coreRepository.getHtml(
        NaverApi.dailyQuote,
        query: <String, dynamic>{'code': symbol, 'page': page},
      );

      // 네이버는 차단해도 200에 안내 페이지를 준다. 상태 코드로는 못 잡고
      // 표를 파싱해 0행이면 정상 응답이 아니라고 본다.
      final DailyQuotePageModel parsed = html == null
          ? DailyQuotePageModel.empty()
          : DailyQuotePageModel.fromHtml(html, requestedPage: page);
      if (parsed.quotes.isNotEmpty) return parsed;

      // 저장본은 1페이지 분량뿐이다. 2페이지 이상을 같은 내용으로 채우면
      // 같은 날짜가 반복되어 차트가 어긋나므로 1페이지만 대체한다.
      if (page != 1) return parsed;

      final String? mock = await _mockRepository.loadHtml('daily_quote.html', source: '일별 시세');
      if (mock == null) return parsed;

      return DailyQuotePageModel.fromHtml(mock, requestedPage: page);
    } catch (e) {
      LogUtil().logError('getDailyQuotes($symbol, $page): $e', module: _file);
    }
    return DailyQuotePageModel.empty();
  }

  /// 저장해 둔 JSON 응답을 Map으로 읽는다. 대체하지 않기로 했으면 `null`이다.
  Future<Map<String, dynamic>?> _mockMap(String fileName, {required String source}) async {
    final String? raw = await _mockRepository.loadJson(fileName, source: source);
    if (raw == null) return null;

    try {
      final Object? decoded = jsonDecode(raw);
      return decoded is Map<String, dynamic> ? decoded : null;
    } catch (e) {
      LogUtil().logError('_mockMap($fileName): $e', module: _file);
      return null;
    }
  }
}
