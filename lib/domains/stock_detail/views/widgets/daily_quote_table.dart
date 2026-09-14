import 'package:flutter/material.dart';

import '../../../../constants/app_text_styles.dart';
import '../../../../enums/price_direction.dart';
import '../../../../theme/theme.dart';
import '../../../../utils/format_util.dart';
import '../../models/daily_quote_model.dart';

/// 일별 시세 표. 날짜 · 종가 · 등락 · 거래량.
class DailyQuoteTable extends StatelessWidget {
  const DailyQuoteTable({required this.quotes, super.key});

  /// Figma 날짜 열 고정 너비. 나머지 세 열이 남은 폭을 나눠 갖는다.
  static const double _dateColumnWidth = 46;

  /// 행 높이와 세로 여백.
  static const double _rowHeight = 32;

  final List<DailyQuoteModel> quotes;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final AppDimens dimens = context.dimens;

    return Column(
      spacing: dimens.space1,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('일별 시세', style: AppTextStyles.label.copyWith(color: colors.textPrimary)),
        Column(
          children: [
            const _HeadRow(),
            for (final DailyQuoteModel quote in quotes) _QuoteRow(quote: quote),
          ],
        ),
      ],
    );
  }
}

class _HeadRow extends StatelessWidget {
  const _HeadRow();

  @override
  Widget build(BuildContext context) {
    final Color color = context.colors.textSecondary;

    return _TableRow(
      date: Text('날짜', style: AppTextStyles.caption.copyWith(color: color)),
      cells: [
        for (final String label in <String>['종가', '등락', '거래량'])
          Text(
            label,
            textAlign: TextAlign.right,
            style: AppTextStyles.caption.copyWith(color: color),
          ),
      ],
    );
  }
}

class _QuoteRow extends StatelessWidget {
  const _QuoteRow({required this.quote});

  final DailyQuoteModel quote;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;

    return _TableRow(
      hasTopBorder: true,
      date: Text(
        FormatUtil.monthDay(quote.localDate),
        style: AppTextStyles.caption.copyWith(color: colors.textSecondary),
      ),
      cells: <Widget>[
        _NumberCell(text: FormatUtil.decimal(quote.closePrice), color: colors.textPrimary),
        _NumberCell(
          text: FormatUtil.signedDecimal(quote.change),
          color: quote.direction.text(colors),
        ),
        _NumberCell(
          text: FormatUtil.decimal(quote.accumulatedTradingVolume),
          color: colors.textSecondary,
        ),
      ],
    );
  }
}

class _NumberCell extends StatelessWidget {
  const _NumberCell({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.right,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: AppTextStyles.caption.copyWith(color: color),
    );
  }
}

/// 머리글과 데이터 행이 같은 열 폭을 쓰도록 한곳에서 배치한다.
class _TableRow extends StatelessWidget {
  const _TableRow({required this.date, required this.cells, this.hasTopBorder = false});

  final Widget date;
  final List<Widget> cells;
  final bool hasTopBorder;

  @override
  Widget build(BuildContext context) {
    final AppDimens dimens = context.dimens;

    return Container(
      height: DailyQuoteTable._rowHeight,
      decoration: hasTopBorder
          ? BoxDecoration(
              border: Border(
                top: BorderSide(color: context.colors.borderSubtle, width: dimens.borderHairline),
              ),
            )
          : null,
      child: Row(
        spacing: dimens.space2,
        children: [
          SizedBox(width: DailyQuoteTable._dateColumnWidth, child: date),
          ...cells.map((Widget cell) {
            return Expanded(child: cell);
          }),
        ],
      ),
    );
  }
}
