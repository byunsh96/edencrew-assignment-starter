//TODO 리뷰 확인

/// 개발 중에만 켜는 플래그.
abstract final class DevConfig {
  /// 일반 로그 출력 여부.
  static const bool enableLog = true;

  /// 네트워크 요청·응답 로그 출력 여부. 응답 본문이 길어 따로 끊을 수 있게 분리했다.
  static const bool enableNetworkLog = true;

  /// 네트워크 로그에 찍을 응답 본문의 최대 길이.
  /// 일별 시세 HTML은 한 페이지가 수만 자라 그대로 찍으면 콘솔이 덮인다.
  static const int networkLogBodyLimit = 500;
}
