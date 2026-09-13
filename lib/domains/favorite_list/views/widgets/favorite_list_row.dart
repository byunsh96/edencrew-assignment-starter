import 'package:flutter/material.dart';

import '../../../../constants/app_text_styles.dart';
import '../../../../enums/price_direction.dart';
import '../../../../models/stock_quote.dart';
import '../../../../theme/theme.dart';
import '../../../../utils/format_util.dart';
import '../../../../widgets/app_ink_well.dart';
import '../../models/watchlist_item.dart';

//TODO 리뷰 확인

/// 관심 목록 한 행. 종목명 · 코드 · 현재가 · 등락.
class FavoriteListRow extends StatelessWidget {
  const FavoriteListRow({required this.item, this.onTap, super.key});

  final WatchlistItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final AppDimens dimens = context.dimens;

    return AppInkWell(
      onTap: onTap,
      child: Container(
        // 구분선이 행 높이를 먹지 않도록 foregroundDecoration에 둔다.
        // decoration에 두면 Border 두께가 padding에 더해져 행이 1px 커진다.
        foregroundDecoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: colors.borderSubtle, width: dimens.borderHairline),
          ),
        ),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          spacing: dimens.space3,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    item.stock.name,
                    // 긴 종목명이 시세를 밀어내지 않도록 한 줄로 자른다.
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.body.copyWith(color: colors.textPrimary),
                  ),
                  SizedBox(height: dimens.space1 / 2),
                  Text(
                    item.stock.symbolWithMarket,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.caption.copyWith(color: colors.textSecondary),
                  ),
                ],
              ),
            ),
            SizedBox(width: dimens.space3),
            if (item.quote case final StockQuote quote)
              _Quote(quote: quote)
            else
              const _QuoteSkeleton(),
          ],
        ),
      ),
    );
  }
}

class _Quote extends StatelessWidget {
  const _Quote({required this.quote});

  final StockQuote quote;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final PriceDirection direction = quote.direction;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Text(
          FormatUtil.decimal(quote.currentPrice),
          style: AppTextStyles.body.copyWith(color: colors.textPrimary),
        ),
        SizedBox(height: context.dimens.space1 / 2),
        Text(
          '${FormatUtil.signedDecimal(quote.change)} '
          '(${FormatUtil.signedPercent(quote.changeRate)})',
          style: AppTextStyles.caption.copyWith(color: direction.text(colors)),
        ),
      ],
    );
  }
}

/// 시세를 아직 받지 못한 행.
class _QuoteSkeleton extends StatelessWidget {
  const _QuoteSkeleton();

  /// Figma 스켈레톤 막대 크기.
  static const Size _priceBar = Size(64, 16);
  static const Size _changeBar = Size(48, 12);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        const _Bar(size: _priceBar),
        SizedBox(height: context.dimens.space1 / 2),
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
