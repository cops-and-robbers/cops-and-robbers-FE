import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/network/models/page_info_model.dart';

part 'notice_response_model.freezed.dart';
part 'notice_response_model.g.dart';

/// 공지사항 단건 응답 DTO
///
/// `GET /api/notices` 응답 배열의 각 원소에 대응한다.
/// 백엔드 스키마: api-docs.json#NoticeResponse
@freezed
class NoticeResponseModel with _$NoticeResponseModel {
  const factory NoticeResponseModel({
    required int id,
    required String title,
    required String content,
    required bool pinned,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _NoticeResponseModel;

  factory NoticeResponseModel.fromJson(Map<String, dynamic> json) =>
      _$NoticeResponseModelFromJson(json);
}

/// 공지사항 목록 응답 DTO
///
/// 백엔드 스키마: api-docs.json#NoticeListResponse
@freezed
class NoticeListResponseModel with _$NoticeListResponseModel {
  const factory NoticeListResponseModel({
    required List<NoticeResponseModel> content,
    required PageInfoModel page,
  }) = _NoticeListResponseModel;

  factory NoticeListResponseModel.fromJson(Map<String, dynamic> json) =>
      _$NoticeListResponseModelFromJson(json);
}
