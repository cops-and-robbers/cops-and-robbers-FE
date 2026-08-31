// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'community_chat_socket_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$communityChatSocketHash() =>
    r'33e9b23dd0195fea93811eacb98fac7de99fd436';

/// 커뮤니티 소켓의 수명 — 로그인~로그아웃
///
/// 방 화면이 아니라 여기가 소켓을 연다. 유저당 알림 채널(DEC-0045)은 목록 화면에
/// 있든 다른 탭에 있든 계속 받아야 하기 때문이다. 재연결 정책(1·2·4·8·10초, 5회,
/// 인증 에러면 REST 한 번으로 토큰 갱신)은 방 Notifier에서 그대로 옮겨 왔다 —
/// 방이 안 열려 있을 때도 재연결할 주체가 있어야 한다.
///
/// 메시지·연결 상태·에러는 [events]로 그대로 흘려보낸다. 방 Notifier는 제 방 것만,
/// 목록 Notifier는 전부 받는다.
///
/// Copied from [CommunityChatSocket].
@ProviderFor(CommunityChatSocket)
final communityChatSocketProvider =
    NotifierProvider<CommunityChatSocket, CommunityChatSocketState>.internal(
      CommunityChatSocket.new,
      name: r'communityChatSocketProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$communityChatSocketHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$CommunityChatSocket = Notifier<CommunityChatSocketState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
