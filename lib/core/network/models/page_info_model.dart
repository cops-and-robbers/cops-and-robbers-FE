import 'package:freezed_annotation/freezed_annotation.dart';

part 'page_info_model.freezed.dart';
part 'page_info_model.g.dart';

/// 페이지네이션 응답 봉투의 페이지 정보 DTO
///
/// 백엔드 스키마: api-docs.json#PageInfo
/// 목록형 API 여러 곳(`/api/notices`, `/api/community-posts`)이 공유하므로
/// feature가 아니라 core에 둔다.
/// [number]는 0-based 페이지 인덱스.
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
