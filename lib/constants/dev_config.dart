/// 개발 중에만 켜는 플래그.
abstract final class DevConfig {
  /// 네이버가 차단하거나 5xx를 돌려줄 때 `assets/mock/`에 저장해 둔 응답으로 이어간다.
  ///
  /// `docs/NAVER_API.md`의 「네트워크가 막힐 때」 항목을 따른 것이다.
  /// 실제 시세가 아닌 저장본이 화면에 뜨므로 [MockNotice]가 배너로 알린다.
  ///
  /// **제출 전에는 `false`로 두거나, 최소한 릴리즈 빌드에서 켜지지 않는지 확인한다.**
  /// 고정된 과거 시세를 실시간 시세로 오인할 수 있다.
  static const bool useMockOnFailure = true;
}
