import 'package:flutter/material.dart';

import '../../../../constants/app_icons.dart';
import '../../../../constants/app_text_styles.dart';
import '../../../../theme/theme.dart';
import '../../../../widgets/app_svg_icon.dart';

//TODO 리뷰 확인

/// 검색 입력창. 돋보기 · 입력칸 · 지우기 버튼.
class SearchField extends StatelessWidget {
  const SearchField({
    required this.controller,
    required this.onChanged,
    required this.onCleared,
    super.key,
  });

  /// Figma 검색바 아이콘 크기.
  static const double _iconSize = 16;

  /// Figma 입력칸 세로 여백.
  static const double _fieldVerticalPadding = 10;

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onCleared;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final AppDimens dimens = context.dimens;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        dimens.space4,
        dimens.space2,
        dimens.space4,
        dimens.space3,
      ),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: dimens.space3,
          vertical: _fieldVerticalPadding,
        ),
        decoration: BoxDecoration(
          color: colors.surfaceSunken,
          border: Border.all(
            color: colors.borderStrong,
            width: dimens.borderHairline,
          ),
          borderRadius: BorderRadius.circular(dimens.radiusMd),
        ),
        child: Row(
          children: <Widget>[
            AppSvgIcon(
              AppIcons.search,
              size: _iconSize,
              color: colors.textTertiary,
            ),
            SizedBox(width: dimens.space2),
            Expanded(
              child: TextField(
                controller: controller,
                onChanged: onChanged,
                textInputAction: TextInputAction.search,
                cursorColor: colors.accentDefault,
                style: AppTextStyles.body.copyWith(color: colors.textPrimary),
                decoration: InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  hintText: '종목명 또는 종목코드',
                  hintStyle:
                      AppTextStyles.body.copyWith(color: colors.textTertiary),
                ),
              ),
            ),
            SizedBox(width: dimens.space2),
            // 지울 내용이 있을 때만 보인다. 빈 입력칸의 X는 누를 이유가 없다.
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: controller,
              builder: (BuildContext context, TextEditingValue value, _) {
                if (value.text.isEmpty) {
                  return const SizedBox(width: _iconSize);
                }
                return InkWell(
                  onTap: onCleared,
                  child: AppSvgIcon(
                    AppIcons.close,
                    size: _iconSize,
                    color: colors.textTertiary,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
