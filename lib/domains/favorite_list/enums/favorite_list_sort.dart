/// 관심 목록 정렬 기준.
enum FavoriteListSort {
  price('현재가순'),
  changeRate('등락률순'),
  name('가나다순');

  const FavoriteListSort(this.label);

  /// 헤더 칩과 정렬 바텀시트에 그대로 노출하는 문구.
  final String label;
}
