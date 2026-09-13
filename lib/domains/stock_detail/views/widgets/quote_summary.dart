import 'package:flutter/material.dart';

import '../../../../constants/app_text_styles.dart';
import '../../../../models/stock_quote.dart';
import '../../../../theme/theme.dart';
import '../../../../utils/format_util.dart';

//TODO 리뷰 확인

/// 시가 · 고가 · 저가 · 거래량 · 시가총액 요약 카드.
class QuoteSummary extends StatelessWidget {
  const QuoteSummary({required this.quote, super.key});

  /// Figma 카드 안쪽 여백.
  static const double _cellVerticalPadding = 9;
  static const double _cellHorizontalPadding = 10;

  /// 라벨과 값 사이 간격.
  static const double _cellGap = 3;

  final StockQuote quote;

  @override
  Widget build(BuildContext context) {
    final AppDimens dimens = context.dimens;

    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            _Cell(label: '시가', value: FormatUtil.decimal(quote.openPrice)),
            SizedBox(width: dimens.space2),
            _Cell(label: '고가', value: FormatUtil.decimal(quote.highPrice)),
            SizedBox(width: dimens.space2),
            _Cell(label: '저가', value: FormatUtil.decimal(quote.lowPrice)),
          ],
        ),
        SizedBox(height: dimens.space2),
        Row(
          children: <Widget>[
            _Cell(
              label: '거래량',
              value: FormatUtil.volume(quote.accumulatedTradingVolume),
            ),
            SizedBox(width: dimens.space2),
            _Cell(
              label: '시가총액',
              value: FormatUtil.marketCap(quote.marketCap),
            ),
          ],
        ),
      ],
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: QuoteSummary._cellHorizontalPadding,
          vertical: QuoteSummary._cellVerticalPadding,
        ),
        decoration: BoxDecoration(
          color: colors.surfaceSunken,
          borderRadius: BorderRadius.circular(context.dimens.radiusMd),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              label,
              style: AppTextStyles.caption
                  .copyWith(color: colors.textSecondary),
            ),
            const SizedBox(height: QuoteSummary._cellGap),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.body.copyWith(color: colors.textPrimary),
            ),
          ],
        ),
      ),
    );
  }
}
