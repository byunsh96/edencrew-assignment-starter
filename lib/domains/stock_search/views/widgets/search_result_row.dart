import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../constants/app_icons.dart';
import '../../../../models/stock.dart';
import '../../../../theme/theme.dart';
import '../../../../widgets/app_ink_well.dart';
import '../../../../widgets/app_svg_icon.dart';
import '../../../../widgets/stock_label.dart';
import '../../../favorite_list/controllers/favorite_controller.dart';

/// 검색 결과 한 행. 종목명(검색어 하이라이트) · 코드 · 관심 토글.
class SearchResultRow extends StatelessWidget {
  const SearchResultRow({
    required this.item,
    required this.keyword,
    required this.onFavoriteToggled,
    this.onTap,
    super.key,
  });

  final Stock item;
  final String keyword;
  final ValueChanged<bool> onFavoriteToggled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final AppDimens dimens = context.dimens;

    return AppInkWell(
      onTap: onTap,
      child: Container(
        foregroundDecoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: colors.borderSubtle, width: dimens.borderHairline),
          ),
        ),
        padding: EdgeInsets.symmetric(horizontal: dimens.space4, vertical: dimens.space3),
        child: Row(
          spacing: dimens.space3,
          children: [
            Expanded(child: StockLabel.highlighted(stock: item, keyword: keyword)),
            _FavoriteButton(item: item, onToggled: onFavoriteToggled),
          ],
        ),
      ),
    );
  }

}

class _FavoriteButton extends StatelessWidget {
  const _FavoriteButton({required this.item, required this.onToggled});

  final Stock item;
  final ValueChanged<bool> onToggled;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final AppDimens dimens = context.dimens;

    // 관심 상태만 구독한다. 목록 전체가 아니라 이 행만 다시 그린다.
    return Selector<FavoriteController, bool>(
      selector: (_, FavoriteController controller) => controller.contains(item.symbol),
      builder: (BuildContext context, bool isFavorite, _) => AppInkWell(
        onTap: () {
          final bool added = context.read<FavoriteController>().toggle(item);
          onToggled(added);
        },
        child: AppSvgIcon(
          isFavorite ? AppIcons.starFill : AppIcons.star,
          size: dimens.iconMdLg,
          color: isFavorite ? colors.favoriteActive : colors.favoriteInactive,
        ),
      ),
    );
  }
}
