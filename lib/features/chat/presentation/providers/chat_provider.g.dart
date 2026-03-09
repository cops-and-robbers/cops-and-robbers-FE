// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$chatStompDatasourceHash() =>
    r'86264d738ae93310d0d14f3470deb7e113e83ae3';

/// ChatStompDatasource Provider (싱글톤)
///
/// Copied from [chatStompDatasource].
@ProviderFor(chatStompDatasource)
final chatStompDatasourceProvider =
    AutoDisposeProvider<ChatStompDatasource>.internal(
      chatStompDatasource,
      name: r'chatStompDatasourceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$chatStompDatasourceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ChatStompDatasourceRef = AutoDisposeProviderRef<ChatStompDatasource>;
String _$chatNotifierHash() => r'785d5afdc6598ee355e6651ea61f4da8b47f9eec';

/// 채팅 상태 관리 Notifier
///
/// STOMP 연결/구독/발행/에러 처리를 관리합니다.
/// GamePage 진입 시 [connectAndSubscribe]를 호출하고,
/// 이탈 시 [disconnectChat]을 호출합니다.
///
/// Copied from [ChatNotifier].
@ProviderFor(ChatNotifier)
final chatNotifierProvider =
    AutoDisposeNotifierProvider<ChatNotifier, ChatState>.internal(
      ChatNotifier.new,
      name: r'chatNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$chatNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ChatNotifier = AutoDisposeNotifier<ChatState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
