import 'package:flutter/foundation.dart';

//TODO 리뷰 확인

/// mock 응답이 화면에 쓰였는지 알린다.
///
/// 저장된 과거 응답을 실시간 데이터로 오인하지 않도록, 한 번이라도 대체가 일어나면
/// 화면 상단에 배너를 띄운다. ([MockBanner])
abstract final class MockNotice {
  /// mock으로 대체된 endpoint 이름. 배너 문구에 그대로 쓴다.
  static final ValueNotifier<Set<String>> sources =
      ValueNotifier<Set<String>>(<String>{});

  static void mark(String source) {
    if (sources.value.contains(source)) return;
    // ValueNotifier는 동일 인스턴스를 대입하면 알리지 않으므로 새 Set으로 바꾼다.
    sources.value = <String>{...sources.value, source};
  }
}
