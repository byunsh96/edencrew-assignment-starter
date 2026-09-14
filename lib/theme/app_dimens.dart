import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

/// Figma `Scale` 컬렉션을 옮긴 간격 / 반경 / 크기 토큰입니다.
///
/// 화면 코드에서는 `context.dimens.space4` 형태로 사용해 주세요.
@immutable
class AppDimens extends ThemeExtension<AppDimens> {
  const AppDimens({
    required this.spaceHalf,
    required this.space1,
    required this.space2,
    required this.space2Mid,
    required this.space3,
    required this.space3Mid,
    required this.space4,
    required this.space5,
    required this.space6,
    required this.radiusSm,
    required this.radiusMd,
    required this.radiusLg,
    required this.radiusXlg,
    required this.borderHairline,
    required this.iconSm,
    required this.iconSmMd,
    required this.iconMd,
    required this.iconMdLg,
    required this.iconLg,
    required this.iconXlg,
    required this.rowMinHeight,
    required this.tabBarHeight,
    required this.bottomSheetTitleHeight,
  });

  const AppDimens.standard()
    : spaceHalf = 2,
      space1 = 4,
      space2 = 8,
      space2Mid = 10,
      space3 = 12,
      space3Mid = 14,
      space4 = 16,
      space5 = 20,
      space6 = 24,
      radiusSm = 4,
      radiusMd = 8,
      radiusLg = 12,
      radiusXlg = 16,
      borderHairline = 1,
      iconSm = 16,
      iconSmMd = 18,
      iconMd = 20,
      iconMdLg = 22,
      iconLg = 24,
      iconXlg = 40,
      rowMinHeight = 56,
      tabBarHeight = 56,
      bottomSheetTitleHeight = 64;

  final double spaceHalf;
  final double space1;
  final double space2;

  /// space2(8)와 space3(12) 사이 값입니다. Figma `Scale`에 없어 추가했습니다.
  /// 검색 입력칸 세로 여백이 이 값입니다.
  final double space2Mid;

  final double space3;

  /// space3(12)과 space4(16) 사이 값입니다. Figma `Scale`에 없어 추가했습니다.
  /// 상세 화면 본문 위쪽 여백이 이 값입니다.
  final double space3Mid;
  final double space4;
  final double space5;
  final double space6;

  final double radiusSm;
  final double radiusMd;
  final double radiusLg;
  // bottom sheet의 radius
  final double radiusXlg;

  final double borderHairline;

  final double iconSm;
  final double iconSmMd;
  final double iconMd;
  final double iconMdLg;
  final double iconLg;

  /// 빈 상태 일러스트 크기입니다.
  final double iconXlg;

  /// 목록 행의 최소 높이입니다.
  final double rowMinHeight;

  /// 하단 탭 바의 높이입니다.
  final double tabBarHeight;

  /// 하단 시트 제목의 최소 높이입니다.
  final double bottomSheetTitleHeight;

  @override
  AppDimens copyWith({
    double? spaceHalf,
    double? space1,
    double? space2,
    double? space2Mid,
    double? space3,
    double? space3Mid,
    double? space4,
    double? space5,
    double? space6,
    double? radiusSm,
    double? radiusMd,
    double? radiusLg,
    double? radiusXlg,
    double? borderHairline,
    double? iconSm,
    double? iconSmMd,
    double? iconMd,
    double? iconMdLg,
    double? iconLg,
    double? iconXlg,
    double? rowMinHeight,
    double? tabBarHeight,
    double? bottomSheetTitleHeight,
  }) {
    return AppDimens(
      spaceHalf: spaceHalf ?? this.spaceHalf,
      space1: space1 ?? this.space1,
      space2: space2 ?? this.space2,
      space2Mid: space2Mid ?? this.space2Mid,
      space3: space3 ?? this.space3,
      space3Mid: space3Mid ?? this.space3Mid,
      space4: space4 ?? this.space4,
      space5: space5 ?? this.space5,
      space6: space6 ?? this.space6,
      radiusSm: radiusSm ?? this.radiusSm,
      radiusMd: radiusMd ?? this.radiusMd,
      radiusLg: radiusLg ?? this.radiusLg,
      radiusXlg: radiusXlg ?? this.radiusXlg,
      borderHairline: borderHairline ?? this.borderHairline,
      iconSm: iconSm ?? this.iconSm,
      iconSmMd: iconSmMd ?? this.iconSmMd,
      iconMd: iconMd ?? this.iconMd,
      iconMdLg: iconMdLg ?? this.iconMdLg,
      iconLg: iconLg ?? this.iconLg,
      iconXlg: iconXlg ?? this.iconXlg,
      rowMinHeight: rowMinHeight ?? this.rowMinHeight,
      tabBarHeight: tabBarHeight ?? this.tabBarHeight,
      bottomSheetTitleHeight: bottomSheetTitleHeight ?? this.bottomSheetTitleHeight,
    );
  }

  @override
  AppDimens lerp(covariant AppDimens? other, double t) {
    if (other == null) return this;
    return AppDimens(
      spaceHalf: lerpDouble(spaceHalf, other.spaceHalf, t)!,
      space1: lerpDouble(space1, other.space1, t)!,
      space2: lerpDouble(space2, other.space2, t)!,
      space2Mid: lerpDouble(space2Mid, other.space2Mid, t)!,
      space3: lerpDouble(space3, other.space3, t)!,
      space3Mid: lerpDouble(space3Mid, other.space3Mid, t)!,
      space4: lerpDouble(space4, other.space4, t)!,
      space5: lerpDouble(space5, other.space5, t)!,
      space6: lerpDouble(space6, other.space6, t)!,
      radiusSm: lerpDouble(radiusSm, other.radiusSm, t)!,
      radiusMd: lerpDouble(radiusMd, other.radiusMd, t)!,
      radiusLg: lerpDouble(radiusLg, other.radiusLg, t)!,
      radiusXlg: lerpDouble(radiusXlg, other.radiusXlg, t)!,
      borderHairline: lerpDouble(borderHairline, other.borderHairline, t)!,
      iconSm: lerpDouble(iconSm, other.iconSm, t)!,
      iconSmMd: lerpDouble(iconSmMd, other.iconSmMd, t)!,
      iconMd: lerpDouble(iconMd, other.iconMd, t)!,
      iconMdLg: lerpDouble(iconMdLg, other.iconMdLg, t)!,
      iconLg: lerpDouble(iconLg, other.iconLg, t)!,
      iconXlg: lerpDouble(iconXlg, other.iconXlg, t)!,
      rowMinHeight: lerpDouble(rowMinHeight, other.rowMinHeight, t)!,
      tabBarHeight: lerpDouble(tabBarHeight, other.tabBarHeight, t)!,
      bottomSheetTitleHeight: lerpDouble(bottomSheetTitleHeight, other.bottomSheetTitleHeight, t)!,
    );
  }
}
