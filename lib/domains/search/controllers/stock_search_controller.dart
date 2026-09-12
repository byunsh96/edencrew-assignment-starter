import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../repository/stock_repository.dart';
import '../models/stock_search_item.dart';

/// 검색 화면 상태.
///
/// Flutter Material의 `SearchController`와 이름이 겹치지 않도록 접두사를 붙였다.
class StockSearchController extends ChangeNotifier {
  StockSearchController({required StockRepository stockRepository})
      : _stockRepository = stockRepository;

  /// 입력이 멈춘 뒤 요청까지 기다리는 시간.
  /// 한 글자마다 호출하면 자동완성 endpoint에 요청이 몰린다.
  static const Duration _debounce = Duration(milliseconds: 300);

  final StockRepository _stockRepository;

  Timer? _debounceTimer;
  String _keyword = '';
  List<StockSearchItem> _results = <StockSearchItem>[];
  bool _isLoading = false;

  String get keyword => _keyword;

  List<StockSearchItem> get results =>
      List<StockSearchItem>.unmodifiable(_results);

  bool get isLoading => _isLoading;

  /// 검색어를 입력하기 전인지. 빈 상태 두 가지를 가른다.
  bool get hasKeyword => _keyword.trim().isNotEmpty;

  void onKeywordChanged(String value) {
    _keyword = value;
    _debounceTimer?.cancel();

    if (!hasKeyword) {
      _results = <StockSearchItem>[];
      _isLoading = false;
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();
    _debounceTimer = Timer(_debounce, _search);
  }

  void clear() => onKeywordChanged('');

  Future<void> _search() async {
    final String requested = _keyword.trim();
    final List<StockSearchItem> results =
        await _stockRepository.getAutoComplete(requested);

    // 응답이 도착하는 사이 검색어가 바뀌었으면 버린다.
    // 늦게 온 이전 요청이 최신 결과를 덮어쓰지 않게 해야 한다.
    if (requested != _keyword.trim()) return;

    _results = results;
    _isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}
