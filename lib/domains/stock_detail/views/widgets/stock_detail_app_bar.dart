import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../constants/app_icons.dart';
import '../../../../constants/app_text_styles.dart';
import '../../../../models/favorite_stock.dart';
import '../../../../theme/theme.dart';
import '../../../../views/widgets/app_svg_icon.dart';
import '../../../watchlist/controllers/favorite_controller.dart';

/// 상세 화면 상단. 뒤로가기 · 종목명 · 관심 토글.
class StockDetailAppBar extends StatelessWidget {
  const StockDetailAppBar({
    required this.stock,
    required this.onFavoriteToggled,
    super.key,
  });

  /// Figma 상단바 세로 여백.
  static const double _verticalPadding = 10;
  static const double _backIconSize = 20;
  static const double _starIconSize = 22;

  final FavoriteStock stock;
  final ValueChanged<bool> onFavoriteToggled;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final AppDimens dimens = context.dimens;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dimens.space4,
        vertical: _verticalPadding,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: colors.borderSubtle,
            width: dimens.borderHairline,
          ),
        ),
      ),
      child: Row(
        children: <Widget>[
          InkWell(
            onTap: Navigator.of(context).pop,
            child: AppSvgIcon(
              AppIcons.back,
              size: _backIconSize,
              color: colors.textSecondary,
            ),
          ),
          SizedBox(width: dimens.space3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  stock.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style:
                      AppTextStyles.body.copyWith(color: colors.textPrimary),
                ),
                Text(
                  stock.symbolWithMarket,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption
                      .copyWith(color: colors.textSecondary),
                ),
              ],
            ),
          ),
          SizedBox(width: dimens.space3),
          Selector<FavoriteController, bool>(
            selector: (_, FavoriteController controller) =>
                controller.contains(stock.symbol),
            builder: (BuildContext context, bool isFavorite, _) => InkWell(
              onTap: () => onFavoriteToggled(
                context.read<FavoriteController>().toggle(stock),
              ),
              child: AppSvgIcon(
                isFavorite ? AppIcons.starFill : AppIcons.star,
                size: _starIconSize,
                color: isFavorite
                    ? colors.favoriteActive
                    : colors.favoriteInactive,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
