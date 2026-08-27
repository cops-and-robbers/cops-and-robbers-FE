import 'package:freezed_annotation/freezed_annotation.dart';

part 'community_post_model.freezed.dart';
part 'community_post_model.g.dart';

/// 모임 장소 DTO
///
/// 백엔드 스키마: api-docs.json#LocationResponse (v2.21.0)
///
/// 표기는 두 값이 짝을 이룬다 — 서버가 좌표를 역지오코딩해 저장한 [region](동 단위)과
/// 작성자가 직접 입력한 [placeName]. 좌표로는 건물명·장소명을 신뢰할 수준으로 얻을 수
/// 없어 둘로 나눈 것이고, 화면은 둘을 병기한다 (DEC-0015).
@freezed
class CommunityLocationModel with _$CommunityLocationModel {
  const factory CommunityLocationModel({
    required double latitude,
    required double longitude,

    /// 동 단위 지역 — `서울특별시 광진구 군자동`. 역지오코딩 실패 시 null.
    String? region,

    /// 번지까지 붙은 지번 주소 — `서울특별시 광진구 화양동 164-2`.
    ///
    /// 화면에는 안 쓰고 복사에만 쓴다 — 지도 앱에 붙여넣어야 핀이 찍히는데
    /// [region]의 동까지로는 안 된다. 역지오코딩이 실패한 글은 null이다.
    String? address,

    /// 작성자가 입력한 만나는 곳 — `어린이대공원 정문`.
    ///
    /// 스키마상 non-null이지만 nullable로 받는다: v2.17.0 이전에 쓰인 글까지
    /// 서버가 채웠다는 보장이 없고, 응답 한 건 때문에 목록 전체가 파싱 실패로
    /// 날아가는 편이 장소 한 줄이 비는 것보다 나쁘다.
    String? placeName,

    /// 국가 코드(ISO 3166-1 alpha-2). 역지오코딩 실패 시 null.
    String? countryCode,
  }) = _CommunityLocationModel;

  factory CommunityLocationModel.fromJson(Map<String, dynamic> json) =>
      _$CommunityLocationModelFromJson(json);
}

/// 좌표 주소 조회 응답 DTO
///
/// 백엔드 스키마: api-docs.json#AddressResponse (v2.18.0)
///
/// 작성 화면에서 핀을 찍은 직후 위치를 확인시키는 용도다 — 서버가 저장하지 않는다.
/// [region]은 글에 저장될 값이고, [address]는 번지까지 붙어 작성자가 "여기 맞나"를
/// 판단하는 값이다. [countryCode]는 그 핀이 속한 나라이며, 목록 필터에는 쓰지 않는다
/// — 목록은 보는 사람의 현재 위치가 기준이라 `/country`가 따로 담당한다.
@freezed
class CommunityAddressResponseModel with _$CommunityAddressResponseModel {
  const factory CommunityAddressResponseModel({
    String? region,
    String? address,
    String? countryCode,
  }) = _CommunityAddressResponseModel;

  factory CommunityAddressResponseModel.fromJson(Map<String, dynamic> json) =>
      _$CommunityAddressResponseModelFromJson(json);
}

/// 커서 페이지네이션 응답 봉투의 커서 정보 DTO
///
/// 백엔드 스키마: api-docs.json#CursorInfo (v2.18.0)
///
/// 목록 API 중 커서를 쓰는 건 아직 커뮤니티뿐이라 여기 둔다. 두 번째 API가
/// 커서로 바뀌면 `PageInfoModel`처럼 core로 옮긴다.
/// [nextCursor]는 서버 내부 형식이다 — 파싱하지 말고 다음 요청에 그대로 싣는다.
/// [hasNext]가 false면 [nextCursor]는 항상 null이다.
@freezed
class CursorInfoModel with _$CursorInfoModel {
  const factory CursorInfoModel({
    required String? nextCursor,
    required bool hasNext,
  }) = _CursorInfoModel;

  factory CursorInfoModel.fromJson(Map<String, dynamic> json) =>
      _$CursorInfoModelFromJson(json);
}

/// 모집 게시글 단건 응답 DTO
///
/// 백엔드 스키마: api-docs.json#CommunityPostResponse (v2.18.0)
///
/// [writerNickname]은 탈퇴한 작성자면 null이다.
/// [currentParticipants]는 백엔드가 아직 안 보내는 값이다 — "참여" 개념 자체가
/// 서버에 정의되지 않았다. 미리 선언해 두면 필드가 추가되는 순간 코드 변경 없이
/// 값이 흘러들어온다.
/// `status`를 enum이 아니라 `String`으로 받는 이유: 도메인 변환을 Repository
/// 경계에서 하고, 알 수 없는 값이면 거기서 예외를 던지기 위함이다.
@freezed
class CommunityPostResponseModel with _$CommunityPostResponseModel {
  const factory CommunityPostResponseModel({
    required int id,
    required int writerId,
    required String title,
    required String content,
    required DateTime meetingAt,
    required CommunityLocationModel location,
    required int maxParticipants,
    required String status,
    required DateTime createdAt,

    /// 작성자 닉네임. 탈퇴한 작성자면 null.
    String? writerNickname,

    /// 좋아요·스크랩 수와 내 반응. 목록·단건·내 스크랩 세 표면 모두에 실려 온다.
    ///
    /// non-null로 받는다 — 서버가 빠뜨리면 여기서 파싱이 멈춘다. nullable로 받아
    /// 0·꺼짐으로 물러서면 "아무도 안 눌렀다"는 틀린 화면이 에러 없이 나온다.
    /// 비로그인 조회는 카운트는 정상이고 [liked]·[scrapped]만 false다.
    required int likeCount,
    required int scrapCount,
    required bool liked,
    required bool scrapped,

    // ── 백엔드 추가 예정 ──
    int? currentParticipants,
    bool? chatJoined,
  }) = _CommunityPostResponseModel;

  factory CommunityPostResponseModel.fromJson(Map<String, dynamic> json) =>
      _$CommunityPostResponseModelFromJson(json);
}

/// 모집 게시글 목록 응답 DTO
///
/// 백엔드 스키마: api-docs.json#CommunityPostListResponse (v2.18.0)
/// 총 개수(`totalElements`)는 커서 방식이라 제공되지 않는다.
///
/// v2.18.0에서 최상위 `countryCode`가 빠졌다 — 목록이 좌표를 안 받게 되면서
/// 요청값을 그대로 되돌려주는 중복이 됐다(DEC-0021).
@freezed
class CommunityPostListResponseModel with _$CommunityPostListResponseModel {
  const factory CommunityPostListResponseModel({
    required List<CommunityPostResponseModel> content,
    required CursorInfoModel cursor,
  }) = _CommunityPostListResponseModel;

  factory CommunityPostListResponseModel.fromJson(Map<String, dynamic> json) =>
      _$CommunityPostListResponseModelFromJson(json);
}

/// 좌표 국가 조회 응답 DTO
///
/// 백엔드 스키마: api-docs.json#CountryResponse (v2.18.0)
///
/// 목록을 부르기 전에 국가를 한 번 정하는 용도다. 주소를 만들지 않아 벤더 호출이
/// 1회고 로그인도 필요 없다(DEC-0021).
///
/// [countryCode]를 nullable로 받는 이유: 스키마에 `required`가 없다. non-null로
/// 못 박으면 서버가 값을 빠뜨리는 순간 파싱이 통째로 터지는데, 이 API는 실패해도
/// 기기 로케일로 물러설 수 있는 자리라 그렇게까지 강하게 막을 이유가 없다.
@freezed
class CommunityCountryResponseModel with _$CommunityCountryResponseModel {
  const factory CommunityCountryResponseModel({String? countryCode}) =
      _CommunityCountryResponseModel;

  factory CommunityCountryResponseModel.fromJson(Map<String, dynamic> json) =>
      _$CommunityCountryResponseModelFromJson(json);
}

/// 모임 장소 요청 DTO
///
/// 백엔드 스키마: api-docs.json#Location
///
/// 응답의 [CommunityLocationModel]과 달리 `region`·`countryCode`가 없다 — 서버가
/// 좌표를 역지오코딩해 채우는 값이라 클라이언트가 보내지 않는다. 반면
/// [placeName]은 작성자 입력이라 필수다(빠지면 400).
@freezed
class CommunityLocationRequestModel with _$CommunityLocationRequestModel {
  const factory CommunityLocationRequestModel({
    required double latitude,
    required double longitude,

    /// 만나는 곳 — 최대 50자. 예: `어린이대공원 정문`
    required String placeName,
  }) = _CommunityLocationRequestModel;

  factory CommunityLocationRequestModel.fromJson(Map<String, dynamic> json) =>
      _$CommunityLocationRequestModelFromJson(json);
}

/// 게시글 작성·수정 요청 DTO
///
/// 백엔드 스키마: api-docs.json#CommunityPostCreateRequest ·
/// #CommunityPostUpdateRequest — 두 스키마의 필드가 완전히 같아 하나로 쓴다.
///
/// 수정은 전체 교체(PUT)라 바꾸지 않는 필드도 현재 값을 그대로 다시 실어야 한다.
@freezed
class CommunityPostWriteRequestModel with _$CommunityPostWriteRequestModel {
  const factory CommunityPostWriteRequestModel({
    required String title,
    required String content,

    /// 서버는 timezone suffix가 붙은 ISO 8601을 기대한다. 로컬 DateTime을 그냥
    /// 직렬화하면 suffix가 빠져 서버 로컬 시각으로 읽히므로 UTC로 정규화한다
    /// (`create_session_response.dart`와 같은 판단).
    @JsonKey(toJson: _dateTimeToIso) required DateTime meetingAt,
    required CommunityLocationRequestModel location,
    required int maxParticipants,
  }) = _CommunityPostWriteRequestModel;

  factory CommunityPostWriteRequestModel.fromJson(Map<String, dynamic> json) =>
      _$CommunityPostWriteRequestModelFromJson(json);
}

/// 모집 상태 변경 요청 DTO
///
/// 백엔드 스키마: api-docs.json#CommunityPostStatusRequest
///
/// [status]는 와이어 문자열(`RECRUITING`·`COMPLETED`)이다 — 도메인 enum →
/// 문자열 변환은 `CommunityPostStatusWire.wireValue`가 담당한다.
@freezed
class CommunityPostStatusRequestModel with _$CommunityPostStatusRequestModel {
  const factory CommunityPostStatusRequestModel({required String status}) =
      _CommunityPostStatusRequestModel;

  factory CommunityPostStatusRequestModel.fromJson(Map<String, dynamic> json) =>
      _$CommunityPostStatusRequestModelFromJson(json);
}

/// DateTime → ISO 8601 (UTC `Z` suffix 포함) 직렬화 헬퍼
String _dateTimeToIso(DateTime dt) => dt.toUtc().toIso8601String();
