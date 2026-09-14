import 'package:flutter/material.dart';

import '../../../../models/stock.dart';
import '../../../../theme/theme.dart';
import '../../../../widgets/app_ink_well.dart';
import '../../../../widgets/favorite_star_button.dart';
import '../../../../widgets/stock_label.dart';

/// 검색 결과 한 행. 종목명(검색어 하이라이트) · 코드 · 관심 토글.
class SearchResultRow extends StatelessWidget {
  const SearchResultRow({
    required this.item,
    required this.keyword,
    this.onTap,
    super.key,
  });

  final Stock item;
  final String keyword;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final AppDimens dimens = context.dimens;

    return AppInkWell(
      onTap: onTap,
      child: Container(
        foregroundDecoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: colors.borderSubtle, width: dimens.borderHairline),
          ),
        ),
        padding: EdgeInsets.symmetric(horizontal: dimens.space4, vertical: dimens.space3),
        child: Row(
          spacing: dimens.space3,
          children: [
            Expanded(child: StockLabel.highlighted(stock: item, keyword: keyword)),
            FavoriteStarButton(stock: item),
          ],
        ),
      ),
    );
  }

}
