import 'package:freezed_annotation/freezed_annotation.dart';

part 'bug_report_request_model.freezed.dart';
part 'bug_report_request_model.g.dart';

/// 버그 제보 요청 DTO
///
/// `POST /api/bugs` 요청 본문.
/// [content]는 1~1000자(서버 스펙 기준).
@freezed
class BugReportRequestModel with _$BugReportRequestModel {
  const factory BugReportRequestModel({
    required String content,
  }) = _BugReportRequestModel;

  factory BugReportRequestModel.fromJson(Map<String, dynamic> json) =>
      _$BugReportRequestModelFromJson(json);
}
