import 'package:freezed_annotation/freezed_annotation.dart';

part 'ready_request.freezed.dart';
part 'ready_request.g.dart';

/// 준비 상태 변경 요청 DTO
///
/// `PATCH /api/games/{gameId}/lobby/ready` 요청 바디
///
/// **요청 예시**:
/// ```json
/// {
///   "isReady": true
/// }
/// ```
@freezed
class ReadyRequest with _$ReadyRequest {
  const factory ReadyRequest({
    /// 준비 상태 (true: 준비 완료, false: 준비 취소)
    required bool isReady,
  }) = _ReadyRequest;

  factory ReadyRequest.fromJson(Map<String, dynamic> json) =>
      _$ReadyRequestFromJson(json);
}
