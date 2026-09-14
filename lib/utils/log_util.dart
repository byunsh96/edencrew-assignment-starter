  import 'dart:developer' as developer;

  //TODO 리뷰 확인

  /// 앱 전역 로거. `print` 대신 사용한다.
  ///
  /// `LogUtil().logError('메서드명: $e', module: _file)` 형태로 호출한다.
  class LogUtil {
    factory LogUtil() => _instance;

    LogUtil._();

    static final LogUtil _instance = LogUtil._();

    void logInfo(String message, {String? module}) =>
        _write('INFO', message, module);

    void logNetwork(String message, {String? module}) =>
        _write('NETWORK', message, module);

    /// 에러는 원인 추적이 막히면 안 되므로 항상 남긴다.
    void logError(
      String message, {
      String? module,
      Object? error,
      StackTrace? stackTrace,
    }) {
      _write('ERROR', message, module, error: error, stackTrace: stackTrace);
    }

    void _write(
      String level,
      String message,
      String? module, {
      Object? error,
      StackTrace? stackTrace,
    }) {
      developer.log(
        message,
        name: module == null ? level : '$level·$module',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }
