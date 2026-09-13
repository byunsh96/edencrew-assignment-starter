//TODO 리뷰 확인

/// 네이버 증권 endpoint 모음.
///
/// endpoint마다 호스트가 달라 `CoreRepository`에 `baseUrl`을 두지 않는다.
/// 호출부는 여기 상수를 전체 URL 그대로 넘긴다.
abstract final class NaverApi {
  /// 검색 자동완성. query: `q`, `target`
  static const String autoComplete = 'https://ac.stock.naver.com/ac';

  /// 실시간 시세. query: `query` (`SERVICE_ITEM:005930,000660` 형태)
  ///
  /// 관심종목을 한 번에 묶어 조회한다. 종목마다 따로 호출하지 않는다.
  static const String realtime = 'https://polling.finance.naver.com/api/realtime';

  /// 일별 시세 HTML. query: `code`, `page`
  ///
  /// JSON이 아니라 EUC-KR HTML을 반환한다. `CoreRepository.getHtml`로 받는다.
  static const String dailyQuote = 'https://finance.naver.com/item/sise_day.naver';

  /// 종목 메타데이터. 종목명과 거래소명을 얻는다.
  static String stockMeta(String symbol) =>
      'https://stock.naver.com/api/securityFe/api/fchart/domestic/stock/$symbol';

  /// 실시간 시세 query에 들어가는 접두사.
  static const String realtimeQueryPrefix = 'SERVICE_ITEM:';
}
