import 'dart:convert';
import 'dart:io';

import 'package:cp949_codec/cp949_codec.dart';
import 'package:edencrew_assignment_starter/domains/stock_search/models/stock_search_item.dart';
import 'package:edencrew_assignment_starter/domains/stock_detail/models/daily_quote.dart';
import 'package:edencrew_assignment_starter/domains/stock_detail/models/daily_quote_page.dart';
import 'package:edencrew_assignment_starter/enums/price_direction.dart';
import 'package:edencrew_assignment_starter/models/stock_meta.dart';
import 'package:edencrew_assignment_starter/models/stock_quote.dart';
import 'package:edencrew_assignment_starter/utils/parse_util.dart';
import 'package:flutter_test/flutter_test.dart';

/// `assets/mock/`에 저장해 둔 실제 응답으로 파싱을 검증한다.
///
/// 네이버 endpoint는 호출이 잦으면 차단될 수 있어 저장본으로 테스트한다.
void main() {
  Map<String, dynamic> readJson(String name, {required bool isEucKr}) {
    final List<int> bytes = File('assets/mock/$name').readAsBytesSync();
    final String body =
        isEucKr
            ? cp949.decode(bytes, allowInvalid: true)
            : utf8.decode(bytes, allowMalformed: true);
    return jsonDecode(body) as Map<String, dynamic>;
  }

  group('검색 자동완성', () {
    test('국내 6자리 종목코드만 통과시킨다', () {
      final Map<String, dynamic> json =
          readJson('auto_complete.json', isEucKr: false);

      final List<StockSearchItem> items = ParseUtil.parseList<
          Map<String, dynamic>>(json, 'items', (Map<String, dynamic> e) => e)
          .where(StockSearchItem.isDomesticStock)
          .map(StockSearchItem.fromJson)
          .toList();

      expect(items, isNotEmpty);
      for (final StockSearchItem item in items) {
        expect(item.symbol, matches(RegExp(r'^\d{6}$')));
        expect(item.name, isNotEmpty);
      }

      final StockSearchItem samsung =
          items.firstWhere((StockSearchItem e) => e.symbol == '005930');
      expect(samsung.name, '삼성전자');
      expect(samsung.marketName, '코스피');
      expect(samsung.canonicalId, 'domestic:005930');
      expect(samsung.symbolWithMarket, '005930 · 코스피');
    });
  });

  group('실시간 시세', () {
    test('EUC-KR 응답에서 종목명이 깨지지 않는다', () {
      final Map<String, dynamic> json =
          readJson('realtime_quote.json', isEucKr: true);
      final Map<String, dynamic> area = Map<String, dynamic>.from(
        ((json['result'] as Map<String, dynamic>)['areas'] as List<dynamic>)
            .first as Map<dynamic, dynamic>,
      );

      final List<StockQuote> quotes =
          ParseUtil.parseList<StockQuote>(area, 'datas', StockQuote.fromJson);

      expect(quotes.length, 3);

      final StockQuote samsung =
          quotes.firstWhere((StockQuote e) => e.symbol == '005930');
      expect(samsung.name, '삼성전자'); // UTF-8로 읽으면 깨진다
      expect(samsung.currentPrice, greaterThan(0));
      expect(samsung.listedShareCount, greaterThan(0));
    });

    test('등락은 응답 값이 아니라 nv - pcv로 계산한다', () {
      final Map<String, dynamic> json =
          readJson('realtime_quote.json', isEucKr: true);
      final Map<String, dynamic> area = Map<String, dynamic>.from(
        ((json['result'] as Map<String, dynamic>)['areas'] as List<dynamic>)
            .first as Map<dynamic, dynamic>,
      );
      final StockQuote quote =
          ParseUtil.parseList<StockQuote>(area, 'datas', StockQuote.fromJson)
              .first;

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
      final StockMeta meta =
          StockMeta.fromJson(readJson('stock_meta.json', isEucKr: false));

      expect(meta.symbol, '005930');
      expect(meta.name, '삼성전자');
      expect(meta.marketName, '코스피');
      expect(meta.symbolWithMarket, '005930 · 코스피');
    });
  });

  group('일별 시세 HTML', () {
    late DailyQuotePage page;

    setUpAll(() {
      final String html =
          cp949.decode(
        File('assets/mock/daily_quote.html').readAsBytesSync(),
        allowInvalid: true,
      );
      page = DailyQuotePage.fromHtml(html, requestedPage: 1);
    });

    test('한 페이지에서 거래일 10건을 읽는다', () {
      expect(page.quotes.length, DailyQuotePage.rowsPerPage);
      expect(page.isEmpty, isFalse);
    });

    test('마지막 페이지 번호를 읽는다', () {
      expect(page.lastPage, greaterThan(1));
    });

    test('날짜는 yyyyMMdd로 정규화된다', () {
      for (final DailyQuote quote in page.quotes) {
        expect(quote.date, matches(RegExp(r'^\d{8}$')));
      }
    });

    test('전일비는 절댓값이므로 하락 표시에 부호를 붙인다', () {
      // 시안 종목(005930) 1페이지 첫 행은 하락이다.
      final DailyQuote first = page.quotes.first;
      expect(first.change, isNot(0));
      expect(
        first.direction,
        first.change < 0 ? PriceDirection.down : PriceDirection.up,
      );
    });

    test('시가·고가·저가·거래량이 모두 양수로 파싱된다', () {
      for (final DailyQuote quote in page.quotes) {
        expect(quote.closePrice, greaterThan(0));
        expect(quote.openPrice, greaterThan(0));
        expect(quote.highPrice, greaterThanOrEqualTo(quote.lowPrice));
        expect(quote.accumulatedTradingVolume, greaterThan(0));
      }
    });
  });
}
