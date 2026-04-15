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
