import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'radio_token_model.freezed.dart';
part 'radio_token_model.g.dart';

/// 무전 서버 접속 토큰 응답 (`POST /api/games/{gameId}/radio/token`)
///
/// [url]은 앱에 박지 않고 이 값을 쓴다 — 음성 서버를 옮겨도 앱 수정이 없게 (DEC-0115).
/// [identity]는 유저 ID가 아니라 참가자 ID다.
@freezed
class RadioTokenModel with _$RadioTokenModel {
  const RadioTokenModel._();

  const factory RadioTokenModel({
    required String url,
    required String room,
    required String identity,
    required String token,
    required String expiresAt,
  }) = _RadioTokenModel;

  factory RadioTokenModel.fromJson(Map<String, dynamic> json) =>
      _$RadioTokenModelFromJson(json);

  /// 토큰 수명 = `exp - iat`.
  ///
  /// [expiresAt]을 폰 시계와 비교하면 시계가 틀어진 기기에서 갱신 시점이 어긋나서,
  /// 서버가 정한 수명만 꺼내 응답 받은 시각에 더한다.
  Duration get lifetime {
    final payload = token.split('.')[1];
    final json =
        jsonDecode(utf8.decode(base64Url.decode(base64Url.normalize(payload))))
            as Map<String, dynamic>;
    return Duration(seconds: (json['exp'] as int) - (json['iat'] as int));
  }
}
