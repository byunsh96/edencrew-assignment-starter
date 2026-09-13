import 'package:flutter/material.dart';

import '../theme/theme.dart';

//TODO 리뷰 확인

/// Figma `Screens` 페이지의 텍스트 스타일을 옮긴 서체 스케일.
///
/// 스타터의 `AppTypography`는 서체와 굵기만 정의한다. 크기와 행간은 Figma가 변수가
/// 아니라 텍스트 스타일로 관리해서 토큰에 빠져 있었다. 화면마다 숫자를 다시 적으면
/// 매직 넘버 금지 규칙과 부딪히므로 여기 모은다.
/// 원본 `app_typography.dart`를 고치지 않기 위해 별도 파일로 뒀다.
///
/// 색은 넣지 않는다. `context.colors`의 토큰과 조합해서 쓴다.
///
/// ```dart
/// Text(
///   '삼성전자',
///   style: AppTextStyles.body.copyWith(color: context.colors.textPrimary),
/// )
/// ```
///
/// `letterSpacing`은 Figma가 `em` 단위라 `fontSize`를 곱해 논리 픽셀로 환산했다.
abstract final class AppTextStyles {
  /// Figma `display/price` — 30/36 Bold. 상세 화면 현재가.
  static const TextStyle displayPrice = TextStyle(
    fontFamily: AppTypography.fontFamily,
    fontSize: 30,
    height: 36 / 30,
    fontWeight: AppTypography.bold,
    letterSpacing: -0.4, // -0.0133em × 30
  );

  /// Figma `title` — 19/22 Bold. 화면 제목.
  static const TextStyle title = TextStyle(
    fontFamily: AppTypography.fontFamily,
    fontSize: 19,
    height: 22 / 19,
    fontWeight: AppTypography.bold,
    letterSpacing: -0.2,
  );

  /// Figma `body` — 15/20 Medium. 종목명·현재가 등 본문.
  static const TextStyle body = TextStyle(
    fontFamily: AppTypography.fontFamily,
    fontSize: 15,
    height: 20 / 15,
    fontWeight: AppTypography.medium,
    letterSpacing: -0.1,
  );

  /// Figma `label` — 13/18 Bold. 강조 레이블.
  static const TextStyle label = TextStyle(
    fontFamily: AppTypography.fontFamily,
    fontSize: 13,
    height: 18 / 13,
    fontWeight: AppTypography.bold,
  );

  /// Figma 13/18 Regular. 상세 화면 기간 탭 칩 레이블.
  ///
  /// Figma에 이름이 없는 스타일이라 [label]과 굵기만 다른 점을 이름에 드러냈다.
  static const TextStyle labelRegular = TextStyle(
    fontFamily: AppTypography.fontFamily,
    fontSize: 13,
    height: 18 / 13,
    fontWeight: AppTypography.regular,
  );

  /// Figma `caption` — 11/14 Regular. 종목코드·시장·보조 문구.
  static const TextStyle caption = TextStyle(
    fontFamily: AppTypography.fontFamily,
    fontSize: 11,
    height: 14 / 11,
    letterSpacing: 0,
    fontWeight: AppTypography.regular,
  );
}
