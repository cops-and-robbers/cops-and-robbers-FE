import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';

import '../errors/app_exception.dart';

/// 주어진 에러가 "네트워크성 실패"인지 판별한다.
///
/// 스플래시 오프라인 가드의 루프 복구 경로에서 사용한다.
/// 네트워크성 실패로 분류되면 사용자를 오프라인 화면으로 되돌린다.
///
/// 네트워크성 실패로 판정되는 케이스:
/// - `NetworkException` — `DioExceptionHandler`가 변환한 타임아웃/연결 에러
/// - `TimeoutException` — `Future.timeout()`에서 발생
/// - `SocketException` — DNS 실패, 호스트 도달 불가
/// - `DioException` 중 `connectionError`, `connectionTimeout`,
///   `sendTimeout`, `receiveTimeout` 타입 (원시 Dio 에러 대비)
///
/// 서버 5xx, 400번대, 파싱 에러 등은 모두 false.
bool isNetworkFailure(Object error) {
  if (error is NetworkException) return true;
  if (error is TimeoutException) return true;
  if (error is SocketException) return true;
  if (error is DioException) {
    return error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout;
  }
  return false;
}

/// 주어진 에러가 "서버 장애"(HTTP 5xx)인지 판별한다.
///
/// Repository가 [DioExceptionHandler]로 변환한 [AppException]은 원인 Dio 에러를
/// `originalException`에 보존하므로, 그 응답 상태 코드로 판정한다. 원시
/// [DioException]도 받는다. 연결 불가·타임아웃은 [isNetworkFailure] 소관이라
/// 여기서는 false.
bool isServerFailure(Object error) {
  final original = error is AppException ? error.originalException : error;
  if (original is! DioException) return false;
  return (original.response?.statusCode ?? 0) >= 500;
}

/// API 실패를 "화면이 무엇을 안내할지" 기준으로 한 곳에서 분류한다.
///
/// - [network]: 기기 연결·타임아웃 — 오프라인 안내 또는 (사전 체크 통과 후면) 서버 장애
/// - [server]: 5xx — 서버 장애, 재시도가 의미 있다
/// - [client]: 4xx — 요청 자체가 거절됨. errorCode별 문구는 `errorByException`이 담당
/// - [other]: 파싱 등 — 재시도해도 같은 결과
enum FailureKind { network, server, client, other }

FailureKind classifyFailure(Object error) {
  if (isNetworkFailure(error)) return FailureKind.network;
  if (isServerFailure(error)) return FailureKind.server;
  final original = error is AppException ? error.originalException : error;
  final status = original is DioException
      ? original.response?.statusCode
      : null;
  if (status != null && status >= 400 && status < 500) {
    return FailureKind.client;
  }
  return FailureKind.other;
}
