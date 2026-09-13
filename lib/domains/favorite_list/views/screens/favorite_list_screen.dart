import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../constants/app_icons.dart';
import '../../../../theme/theme.dart';
import '../../../../widgets/app_empty_view.dart';
import '../../../stock_detail/views/screens/stock_detail_screen.dart';
import '../../controllers/favorite_controller.dart';
import '../../controllers/favorite_list_controller.dart';
import '../../models/watchlist_item.dart';
import '../widgets/watchlist_header.dart';
import '../widgets/watchlist_row.dart';

//TODO 리뷰 확인

/// 관심 화면.
class FavoriteListScreen extends StatelessWidget {
  const FavoriteListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<FavoriteListController>(
      create: (BuildContext context) =>
          FavoriteListController(favoriteController: context.read<FavoriteController>()),
      child: const _FavoriteListView(),
    );
  }
}

class _FavoriteListView extends StatelessWidget {
  const _FavoriteListView();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const WatchlistHeader(),
        Expanded(
          child: Consumer<FavoriteListController>(
            builder: (BuildContext context, FavoriteListController controller, _) {
              if (controller.isEmpty) {
                return const AppEmptyView(
                  icon: AppIcons.star,
                  title: '관심 종목이 없습니다',
                  description: '검색 탭에서 종목을 찾아\n별 아이콘을 눌러 추가해 주세요.',
                );
              }

              final List<WatchlistItem> items = controller.items;
              return RefreshIndicator(
                onRefresh: controller.fetchQuotes,
                color: context.colors.accentDefault,
                backgroundColor: context.colors.surfaceRaised,
                child: ListView.builder(
                  // 목록이 짧아도 당겨서 새로고침이 되도록 한다.
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: items.length,
                  itemBuilder: (BuildContext context, int index) => WatchlistRow(
                    item: items[index],
                    onTap: () => StockDetailScreen.push(context, items[index].stock),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
