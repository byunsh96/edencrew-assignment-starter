import 'dart:convert';

import 'package:cp949_codec/cp949_codec.dart';
import 'package:dio/dio.dart';

import '../../constants/dev_config.dart';
import '../../utils/log_util.dart';
import '../models/api_response.dart';

//TODO 리뷰 확인

/// 모든 네트워크 요청이 지나가는 지점.
///
/// 네이버 endpoint는 호스트가 서로 달라 `baseUrl`을 두지 않는다.
/// 호출부가 `NaverApi`의 전체 URL을 그대로 넘긴다.
class CoreRepository {
  CoreRepository({Dio? dio}) : _dio = dio ?? Dio(_defaultOptions);

  static const String _file = 'CoreRepository';

  static const Duration _timeout = Duration(seconds: 10);

  /// finance.naver.com은 기본 UA로 요청하면 응답을 주지 않는 경우가 있다.
  static const String _userAgent =
      'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 '
      '(KHTML, like Gecko) Chrome/124.0 Safari/537.36';

  static final BaseOptions _defaultOptions = BaseOptions(
    connectTimeout: _timeout,
    receiveTimeout: _timeout,
    headers: <String, String>{'User-Agent': _userAgent},
    // 4xx·5xx를 예외로 던지지 않고 statusCode로 받아 ApiResponse에 담는다.
    validateStatus: (_) => true,
  );

  final Dio _dio;

  /// JSON 응답을 받는다.
  Future<ApiResponse> getData(
    String url, {
    Map<String, dynamic>? query,
  }) async {
    try {
      LogUtil().logNetwork('GET $url ${query ?? ''}', module: _file);

      // 인코딩이 endpoint마다 달라 항상 원문 바이트로 받아 직접 디코딩한다.
      final Response<List<int>> response = await _dio.get<List<int>>(
        url,
        queryParameters: query,
        options: Options(responseType: ResponseType.bytes),
      );
      final int statusCode = response.statusCode ?? 0;

      if (statusCode < 200 || statusCode >= 300) {
        LogUtil().logError(
          'getData($url): $statusCode ${response.statusMessage}',
          module: _file,
        );
        return ApiResponse(
          statusCode: statusCode,
          errorMessage: response.statusMessage,
        );
      }

      final String body = _decode(response);
      LogUtil().logNetwork('<- $statusCode ${_summarize(body)}', module: _file);

      return ApiResponse(
        statusCode: statusCode,
        data: body.isEmpty ? null : jsonDecode(body),
      );
    } catch (e) {
      LogUtil().logError('getData($url): $e', module: _file);
      return const ApiResponse.failure('네트워크 요청에 실패했다.');
    }
  }

  /// EUC-KR HTML 응답을 문자열로 받는다.
  ///
  /// Dio가 본문을 UTF-8로 디코딩하면 한글이 깨진다.
  /// `ResponseType.bytes`로 원문을 받아 EUC-KR로 직접 디코딩한다.
  Future<String?> getHtml(
    String url, {
    Map<String, dynamic>? query,
  }) async {
    try {
      LogUtil().logNetwork('GET(HTML) $url ${query ?? ''}', module: _file);

      final Response<List<int>> response = await _dio.get<List<int>>(
        url,
        queryParameters: query,
        options: Options(responseType: ResponseType.bytes),
      );

      final int statusCode = response.statusCode ?? 0;
      if (statusCode != 200 || response.data == null) {
        LogUtil().logError('getHtml($url): status $statusCode', module: _file);
        return null;
      }

      return _decode(response);
    } catch (e) {
      LogUtil().logError('getHtml($url): $e', module: _file);
    }
    return null;
  }

  /// 응답 헤더의 charset을 보고 디코딩한다.
  ///
  /// 네이버는 endpoint마다 인코딩이 다르다. 실시간 시세는 JSON인데도 EUC-KR이라
  /// UTF-8로 읽으면 종목명이 깨진다.
  ///
  /// | endpoint | Content-Type |
  /// |---|---|
  /// | `polling.finance.naver.com` | `text/plain;charset=EUC-KR` |
  /// | `finance.naver.com` | `text/html;charset=EUC-KR` |
  /// | 나머지 | UTF-8 |
  String _decode(Response<List<int>> response) {
    final List<int> bytes = response.data ?? const <int>[];
    final String contentType =
        response.headers.value(Headers.contentTypeHeader)?.toLowerCase() ?? '';

    // CP949는 EUC-KR의 상위 호환이다. allowInvalid로 깨진 바이트가 섞여도
    // 예외 대신 대체 문자(U+FFFD)로 넘어간다.
    if (contentType.contains('euc-kr')) {
      return cp949.decode(bytes, allowInvalid: true);
    }
    return utf8.decode(bytes, allowMalformed: true);
  }

  /// 앱 종료 시 연결을 정리한다. `Provider`의 `dispose`에서 부른다.
  void close() => _dio.close();

  /// 응답 본문이 길면 앞부분만 남긴다. 일별 시세 HTML은 한 페이지가 수만 자다.
  String _summarize(String? body) {
    if (body == null) return '';
    if (body.length <= DevConfig.networkLogBodyLimit) return body;
    return '${body.substring(0, DevConfig.networkLogBodyLimit)}... (${body.length}자)';
  }
}
