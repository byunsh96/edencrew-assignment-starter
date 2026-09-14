import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/app_icons.dart';
import '../domains/favorite_list/controllers/favorite_controller.dart';
import '../models/stock.dart';
import '../theme/theme.dart';
import 'app_ink_well.dart';
import 'app_svg_icon.dart';
import 'app_toast.dart';

/// 관심 등록 · 해제 별 버튼.
///
/// 검색 결과 행과 상세 상단바가 같은 버튼을 쓴다.
/// 두 화면 모두 토글 직후 하는 일이 토스트뿐이라 여기서 함께 띄운다.
/// 호출부는 결과를 돌려받을 필요가 없다.
class FavoriteStarButton extends StatelessWidget {
  const FavoriteStarButton({required this.stock, super.key});

  final Stock stock;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final AppDimens dimens = context.dimens;

    // 관심 상태만 구독한다. 목록 전체가 아니라 이 버튼만 다시 그린다.
    return Selector<FavoriteController, bool>(
      selector: (_, FavoriteController controller) => controller.contains(stock.symbol),
      builder: (BuildContext context, bool isFavorite, _) => AppInkWell(
        // 토스트 문구가 등록과 해제로 갈리므로 toggle의 반환값을 그대로 넘긴다.
        onTap: () =>
            AppToast.favorite(context, added: context.read<FavoriteController>().toggle(stock)),
        child: AppSvgIcon(
          isFavorite ? AppIcons.starFill : AppIcons.star,
          size: dimens.iconMdLg,
          color: isFavorite ? colors.favoriteActive : colors.favoriteInactive,
        ),
      ),
    );
  }
}
