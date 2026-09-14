import 'package:html/dom.dart';
import 'package:html/parser.dart';

import '../../../utils/format_util.dart';
import '../../../utils/parse_util.dart';
import 'daily_quote_model.dart';

class DailyQuotePageModel {
  const DailyQuotePageModel({required this.quotes, required this.lastPage});

  /// 응답이 비었거나 파싱에 실패했을 때의 fallback.
  static const DailyQuotePageModel empty = DailyQuotePageModel(quotes: <DailyQuoteModel>[], lastPage: 1);

  /// 한 페이지에 담기는 거래일 수.
  static const int rowsPerPage = 10;

  /// EUC-KR로 디코딩된 HTML을 파싱한다.
  ///
  /// [requestedPage]는 `맨뒤` 링크를 찾지 못했을 때 쓰는 fallback이다.
  /// 마지막 페이지에서는 그 링크가 사라지므로 없다고 해서 오류는 아니다.
  factory DailyQuotePageModel.fromHtml(String html, {required int requestedPage}) {
    final Document document = parse(html);
    return DailyQuotePageModel(
      quotes: _parseRows(document),
      lastPage: _parseLastPage(document) ?? requestedPage,
    );
  }

  final List<DailyQuoteModel> quotes;
  final int lastPage;

  bool get isEmpty => quotes.isEmpty;

  /// 표의 데이터 행만 골라 파싱한다.
  ///
  /// 헤더와 여백 행이 섞여 있어 `td`가 7개이고 날짜가 온전한 행만 남긴다.
  /// 전일비는 절댓값으로 오고 방향은 `em.bu_pdn`(하락) 클래스로 구분한다.
  static List<DailyQuoteModel> _parseRows(Document document) {
    final List<DailyQuoteModel> result = <DailyQuoteModel>[];

    for (final Element row in document.querySelectorAll('table.type2 tr')) {
      final List<Element> cells = row.querySelectorAll('td');
      if (cells.length != 7) continue;

      final String date = FormatUtil.normalizeDate(cells[0].text.trim());
      if (date.length != 8) continue;

      final bool isDown = row.querySelector('em.bu_pdn') != null;
      final int changeAmount = _number(cells[2]);

      result.add(
        DailyQuoteModel(
          date: date,
          closePrice: _number(cells[1]),
          change: isDown ? -changeAmount : changeAmount,
          openPrice: _number(cells[3]),
          highPrice: _number(cells[4]),
          lowPrice: _number(cells[5]),
          accumulatedTradingVolume: _number(cells[6]),
        ),
      );
    }
    return result;
  }

  /// 페이지 네비게이션의 `맨뒤` 링크에서 마지막 페이지를 읽는다.
  static int? _parseLastPage(Document document) {
    final String? href = document.querySelector('td.pgRR a')?.attributes['href'];
    if (href == null) return null;

    final String? page = Uri.tryParse(href)?.queryParameters['page'];
    return page == null ? null : int.tryParse(page);
  }

  /// 셀에서 숫자만 남겨 파싱한다.
  /// 전일비 셀에는 방향을 알리는 `하락` / `상승` 텍스트가 숫자와 함께 들어 있다.
  static int _number(Element cell) {
    final String digits = cell.text.replaceAll(RegExp(r'[^0-9]'), '');
    return ParseUtil.parse<int>(<String, dynamic>{'v': digits}, 'v');
  }
}
