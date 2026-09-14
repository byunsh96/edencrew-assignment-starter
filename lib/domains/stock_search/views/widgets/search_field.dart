import 'package:flutter/material.dart';

import '../../../../widgets/app_ink_well.dart';
import '../../../../constants/app_icons.dart';
import '../../../../constants/app_text_styles.dart';
import '../../../../theme/theme.dart';
import '../../../../widgets/app_svg_icon.dart';

/// 검색 입력창. 돋보기 · 입력칸 · 지우기 버튼.
class SearchField extends StatelessWidget {
  const SearchField({
    required this.controller,
    required this.onChanged,
    required this.onCleared,
    super.key,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onCleared;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final AppDimens dimens = context.dimens;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Container(
        foregroundDecoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(color: colors.borderStrong, width: dimens.borderHairline),
          borderRadius: BorderRadius.circular(dimens.radiusMd),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(color: colors.surfaceSunken),
          child: Row(
            spacing: dimens.space2,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AppSvgIcon(AppIcons.search, size: dimens.iconSm, color: colors.textTertiary),
              Expanded(
                child: TextField(
                  controller: controller,
                  onChanged: onChanged,
                  cursorColor: colors.accentDefault,
                  style: AppTextStyles.body.copyWith(color: colors.textPrimary),
                  decoration: InputDecoration(
                    isDense: true, // 세로 여유분 거둬냄
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    hintText: '종목명 또는 종목코드',
                    hintStyle: AppTextStyles.body.copyWith(color: colors.textTertiary),
                  ),
                ),
              ),
              // 지울 내용이 있을 때만 보인다. 빈 입력칸의 X는 누를 이유가 없다.
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: controller,
                builder: (BuildContext context, TextEditingValue value, _) {
                  if (value.text.isEmpty) {
                    return SizedBox(width: dimens.iconSm);
                  }
                  return AppInkWell(
                    onTap: onCleared,
                    child: AppSvgIcon(
                      AppIcons.close,
                      size: dimens.iconSm,
                      color: colors.textTertiary,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
