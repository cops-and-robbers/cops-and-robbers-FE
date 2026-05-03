import 'package:freezed_annotation/freezed_annotation.dart';

part 'bug_report_request_model.freezed.dart';
part 'bug_report_request_model.g.dart';

/// 버그 제보 요청 DTO
///
/// `POST /api/bugs` 요청 본문.
/// 서버 스펙: [content]는 최대 1000자(빈 문자열 허용).
/// UI 정책: 빈 입력은 제출 버튼 비활성화로 차단한다.
@freezed
class BugReportRequestModel with _$BugReportRequestModel {
  const factory BugReportRequestModel({
    required String content,
  }) = _BugReportRequestModel;

  factory BugReportRequestModel.fromJson(Map<String, dynamic> json) =>
      _$BugReportRequestModelFromJson(json);
}
