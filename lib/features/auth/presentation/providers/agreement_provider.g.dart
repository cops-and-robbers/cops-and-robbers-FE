// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'agreement_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$agreementNotifierHash() => r'da209d1ffe60b660911edcea70ba2fb645fab390';

/// 약관 동의 화면 전용 Notifier
///
/// 체크박스 상태 관리 + `PUT /api/user/agreements` 제출을 담당합니다.
/// 제출 성공 시 AuthNotifier의 requiresAgreement를 false로 갱신하는 책임은
/// 호출자(AgreementPage)가 담당합니다 (Provider 간 강결합 회피).
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
