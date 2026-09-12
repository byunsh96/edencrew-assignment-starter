/// 상세 화면 기간 탭.
enum ChartPeriod {
  oneMonth('1개월', 2),
  threeMonths('3개월', 6),
  sixMonths('6개월', 12),
  oneYear('1년', 25);

  const ChartPeriod(this.label, this.pageCount);

  final String label;

  /// 이 기간을 채우는 데 필요한 일별 시세 페이지 수.
  ///
  /// 한 페이지에 10거래일이 담긴다. 1년은 거래일 약 245일이라 25페이지다.
  /// (`docs/NAVER_API.md`의 기간별 표를 그대로 옮겼다)
  final int pageCount;
}
