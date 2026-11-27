import 'package:cops_and_robbers/core/services/remote_config/unreleased_version.dart';
import 'package:flutter_test/flutter_test.dart';

// 스토어에 4.1.21이 나가 있고 4.1.22가 심사 중인 상황을 기준으로 한다.
bool _check(String app, {String min = '4.1.21', String latest = '4.1.21'}) =>
    isUnreleasedVersion(
      appVersion: app,
      minimumVersion: min,
      latestVersion: latest,
    );

void main() {
  test('review_build_is_unreleased_when_higher_than_both_store_values', () {
    expect(_check('4.1.22'), isTrue);
  });

  test('store_version_is_released_when_equal_to_store_values', () {
    expect(_check('4.1.21'), isFalse);
  });

  test('old_version_is_released_when_lower_than_store_values', () {
    expect(_check('4.1.20'), isFalse);
  });

  // 출시 후 최소 버전만 올리고 최신 버전 올리기를 잊었다
  test('new_version_is_released_when_only_minimum_was_raised', () {
    expect(_check('4.1.22', min: '4.1.22'), isFalse);
  });

  // 강제 업데이트 없이 최신 버전만 올린 출시
  test('new_version_is_released_when_only_latest_was_raised', () {
    expect(_check('4.1.22', latest: '4.1.22'), isFalse);
  });

  test('compares_numbers_not_text_when_patch_reaches_two_digits', () {
    expect(_check('4.1.10', min: '4.1.9', latest: '4.1.9'), isTrue);
    expect(_check('4.1.9', min: '4.1.10', latest: '4.1.10'), isFalse);
  });

  // 4.2.0이나 5.0.0처럼 앞자리가 오르는 출시
  test('compares_major_and_minor_before_patch_when_they_differ', () {
    expect(_check('4.2.0', min: '4.1.99', latest: '4.1.99'), isTrue);
    expect(_check('4.1.99', min: '4.2.0', latest: '4.2.0'), isFalse);
    expect(_check('5.0.0', min: '4.9.9', latest: '4.9.9'), isTrue);
  });

  // 콘솔에서 값을 잘못 넣었을 때 모든 사용자가 점검을 건너뛰면 안 된다
  test('nobody_is_unreleased_when_a_version_is_unreadable', () {
    expect(_check('4.1.22', latest: ''), isFalse);
    expect(_check('4.1.22', min: '4.1'), isFalse);
    expect(_check('4.1.22-beta'), isFalse);
    // 자릿수가 터무니없이 긴 값은 읽다가 죽지 않고 못 읽은 값으로 본다
    expect(_check('4.1.22', latest: '4.1.99999999999999999999'), isFalse);
  });
}
