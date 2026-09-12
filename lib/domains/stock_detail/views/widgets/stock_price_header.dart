import 'package:flutter/material.dart';

import '../../../../constants/app_text_styles.dart';
import '../../../../enums/price_direction.dart';
import '../../../../models/stock_quote.dart';
import '../../../../theme/theme.dart';
import '../../../../utils/format_util.dart';

/// 현재가와 전일 대비 등락.
class StockPriceHeader extends StatelessWidget {
  const StockPriceHeader({required this.quote, super.key});

  final StockQuote quote;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final PriceDirection direction = quote.direction;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: <Widget>[
        Text(
          FormatUtil.decimal(quote.currentPrice),
          style:
              AppTextStyles.displayPrice.copyWith(color: colors.textPrimary),
        ),
        SizedBox(width: context.dimens.space2),
        Flexible(
          child: Text(
            '${direction.sign} ${FormatUtil.decimal(quote.change.abs())} '
            '(${FormatUtil.signedPercent(quote.changeRate)})',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.body.copyWith(color: direction.text(colors)),
          ),
        ),
      ],
    );
  }
}
