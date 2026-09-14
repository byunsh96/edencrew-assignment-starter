import 'package:cp949_codec/cp949_codec.dart';
import 'package:flutter/services.dart';

import '../constants/dev_config.dart';
import '../utils/log_util.dart';
import '../utils/mock_notice.dart';

//TODO 리뷰 확인

/// `assets/mock/`에 저장해 둔 응답을 읽는다.
///
/// 네이버 endpoint는 호출이 잦으면 차단될 수 있어 개발 중 대체 경로로 쓴다.
/// (`docs/NAVER_API.md` 「네트워크가 막힐 때」)
class MockRepository {
  static const String _file = 'MockRepository';
  static const String _dir = 'assets/mock';

  /// JSON mock을 읽는다. 플래그가 꺼져 있으면 `null`을 돌려줘 호출부가 실패를 유지한다.
  Future<String?> loadJson(String fileName, {required String source}) async {
    if (!DevConfig.useMockOnFailure) return null;

    try {
      final String raw = await rootBundle.loadString('$_dir/$fileName');
      _mark(source, fileName);
      return raw;
    } catch (e) {
      LogUtil().logError('loadJson($fileName): $e', module: _file);
      return null;
    }
  }

  /// HTML mock을 읽는다. 저장본도 EUC-KR이라 실제 응답과 같은 방식으로 디코딩한다.
  Future<String?> loadHtml(String fileName, {required String source}) async {
    if (!DevConfig.useMockOnFailure) return null;

    try {
      final ByteData data = await rootBundle.load('$_dir/$fileName');
      final String raw = cp949.decode(data.buffer.asUint8List(), allowInvalid: true);
      _mark(source, fileName);
      return raw;
    } catch (e) {
      LogUtil().logError('loadHtml($fileName): $e', module: _file);
      return null;
    }
  }

  void _mark(String source, String fileName) {
    MockNotice.mark(source);
    LogUtil().logInfo('mock 대체: $source <- $fileName', module: _file);
  }
}
