import 'package:flutter/material.dart';

import '../constants/app_text_styles.dart';
import '../theme/theme.dart';
import 'app_svg_icon.dart';

//TODO 리뷰 확인

/// 목록이 비었을 때 보여주는 안내. 관심 · 검색 화면이 같은 구조를 쓴다.
class AppEmptyView extends StatelessWidget {
  const AppEmptyView({required this.icon, required this.title, required this.description, super.key});

  /// Figma 빈 상태 아이콘 크기.
  static const double _iconSize = 40;

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
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            AppSvgIcon(icon, size: _iconSize, color: colors.textTertiary),
            SizedBox(height: dimens.space3),
            Text(title, style: AppTextStyles.title.copyWith(color: colors.textSecondary)),
            SizedBox(height: dimens.space3),
            Text(
              description,
              // Figma 텍스트 레이어는 RIGHT 정렬이지만 가운데 정렬된 빈 상태에서
              // 오른쪽 정렬은 어색해 CENTER로 구현했다.
              textAlign: TextAlign.center,
              style: AppTextStyles.caption.copyWith(color: colors.textTertiary),
            ),
          ],
        ),
      ),
    );
  }
}
