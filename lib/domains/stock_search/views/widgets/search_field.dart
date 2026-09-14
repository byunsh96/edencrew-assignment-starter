import 'package:flutter/material.dart';

import '../../../../widgets/app_ink_well.dart';
import '../../../../constants/app_icons.dart';
import '../../../../constants/app_text_styles.dart';
import '../../../../theme/theme.dart';
import '../../../../widgets/app_svg_icon.dart';

/// 검색 입력창. 돋보기 · 입력칸 · 지우기 버튼.
///
/// 입력칸 영역 어디를 눌러도 포커스가 잡히도록 [FocusNode]를 직접 들고 있다.
class SearchField extends StatefulWidget {
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
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final AppDimens dimens = context.dimens;

    return Padding(
      padding: EdgeInsets.fromLTRB(dimens.space4, dimens.space2, dimens.space4, dimens.space3),
      child: GestureDetector(
        // 돋보기 옆 빈 공간을 눌러도 입력칸이 열려야 한다.
        // 배경만 있고 자식이 없는 영역까지 탭을 받도록 opaque로 둔다.
        behavior: HitTestBehavior.opaque,
        onTap: _focusNode.requestFocus,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: dimens.space3, vertical: dimens.space2Mid),
          decoration: BoxDecoration(
            color: colors.surfaceSunken,
            borderRadius: BorderRadius.circular(dimens.radiusMd),
          ),
          foregroundDecoration: BoxDecoration(
            border: Border.all(color: colors.borderStrong, width: dimens.borderHairline),
            borderRadius: BorderRadius.circular(dimens.radiusMd),
          ),
          child: Row(
            spacing: dimens.space2,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AppSvgIcon(AppIcons.search, size: dimens.iconSm, color: colors.textTertiary),
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  focusNode: _focusNode,
                  onChanged: widget.onChanged,
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
                valueListenable: widget.controller,
                builder: (BuildContext context, TextEditingValue value, _) {
                  if (value.text.isEmpty) {
                    return SizedBox(width: dimens.iconSm);
                  }
                  return AppInkWell(
                    onTap: widget.onCleared,
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
