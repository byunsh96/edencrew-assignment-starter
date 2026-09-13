import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../constants/app_icons.dart';
import '../../../../core/repository/core_repository.dart';
import '../../../../repository/stock_repository.dart';
import '../../../../theme/theme.dart';
import '../../../../widgets/app_empty_view.dart';
import '../../../stock_detail/views/screens/stock_detail_screen.dart';
import '../../controllers/favorite_controller.dart';
import '../../controllers/watchlist_controller.dart';
import '../../models/watchlist_item.dart';
import '../widgets/watchlist_header.dart';
import '../widgets/watchlist_row.dart';

/// 관심 화면.
class WatchlistScreen extends StatelessWidget {
  const WatchlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 화면 전용 컨트롤러라 화면 위젯에 붙인다. 화면이 사라지면 함께 dispose된다.
    return ChangeNotifierProvider<WatchlistController>(
      create: (BuildContext context) => WatchlistController(stockRepository: StockRepository(context.read<CoreRepository>()), favoriteController: context.read<FavoriteController>()),
      child: const _WatchlistView(),
    );
  }
}

class _WatchlistView extends StatelessWidget {
  const _WatchlistView();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        const WatchlistHeader(),
        Expanded(
          child: Consumer<WatchlistController>(
            builder: (BuildContext context, WatchlistController controller, _) {
              if (controller.isEmpty) {
                return const AppEmptyView(icon: AppIcons.star, title: '관심 종목이 없습니다', description: '검색 탭에서 종목을 찾아\n별 아이콘을 눌러 추가해 주세요.');
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
                  itemBuilder: (BuildContext context, int index) => WatchlistRow(item: items[index], onTap: () => StockDetailScreen.push(context, items[index].stock)),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
