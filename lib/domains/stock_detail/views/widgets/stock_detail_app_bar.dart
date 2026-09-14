import 'package:flutter/material.dart';

import '../../../../constants/app_icons.dart';
import '../../../../models/stock_model.dart';
import '../../../../theme/theme.dart';
import '../../../../widgets/app_ink_well.dart';
import '../../../../widgets/app_svg_icon.dart';
import '../../../../widgets/favorite_star_button.dart';
import '../../../../widgets/stock_label.dart';

/// 상세 화면 상단. 뒤로가기 · 종목명 · 관심 토글.
class StockDetailAppBar extends StatelessWidget {
  const StockDetailAppBar({required this.stock, super.key});

  final StockModel stock;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final AppDimens dimens = context.dimens;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: dimens.space4, vertical: dimens.space2Mid),
      foregroundDecoration: BoxDecoration(
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
          Expanded(child: StockLabel(stock: stock)),
          FavoriteStarButton(stock: stock),
        ],
      ),
    );
  }
}
