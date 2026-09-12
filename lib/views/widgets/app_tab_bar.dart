import 'package:flutter/material.dart';

import '../../constants/app_icons.dart';
import '../../constants/app_text_styles.dart';
import '../../theme/theme.dart';
import 'app_svg_icon.dart';

/// 관심 · 검색을 오가는 하단 탭 바.
class AppTabBar extends StatelessWidget {
  const AppTabBar({
    required this.currentIndex,
    required this.onChanged,
    super.key,
  });

  /// 탭 바 높이. 토스트를 탭 바 위에 띄울 때 쓴다. (safe area 제외)
  static const double height = 63;

  /// Figma 탭 아이콘 크기.
  static const double _iconSize = 22;

  /// 아이콘과 레이블 사이 간격.
  static const double _iconLabelGap = 3;

  final int currentIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final AppDimens dimens = context.dimens;

    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceRaised,
        border: Border(
          top: BorderSide(
            color: colors.borderSubtle,
            width: dimens.borderHairline,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: dimens.space2),
          child: Row(
            children: <Widget>[
              _Tab(
                // 관심 탭은 선택됐을 때만 채워진 별을 쓴다.
                icon: currentIndex == 0 ? AppIcons.starFill : AppIcons.star,
                label: '관심',
                isSelected: currentIndex == 0,
                onTap: () => onChanged(0),
              ),
              _Tab(
                icon: AppIcons.search,
                label: '검색',
                isSelected: currentIndex == 1,
                onTap: () => onChanged(1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final Color color = isSelected ? colors.navActive : colors.navInactive;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: context.dimens.space1),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              AppSvgIcon(icon, size: AppTabBar._iconSize, color: color),
              const SizedBox(height: AppTabBar._iconLabelGap),
              Text(label, style: AppTextStyles.caption.copyWith(color: color)),
            ],
          ),
        ),
      ),
    );
  }
}
