//TODO 리뷰 확인

/// Figma `Screens` 페이지에서 추출한 SVG 아이콘 경로.
///
/// 주석의 숫자는 Figma 기준 크기다. 실제 색은 SVG에 박혀 있으므로
/// `AppSvgIcon`의 `color`로 덮어써서 토큰 색을 적용한다.
abstract final class AppIcons {
  /// 관심 미등록 별. 22
  static const String star = 'assets/icons/ico_star.svg';

  /// 관심 등록 별(채움). 22
  static const String starFill = 'assets/icons/ico_star_fill.svg';

  /// 하단 탭 바 검색. 22
  static const String search = 'assets/icons/ico_search.svg';

  /// 검색 결과 없음 일러스트. 40
  static const String searchEmpty = 'assets/icons/ico_search_empty.svg';

  /// 검색어 지우기. 16
  static const String close = 'assets/icons/ico_x.svg';

  /// 시세 새로고침. 20
  static const String refresh = 'assets/icons/ico_refresh.svg';

  /// 정렬 바텀시트 열기. 20
  static const String align = 'assets/icons/ico_align.svg';

  /// 정렬 선택 표시. 24
  static const String check = 'assets/icons/ico_check.svg';

  /// 상세 화면 뒤로가기. 20
  static const String back = 'assets/icons/ico_back.svg';
}
