import 'dart:convert';

import 'package:cp949_codec/cp949_codec.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../utils/log_util.dart';
import '../models/api_response_model.dart';

/// 모든 네트워크 요청이 지나가는 지점.

class CoreRepository {
  CoreRepository({Dio? dio}) : _dio = dio ?? Dio(_defaultOptions);

  static CoreRepository _instance = CoreRepository();

  /// 앱 전체가 Dio 커넥션 풀 하나를 공유한다.
  /// 상태를 갖지 않아 위젯 트리에 수명을 묶을 이유가 없어 싱글턴으로 둔다.
  static CoreRepository get instance => _instance;

  /// 테스트에서 mock adapter를 물린 Dio로 갈아끼우는 지점.
  ///
  /// 읽기는 막지 않고 쓰기에만 `@visibleForTesting`을 달아,
  /// 프로덕션 코드가 실수로 싱글턴을 바꾸면 분석기가 잡아낸다.
  /// 주입 지점을 여기 하나로 모아 컨트롤러 생성자가 테스트 사정을 떠안지 않게 한다.
  @visibleForTesting
  static set instance(CoreRepository repository) => _instance = repository;

  static const String _file = 'CoreRepository';

  static const Duration _timeout = Duration(seconds: 10);

  /// 네트워크 로그에 찍을 응답 본문의 최대 길이.
  /// 일별 시세 HTML은 한 페이지가 수만 자라 그대로 찍으면 콘솔이 덮인다.
  static const int _logBodyLimit = 500;

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
  Future<ApiResponseModel> getData(String url, {Map<String, dynamic>? query}) async {
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
        LogUtil().logError('getData($url): $statusCode ${response.statusMessage}', module: _file);
        return ApiResponseModel(statusCode: statusCode, errorMessage: response.statusMessage);
      }

      final String body = _decode(response);
      LogUtil().logNetwork('<- $statusCode ${_summarize(body)}', module: _file);

      return ApiResponseModel(statusCode: statusCode, data: body.isEmpty ? null : jsonDecode(body));
    } catch (e) {
      LogUtil().logError('getData($url): $e', module: _file);
      return const ApiResponseModel.failure('네트워크 요청에 실패했다.');
    }
  }

  /// EUC-KR HTML 응답을 문자열로 받는다.
  ///
  /// Dio가 본문을 UTF-8로 디코딩하면 한글이 깨진다.
  /// `ResponseType.bytes`로 원문을 받아 EUC-KR로 직접 디코딩한다.
  Future<String?> getHtml(String url, {Map<String, dynamic>? query}) async {
    try {
      LogUtil().logNetwork('GET(HTML) $url ${query ?? ''}', module: _file);

      final Response<List<int>> response = await _dio.get<List<int>>(
        url,
        queryParameters: query,
        // 원시 바이트로 받는다
        options: Options(responseType: ResponseType.bytes),
      );

      final int statusCode = response.statusCode ?? 0;

      if (statusCode == 200 && response.data != null) {
        //
        return _decode(response);
      }

      LogUtil().logError('getHtml($url): status $statusCode', module: _file);
      return null;
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
    if (body.length <= _logBodyLimit) return body;
    return '${body.substring(0, _logBodyLimit)}... (${body.length}자)';
  }
}
