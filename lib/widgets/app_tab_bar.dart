import 'package:edencrew_assignment_starter/widgets/app_ink_well.dart';
import 'package:flutter/material.dart';

import '../constants/app_icons.dart';
import '../constants/app_text_styles.dart';
import '../enums/main_tab.dart';
import '../theme/theme.dart';
import 'app_svg_icon.dart';

class AppTabBar extends StatelessWidget {
  const AppTabBar({super.key, required this.current, required this.onChanged});

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
          padding: const EdgeInsets.symmetric(vertical: 8),
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
      child: AppInkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            spacing: 3,
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppSvgIcon(_icon, size: context.dimens.iconMdLg, color: color),
              Text(tab.label, style: AppTextStyles.caption.copyWith(color: color)),
            ],
          ),
        ),
      ),
    );
  }
}
