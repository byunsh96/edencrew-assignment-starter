import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

//TODO 리뷰 확인

/// Figma에서 내려받은 SVG 아이콘.
///
/// SVG 파일에는 Figma 시안의 색이 박혀 있다. 같은 아이콘이 상태에 따라 다른 토큰 색을
/// 쓰므로([AppIcons.star]의 관심 등록/해제 등) [color]로 항상 덮어쓴다.
class AppSvgIcon extends StatelessWidget {
  const AppSvgIcon(
    this.asset, {
    required this.size,
    required this.color,
    super.key,
  });

  final String asset;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      asset,
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }
}
