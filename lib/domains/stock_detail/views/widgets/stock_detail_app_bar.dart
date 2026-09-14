import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../constants/app_icons.dart';
import '../../../../constants/app_text_styles.dart';
import '../../../../models/stock.dart';
import '../../../../theme/theme.dart';
import '../../../../widgets/app_ink_well.dart';
import '../../../../widgets/app_svg_icon.dart';
import '../../../favorite_list/controllers/favorite_controller.dart';

/// 상세 화면 상단. 뒤로가기 · 종목명 · 관심 토글.
class StockDetailAppBar extends StatelessWidget {
  const StockDetailAppBar({required this.stock, required this.onFavoriteToggled, super.key});

  final Stock stock;
  final ValueChanged<bool> onFavoriteToggled;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final AppDimens dimens = context.dimens;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: dimens.space4, vertical: dimens.space2Mid),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: colors.borderSubtle, width: dimens.borderHairline),
        ),
      ),
      child: Row(
        spacing: dimens.space3,
        children: [
          AppInkWell(
            onTap: Navigator.of(context).pop,
            child: AppSvgIcon(AppIcons.back, size: dimens.iconMd, color: colors.textSecondary),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stock.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.body.copyWith(color: colors.textPrimary),
                ),
                Text(
                  stock.symbolWithMarket,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption.copyWith(color: colors.textSecondary),
                ),
              ],
            ),
          ),
          Selector<FavoriteController, bool>(
            selector: (_, FavoriteController controller) => controller.contains(stock.symbol),
            builder: (BuildContext context, bool isFavorite, _) => InkWell(
              onTap: () => onFavoriteToggled(context.read<FavoriteController>().toggle(stock)),
              child: AppSvgIcon(
                isFavorite ? AppIcons.starFill : AppIcons.star,
                size: dimens.iconMdLg,
                color: isFavorite ? colors.favoriteActive : colors.favoriteInactive,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
