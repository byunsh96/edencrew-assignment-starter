import 'package:flutter/material.dart';

import '../../../../constants/app_text_styles.dart';
import '../../../../models/stock_quote.dart';
import '../../../../theme/theme.dart';
import '../../../../utils/format_util.dart';

/// 시가 · 고가 · 저가 · 거래량 · 시가총액 요약 카드.
class QuoteSummary extends StatelessWidget {
  const QuoteSummary({required this.quote, super.key});

  final StockQuote quote;

  @override
  Widget build(BuildContext context) {
    final AppDimens dimens = context.dimens;

    return Column(
      spacing: dimens.space2,
      children: [
        Row(
          spacing: dimens.space2,
          children: [
            _Cell(label: '시가', value: FormatUtil.decimal(quote.openPrice)),
            _Cell(label: '고가', value: FormatUtil.decimal(quote.highPrice)),
            _Cell(label: '저가', value: FormatUtil.decimal(quote.lowPrice)),
          ],
        ),
        Row(
          spacing: dimens.space2,
          children: [
            _Cell(label: '거래량', value: FormatUtil.volume(quote.accumulatedTradingVolume)),
            _Cell(label: '시가총액', value: FormatUtil.marketCap(quote.marketCap)),
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

  //TODO 홀수 style 확인 필요
  final double _cellVerticalPadding = 9; //8일 것 같음
  final double _cellGap = 3; //2 또는 4일 것 같음

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;

    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: context.dimens.space2Mid,
          vertical: _cellVerticalPadding,
        ),
        decoration: BoxDecoration(
          color: colors.surfaceSunken,
          borderRadius: BorderRadius.circular(context.dimens.radiusMd),
        ),
        child: Column(
          spacing: _cellGap,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTextStyles.caption.copyWith(color: colors.textSecondary)),
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
