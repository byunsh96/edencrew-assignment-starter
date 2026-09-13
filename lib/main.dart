import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'binding/app_providers.dart';
import 'theme/theme.dart';
import 'domains/home/home_screen.dart';

//TODO 리뷰 확인

void main() {
  runApp(MultiProvider(providers: AppProviders.global, child: const EdencrewAssignmentApp()));
}

class EdencrewAssignmentApp extends StatelessWidget {
  const EdencrewAssignmentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: '이든크루 평가 과제', theme: AppTheme.dark, home: const HomeScreen());
  }
}
