import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../constants/app_icons.dart';
import '../../../../constants/app_text_styles.dart';
import '../../../../theme/theme.dart';
import '../../../../widgets/app_ink_well.dart';
import '../../../../widgets/app_svg_icon.dart';
import '../../controllers/favorite_list_controller.dart';
import '../../enums/favorite_list_sort.dart';
import 'favorite_list_sort_sheet.dart';

//TODO 리뷰 확인

/// 관심 화면 헤더. 제목 · 정렬 칩 · 새로고침.
class FavoriteListHeader extends StatelessWidget {
  const FavoriteListHeader({super.key});

  /// Figma 헤더 아이콘 크기.
  static const double _iconSize = 20;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final AppDimens dimens = context.dimens;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: dimens.space4, vertical: dimens.space3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text('관심', style: AppTextStyles.title.copyWith(color: colors.textPrimary)),
          Row(
            spacing: dimens.space4,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const _SortChip(),
              AppInkWell(
                onTap: context.read<FavoriteListController>().fetchQuotes,
                child: AppSvgIcon(AppIcons.refresh, size: _iconSize, color: colors.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 현재 정렬 기준을 보여주고, 누르면 정렬 바텀시트를 연다.
class _SortChip extends StatelessWidget {
  const _SortChip();

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final AppDimens dimens = context.dimens;

    return AppInkWell(
      onTap: () => FavoriteListSortSheet.show(context),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: dimens.space1),
        child: Row(
          children: [
            Selector<FavoriteListController, FavoriteListSort>(
              selector: (_, FavoriteListController controller) => controller.sort,
              builder: (_, FavoriteListSort sort, _) => Text(
                sort.label,
                style: AppTextStyles.label.copyWith(color: colors.textSecondary),
              ),
            ),
            AppSvgIcon(
              AppIcons.align,
              size: FavoriteListHeader._iconSize,
              color: colors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
