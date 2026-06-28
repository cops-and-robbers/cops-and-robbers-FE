import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../auth/domain/entities/auth_result_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/user_game_status_entity.dart';
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

  /// join 성공 — [isEventGame]이면 인게임 직행, 아니면 [gameId] 대기실로 이동.
  const factory DeepLinkJoinOutcome.joinedRoom({
    required int gameId,
    required int participantId,
    @Default(false) bool isEventGame,
  }) = JoinedRoomOutcome;

  /// 이미 방에 참가 중 — [participation] 의 활성 게임으로 복귀 + 안내 토스트.
  ///
  /// 백엔드 409 응답은 "참가 중인 게임이 어디인지"를 알려주지 않으므로,
  /// Notifier 가 활성 게임을 별도 조회해 채운다. 조회 실패/미참가 시 null 이며
  /// 호출자(Page)는 홈으로 폴백한다.
  const factory DeepLinkJoinOutcome.alreadyInRoom({
    UserGameParticipationEntity? participation,
  }) = AlreadyInRoomOutcome;

  /// 처리 불가 에러 — [messageKey] 또는 [errorCode] 로 사용자에게 메시지 표시.
  ///
  /// [errorCode] 가 있으면 UI 가 errorByCode 로 직접 변환한다.
  /// [messageKey] 는 네트워크/내부 에러처럼 errorCode 가 없는 경로에 사용한다.
  const factory DeepLinkJoinOutcome.failure({
    String? messageKey,
    String? errorCode,
  }) = FailureOutcome;
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
      return DeepLinkJoinOutcome.joinedRoom(
        gameId: result.gameId,
        participantId: result.participantId,
        isEventGame: result.isEventGame,
      );
    } catch (e) {
      return _classifyError(e);
    }
  }

  /// 409 "이미 방 참가 중"을 현재 활성 게임 복귀 outcome 으로 해소한다.
  ///
  /// 활성 게임 조회 실패/미참가 시 participation 이 null 인 outcome 을 반환하며,
  /// Page 는 이를 홈 폴백으로 처리한다.
  Future<DeepLinkJoinOutcome> _resolveAlreadyInRoom() async {
    try {
      final status = await ref.read(getMyActiveGameUsecaseProvider).execute();
      final info = status.participationInfo;
      if (status.isParticipating && info != null) {
        return DeepLinkJoinOutcome.alreadyInRoom(participation: info);
      }
    } catch (e) {
      debugPrint('[DeepLinkJoinNotifier] 활성 게임 조회 실패: $e');
    }
    return const DeepLinkJoinOutcome.alreadyInRoom();
  }

  /// 에러를 [DeepLinkJoinOutcome] 으로 분류합니다.
  ///
  /// [DioExceptionHandler] 가 DioException 을 AppException 으로 변환할 때
  /// message 는 영문 고정값('conflict', 'bad request' 등)이고,
  /// code 필드에 백엔드 errorCode 가 담깁니다.
  /// ValidationException 은 errorCode 를 [FailureOutcome.errorCode] 로 전달하고
  /// UI 가 errorByCode 로 사용자 메시지를 결정합니다.
  Future<DeepLinkJoinOutcome> _classifyError(Object error) async {
    // 409 Conflict — join 흐름에서는 "이미 다른 방 참가 중" 의미.
    // DioExceptionHandler 가 409 를 ServerException(messageKey: 'errorTemporaryRetry',
    // code: 백엔드 errorCode) 으로 변환하므로, messageKey 가 아니라 errorCode 로 판별한다.
    if (error is ServerException) {
      if (error.code == 'ALREADY_PARTICIPATING') {
        return _resolveAlreadyInRoom();
      }
      if (error.code != null) {
        return DeepLinkJoinOutcome.failure(errorCode: error.code);
      }
      return DeepLinkJoinOutcome.failure(
        messageKey: error.messageKey ?? 'errorServerInternal',
      );
    }

    // 400 — 백엔드 errorCode를 그대로 UI 로 전달, UI 가 errorByCode 로 변환한다.
    // errorCode 가 없는 드문 경우(파싱 실패 등)는 INVALID_INVITE_CODE 로 폴백.
    if (error is ValidationException) {
      return DeepLinkJoinOutcome.failure(
        errorCode: error.code ?? 'INVALID_INVITE_CODE',
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
