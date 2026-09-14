import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../constants/app_text_styles.dart';
import '../../../../models/stock.dart';
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

/// 종목 상세 화면.
class StockDetailScreen extends StatelessWidget {
  const StockDetailScreen({required this.stock, super.key});

  final Stock stock;

  /// 관심 · 검색 목록에서 이 화면으로 이동한다.
  static Future<void> push(BuildContext context, Stock stock) {
    return Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => StockDetailScreen(stock: stock)));
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<StockDetailController>(
      create: (BuildContext context) => StockDetailController(
        favoriteController: context.read<FavoriteController>(),
        stock: stock,
      ),
      child: const _StockDetailView(),
    );
  }
}

class _StockDetailView extends StatelessWidget {
  const _StockDetailView();

  void _onFavoriteToggled(BuildContext context, bool added) =>
      AppToast.favorite(context, added: added);

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final AppDimens dimens = context.dimens;

    return Scaffold(
      backgroundColor: colors.surfaceBase,
      body: SafeArea(
        child: Column(
          children: [
            // 종목명·거래소명은 메타 endpoint 응답으로 갱신되므로 컨트롤러에서 읽는다.
            //
            // Selector를 쓰지 않는다. Stock의 ==는 종목 식별자(canonicalId)만 보므로
            // 이름이 바뀌어도 같은 값으로 판정되어 리빌드가 일어나지 않는다.
            Consumer<StockDetailController>(
              builder: (BuildContext context, StockDetailController controller, _) =>
                  StockDetailAppBar(
                    stock: controller.stock,
                    onFavoriteToggled: (bool added) => _onFavoriteToggled(context, added),
                  ),
            ),
            Expanded(
              // 탭 바가 없는 화면이라 본문 영역이 곧 토스트의 아래쪽 경계가 된다.
              child: AppToastScope(
                child: Consumer<StockDetailController>(
                  builder: (BuildContext context, StockDetailController controller, _) {
                    if (controller.isLoading) {
                      return Center(child: CircularProgressIndicator(color: colors.accentDefault));
                    }

                    return SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(
                        dimens.space4,
                        dimens.space3Mid,
                        dimens.space4,
                        dimens.space4,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (controller.quote case final StockQuote quote) ...<Widget>[
                            StockPriceHeader(quote: quote),
                            SizedBox(height: dimens.space4),
                          ],
                          PeriodTabs(
                            selected: controller.period,
                            onChanged: controller.changePeriod,
                          ),
                          SizedBox(height: dimens.space4),
                          if (controller.isPeriodLoading)
                            const SizedBox(
                              height: CandleChart.height,
                              child: Center(child: CircularProgressIndicator()),
                            )
                          else
                            CandleChart(quotes: controller.dailyQuotes),
                          // 앞의 간격을 요약 카드와 함께 묶는다. Figma에서 이 16은
                          // Price 그룹 내부 간격이라 카드가 빠지면 함께 사라져야 한다.
                          // 뒤의 24는 Price와 Daily 사이 간격이라 항상 남는다.
                          if (controller.quote case final StockQuote quote) ...<Widget>[
                            SizedBox(height: dimens.space4),
                            QuoteSummary(quote: quote),
                          ],
                          SizedBox(height: dimens.space6),
                          if (controller.dailyQuotes.isEmpty)
                            Text(
                              '일별 시세를 불러오지 못했습니다.',
                              textAlign: TextAlign.center,
                              style: AppTextStyles.caption.copyWith(color: colors.textTertiary),
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
