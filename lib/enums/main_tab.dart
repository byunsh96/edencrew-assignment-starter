//TODO 리뷰 확인

/// 하단 탭 바의 탭.
///
/// 선언 순서가 곧 탭이 놓이는 순서다.
/// 화면과 아이콘 매핑은 각각 `HomeScreen`과 `AppTabBar`에서 `switch`로 처리한다.
/// 여기에 값을 추가하면 컴파일러가 빠진 분기를 잡아준다.
enum MainTab {
  watchlist('관심'),
  search('검색');

  const MainTab(this.label);

  /// 탭 바에 그대로 노출하는 문구.
  final String label;
}
