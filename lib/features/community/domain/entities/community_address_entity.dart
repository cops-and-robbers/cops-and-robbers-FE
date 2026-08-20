import 'package:freezed_annotation/freezed_annotation.dart';

part 'community_address_entity.freezed.dart';

/// 좌표를 찍었을 때 서버가 돌려주는 주소 도메인 엔티티
///
/// 저장되는 값이 아니다 — 작성 화면에서 "여기가 맞나"를 사용자에게 확인시키는
/// 용도로만 쓰고, 글에 실제로 저장되는 건 서버가 다시 계산하는 [region]이다.
/// [address]는 번지까지 붙어 확인에 쓰이고 전송하지 않는다.
@freezed
class CommunityAddressEntity with _$CommunityAddressEntity {
  const factory CommunityAddressEntity({
    /// 동 단위 지역 — `서울특별시 광진구 화양동`. 글에 저장될 값과 같다.
    String? region,

    /// 번지까지 포함한 주소 — `서울특별시 광진구 화양동 1-20`. 확인용.
    String? address,

    /// 국가 코드(ISO 3166-1 alpha-2). 목록 조회 필터에 그대로 쓸 수 있다.
    String? countryCode,
  }) = _CommunityAddressEntity;
}
