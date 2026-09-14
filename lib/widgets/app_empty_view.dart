import 'package:flutter/material.dart';

import '../constants/app_text_styles.dart';
import '../theme/theme.dart';
import 'app_svg_icon.dart';

/// 목록이 비었을 때 보여주는 안내. 관심 · 검색 화면이 같은 구조를 쓴다.
class AppEmptyView extends StatelessWidget {
  const AppEmptyView({
    required this.icon,
    required this.title,
    required this.description,
    super.key,
  });

  final String icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final AppDimens dimens = context.dimens;

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: dimens.space4),
        child: Column(
          spacing: dimens.space3,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            AppSvgIcon(icon, size: dimens.iconXlg, color: colors.textTertiary),
            Text(title, style: AppTextStyles.title.copyWith(color: colors.textSecondary)),
            Text(
              description,
              textAlign: TextAlign.center,
              style: AppTextStyles.caption.copyWith(color: colors.textTertiary),
            ),
          ],
        ),
      ),
    );
  }
}
