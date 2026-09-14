import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:edencrew_assignment_starter/core/repository/core_repository.dart';
import 'package:edencrew_assignment_starter/domains/favorite_list/controllers/favorite_controller.dart';
import 'package:edencrew_assignment_starter/domains/favorite_list/controllers/favorite_list_controller.dart';
import 'package:edencrew_assignment_starter/domains/favorite_list/enums/favorite_list_sort.dart';
import 'package:edencrew_assignment_starter/domains/favorite_list/models/favorite_list_item_model.dart';
import 'package:edencrew_assignment_starter/domains/favorite_list/views/widgets/favorite_list_sort_sheet.dart';
import 'package:edencrew_assignment_starter/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:edencrew_assignment_starter/models/stock_model.dart';

/// 정렬 바텀시트와 정렬 규칙을 검증한다.
void main() {
  const List<StockModel> stocks = <StockModel>[
    StockModel(symbol: '005930', name: '삼성전자', marketName: '코스피'),
    StockModel(symbol: '000660', name: 'SK하이닉스', marketName: '코스피'),
    StockModel(symbol: '035720', name: '카카오', marketName: '코스피'),
    // 시세 응답에 없는 종목. 스켈레톤으로 그려진다.
    StockModel(symbol: '999999', name: '가상종목', marketName: '코스닥'),
  ];

  late FavoriteListController controller;

  setUp(() async {
    final FavoriteController favorites = FavoriteController();
    for (final StockModel stock in stocks) {
      favorites.toggle(stock);
    }

    final Dio dio = Dio()..httpClientAdapter = _MockAdapter();
    CoreRepository.instance = CoreRepository(dio: dio);
    controller = FavoriteListController(favoriteController: favorites);

    while (controller.isLoading) {
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
  });

  tearDown(() => controller.dispose());

  test('현재가순은 내림차순이고 시세 미수신 행이 맨 뒤로 간다', () {
    final List<FavoriteListItemModel> items = controller.items;

    expect(items.last.stock.symbol, '999999');
    expect(items.last.hasQuote, isFalse);

    final List<int> prices = items
        .where((FavoriteListItemModel e) => e.hasQuote)
        .map((FavoriteListItemModel e) => e.quote!.currentPrice)
        .toList();
    expect(prices, List<int>.from(prices)..sort((int a, int b) => b - a));
  });

  test('가나다순에서도 시세 미수신 행은 뒤로 간다', () {
    controller.changeSort(FavoriteListSort.name);
    final List<FavoriteListItemModel> items = controller.items;

    // '가상종목'은 가나다순으로 맨 앞이지만 시세가 없어 뒤로 밀린다.
    expect(items.last.stock.name, '가상종목');
    expect(items.first.stock.name, 'SK하이닉스');
  });

  testWidgets('정렬 바텀시트는 선택된 항목에만 체크를 보인다', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        // 실제로는 showModalBottomSheet가 Material을 제공한다.
        home: Scaffold(
          body: ChangeNotifierProvider<FavoriteListController>.value(
            value: controller,
            child: const FavoriteListSortSheet(
              selected: FavoriteListSort.changeRate,
              onSelected: _noop,
            ),
          ),
        ),
      ),
    );

    expect(find.text('정렬'), findsOneWidget);
    for (final FavoriteListSort sort in FavoriteListSort.values) {
      expect(find.text(sort.label), findsOneWidget);
    }
    // 체크 아이콘은 선택된 항목 하나에만 붙는다.
    expect(find.byType(InkWell), findsNWidgets(FavoriteListSort.values.length));
  });
}

void _noop(FavoriteListSort _) {}

/// 저장한 실시간 시세 응답을 돌려준다. 999999는 응답에 없다.
class _MockAdapter implements HttpClientAdapter {
  late final List<int> _realtime = File('assets/mock/realtime_quote.json').readAsBytesSync();

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromBytes(
      _realtime,
      200,
      headers: <String, List<String>>{
        Headers.contentTypeHeader: <String>['text/plain;charset=EUC-KR'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
