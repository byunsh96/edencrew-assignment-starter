import 'package:flutter/material.dart';

import '../theme/theme.dart';

//TODO 리뷰 확인

/// 등락 방향.
///
/// 국내 시장 관행을 따라 상승은 빨강, 하락은 파랑이다.
/// 보합을 빠뜨리면 0%가 하락으로 표시되므로 세 상태를 모두 둔다.
enum PriceDirection {
  up,
  down,
  flat;

  static PriceDirection of(num change) {
    if (change > 0) return PriceDirection.up;
    if (change < 0) return PriceDirection.down;
    return PriceDirection.flat;
  }

  /// 상세 화면 현재가 옆에 붙는 방향 기호.
  String get sign => switch (this) {
        PriceDirection.up => '▲',
        PriceDirection.down => '▼',
        PriceDirection.flat => '-',
      };
}

/// 등락 방향에 대응하는 토큰 색.
///
/// View마다 `switch`를 반복하지 않도록 한곳에 모은다.
extension PriceDirectionColor on PriceDirection {
  Color text(AppColors colors) => switch (this) {
        PriceDirection.up => colors.priceUpText,
        PriceDirection.down => colors.priceDownText,
        PriceDirection.flat => colors.priceFlatText,
      };

  Color background(AppColors colors) => switch (this) {
        PriceDirection.up => colors.priceUpBg,
        PriceDirection.down => colors.priceDownBg,
        PriceDirection.flat => colors.priceFlatBg,
      };

  Color chartLine(AppColors colors) => switch (this) {
        PriceDirection.up => colors.chartLineUp,
        PriceDirection.down => colors.chartLineDown,
        PriceDirection.flat => colors.chartLineFlat,
      };
}
