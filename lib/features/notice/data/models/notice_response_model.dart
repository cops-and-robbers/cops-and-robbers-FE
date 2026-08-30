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

    /// 본문의 실제 언어 코드(소문자 `ko`·`ja`·`en`).
    /// 요청한 언어의 번역이 없으면 서버가 대체한 언어가 내려온다.
    String? language,

    /// 요청한 언어 코드. [language]와 다르면 요청한 언어의 번역이 아직 없다는 뜻.
    String? requestedLanguage,
    required bool pinned,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _NoticeResponseModel;

  const NoticeResponseModel._();

  /// 서버가 다른 언어로 대체해 내려줬는지 여부.
  ///
  /// api-docs가 두 필드를 required로 두지 않아 nullable로 받는다. 한쪽이라도
  /// 없으면 대체 여부를 알 수 없으므로 안내를 띄우지 않는 쪽으로 떨어뜨린다.
  bool get isTranslationFallback =>
      language != null &&
      requestedLanguage != null &&
      language != requestedLanguage;

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
