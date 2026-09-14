import 'package:flutter/material.dart';

import '../constants/app_text_styles.dart';
import '../theme/theme.dart';
import '../utils/mock_notice.dart';

//TODO 리뷰 확인

/// 저장된 mock 응답이 화면에 쓰이고 있음을 알리는 띠.
///
/// 네이버가 차단하면 `assets/mock/`의 과거 응답으로 화면을 이어가는데,
/// 표시가 없으면 고정된 옛 시세를 실시간으로 오인한다.
/// 한 번이라도 대체가 일어나면 앱을 다시 켤 때까지 계속 보인다.
class MockBanner extends StatelessWidget {
  const MockBanner({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final AppDimens dimens = context.dimens;

    return ValueListenableBuilder<Set<String>>(
      valueListenable: MockNotice.sources,
      builder: (BuildContext context, Set<String> sources, Widget? child) {
        if (sources.isEmpty) return child!;

        return Column(
          children: [
            Material(
              color: colors.feedbackWarning,
              child: SafeArea(
                bottom: false,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: dimens.space4,
                    vertical: dimens.space2,
                  ),
                  child: Text(
                    '저장된 mock 응답 사용 중 · ${sources.join(" · ")}',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.caption.copyWith(color: colors.surfaceBase),
                  ),
                ),
              ),
            ),
            Expanded(child: child!),
          ],
        );
      },
      child: child,
    );
  }
}
