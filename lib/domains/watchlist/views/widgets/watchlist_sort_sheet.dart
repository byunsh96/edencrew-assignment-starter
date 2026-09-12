import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../constants/app_icons.dart';
import '../../../../constants/app_text_styles.dart';
import '../../../../theme/theme.dart';
import '../../../../views/widgets/app_svg_icon.dart';
import '../../controllers/watchlist_controller.dart';
import '../../enums/watchlist_sort.dart';

/// 정렬 기준을 고르는 바텀시트.
class WatchlistSortSheet extends StatelessWidget {
  const WatchlistSortSheet({
    required this.selected,
    required this.onSelected,
    super.key,
  });

  /// Figma 시트 상단 라운드.
  static const double _sheetRadius = 16;

  /// 제목 영역 높이.
  static const double _titleHeight = 64;

  /// 항목 한 줄 높이.
  static const double _optionHeight = 56;

  /// 시트 좌우 여백. 목록 행(16)보다 넓다.
  static const double _horizontalPadding = 24;

  /// 체크 아이콘 크기.
  static const double _checkSize = 24;

  final WatchlistSort selected;
  final ValueChanged<WatchlistSort> onSelected;

  /// 바텀시트는 별도 route라 상위 provider를 상속받지 못한다.
  /// 필요한 값만 꺼내 넘기고 결과를 콜백으로 돌려받는다.
  static Future<void> show(BuildContext context) {
    final WatchlistController controller = context.read<WatchlistController>();

    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext sheetContext) => WatchlistSortSheet(
        selected: controller.sort,
        onSelected: (WatchlistSort sort) {
          controller.changeSort(sort);
          Navigator.of(sheetContext).pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;

    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceOverlay,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(_sheetRadius),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SizedBox(
              height: _titleHeight,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: _horizontalPadding,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '정렬',
                    style: AppTextStyles.title
                        .copyWith(color: colors.textPrimary),
                  ),
                ),
              ),
            ),
            for (final WatchlistSort sort in WatchlistSort.values)
              _Option(
                sort: sort,
                isSelected: sort == selected,
                onTap: () => onSelected(sort),
              ),
          ],
        ),
      ),
    );
  }
}

class _Option extends StatelessWidget {
  const _Option({
    required this.sort,
    required this.isSelected,
    required this.onTap,
  });

  final WatchlistSort sort;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;

    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: WatchlistSortSheet._optionHeight,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: WatchlistSortSheet._horizontalPadding,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                sort.label,
                style: AppTextStyles.body.copyWith(
                  color:
                      isSelected ? colors.textPrimary : colors.textSecondary,
                ),
              ),
              if (isSelected)
                AppSvgIcon(
                  AppIcons.check,
                  size: WatchlistSortSheet._checkSize,
                  color: colors.textPrimary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
