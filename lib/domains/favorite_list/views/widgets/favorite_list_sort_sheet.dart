import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../constants/app_icons.dart';
import '../../../../constants/app_text_styles.dart';
import '../../../../theme/theme.dart';
import '../../../../widgets/app_ink_well.dart';
import '../../../../widgets/app_svg_icon.dart';
import '../../controllers/favorite_list_controller.dart';
import '../../enums/favorite_list_sort.dart';

/// 정렬 기준을 고르는 바텀시트.
class FavoriteListSortSheet extends StatelessWidget {
  const FavoriteListSortSheet({required this.selected, required this.onSelected, super.key});

  final FavoriteListSort selected;
  final ValueChanged<FavoriteListSort> onSelected;

  /// 바텀시트는 별도 route라 상위 provider를 상속받지 못한다.
  /// 필요한 값만 꺼내 넘기고 결과를 콜백으로 돌려받는다.
  static Future<void> show(BuildContext context) {
    final FavoriteListController controller = context.read<FavoriteListController>();

    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext sheetContext) => FavoriteListSortSheet(
        selected: controller.sort,
        onSelected: (FavoriteListSort sort) {
          controller.changeSort(sort);
          Navigator.of(sheetContext).pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final AppDimens dimens = context.dimens;

    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceOverlay,
        borderRadius: BorderRadius.vertical(top: Radius.circular(dimens.radiusXlg)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: dimens.bottomSheetTitleHeight,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('정렬', style: AppTextStyles.title.copyWith(color: colors.textPrimary)),
              ),
            ),
            for (final FavoriteListSort sort in FavoriteListSort.values)
              _Option(sort: sort, isSelected: sort == selected, onTap: () => onSelected(sort)),
          ],
        ),
      ),
    );
  }
}

class _Option extends StatelessWidget {
  const _Option({required this.sort, required this.isSelected, required this.onTap});

  final FavoriteListSort sort;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final AppDimens dimens = context.dimens;

    return AppInkWell(
      onTap: onTap,
      child: Container(
        height: dimens.rowMinHeight,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              sort.label,
              style: AppTextStyles.body.copyWith(
                color: isSelected ? colors.textPrimary : colors.textSecondary,
              ),
            ),
            if (isSelected)
              AppSvgIcon(AppIcons.check, size: dimens.iconLg, color: colors.textFafafa),
          ],
        ),
      ),
    );
  }
}
