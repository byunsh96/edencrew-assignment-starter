import 'dart:async';

import 'package:flutter/foundation.dart';


/// 연속 호출 중 마지막 것만 실행되도록 일정 시간 미룬다.
///
/// 검색어를 한 글자씩 입력할 때마다 요청을 보내면 자동완성 endpoint에 호출이 몰린다.
/// 입력이 멈춘 뒤에 한 번만 보내기 위해 쓴다.
///
/// 타이머 정리를 잊으면 화면을 나간 뒤에도 콜백이 실행되어
/// `dispose`된 컨트롤러에서 `notifyListeners()`가 불린다.
/// 그 책임을 이 mixin 안에 가둔다.
///
/// ```dart
/// class StockSearchController extends ChangeNotifier with DebounceMixin {
///   void onKeywordChanged(String value) {
///     cancelDebounce();
///     debounce(const Duration(milliseconds: 300), _search);
///   }
/// }
/// ```
///
/// `on ChangeNotifier`라 `with` 순서상 이 mixin의 [dispose]가 먼저 실행된다.
/// 컨트롤러가 [dispose]를 다시 오버라이드한다면 `super.dispose()`를 반드시 불러야
/// 타이머가 정리된다.
mixin DebounceMixin on ChangeNotifier {
  Timer? _debounceTimer;

  /// 예약된 작업이 남아 있는지. 화면에 로딩을 띄울지 판단할 때 쓴다.
  bool get isDebouncing => _debounceTimer?.isActive ?? false;

  /// 이전 예약을 취소하고 [duration] 뒤에 [action]을 실행한다.
  void debounce(Duration duration, VoidCallback action) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(duration, action);
  }

  /// 예약을 취소한다. 검색어를 지웠을 때처럼 즉시 멈춰야 할 때 쓴다.
  void cancelDebounce() => _debounceTimer?.cancel();

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}
