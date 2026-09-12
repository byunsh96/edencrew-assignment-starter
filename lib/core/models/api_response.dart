/// 네트워크 응답 공통 래퍼.
///
/// Repository는 이 객체만 받아 모델로 바꾼다. Controller가 raw json을 보지 않는다.
class ApiResponse {
  const ApiResponse({
    required this.statusCode,
    this.data,
    this.errorMessage,
  });

  /// 요청 자체가 실패해 응답 코드조차 없는 경우.
  const ApiResponse.failure(this.errorMessage)
      : statusCode = 0,
        data = null;

  final int statusCode;
  final Object? data;
  final String? errorMessage;

  bool get isSuccess =>
      errorMessage == null && statusCode >= 200 && statusCode < 300;

  /// 본문을 `Map`으로 본다. 형태가 다르면 null.
  Map<String, dynamic>? get asMap =>
      data is Map ? Map<String, dynamic>.from(data! as Map) : null;

  /// 본문을 `List`로 본다. 형태가 다르면 빈 리스트.
  List<dynamic> get asList =>
      data is List ? data! as List<dynamic> : const <dynamic>[];
}
