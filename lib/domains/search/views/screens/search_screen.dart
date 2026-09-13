import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../constants/app_icons.dart';
import '../../../../core/repository/core_repository.dart';
import '../../../../repository/stock_repository.dart';
import '../../../../theme/theme.dart';
import '../../../../widgets/app_empty_view.dart';
import '../../../../models/favorite_stock.dart';
import '../../../../widgets/app_toast.dart';
import '../../../stock_detail/views/screens/stock_detail_screen.dart';
import '../../controllers/stock_search_controller.dart';
import '../../models/stock_search_item.dart';
import '../widgets/search_field.dart';
import '../widgets/search_result_row.dart';

/// 검색 화면.
class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<StockSearchController>(
      create: (BuildContext context) => StockSearchController(stockRepository: StockRepository(context.read<CoreRepository>())),
      child: const _SearchView(),
    );
  }
}

class _SearchView extends StatefulWidget {
  const _SearchView();

  @override
  State<_SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<_SearchView> {
  /// dispose가 필요해 StatefulWidget을 쓴다.
  final TextEditingController _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _onCleared() {
    _textController.clear();
    context.read<StockSearchController>().clear();
  }

  void _onFavoriteToggled(bool added) => AppToast.favorite(context, added: added);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        SearchField(controller: _textController, onChanged: context.read<StockSearchController>().onKeywordChanged, onCleared: _onCleared),
        Expanded(
          child: Consumer<StockSearchController>(
            builder: (BuildContext context, StockSearchController controller, _) {
              if (!controller.hasKeyword) {
                return const AppEmptyView(icon: AppIcons.search, title: '종목을 검색해 보세요', description: '종목명 또는 종목코드 6자리로\n검색하실 수 있습니다.');
              }

              if (controller.isLoading) {
                return Center(child: CircularProgressIndicator(color: context.colors.accentDefault));
              }

              final List<StockSearchItem> results = controller.results;
              if (results.isEmpty) {
                return AppEmptyView(icon: AppIcons.searchEmpty, title: '검색 결과가 없습니다', description: _notFoundMessage(controller.keyword));
              }

              return ListView.builder(
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                itemCount: results.length,
                itemBuilder: (BuildContext context, int index) => SearchResultRow(
                  item: results[index],
                  keyword: controller.keyword,
                  onFavoriteToggled: _onFavoriteToggled,
                  onTap: () => StockDetailScreen.push(context, FavoriteStock(symbol: results[index].symbol, name: results[index].name, marketName: results[index].marketName)),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// 검색 결과 없음 안내. 사용자가 입력한 검색어를 그대로 넣는다.
  ///
  /// 검색어가 길면 안내문이 화면을 넘기므로 잘라서 보여준다.
  /// Figma에 정의되지 않은 부분이라 직접 정했다.
  String _notFoundMessage(String keyword) {
    const int maxLength = 20;
    final String trimmed = keyword.trim();
    final String shown = trimmed.length <= maxLength ? trimmed : '${trimmed.substring(0, maxLength)}...';

    return "'$shown'와\n일치하는 검색 결과를 찾지 못했습니다.";
  }
}
