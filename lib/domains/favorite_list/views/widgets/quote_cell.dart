import 'package:flutter/material.dart';

import '../../../../constants/app_text_styles.dart';
import '../../../../enums/price_direction.dart';
import '../../../../models/stock_quote_model.dart';
import '../../../../theme/theme.dart';
import '../../../../utils/format_util.dart';

/// 시세 수신 여부에 따라 실제 시세와 스켈레톤을 갈라준다.
///
/// 분기를 여기 모아 호출부가 `null` 여부를 알지 않아도 되게 한다.
class QuoteCell extends StatelessWidget {
  const QuoteCell({super.key, this.quote});

  final StockQuoteModel? quote;

  @override
  Widget build(BuildContext context) {
    if (quote case final StockQuoteModel quote) return _Quote(quote: quote);
    return const _QuoteSkeleton();
  }
}

class _Quote extends StatelessWidget {
  const _Quote({required this.quote});

  final StockQuoteModel quote;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final PriceDirection direction = quote.direction;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      spacing: context.dimens.spaceHalf,
      children: <Widget>[
        Text(
          FormatUtil.decimal(quote.currentPrice),
          style: AppTextStyles.body.copyWith(color: colors.textPrimary),
        ),
        Text(
          '${FormatUtil.signedDecimal(quote.change)} '
          '(${FormatUtil.signedPercent(quote.changeRate)})',
          style: AppTextStyles.caption.copyWith(color: direction.text(colors)),
        ),
      ],
    );
  }
}

/// skeleton
class _QuoteSkeleton extends StatelessWidget {
  const _QuoteSkeleton();

  /// Figma 스켈레톤 막대 크기.
  static const Size _priceBar = Size(64, 16);
  static const Size _changeBar = Size(48, 12);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      spacing: context.dimens.spaceHalf,
      children: [
        const _Bar(size: _priceBar),
        const _Bar(size: _changeBar),
      ],
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.size});

  final Size size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.width,
      height: size.height,
      decoration: BoxDecoration(
        color: context.colors.feedbackSkeleton,
        borderRadius: BorderRadius.circular(context.dimens.radiusSm),
      ),
    );
  }
}
