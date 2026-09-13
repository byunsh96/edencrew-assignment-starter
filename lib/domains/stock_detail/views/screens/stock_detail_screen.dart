import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../constants/app_text_styles.dart';
import '../../../../models/favorite_stock.dart';
import '../../../../models/stock_quote.dart';
import '../../../../theme/theme.dart';
import '../../../../widgets/app_toast.dart';
import '../../../../widgets/app_toast_scope.dart';
import '../../../favorite_list/controllers/favorite_controller.dart';
import '../../controllers/stock_detail_controller.dart';
import '../widgets/candle_chart.dart';
import '../widgets/daily_quote_table.dart';
import '../widgets/period_tabs.dart';
import '../widgets/quote_summary.dart';
import '../widgets/stock_detail_app_bar.dart';
import '../widgets/stock_price_header.dart';

//TODO 리뷰 확인

/// 종목 상세 화면.
class StockDetailScreen extends StatelessWidget {
  const StockDetailScreen({required this.stock, super.key});

  final FavoriteStock stock;

  /// 관심 · 검색 목록에서 이 화면으로 이동한다.
  static Future<void> push(BuildContext context, FavoriteStock stock) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => StockDetailScreen(stock: stock),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<StockDetailController>(
      create: (BuildContext context) => StockDetailController(
        favoriteController: context.read<FavoriteController>(),
        stock: stock,
      ),
      child: _StockDetailView(stock: stock),
    );
  }
}

class _StockDetailView extends StatelessWidget {
  const _StockDetailView({required this.stock});

  /// Figma Body 여백과 섹션 간격.
  static const double _bodyTopPadding = 14;
  static const double _sectionGap = 24;
  static const double _priceGroupGap = 16;

  final FavoriteStock stock;

  void _onFavoriteToggled(BuildContext context, bool added) =>
      AppToast.favorite(context, added: added);

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;

    return Scaffold(
      backgroundColor: colors.surfaceBase,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            StockDetailAppBar(
              stock: stock,
              onFavoriteToggled: (bool added) =>
                  _onFavoriteToggled(context, added),
            ),
            Expanded(
              // 탭 바가 없는 화면이라 본문 영역이 곧 토스트의 아래쪽 경계가 된다.
              child: AppToastScope(
                child: Consumer<StockDetailController>(
                builder: (
                  BuildContext context,
                  StockDetailController controller,
                  _,
                ) {
                  if (controller.isLoading) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: colors.accentDefault,
                      ),
                    );
                  }

                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, _bodyTopPadding, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        if (controller.quote case final StockQuote quote) ...[
                          StockPriceHeader(quote: quote),
                          const SizedBox(height: _priceGroupGap),
                        ],
                        PeriodTabs(
                          selected: controller.period,
                          onChanged: controller.changePeriod,
                        ),
                        const SizedBox(height: _priceGroupGap),
                        if (controller.isPeriodLoading)
                          const SizedBox(
                            height: CandleChart.height,
                            child: Center(child: CircularProgressIndicator()),
                          )
                        else
                          CandleChart(quotes: controller.dailyQuotes),
                        const SizedBox(height: _priceGroupGap),
                        if (controller.quote case final StockQuote quote)
                          QuoteSummary(quote: quote),
                        const SizedBox(height: _sectionGap),
                        if (controller.dailyQuotes.isEmpty)
                          Text(
                            '일별 시세를 불러오지 못했습니다.',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.caption
                                .copyWith(color: colors.textTertiary),
                          )
                        else
                          DailyQuoteTable(quotes: controller.dailyQuotes),
                      ],
                    ),
                  );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
