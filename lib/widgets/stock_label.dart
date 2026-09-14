import 'package:flutter/material.dart';

import '../constants/app_text_styles.dart';
import '../models/stock_model.dart';
import '../theme/theme.dart';

//TODO Figma 확인 필요.
// 종목명 + `종목코드 · 시장`은 관심 목록 · 검색 결과 · 상세 상단바에서 같은 모습으로 쓰이는데
// 시안에는 하나의 컴포넌트로 묶여 있지 않고 화면마다 따로 그려져 있다.
// 그래서 세로 간격도 화면마다 다르다. (상세 상단바 1px / 그 외 2px)
// 같은 요소로 보고 spaceHalf(2)로 통일해 진행한다. 시안이 컴포넌트로 정리되면 다시 맞춘다.

/// 종목명과 `종목코드 · 시장`을 위아래로 보여준다.
///
/// 관심 목록 · 검색 결과 · 상세 상단바가 같은 구조를 쓴다.
class StockLabel extends StatelessWidget {
  const StockLabel({required this.stock, super.key}) : keyword = null;

  /// 종목명에서 [keyword]와 일치하는 부분을 강조한다. 검색 결과에서 쓴다.
  const StockLabel.highlighted({required this.stock, required String this.keyword, super.key});

  final StockModel stock;

  /// 강조할 검색어. `null`이면 종목명을 그대로 그린다.
  /// 두 생성자를 가르는 유일한 값이다.
  final String? keyword;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final AppDimens dimens = context.dimens;

    return Column(
      spacing: dimens.spaceHalf,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 강조 구간이 없을 때도 Text.rich가 Text와 같은 결과를 그리므로 분기하지 않는다.
        Text.rich(_nameSpan(colors), maxLines: 1, overflow: TextOverflow.ellipsis),
        Text(
          stock.symbolWithMarket,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.caption.copyWith(color: colors.textSecondary),
        ),
      ],
    );
  }

  /// 종목명에서 검색어와 일치하는 구간만 [AppColors.searchHighlight]로 칠한다.
  ///
  /// 검색어가 없거나 일치하지 않으면 강조 없는 span을 돌려준다.
  TextSpan _nameSpan(AppColors colors) {
    final TextStyle base = AppTextStyles.body.copyWith(color: colors.textPrimary);
    final String trimmed = keyword?.trim() ?? '';
    if (trimmed.isEmpty) return TextSpan(text: stock.name, style: base);

    final int start = stock.name.toLowerCase().indexOf(trimmed.toLowerCase());
    if (start < 0) return TextSpan(text: stock.name, style: base);

    final int end = start + trimmed.length;
    return TextSpan(
      style: base,
      children: <TextSpan>[
        TextSpan(text: stock.name.substring(0, start)),
        TextSpan(
          text: stock.name.substring(start, end),
          style: TextStyle(color: colors.searchHighlight),
        ),
        TextSpan(text: stock.name.substring(end)),
      ],
    );
  }
}
