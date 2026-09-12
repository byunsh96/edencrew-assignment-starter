import 'package:edencrew_assignment_starter/binding/app_providers.dart';
import 'package:edencrew_assignment_starter/main.dart';
import 'package:edencrew_assignment_starter/views/widgets/app_tab_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  // 스타터 원본은 StartHereScreen을 검증했다. 시작 화면을 MainScreen으로 바꾸면서
  // 검증 대상만 옮기고 "다크 테마로 렌더링된다"는 의도는 그대로 뒀다.
  testWidgets('시작 화면이 다크 테마로 렌더링된다', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: AppProviders.global,
        child: const EdencrewAssignmentApp(),
      ),
    );

    expect(
      Theme.of(tester.element(find.byType(Scaffold))).brightness,
      Brightness.dark,
    );
  });

  testWidgets('관심 종목이 없으면 빈 상태와 탭 바가 함께 보인다', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: AppProviders.global,
        child: const EdencrewAssignmentApp(),
      ),
    );

    expect(find.text('관심'), findsWidgets);
    expect(find.text('관심 종목이 없습니다'), findsOneWidget);
    // 빈 상태에서도 헤더와 하단 탭 바는 유지된다.
    expect(find.byType(AppTabBar), findsOneWidget);
  });
}
