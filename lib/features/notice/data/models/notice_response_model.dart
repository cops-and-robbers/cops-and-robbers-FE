import 'package:freezed_annotation/freezed_annotation.dart';

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

/// 페이지 정보 DTO
///
/// 백엔드 스키마: api-docs.json#PageInfo
/// `number`는 0-based 페이지 인덱스.
@freezed
class PageInfoModel with _$PageInfoModel {
  const factory PageInfoModel({
    required int size,
    required int number,
    required int totalElements,
    required int totalPages,
  }) = _PageInfoModel;

  factory PageInfoModel.fromJson(Map<String, dynamic> json) =>
      _$PageInfoModelFromJson(json);
}
