// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'agreement_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$agreementNotifierHash() => r'08dc74430481c78c6d2ac9e3b02093468ebf49f4';

/// 약관 동의 화면 전용 Notifier
///
/// 체크박스 상태 관리 + `PUT /api/user/agreements` 제출을 담당합니다.
/// 제출 성공 시 AuthNotifier의 requiresAgreement를 false로 갱신하는 책임은
/// 호출자(AgreementPage)가 담당합니다 (Provider 간 강결합 회피).
///
/// [build] 진입 시 `GET /api/user/agreements`를 호출하여 서버에 저장된
/// 현재 동의 상태로 체크박스를 초기화합니다. 백엔드가 정책 갱신으로 특정
/// 약관만 false로 되돌리는 경우, 이미 동의한 약관은 체크된 상태로 표시되어
/// 사용자가 변경된 약관만 새로 체크하면 되도록 합니다.
///
/// Copied from [AgreementNotifier].
@ProviderFor(AgreementNotifier)
final agreementNotifierProvider =
    AutoDisposeNotifierProvider<AgreementNotifier, AgreementState>.internal(
      AgreementNotifier.new,
      name: r'agreementNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$agreementNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$AgreementNotifier = AutoDisposeNotifier<AgreementState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
