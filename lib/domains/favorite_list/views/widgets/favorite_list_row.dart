import 'package:edencrew_assignment_starter/domains/favorite_list/views/widgets/quote_cell.dart';
import 'package:flutter/material.dart';

import '../../../../constants/app_text_styles.dart';
import '../../../../theme/theme.dart';
import '../../../../widgets/app_ink_well.dart';
import '../../models/watchlist_item.dart';

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
                spacing: dimens.spaceHalf,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.stock.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.body.copyWith(color: colors.textPrimary),
                  ),
                  Text(
                    item.stock.symbolWithMarket,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.caption.copyWith(color: colors.textSecondary),
                  ),
                ],
              ),
            ),
            QuoteCell(quote: item.quote),
          ],
        ),
      ),
    );
  }
}
