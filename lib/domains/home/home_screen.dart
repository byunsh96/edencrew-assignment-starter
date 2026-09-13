import 'package:flutter/material.dart';
import '../../enums/main_tab.dart';
import '../../theme/theme.dart';
import '../../widgets/app_tab_bar.dart';
import '../../widgets/app_toast_scope.dart';
import '../search/views/screens/search_screen.dart';
import '../favorite_list/views/screens/favorite_list_screen.dart';

/// 관심 · 검색 두 탭을 담는 화면.
///
/// `IndexedStack`을 써서 탭을 오갈 때 각 화면의 상태와 스크롤 위치를 유지한다.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ValueNotifier<MainTab> _currentTab = ValueNotifier<MainTab>(MainTab.watchlist);

  @override
  void dispose() {
    _currentTab.dispose();
    super.dispose();
  }

  /// 탭에 대응하는 화면. `switch`라서 탭을 추가하면 컴파일러가 빠진 분기를 잡아준다.
  Widget _screenOf(MainTab tab) => switch (tab) {
    MainTab.watchlist => const FavoriteListScreen(),
    MainTab.search => const SearchScreen(),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.surfaceBase,
      body: SafeArea(
        bottom: false,
        child: ValueListenableBuilder<MainTab>(
          valueListenable: _currentTab,
          builder: (BuildContext context, MainTab tab, _) => Column(
            children: [
              Expanded(
                // 토스트가 탭 바를 가리지 않도록 탭 바를 뺀 영역만 감싼다.
                child: AppToastScope(
                  child: IndexedStack(
                    index: tab.index,
                    children: [for (final MainTab each in MainTab.values) _screenOf(each)],
                  ),
                ),
              ),
              AppTabBar(current: tab, onChanged: (MainTab next) => _currentTab.value = next),
            ],
          ),
        ),
      ),
    );
  }
}
