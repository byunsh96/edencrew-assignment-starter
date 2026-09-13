import 'package:flutter/material.dart';

import '../../theme/theme.dart';
import '../../widgets/app_tab_bar.dart';
import '../search/views/screens/search_screen.dart';
import '../watchlist/views/screens/watchlist_screen.dart';

/// 관심 · 검색 두 탭을 담는 화면.
///
/// `IndexedStack`을 써서 탭을 오갈 때 각 화면의 상태와 스크롤 위치를 유지한다.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ValueNotifier<int> _currentIndex = ValueNotifier<int>(0);

  @override
  void dispose() {
    _currentIndex.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.surfaceBase,
      body: SafeArea(
        bottom: false,
        child: ValueListenableBuilder<int>(
          valueListenable: _currentIndex,
          builder: (BuildContext context, int index, _) => Column(
            children: <Widget>[
              Expanded(
                child: IndexedStack(index: index, children: const <Widget>[WatchlistScreen(), SearchScreen()]),
              ),
              AppTabBar(currentIndex: index, onChanged: (int next) => _currentIndex.value = next),
            ],
          ),
        ),
      ),
    );
  }
}
