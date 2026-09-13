import 'package:edencrew_assignment_starter/constants/app_icons.dart';
import 'package:edencrew_assignment_starter/theme/theme.dart';
import 'package:edencrew_assignment_starter/views/widgets/app_svg_icon.dart';
import 'package:edencrew_assignment_starter/views/widgets/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// 관심 등록 · 해제 토스트가 Figma 시안의 아이콘과 색을 쓰는지 검증한다.
///
/// 시안 값
/// - 등록: `ico_starFill`, `#F5B544` (favoriteActive)
/// - 해제: `ico_star`,     `#B4B2A9` (textSecondary)
void main() {
  const AppColors colors = AppColors.dark();

  Future<AppSvgIcon> showToast(WidgetTester tester, {required bool added}) async {
    late BuildContext capturedContext;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: Builder(
          builder: (BuildContext context) {
            capturedContext = context;
            return const Scaffold();
          },
        ),
      ),
    );

    AppToast.favorite(capturedContext, added: added);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250)); // 페이드 인

    return tester.widget<AppSvgIcon>(find.byType(AppSvgIcon));
  }

  /// 토스트가 스스로 사라질 때까지 돌려 타이머를 남기지 않는다.
  Future<void> settle(WidgetTester tester) async {
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
  }

  testWidgets('등록 토스트는 채워진 금색 별을 쓴다', (WidgetTester tester) async {
    final AppSvgIcon icon = await showToast(tester, added: true);

    expect(icon.asset, AppIcons.starFill);
    expect(icon.color, colors.favoriteActive);
    expect(find.text('관심이 등록되었습니다'), findsOneWidget);

    await settle(tester);
  });

  testWidgets('해제 토스트는 외곽선 회색 별을 쓴다', (WidgetTester tester) async {
    final AppSvgIcon icon = await showToast(tester, added: false);

    expect(icon.asset, AppIcons.star);
    // 금색(favoriteActive)이 아니어야 한다. 해제인데 등록처럼 보이면 안 된다.
    expect(icon.color, colors.textSecondary);
    expect(icon.color, isNot(colors.favoriteActive));
    expect(find.text('관심이 해제되었습니다'), findsOneWidget);

    await settle(tester);
  });
}
