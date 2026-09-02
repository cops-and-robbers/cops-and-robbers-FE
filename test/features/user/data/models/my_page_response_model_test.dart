import 'package:cops_and_robbers/features/user/data/models/my_page_response_model.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _json() => {
  'userId': 1,
  'nickname': '홍길동',
  'socialPlatform': 'GOOGLE',
  'allowGamePush': true,
  'allowMarketingPush': false,
  'profileIcon': 3,
};

void main() {
  group('MyPageResponseModel', () {
    test('allowCommunityPush를 읽는다', () {
      final model = MyPageResponseModel.fromJson(
        _json()..['allowCommunityPush'] = false,
      );

      expect(model.allowCommunityPush, isFalse);
    });

    // 가입 기본값이 수신 동의(true)다. 계약상 필수가 아니라 키가 빠져도
    // 닉네임 조회까지 같이 죽지 않아야 한다(profileIcon과 같은 이유).
    test('allowCommunityPush 키가 없으면 true다', () {
      final model = MyPageResponseModel.fromJson(_json());

      expect(model.allowCommunityPush, isTrue);
    });
  });
}
