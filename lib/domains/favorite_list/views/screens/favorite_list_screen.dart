import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../constants/app_icons.dart';
import '../../../../widgets/app_empty_view.dart';
import '../../../stock_detail/views/screens/stock_detail_screen.dart';
import '../../controllers/favorite_controller.dart';
import '../../controllers/favorite_list_controller.dart';
import '../../models/favorite_list_item_model.dart';
import '../widgets/favorite_list_header.dart';
import '../widgets/favorite_list_row.dart';

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
        const FavoriteListHeader(),
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

              final List<FavoriteListItemModel> items = controller.items;

              return RefreshIndicator(
                onRefresh: controller.fetchQuotes,
                child: ListView.builder(
                  // 목록이 짧아도 당겨서 새로고침이 되도록 한다.
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: items.length,
                  itemBuilder: (BuildContext context, int index) => FavoriteListRow(
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
