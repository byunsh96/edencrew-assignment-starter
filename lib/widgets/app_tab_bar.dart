import 'package:flutter/material.dart';

import '../constants/app_icons.dart';
import '../constants/app_text_styles.dart';
import '../enums/main_tab.dart';
import '../theme/theme.dart';
import 'app_svg_icon.dart';

//TODO 리뷰 확인

/// 관심 · 검색을 오가는 하단 탭 바.
class AppTabBar extends StatelessWidget {
  const AppTabBar({required this.current, required this.onChanged, super.key});

  /// 탭 바 높이. 토스트를 탭 바 위에 띄울 때 쓴다. (safe area 제외)
  static const double height = 63;

  /// Figma 탭 아이콘 크기.
  static const double _iconSize = 22;

  /// 아이콘과 레이블 사이 간격.
  static const double _iconLabelGap = 3;

  final MainTab current;
  final ValueChanged<MainTab> onChanged;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final AppDimens dimens = context.dimens;

    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceRaised,
        border: Border(
          top: BorderSide(color: colors.borderSubtle, width: dimens.borderHairline),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: dimens.space2),
          child: Row(
            children: <Widget>[
              for (final MainTab tab in MainTab.values)
                _Tab(tab: tab, isSelected: tab == current, onTap: () => onChanged(tab)),
            ],
          ),
        ),
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({required this.tab, required this.isSelected, required this.onTap});

  final MainTab tab;
  final bool isSelected;
  final VoidCallback onTap;

  /// 관심 탭만 선택 여부에 따라 채워진 별과 빈 별이 갈린다.
  String get _icon => switch (tab) {
        MainTab.watchlist => isSelected ? AppIcons.starFill : AppIcons.star,
        MainTab.search => AppIcons.search,
      };

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
            spacing: AppTabBar._iconLabelGap,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              AppSvgIcon(_icon, size: AppTabBar._iconSize, color: color),
              Text(tab.label, style: AppTextStyles.caption.copyWith(color: color)),
            ],
          ),
        ),
      ),
    );
  }
}
