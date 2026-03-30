import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../auth/presentation/providers/token_provider.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../data/datasources/chat_stomp_datasource.dart';
import '../../../../core/constants/chat_constants.dart';
import '../../data/models/chat_message_dto.dart';

export '../../data/datasources/chat_stomp_datasource.dart'
    show StompConnectionState;

part 'chat_provider.g.dart';

/// copyWith에서 "값을 전달하지 않음"과 "명시적 null"을 구분하기 위한 sentinel 객체
const _sentinel = Object();

/// ChatStompDatasource Provider (싱글톤)
@riverpod
ChatStompDatasource chatStompDatasource(Ref ref) {
  final datasource = ChatStompDatasource();
  ref.onDispose(() => datasource.dispose());
  return datasource;
}

/// 채팅 상태
class ChatState {
  /// scope == 'ALL' 메시지만 저장
  final List<ChatMessageDto> allScopeMessages;

  /// scope == 'TEAM' 메시지만 저장
  final List<ChatMessageDto> teamScopeMessages;

  final StompConnectionState connectionState;
  final String? errorMessage;
  final Set<int> blockedParticipantIds;

  /// 전체 채팅 읽지 않은 메시지 수
  final int unreadAllCount;

  /// 팀 채팅 읽지 않은 메시지 수
  final int unreadTeamCount;

  /// 프리뷰 카드에 표시할 최신 메시지 (null이면 프리뷰 숨김)
  final ChatMessageDto? lastPreviewMessage;

  const ChatState({
    this.allScopeMessages = const [],
    this.teamScopeMessages = const [],
    this.connectionState = StompConnectionState.disconnected,
    this.errorMessage,
    this.blockedParticipantIds = const {},
    this.unreadAllCount = 0,
    this.unreadTeamCount = 0,
    this.lastPreviewMessage,
  });

  ChatState copyWith({
    List<ChatMessageDto>? allScopeMessages,
    List<ChatMessageDto>? teamScopeMessages,
    StompConnectionState? connectionState,
    Object? errorMessage = _sentinel,
    Set<int>? blockedParticipantIds,
    int? unreadAllCount,
    int? unreadTeamCount,
    Object? lastPreviewMessage = _sentinel,
  }) {
    return ChatState(
      allScopeMessages: allScopeMessages ?? this.allScopeMessages,
      teamScopeMessages: teamScopeMessages ?? this.teamScopeMessages,
      connectionState: connectionState ?? this.connectionState,
      errorMessage: errorMessage == _sentinel
          ? this.errorMessage
          : errorMessage as String?,
      blockedParticipantIds:
          blockedParticipantIds ?? this.blockedParticipantIds,
      unreadAllCount: unreadAllCount ?? this.unreadAllCount,
      unreadTeamCount: unreadTeamCount ?? this.unreadTeamCount,
      lastPreviewMessage: lastPreviewMessage == _sentinel
          ? this.lastPreviewMessage
          : lastPreviewMessage as ChatMessageDto?,
    );
  }
}

/// 채팅 상태 관리 Notifier
///
/// STOMP 연결/구독/발행/에러 처리를 관리합니다.
/// GamePage 진입 시 [connectAndSubscribe]를 호출하고,
/// 이탈 시 [disconnectChat]을 호출합니다.
@riverpod
class ChatNotifier extends _$ChatNotifier {
  StreamSubscription<ChatMessageDto>? _messageSub;
  StreamSubscription<StompConnectionState>? _connectionSub;
  StreamSubscription<StompErrorInfo>? _errorSub;

  /// 401 에러 재연결 시도 횟수 (무한 루프 방지)
  int _authRetryCount = 0;
  static const _maxAuthRetries = 1;

  /// 네트워크 재연결 시도 횟수
  int _reconnectCount = 0;
  static const _maxReconnectRetries = 5;

  /// 재연결 타이머 (단일 타이머 보장)
  Timer? _reconnectTimer;

  /// 의도적 연결 해제 여부
  bool _intentionalDisconnect = false;

  /// STOMP 에러 처리 중 여부 (일반 재연결 방지용)
  bool _isHandlingError = false;

  /// 현재 게임/팀 정보 (재연결용)
  int? _gameId;
  String? _team;

  /// UI 가시성 상태 (ChatOverlay가 통보)
  bool _isSheetExpanded = false;
  int _currentVisiblePage = 0; // 0 = ALL, 1 = TEAM
  /// null이면 아직 초기화되지 않은 상태 (프리뷰 필터링 비활성)
  int? _myParticipantId;

  /// 더미 모드 여부
  bool _isDummyMode = false;

  /// 더미 모드 자동응답 타이머
  Timer? _dummyReplyTimer;

  /// 메시지 리스트 최대 크기
  static const _maxMessages = 200;

  @override
  ChatState build() {
    // datasource provider를 watch하여 Notifier 생존 기간 동안 유지
    ref.watch(chatStompDatasourceProvider);

    ref.onDispose(() {
      _messageSub?.cancel();
      _connectionSub?.cancel();
      _errorSub?.cancel();
      _reconnectTimer?.cancel();
      _dummyReplyTimer?.cancel();
    });
    return const ChatState();
  }

  /// STOMP 연결 후 전체/팀 채팅 구독
  ///
  /// [gameId] 게임 ID
  /// [team] 본인 팀 ("police" 또는 "robber", 소문자)
  Future<void> connectAndSubscribe({
    required int gameId,
    required String team,
  }) async {
    final datasource = ref.read(chatStompDatasourceProvider);

    // 이미 연결 중이거나 연결된 상태면 무시
    if (datasource.currentState == StompConnectionState.connecting ||
        datasource.currentState == StompConnectionState.connected) {
      return;
    }

    // 재연결 상태 초기화
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _gameId = gameId;
    _team = team;
    _intentionalDisconnect = false;
    _isHandlingError = false;
    _reconnectCount = 0;
    _authRetryCount = 0;

    // Access Token 획득
    // TODO: 서버 로그인 연동 후 TokenProvider 구현체가 서버 JWT를 반환하도록 변경 예정.
    // 현재는 Firebase ID Token을 사용.
    final tokenProvider = ref.read(tokenProviderProvider);
    final accessToken = await tokenProvider.getAccessToken();
    if (accessToken == null) {
      debugPrint('[ChatNotifier] ❌ 토큰 획득 실패');
      state = state.copyWith(
        connectionState: StompConnectionState.error,
        errorMessage: '인증 토큰을 가져올 수 없습니다. 재로그인이 필요합니다.',
      );
      return;
    }

    // 스트림 구독 설정
    _setupStreams();

    // 구독 예약 (connected 시 자동 구독)
    datasource.subscribeChat(gameId, team);

    // STOMP 연결
    final wsUrl = ApiEndpoints.gameConnectionUrl;
    debugPrint('[ChatNotifier] 🔗 STOMP 연결 시도: $wsUrl');
    debugPrint('[ChatNotifier] 📍 gameId: $gameId, team: $team');
    debugPrint('[ChatNotifier] 🔑 token length: ${accessToken.length}');
    datasource.connect(wsUrl, accessToken);
  }

  /// 채팅 연결 해제
  void disconnectChat() {
    _intentionalDisconnect = true;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;

    _messageSub?.cancel();
    _connectionSub?.cancel();
    _errorSub?.cancel();
    _messageSub = null;
    _connectionSub = null;
    _errorSub = null;
    _authRetryCount = 0;
    _reconnectCount = 0;
    _isHandlingError = false;
    _gameId = null;
    _team = null;

    final datasource = ref.read(chatStompDatasourceProvider);
    datasource.disconnect();

    _isSheetExpanded = false;
    _currentVisiblePage = 0;
    _myParticipantId = null;
    state = const ChatState();
  }

  /// 채팅 메시지 전송
  ///
  /// [gameId] 게임 ID
  /// [message] 메시지 내용
  /// [scope] "TEAM" 또는 "ALL"
  void sendMessage({
    required int gameId,
    required String message,
    required String scope,
  }) {
    if (message.trim().isEmpty) return;

    // 더미 모드: 로컬에서 메시지 추가
    if (_isDummyMode) {
      _addDummyMessage(
        message: message.trim(),
        scope: scope,
        participantId: _dummyMyPid,
        nickname: '나',
        team: _team?.toUpperCase() ?? ChatTeam.police,
      );
      // 상대방 자동 응답 (1초 후)
      _dummyReplyTimer?.cancel();
      _dummyReplyTimer = Timer(const Duration(seconds: 1), () {
        if (_isDummyMode) {
          _addDummyMessage(
            message: '${scope == ChatScope.team ? '[팀] ' : ''}응답 테스트 메시지!',
            scope: scope,
            participantId: 999,
            nickname: scope == ChatScope.team ? '팀원닉네임' : '상대닉네임',
            team: scope == ChatScope.team
                ? (_team?.toUpperCase() ?? ChatTeam.police)
                : ChatTeam.robber,
          );
        }
      });
      return;
    }

    final datasource = ref.read(chatStompDatasourceProvider);
    datasource.publishChat(gameId, message.trim(), scope);
  }

  /// 게임 이벤트 기반 시스템 메시지를 전체 채팅에 추가합니다.
  void addSystemMessage({required int gameId, required String message}) {
    final msg = ChatMessageDto(
      id: const Uuid().v4(),
      gameId: gameId,
      sender: const ChatSenderDto(
        participantId: 0,
        nickname: '시스템',
        team: ChatTeam.system,
      ),
      message: message,
      timestamp: DateTime.now().toIso8601String(),
      scope: ChatScope.all,
    );
    final updated = [...state.allScopeMessages, msg];
    final trimmed = updated.length > _maxMessages
        ? updated.sublist(updated.length - _maxMessages)
        : updated;
    // 공지는 unread 카운트에 포함하지 않고 프리뷰만 표시
    state = state.copyWith(allScopeMessages: trimmed, lastPreviewMessage: msg);
  }

  /// 유저 차단 (현재 게임 세션 동안만 유지)
  ///
  /// 차단된 유저의 메시지는 ChatMessageList에서 필터링됩니다.
  void blockUser(int participantId) {
    state = state.copyWith(
      blockedParticipantIds: {...state.blockedParticipantIds, participantId},
    );
  }

  /// ChatOverlay가 시트 펼침/접힘 상태 변경 시 호출
  void updateSheetExpanded(bool expanded) {
    _isSheetExpanded = expanded;
    if (expanded) {
      _markCurrentPageAsRead();
    }
  }

  /// ChatOverlay가 탭 스와이프 시 호출
  void updateCurrentPage(int page) {
    _currentVisiblePage = page;
    if (_isSheetExpanded) {
      _markCurrentPageAsRead();
    }
  }

  /// 본인 participantId 설정 (프리뷰 필터링용)
  void setMyParticipantId(int pid) {
    _myParticipantId = pid;
  }

  /// 프리뷰 카드 탭 시 호출
  void onPreviewTapped() {
    final msg = state.lastPreviewMessage;
    if (msg == null) return;

    if (msg.scope == ChatScope.team) {
      state = state.copyWith(unreadTeamCount: 0, lastPreviewMessage: null);
    } else {
      state = state.copyWith(unreadAllCount: 0, lastPreviewMessage: null);
    }
  }

  /// 프리뷰 카드 자동 퇴장 완료 시 호출
  void dismissPreview() {
    state = state.copyWith(lastPreviewMessage: null);
  }

  /// 현재 보고 있는 페이지의 읽지 않은 카운트를 0으로 초기화
  void _markCurrentPageAsRead() {
    if (_currentVisiblePage == 0) {
      if (state.unreadAllCount > 0) {
        state = state.copyWith(unreadAllCount: 0);
      }
    } else {
      if (state.unreadTeamCount > 0) {
        state = state.copyWith(unreadTeamCount: 0);
      }
    }
  }

  // ============================================
  // 더미 모드 (서버 미연동 시 UI 테스트용)
  // ============================================

  int _dummyMyPid = 0;

  /// 더미 모드 활성화 (서버 연결 없이 채팅 UI 테스트)
  void enableDummyMode({required int participantId, required String team}) {
    _isDummyMode = true;
    _dummyMyPid = participantId;
    _team = team.toLowerCase();
    _gameId = 1;

    state = state.copyWith(connectionState: StompConnectionState.connected);

    // 초기 더미 메시지
    _addDummyMessage(
      message: '제한 시간은 30분입니다.',
      scope: ChatScope.all,
      participantId: 0,
      nickname: '시스템',
      team: ChatTeam.system,
    );
    _addDummyMessage(
      message: '게임이 곧 시작됩니다. 모든 플레이어는 준비하세요!',
      scope: ChatScope.all,
      participantId: 0,
      nickname: '시스템',
      team: ChatTeam.system,
    );
    _addDummyMessage(
      message: '도둑 잘 도망쳐 봐요~',
      scope: ChatScope.all,
      participantId: 10,
      nickname: '닉네임',
      team: ChatTeam.police,
    );
    _addDummyMessage(
      message: '이겨봅시다!',
      scope: ChatScope.team,
      participantId: 11,
      nickname: '닉네임',
      team: team.toUpperCase(),
    );
  }

  void _addDummyMessage({
    required String message,
    required String scope,
    required int participantId,
    required String nickname,
    required String team,
  }) {
    final msg = ChatMessageDto(
      id: const Uuid().v4(),
      gameId: _gameId ?? 1,
      sender: ChatSenderDto(
        participantId: participantId,
        nickname: nickname,
        team: team,
      ),
      message: message,
      timestamp: DateTime.now().toIso8601String(),
      scope: scope,
    );

    if (scope == ChatScope.team) {
      final updated = [...state.teamScopeMessages, msg];
      final trimmed = updated.length > _maxMessages
          ? updated.sublist(updated.length - _maxMessages)
          : updated;
      state = state.copyWith(teamScopeMessages: trimmed);
    } else {
      final updated = [...state.allScopeMessages, msg];
      final trimmed = updated.length > _maxMessages
          ? updated.sublist(updated.length - _maxMessages)
          : updated;
      state = state.copyWith(allScopeMessages: trimmed);
    }
    _handleUnreadUpdate(msg);
  }

  // ============================================
  // 내부 메서드
  // ============================================

  void _setupStreams() {
    final datasource = ref.read(chatStompDatasourceProvider);

    // 기존 구독 정리
    _messageSub?.cancel();
    _connectionSub?.cancel();
    _errorSub?.cancel();

    // 연결 상태 구독
    _connectionSub = datasource.onConnectionState.listen((connState) {
      state = state.copyWith(connectionState: connState);

      if (connState == StompConnectionState.connected) {
        // 연결 성공 → 상태 초기화 (구독은 onConnected()에서 자동 처리)
        _authRetryCount = 0;
        _reconnectCount = 0;
        _isHandlingError = false;
        _reconnectTimer?.cancel();
        _reconnectTimer = null;
        state = state.copyWith(errorMessage: null);
      } else if (connState == StompConnectionState.disconnected) {
        // 예기치 않은 연결 종료 → 재연결 시도
        if (!_intentionalDisconnect && !_isHandlingError) {
          _scheduleReconnect();
        }
      }
    });

    // 메시지 수신 구독 (scope별로 분류하여 최대 _maxMessages개 유지)
    _messageSub = datasource.onMessage.listen((message) {
      if (message.scope == ChatScope.team) {
        final updated = [...state.teamScopeMessages, message];
        final trimmed = updated.length > _maxMessages
            ? updated.sublist(updated.length - _maxMessages)
            : updated;
        state = state.copyWith(teamScopeMessages: trimmed);
      } else {
        final updated = [...state.allScopeMessages, message];
        final trimmed = updated.length > _maxMessages
            ? updated.sublist(updated.length - _maxMessages)
            : updated;
        state = state.copyWith(allScopeMessages: trimmed);
      }
      _handleUnreadUpdate(message);
    });

    // STOMP 에러 구독
    _errorSub = datasource.onError.listen((errorInfo) {
      // STOMP 에러 수신 → 일반 재연결 방지 (에러 핸들러가 제어권 가짐)
      _isHandlingError = true;
      _handleStompError(errorInfo);
    });
  }

  /// 새 메시지 수신 시 읽지 않은 카운트 증가 + 프리뷰 메시지 설정
  void _handleUnreadUpdate(ChatMessageDto message) {
    // 내가 보낸 메시지는 무시 (participantId 미설정 시 필터링 안 함)
    final myPid = _myParticipantId;
    if (myPid != null && message.sender.participantId == myPid) return;

    // 차단된 사용자 메시지는 무시
    if (state.blockedParticipantIds.contains(message.sender.participantId)) {
      return;
    }

    final isTeamMessage = message.scope == ChatScope.team;
    final isCurrentlyViewing =
        _isSheetExpanded &&
        (isTeamMessage ? _currentVisiblePage == 1 : _currentVisiblePage == 0);

    // 현재 보고 있는 탭이면 읽음 처리 (카운트 증가 안 함)
    if (isCurrentlyViewing) return;

    // 카운트 증가
    if (isTeamMessage) {
      state = state.copyWith(
        unreadTeamCount: state.unreadTeamCount + 1,
        lastPreviewMessage: message,
      );
    } else {
      // 전체 채팅: 현재 팀 프리뷰가 표시 중이면 전체 채팅 프리뷰로 교체하지 않음
      final currentPreview = state.lastPreviewMessage;
      final shouldUpdatePreview =
          currentPreview == null || currentPreview.scope != ChatScope.team;
      state = state.copyWith(
        unreadAllCount: state.unreadAllCount + 1,
        lastPreviewMessage: shouldUpdatePreview ? message : currentPreview,
      );
    }
  }

  // ============================================
  // 재연결 정책 (B안: Notifier 단일 관리)
  // ============================================

  /// 지수 백오프 재연결 스케줄링
  ///
  /// 1s → 2s → 4s → 8s → 10s(최대), 최대 [_maxReconnectRetries]회
  void _scheduleReconnect() {
    if (_intentionalDisconnect || _gameId == null || _team == null) return;

    _reconnectCount++;
    if (_reconnectCount > _maxReconnectRetries) {
      debugPrint('[ChatNotifier] ❌ 최대 재연결 횟수 초과 ($_maxReconnectRetries)');
      state = state.copyWith(
        connectionState: StompConnectionState.error,
        errorMessage: '서버에 연결할 수 없습니다. 잠시 후 다시 시도해주세요.',
      );
      return;
    }

    final delaySeconds = _calculateBackoffDelay(_reconnectCount);
    debugPrint(
      '[ChatNotifier] 🔄 재연결 예약: $delaySeconds초 후 '
      '($_reconnectCount/$_maxReconnectRetries)',
    );

    // 기존 타이머 취소 (중복 타이머 방지)
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(Duration(seconds: delaySeconds), _attemptReconnect);
  }

  /// 지수 백오프 딜레이 계산: 1, 2, 4, 8, 10(최대)초
  int _calculateBackoffDelay(int attempt) {
    final delay = 1 << (attempt - 1); // 2^(attempt-1)
    return delay.clamp(1, 10);
  }

  /// 재연결 시도
  Future<void> _attemptReconnect() async {
    if (_intentionalDisconnect || _gameId == null || _team == null) return;

    final datasource = ref.read(chatStompDatasourceProvider);

    // 이미 연결 중이거나 연결된 상태면 무시
    if (datasource.currentState == StompConnectionState.connecting ||
        datasource.currentState == StompConnectionState.connected) {
      return;
    }

    debugPrint(
      '[ChatNotifier] 🔄 재연결 시도 ($_reconnectCount/$_maxReconnectRetries)',
    );

    final tokenProvider = ref.read(tokenProviderProvider);
    final accessToken = await tokenProvider.getAccessToken();

    if (_intentionalDisconnect || _gameId == null || _team == null) return;

    if (accessToken == null) {
      debugPrint('[ChatNotifier] ❌ 재연결 토큰 획득 실패');
      // 토큰 획득 실패 → 다음 백오프 딜레이로 재시도
      _scheduleReconnect();
      return;
    }

    datasource.subscribeChat(_gameId!, _team!);
    final wsUrl = ApiEndpoints.gameConnectionUrl;
    datasource.connect(wsUrl, accessToken);
  }

  // ============================================
  // STOMP 에러 처리
  // ============================================

  Future<void> _handleStompError(StompErrorInfo errorInfo) async {
    if (errorInfo.isAuthExpired) {
      _authRetryCount++;

      // 무한 재연결 루프 방지
      if (_authRetryCount > _maxAuthRetries) {
        debugPrint('[ChatNotifier] ❌ 인증 만료 - 최대 재시도 횟수 초과 ($_maxAuthRetries)');
        state = state.copyWith(
          connectionState: StompConnectionState.error,
          errorMessage: '인증이 만료되었습니다. 재로그인이 필요합니다.',
        );
        return;
      }

      debugPrint(
        '[ChatNotifier] 🔄 인증 만료 - 토큰 갱신 시도 '
        '($_authRetryCount/$_maxAuthRetries)',
      );

      // TODO:
      // 서버 JWT 도입 시 refreshAccessTokenIfNeeded()가 refresh API를 호출.
      // 현재는 Firebase의 forceRefresh를 사용.
      final tokenProvider = ref.read(tokenProviderProvider);
      // await 전에 datasource 캡처 (await 후 ref 접근 방지)
      final datasource = ref.read(chatStompDatasourceProvider);
      final newToken = await tokenProvider.refreshAccessTokenIfNeeded();

      if (_intentionalDisconnect || _gameId == null || _team == null) return;

      if (newToken == null) {
        debugPrint('[ChatNotifier] ❌ 토큰 갱신 실패 - 재로그인 필요');
        state = state.copyWith(
          connectionState: StompConnectionState.error,
          errorMessage: '인증이 만료되었습니다. 재로그인이 필요합니다.',
        );
        return;
      }

      // 재연결 (스트림 재설정 불필요 - broadcast StreamController 유지)
      // 재연결 시작 후 이 연결이 실패하면 일반 재연결 정책이 이어받을 수 있도록 플래그 해제
      debugPrint('[ChatNotifier] ✅ 토큰 갱신 성공 - 재연결 시도');
      datasource.subscribeChat(_gameId!, _team!);
      final wsUrl = ApiEndpoints.gameConnectionUrl;
      datasource.connect(wsUrl, newToken);
      _isHandlingError = false;
    } else {
      // 비-401 STOMP 에러: 에러 메시지 표시
      state = state.copyWith(
        connectionState: StompConnectionState.error,
        errorMessage: errorInfo.detail.isNotEmpty
            ? errorInfo.detail
            : 'STOMP 에러가 발생했습니다.',
      );
      _isHandlingError = false; // 비-인증 에러: WebSocket 종료 후 재연결 허용
    }
  }
}
