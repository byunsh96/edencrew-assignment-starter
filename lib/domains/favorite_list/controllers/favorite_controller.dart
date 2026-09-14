import 'package:flutter/foundation.dart';

import '../../../models/stock_model.dart';

//TODO 리뷰 확인

/// 관심 종목 상태. 관심 · 검색 · 상세 세 화면이 같은 인스턴스를 본다.
///
/// 유일하게 전역(`AppProviders.global`)에 올리는 컨트롤러다.
/// 화면별로 목록을 복사해 들고 있지 않는다.
class FavoriteController extends ChangeNotifier {
  final List<StockModel> _items = <StockModel>[];

  /// 등록한 순서를 유지한다. 정렬은 화면 컨트롤러가 맡는다.
  List<StockModel> get items => List<StockModel>.unmodifiable(_items);

  List<String> get symbols =>
      _items.map((StockModel e) => e.symbol).toList(growable: false);

  bool get isEmpty => _items.isEmpty;

  bool contains(String symbol) =>
      _items.any((StockModel e) => e.symbol == symbol);

  /// [StockModel.canonicalId] 기준으로 등록 여부를 본다.
  bool containsStock(StockModel stock) => _items.contains(stock);

  /// 관심 등록 / 해제를 뒤집고 결과를 돌려준다.
  ///
  /// 토스트 문구가 등록과 해제로 갈리므로 호출부가 결과를 알아야 한다.
  bool toggle(StockModel stock) {
    // Stock의 ==가 canonicalId를 보므로 목록 연산이 곧 canonical id 비교다.
    final bool willAdd = !_items.contains(stock);
    if (willAdd) {
      _items.add(stock);
    } else {
      _items.remove(stock);
    }
    notifyListeners();
    return willAdd;
  }

  void remove(String symbol) {
    if (!contains(symbol)) return;
    _items.removeWhere((StockModel e) => e.symbol == symbol);
    notifyListeners();
  }
}
