import 'package:flutter/material.dart';

import '../../../../constants/app_icons.dart';
import '../../../../views/widgets/app_empty_view.dart';

/// 검색 화면.
class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppEmptyView(
      icon: AppIcons.search,
      title: '종목을 검색해 보세요',
      description: '종목명 또는 종목코드 6자리로\n검색하실 수 있습니다.',
    );
  }
}
