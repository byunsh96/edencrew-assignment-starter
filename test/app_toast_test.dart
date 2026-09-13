import 'package:edencrew_assignment_starter/constants/app_icons.dart';
import 'package:edencrew_assignment_starter/theme/theme.dart';
import 'package:edencrew_assignment_starter/widgets/app_svg_icon.dart';
import 'package:edencrew_assignment_starter/widgets/app_toast.dart';
import 'package:edencrew_assignment_starter/widgets/app_toast_scope.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// 관심 등록 · 해제 토스트가 Figma 시안의 아이콘과 색을 쓰는지 검증한다.
///
/// 시안 값
/// - 등록: `ico_starFill`, `#F5B544` (favoriteActive)
/// - 해제: `ico_star`,     `#B4B2A9` (textSecondary)
void main() {
  const AppColors colors = AppColors.dark();
  const AppDimens dimens = AppDimens.standard();

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

  group('뜨는 위치', () {
    /// 탭 바처럼 아래에 붙는 요소를 흉내 낸다.
    const double bottomBarHeight = 100;

    /// 토스트 카드의 사각형. 아이콘이 아니라 카드를 재야 바닥까지의 거리가 정확하다.
    Rect cardRect(WidgetTester tester) => tester.getRect(
          find.ancestor(of: find.byType(AppSvgIcon), matching: find.byType(Material)).first,
        );

    Future<void> show(WidgetTester tester, {required bool withScope}) async {
      late BuildContext inner;
      final Widget probe = Builder(
        builder: (BuildContext context) {
          inner = context;
          return const SizedBox.expand();
        },
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: Scaffold(
            body: withScope
                ? Column(
                    children: <Widget>[
                      Expanded(child: AppToastScope(child: probe)),
                      const SizedBox(height: bottomBarHeight),
                    ],
                  )
                : probe,
          ),
        ),
      );

      AppToast.favorite(inner, added: true);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));
    }

    testWidgets('Scope가 없으면 화면 바닥에서 space3만큼 띄운다', (WidgetTester tester) async {
      await show(tester, withScope: false);

      final double screenHeight = tester.getSize(find.byType(MaterialApp)).height;
      expect(screenHeight - cardRect(tester).bottom, dimens.space3);

      await settle(tester);
    });

    testWidgets('Scope가 있으면 그 영역 바닥에서 space3만큼 띄운다', (WidgetTester tester) async {
      await show(tester, withScope: true);

      final double screenHeight = tester.getSize(find.byType(MaterialApp)).height;
      final double scopeBottom = screenHeight - bottomBarHeight;
      expect(scopeBottom - cardRect(tester).bottom, dimens.space3);

      await settle(tester);
    });
  });
}
