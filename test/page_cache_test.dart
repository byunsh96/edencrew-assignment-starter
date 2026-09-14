import 'dart:io';
import 'dart:typed_data';

import 'package:cp949_codec/cp949_codec.dart';
import 'package:dio/dio.dart';
import 'package:edencrew_assignment_starter/core/repository/core_repository.dart';
import 'package:edencrew_assignment_starter/domains/stock_detail/controllers/stock_detail_controller.dart';
import 'package:edencrew_assignment_starter/domains/stock_detail/enums/chart_period.dart';
import 'package:edencrew_assignment_starter/domains/favorite_list/controllers/favorite_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:edencrew_assignment_starter/models/stock_model.dart';

/// 일별 시세 페이지를 필요한 만큼만 요청하고 재사용하는지 검증한다.
/// 평가 중점 항목이라 네트워크를 가짜 어댑터로 바꿔 요청 횟수를 센다.
void main() {
  const StockModel samsung = StockModel(
    symbol: '005930',
    name: '삼성전자',
    marketName: '코스피',
  );

  late _RecordingAdapter adapter;
  late StockDetailController controller;

  setUp(() {
    adapter = _RecordingAdapter();
    final Dio dio = Dio()..httpClientAdapter = adapter;
    CoreRepository.instance = CoreRepository(dio: dio);

    controller = StockDetailController(
      favoriteController: FavoriteController(),
      stock: samsung,
    );
  });

  tearDown(() => controller.dispose());

  test('1개월은 2페이지만 요청한다', () async {
    await _settle(controller);

    expect(adapter.dailyPages, <int>[1, 2]);
  });

  test('1년으로 바꾸면 이미 받은 페이지는 다시 요청하지 않는다', () async {
    await _settle(controller);
    adapter.dailyPages.clear();

    await controller.changePeriod(ChartPeriod.oneYear);

    // 1·2페이지는 캐시에 있으므로 3페이지부터 25페이지까지만 받는다.
    expect(adapter.dailyPages..sort(), <int>[for (int p = 3; p <= 25; p++) p]);
  });

  test('기간을 되돌리면 요청이 한 건도 나가지 않는다', () async {
    await _settle(controller);
    await controller.changePeriod(ChartPeriod.oneYear);
    adapter.dailyPages.clear();

    await controller.changePeriod(ChartPeriod.oneMonth);

    expect(adapter.dailyPages, isEmpty);
  });

  test('lastPage보다 큰 페이지는 요청하지 않는다', () async {
    adapter.lastPage = 5;
    await _settle(controller);
    adapter.dailyPages.clear();

    await controller.changePeriod(ChartPeriod.oneYear);

    expect(adapter.dailyPages.every((int page) => page <= 5), isTrue);
  });
}

/// 컨트롤러 생성자가 건 초기 로딩이 끝날 때까지 기다린다.
Future<void> _settle(StockDetailController controller) async {
  while (controller.isLoading) {
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
}

/// 실제 네트워크 대신 저장해 둔 응답을 돌려주고 요청 페이지를 기록한다.
class _RecordingAdapter implements HttpClientAdapter {
  final List<int> dailyPages = <int>[];
  int lastPage = 756;

  late final List<int> _dailyHtml =
      File('assets/mock/daily_quote.html').readAsBytesSync();
  /// 저장본은 UTF-8이지만 실제 endpoint는 EUC-KR로 준다. 실제 응답과 같은 바이트로 맞춘다.
  late final List<int> _realtimeJson = cp949.encode(
    File('assets/mock/realtime_quote.json').readAsStringSync(),
  );

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (options.path.contains('sise_day')) {
      dailyPages.add(int.parse('${options.queryParameters['page']}'));
      return ResponseBody.fromBytes(
        _withLastPage(_dailyHtml),
        200,
        headers: <String, List<String>>{
          Headers.contentTypeHeader: <String>['text/html;charset=EUC-KR'],
        },
      );
    }

    return ResponseBody.fromBytes(
      _realtimeJson,
      200,
      headers: <String, List<String>>{
        Headers.contentTypeHeader: <String>['text/plain;charset=EUC-KR'],
      },
    );
  }

  /// 저장본의 맨뒤 링크를 테스트가 원하는 lastPage로 바꾼다.
  List<int> _withLastPage(List<int> bytes) {
    if (lastPage == 756) return bytes;
    return cp949.encode(
      cp949.decode(bytes, allowInvalid: true).replaceAll('page=756', 'page=$lastPage'),
    );
  }

  @override
  void close({bool force = false}) {}
}
