import 'package:flutter/foundation.dart';

import '../../../models/stock.dart';

//TODO 리뷰 확인

/// 관심 종목 상태. 관심 · 검색 · 상세 세 화면이 같은 인스턴스를 본다.
///
/// 유일하게 전역(`AppProviders.global`)에 올리는 컨트롤러다.
/// 화면별로 목록을 복사해 들고 있지 않는다.
class FavoriteController extends ChangeNotifier {
  final List<Stock> _items = <Stock>[];

  /// 등록한 순서를 유지한다. 정렬은 화면 컨트롤러가 맡는다.
  List<Stock> get items => List<Stock>.unmodifiable(_items);

  List<String> get symbols =>
      _items.map((Stock e) => e.symbol).toList(growable: false);

  bool get isEmpty => _items.isEmpty;

  bool contains(String symbol) =>
      _items.any((Stock e) => e.symbol == symbol);

  /// 관심 등록 / 해제를 뒤집고 결과를 돌려준다.
  ///
  /// 토스트 문구가 등록과 해제로 갈리므로 호출부가 결과를 알아야 한다.
  bool toggle(Stock stock) {
    final bool willAdd = !contains(stock.symbol);
    if (willAdd) {
      _items.add(stock);
    } else {
      _items.removeWhere((Stock e) => e.symbol == stock.symbol);
    }
    notifyListeners();
    return willAdd;
  }

  void remove(String symbol) {
    if (!contains(symbol)) return;
    _items.removeWhere((Stock e) => e.symbol == symbol);
    notifyListeners();
  }
}
