import 'package:freezed_annotation/freezed_annotation.dart';

part 'game_push_agreement_model.freezed.dart';
part 'game_push_agreement_model.g.dart';

/// 게임 푸시 알림 동의 조회 응답 DTO
///
/// `GET /api/user/agreements/game-push` 응답.
@freezed
class GamePushAgreementResponseModel with _$GamePushAgreementResponseModel {
  const factory GamePushAgreementResponseModel({required bool allowGamePush}) =
      _GamePushAgreementResponseModel;

  factory GamePushAgreementResponseModel.fromJson(Map<String, dynamic> json) =>
      _$GamePushAgreementResponseModelFromJson(json);
}

/// 게임 푸시 알림 동의 업데이트 요청 DTO
///
/// `PUT /api/user/agreements/game-push` 요청 바디.
@freezed
class GamePushAgreementRequestModel with _$GamePushAgreementRequestModel {
  const factory GamePushAgreementRequestModel({required bool allowGamePush}) =
      _GamePushAgreementRequestModel;

  factory GamePushAgreementRequestModel.fromJson(Map<String, dynamic> json) =>
      _$GamePushAgreementRequestModelFromJson(json);
}
