import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../auth/domain/entities/auth_result_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import 'pending_invite_provider.dart';
import 'session_provider.dart';

part 'deeplink_join_notifier.freezed.dart';
part 'deeplink_join_notifier.g.dart';

/// 딥링크 join 흐름의 결과 (라우팅/토스트는 호출자가 결정).
///
/// Notifier 가 BuildContext 나 GoRouter 에 의존하지 않아 단위 테스트가 가능합니다.
@freezed
sealed class DeepLinkJoinOutcome with _$DeepLinkJoinOutcome {
  /// 미로그인 상태 — 로그인 화면으로 이동해야 함
  const factory DeepLinkJoinOutcome.loginRedirect() = LoginRedirectOutcome;

  /// join 성공 — [gameId] 의 대기실로 이동해야 함
  const factory DeepLinkJoinOutcome.joinedRoom({required int gameId}) =
      JoinedRoomOutcome;

  /// 이미 해당 게임에 참가 중 — 해당 게임의 대기실로 이동하거나 안내 토스트 표시
  const factory DeepLinkJoinOutcome.alreadyInRoom() = AlreadyInRoomOutcome;

  /// 처리 불가 에러 — [messageKey] 로 사용자에게 메시지 표시
  const factory DeepLinkJoinOutcome.failure({required String messageKey}) =
      FailureOutcome;
}

/// 딥링크 초대 코드 수신 후 인증 확인 + join API 호출 + 에러 분기.
///
/// BuildContext 의존성이 없으므로 단위 테스트에서 ProviderContainer 만으로 검증 가능합니다.
/// UI 레이어가 [DeepLinkJoinOutcome] 을 받아 라우팅/토스트를 처리합니다.
@riverpod
class DeepLinkJoinNotifier extends _$DeepLinkJoinNotifier {
  @override
  FutureOr<void> build() {}

  /// 딥링크로 수신한 [inviteCode] 를 처리하고 결과를 반환합니다.
  ///
  /// 1. 미로그인 → 코드를 [PendingInvite] 에 저장 후 [LoginRedirectOutcome] 반환
  /// 2. 로그인 → join API 호출 → 성공 시 [JoinedRoomOutcome], 에러 시 분류
  Future<DeepLinkJoinOutcome> handle(String inviteCode) async {
    // 인증 확인 — future 로 await 하여 build() 완료 후 값을 읽음.
    // valueOrNull 은 AsyncNotifier 가 아직 loading 중일 때 null 을 반환하므로
    // 테스트/콜드스타트 타이밍에서 미로그인으로 오판할 수 있음.
    // authNotifierProvider 자체가 throw 하는 경우(Firebase 초기화 실패 등)도
    // Outcome 으로 감싸서 호출자에게 안정적으로 반환한다.
    AuthResultEntity? user;
    try {
      user = await ref.read(authNotifierProvider.future);
    } catch (e) {
      debugPrint('[DeepLinkJoinNotifier] 인증 상태 읽기 실패: $e');
      return const DeepLinkJoinOutcome.failure(
        messageKey: 'errorServerInternal',
      );
    }

    if (user == null) {
      // 로그인 후 join 흐름 재진입을 위해 코드를 영속 저장.
      // 저장 실패 시 LoginRedirect 대신 사용자에게 명시적 안내 — 그래야
      // 사용자가 로그인 후 코드 미적용 상태에서 혼란을 겪지 않는다.
      try {
        await ref.read(pendingInviteProvider.notifier).save(inviteCode);
      } catch (e) {
        debugPrint('[DeepLinkJoinNotifier] 초대 코드 저장 실패: $e');
        return const DeepLinkJoinOutcome.failure(
          messageKey: 'errorPendingInviteSave',
        );
      }
      return const DeepLinkJoinOutcome.loginRedirect();
    }

    // join API 호출. 백엔드가 상황별 에러 응답으로 분기해 줌
    try {
      final result = await ref
          .read(joinGameByInviteUseCaseProvider)
          .execute(inviteCode);
      return DeepLinkJoinOutcome.joinedRoom(gameId: result.gameId);
    } catch (e) {
      return _classifyError(e);
    }
  }

  /// 에러를 [DeepLinkJoinOutcome] 으로 분류합니다.
  ///
  /// [DioExceptionHandler] 가 DioException 을 AppException 으로 변환할 때
  /// message 는 영문 고정값('conflict', 'bad request' 등)이고, 백엔드 한국어 detail 은
  /// code 필드(= RFC 7807 title)에 담깁니다. 따라서 message 한국어 매칭이 아닌
  /// messageKey / code 필드로 분기해야 합니다.
  ///
  /// TODO: 백엔드가 errorCode 필드를 도입하면 한국어 title 매칭을 코드 매칭으로 교체하세요.
  DeepLinkJoinOutcome _classifyError(Object error) {
    // 409 Conflict — join 흐름에서는 "이미 다른 방 참가 중" 의미
    if (error is ServerException) {
      if (error.messageKey == 'errorConflict') {
        return const DeepLinkJoinOutcome.alreadyInRoom();
      }
      return DeepLinkJoinOutcome.failure(
        messageKey: error.messageKey ?? 'errorServerInternal',
      );
    }

    // 400 — 백엔드 title(code 필드)로 인원 초과 vs 일반 검증 실패 분기.
    // DioExceptionHandler 가 400 응답을 ValidationException 으로 변환하며
    // code 필드에 RFC 7807 title('게임 인원 초과' 등)을 그대로 전달합니다.
    if (error is ValidationException) {
      if (error.code == '게임 인원 초과') {
        return const DeepLinkJoinOutcome.failure(messageKey: 'errorGameFull');
      }
      return const DeepLinkJoinOutcome.failure(
        messageKey: 'errorInviteCodeInvalid',
      );
    }

    // 네트워크 오류 (timeout / connection error)
    if (error is NetworkException) {
      return DeepLinkJoinOutcome.failure(
        messageKey: error.messageKey ?? 'errorNetworkOffline',
      );
    }

    // 미분류 에러는 로그 후 서버 오류로 처리
    debugPrint('[DeepLinkJoinNotifier] 미분류 에러: $error');
    return const DeepLinkJoinOutcome.failure(messageKey: 'errorServerInternal');
  }
}
