import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'binding/app_providers.dart';
import 'theme/theme.dart';
import 'domains/home/home_screen.dart';
import 'widgets/mock_banner.dart';

void main() {
  runApp(MultiProvider(providers: AppProviders.global, child: const EdencrewAssignmentApp()));
}

class EdencrewAssignmentApp extends StatelessWidget {
  const EdencrewAssignmentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '이든크루 평가 과제',
      theme: AppTheme.dark,
      // builder는 Navigator를 child로 받는다. 여기 감싸야 상세 화면까지 배너가 덮인다.
      builder: (BuildContext context, Widget? child) =>
          MockBanner(child: child ?? const SizedBox.shrink()),
      home: const HomeScreen(),
    );
  }
}
