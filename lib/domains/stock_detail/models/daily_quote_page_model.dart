import 'package:html/dom.dart';
import 'package:html/parser.dart';

import '../../../utils/format_util.dart';
import '../../../utils/parse_util.dart';
import 'daily_quote_model.dart';

/// 일별 시세 표의 열 순서.
///
/// `docs/NAVER_API.md`의 `종가, 전일비, 시가, 고가, 저가, 거래량`에 맨 앞 날짜를 더한 것이다.
/// 시가·고가·저가·거래량은 모두 `td.num > span.tah.p11` 구조라 선택자로 구분되지 않는다.
/// 그래서 위치로 집되, 번호에 이름을 붙여 어느 열인지 드러낸다.
enum _Column {
  localDate,
  closePrice,
  change,
  openPrice,
  highPrice,
  lowPrice,
  accumulatedTradingVolume,
}

class DailyQuotePageModel {
  const DailyQuotePageModel({required this.quotes, required this.lastPage});

  final List<DailyQuoteModel> quotes;
  final int lastPage;

  /// 한 페이지에 담기는 거래일 수.
  // static const int rowsPerPage = 10;

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

  ///
  factory DailyQuotePageModel.empty() {
    return DailyQuotePageModel(quotes: <DailyQuoteModel>[], lastPage: 1);
  }

  bool get isEmpty => quotes.isEmpty;

  /// 정규화한 날짜 `yyyyMMdd`의 길이.
  static const int _dateLength = 8;

  /// 표의 데이터 행만 골라 파싱한다.
  static List<DailyQuoteModel> _parseRows(Document document) {
    final List<DailyQuoteModel> result = <DailyQuoteModel>[];

    for (final Element row in document.querySelectorAll('table.type2 tr')) {
      final List<Element> cells = row.querySelectorAll('td');

      // 헤더는 th라 td가 0개, 여백 행은 1개, 페이지 네비게이션은 12개다.
      if (cells.length != _Column.values.length) continue;

      // 마지막 페이지에는 `&nbsp;`만 든 채움 행이 td 7개로 섞여 온다.
      // 그대로 두면 종가·저가가 0인 행이 생겨 차트 Y축이 0까지 내려간다.
      final String date = FormatUtil.normalizeDate(cells.textOf(_Column.localDate));
      if (date.length != _dateLength) continue;

      // 전일비는 절댓값으로 오고 방향은 `em.bu_pdn`(하락) 클래스로만 구분된다.
      final bool isDown = row.querySelector('em.bu_pdn') != null;
      final int changeAmount = cells.numberOf(_Column.change);

      result.add(
        DailyQuoteModel(
          localDate: date,
          closePrice: cells.numberOf(_Column.closePrice),
          openPrice: cells.numberOf(_Column.openPrice),
          highPrice: cells.numberOf(_Column.highPrice),
          lowPrice: cells.numberOf(_Column.lowPrice),
          accumulatedTradingVolume: cells.numberOf(_Column.accumulatedTradingVolume),
          change: isDown ? -changeAmount : changeAmount,
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
}

extension on List<Element> {
  String textOf(_Column column) => this[column.index].text.trim();

  /// 셀에서 숫자만 남겨 파싱한다.
  ///
  /// 전일비 셀에는 방향을 알리는 `하락` / `상승` 텍스트가 숫자와 함께 들어 있고,
  /// 부호는 없다. 쉼표·공백·한글을 모두 걷어내고 자릿수만 남긴다.
  int numberOf(_Column column) {
    final String digits = textOf(column).replaceAll(RegExp(r'[^0-9]'), '');
    return ParseUtil.parse<int>(<String, dynamic>{'v': digits}, 'v');
  }
}
