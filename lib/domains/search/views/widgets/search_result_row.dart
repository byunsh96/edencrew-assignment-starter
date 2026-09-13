import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../constants/app_icons.dart';
import '../../../../constants/app_text_styles.dart';
import '../../../../models/favorite_stock.dart';
import '../../../../theme/theme.dart';
import '../../../../widgets/app_svg_icon.dart';
import '../../../favorite_list/controllers/favorite_controller.dart';
import '../../models/stock_search_item.dart';

//TODO 리뷰 확인

/// 검색 결과 한 행. 종목명(검색어 하이라이트) · 코드 · 관심 토글.
class SearchResultRow extends StatelessWidget {
  const SearchResultRow({
    required this.item,
    required this.keyword,
    required this.onFavoriteToggled,
    this.onTap,
    super.key,
  });

  /// Figma 관심 별 아이콘 크기.
  static const double _starSize = 22;

  final StockSearchItem item;
  final String keyword;
  final ValueChanged<bool> onFavoriteToggled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final AppDimens dimens = context.dimens;

    return InkWell(
      onTap: onTap,
      child: Container(
        constraints: BoxConstraints(minHeight: dimens.rowMinHeight),
        // 구분선이 행 높이를 먹지 않도록 foregroundDecoration에 둔다.
        // decoration에 두면 Border 두께가 padding에 더해져 rowMinHeight를 1px 넘긴다.
        foregroundDecoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: colors.borderSubtle,
              width: dimens.borderHairline,
            ),
          ),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text.rich(
                    _highlighted(colors),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: dimens.space1 / 2),
                  Text(
                    item.symbolWithMarket,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.caption
                        .copyWith(color: colors.textSecondary),
                  ),
                ],
              ),
            ),
            SizedBox(width: dimens.space3),
            _FavoriteButton(item: item, onToggled: onFavoriteToggled),
          ],
        ),
      ),
    );
  }

  /// 종목명에서 검색어와 일치하는 부분만 강조한다.
  TextSpan _highlighted(AppColors colors) {
    final TextStyle base =
        AppTextStyles.body.copyWith(color: colors.textPrimary);
    final String trimmed = keyword.trim();

    if (trimmed.isEmpty) {
      return TextSpan(text: item.name, style: base);
    }

    final int start = item.name.toLowerCase().indexOf(trimmed.toLowerCase());
    if (start < 0) return TextSpan(text: item.name, style: base);

    final int end = start + trimmed.length;
    return TextSpan(
      style: base,
      children: <TextSpan>[
        TextSpan(text: item.name.substring(0, start)),
        TextSpan(
          text: item.name.substring(start, end),
          style: TextStyle(color: colors.searchHighlight),
        ),
        TextSpan(text: item.name.substring(end)),
      ],
    );
  }
}

class _FavoriteButton extends StatelessWidget {
  const _FavoriteButton({required this.item, required this.onToggled});

  final StockSearchItem item;
  final ValueChanged<bool> onToggled;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;

    // 관심 상태만 구독한다. 목록 전체가 아니라 이 행만 다시 그린다.
    return Selector<FavoriteController, bool>(
      selector: (_, FavoriteController controller) =>
          controller.contains(item.symbol),
      builder: (BuildContext context, bool isFavorite, _) => InkWell(
        onTap: () {
          final bool added = context.read<FavoriteController>().toggle(
                FavoriteStock(
                  symbol: item.symbol,
                  name: item.name,
                  marketName: item.marketName,
                ),
              );
          onToggled(added);
        },
        child: AppSvgIcon(
          isFavorite ? AppIcons.starFill : AppIcons.star,
          size: SearchResultRow._starSize,
          color: isFavorite ? colors.favoriteActive : colors.favoriteInactive,
        ),
      ),
    );
  }
}
