import 'dart:convert';
import 'dart:io';

import 'package:cp949_codec/cp949_codec.dart';
import 'package:edencrew_assignment_starter/domains/stock_detail/models/daily_quote_model.dart';
import 'package:edencrew_assignment_starter/domains/stock_detail/models/daily_quote_page_model.dart';
import 'package:edencrew_assignment_starter/enums/price_direction.dart';
import 'package:edencrew_assignment_starter/models/stock_quote_model.dart';
import 'package:edencrew_assignment_starter/utils/parse_util.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:edencrew_assignment_starter/models/stock_model.dart';

/// `assets/mock/`에 저장해 둔 실제 응답으로 파싱을 검증한다.
///
/// 네이버 endpoint는 호출이 잦으면 차단될 수 있어 저장본으로 테스트한다.
///
/// 종목명은 화면만 보고 mock 여부를 구분하려고 가상 이름(`성훈전자` …)으로 바꿔 두었다.
/// 종목코드·가격·날짜는 실제 응답 그대로다. (`assets/mock/README.md`)
void main() {
  /// JSON mock 3개는 저장할 때 UTF-8로 옮겼다.
  /// 실시간 시세는 실제로 EUC-KR로 오지만, 그 디코딩은 저장본을 다시 CP949로 인코딩해
  /// `CoreRepository`에 태우는 `page_cache_test`·`watchlist_sort_test`가 검증한다.
  Map<String, dynamic> readJson(String name) {
    final List<int> bytes = File('assets/mock/$name').readAsBytesSync();
    return jsonDecode(utf8.decode(bytes, allowMalformed: true)) as Map<String, dynamic>;
  }

  group('검색 자동완성', () {
    test('국내 6자리 종목코드만 통과시킨다', () {
      final Map<String, dynamic> json = readJson('auto_complete.json');

      final List<StockModel> items = ParseUtil.parseList<Map<String, dynamic>>(
        json,
        'items',
        (Map<String, dynamic> e) => e,
      ).where(StockModel.isDomesticStock).map(StockModel.fromJson).toList();

      expect(items, isNotEmpty);
      for (final StockModel item in items) {
        expect(item.symbol, matches(RegExp(r'^\d{6}$')));
        expect(item.name, isNotEmpty);
      }

      final StockModel samsung = items.firstWhere((StockModel e) => e.symbol == '005930');
      expect(samsung.name, '성훈전자');
      expect(samsung.marketName, '코스피');
      expect(samsung.canonicalId, 'domestic:005930');
      expect(samsung.symbolWithMarket, '005930 · 코스피');
    });
  });

  group('실시간 시세', () {
    test('datas에서 종목명과 시세를 읽는다', () {
      final Map<String, dynamic> json = readJson('realtime_quote.json');
      final Map<String, dynamic> area = Map<String, dynamic>.from(
        ((json['result'] as Map<String, dynamic>)['areas'] as List<dynamic>).first
            as Map<dynamic, dynamic>,
      );

      final List<StockQuoteModel> quotes = ParseUtil.parseList<StockQuoteModel>(
        area,
        'datas',
        StockQuoteModel.fromJson,
      );

      expect(quotes.length, 3);

      final StockQuoteModel samsung = quotes.firstWhere(
        (StockQuoteModel e) => e.symbol == '005930',
      );
      expect(samsung.name, '성훈전자');
      expect(samsung.currentPrice, greaterThan(0));
      expect(samsung.listedShareCount, greaterThan(0));
    });

    test('등락은 응답 값이 아니라 nv - pcv로 계산한다', () {
      final Map<String, dynamic> json = readJson('realtime_quote.json');
      final Map<String, dynamic> area = Map<String, dynamic>.from(
        ((json['result'] as Map<String, dynamic>)['areas'] as List<dynamic>).first
            as Map<dynamic, dynamic>,
      );
      final StockQuoteModel quote = ParseUtil.parseList<StockQuoteModel>(
        area,
        'datas',
        StockQuoteModel.fromJson,
      ).first;

      expect(quote.change, quote.currentPrice - quote.previousClose);
      expect(
        quote.direction,
        quote.change > 0
            ? PriceDirection.up
            : quote.change < 0
            ? PriceDirection.down
            : PriceDirection.flat,
      );
      expect(quote.marketCap, quote.currentPrice * quote.listedShareCount);
    });
  });

  group('종목 메타', () {
    test('종목명과 거래소명을 읽는다', () {
      final StockModel meta = StockModel.fromMetaJson(readJson('stock_meta.json'));

      expect(meta.symbol, '005930');
      expect(meta.name, '성훈전자');
      expect(meta.marketName, '코스피');
      expect(meta.symbolWithMarket, '005930 · 코스피');
    });
  });

  group('일별 시세 HTML', () {
    late DailyQuotePageModel page;

    setUpAll(() {
      final String html = cp949.decode(
        File('assets/mock/daily_quote.html').readAsBytesSync(),
        allowInvalid: true,
      );
      page = DailyQuotePageModel.fromHtml(html, requestedPage: 1);
    });

    final int rowsPerPage = 10;

    test('한 페이지에서 거래일 10건을 읽는다', () {
      expect(page.quotes.length, rowsPerPage);
      expect(page.isEmpty, isFalse);
    });

    test('마지막 페이지 번호를 읽는다', () {
      expect(page.lastPage, greaterThan(1));
    });

    test('날짜는 yyyyMMdd로 정규화된다', () {
      for (final DailyQuoteModel quote in page.quotes) {
        expect(quote.localDate, matches(RegExp(r'^\d{8}$')));
      }
    });

    test('전일비는 절댓값이므로 하락 표시에 부호를 붙인다', () {
      // 시안 종목(005930) 1페이지 첫 행은 하락이다.
      final DailyQuoteModel first = page.quotes.first;
      expect(first.change, isNot(0));
      expect(first.direction, first.change < 0 ? PriceDirection.down : PriceDirection.up);
    });

    test('시가·고가·저가·거래량이 모두 양수로 파싱된다', () {
      for (final DailyQuoteModel quote in page.quotes) {
        expect(quote.closePrice, greaterThan(0));
        expect(quote.openPrice, greaterThan(0));
        expect(quote.highPrice, greaterThanOrEqualTo(quote.lowPrice));
        expect(quote.accumulatedTradingVolume, greaterThan(0));
      }
    });
  });
}
