import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'lifecycle_log.dart';

/// 앱 생명주기 상태를 감지하고 관리하는 서비스
///
/// WidgetsBindingObserver를 사용하여 앱의 생명주기 상태를
/// 실시간으로 추적하며, 다음 5가지 상태를 감지합니다:
/// - resumed: 포그라운드 (화면에 보임)
/// - inactive: 전환 중 (잠깐)
/// - hidden: 숨김 상태 (백그라운드 전환)
/// - paused: 백그라운드 진입
/// - detached: 앱 종료 직전
///
/// **싱글톤 패턴**: 앱 전체에서 하나의 인스턴스만 사용합니다.
/// **StreamController 재생성**: close 후 재진입 시 자동으로 새 StreamController 생성
///
/// 사용 예시:
/// ```dart
/// final service = AppLifecycleService.instance();
/// service.activate(); // 감지 시작
///
/// service.stateStream.listen((state) {
///   if (state == AppLifecycleState.paused) {
///     // 백그라운드 진입 시 처리
///   }
/// });
///
/// service.deactivate(); // 감지 중지
/// ```
///
/// **빠른 페이지 전환 대응**: StreamController가 닫힌 상태에서 재진입하면
/// 자동으로 새 StreamController를 생성하여 정상 동작합니다.
class AppLifecycleService with WidgetsBindingObserver {
  /// 싱글톤 인스턴스
  static AppLifecycleService? _instance;

  /// 현재 상태 StreamController
  ///
  /// nullable로 선언하여 close 후 재생성 가능
  StreamController<AppLifecycleState>? _stateController;

  /// 상태 변화 이력 (최근 50개)
  final List<LifecycleLog> _logs = [];

  /// 최대 로그 개수
  static const int _maxLogs = 50;

  /// 생명주기 감지 활성화 여부
  bool _isActive = false;

  /// 현재 생명주기 상태
  AppLifecycleState? _currentState;

  /// iOS keep-alive 타이머
  ///
  /// 백그라운드에서 도둑이 가만히 있어 위치 콜백이 끊기는 케이스 방어.
  /// 30초마다 getCurrentPosition을 강제로 호출해 OS가 앱을 suspend 못 하게 함.
  Timer? _keepAliveTimer;

  /// keep-alive 활성화 여부 (BackgroundService 동작 중일 때만 true)
  bool _keepAliveEnabled = false;

  /// keep-alive 인터벌 (30초)
  static const Duration _keepAliveInterval = Duration(seconds: 30);

  /// 현재 백그라운드 상태인지 (paused 또는 hidden)
  bool get isInBackground =>
      _currentState == AppLifecycleState.paused ||
      _currentState == AppLifecycleState.hidden;

  /// keep-alive 활성화 (게임 시작 시 호출)
  ///
  /// 이 시점에 paused 상태면 즉시 타이머 시작.
  ///
  /// WidgetsBindingObserver를 자동으로 등록(activate)한다.
  /// observer 없이는 didChangeAppLifecycleState가 발화되지 않아
  /// isInBackground가 항상 false → keep-alive 타이머/백그라운드 알림/STOMP 백오프
  /// 모두 작동 안 함. 따라서 keep-alive 사용 = observer 필요로 묶어서 처리.
  void enableKeepAlive() {
    if (!_isActive) {
      activate();
    }
    _keepAliveEnabled = true;
    debugPrint('✅ AppLifecycleService: keep-alive 활성화');
    if (isInBackground) {
      _startKeepAliveTimer();
    }
  }

  /// keep-alive 비활성화 (게임 종료 시 호출)
  void disableKeepAlive() {
    _keepAliveEnabled = false;
    _stopKeepAliveTimer();
    debugPrint('✅ AppLifecycleService: keep-alive 비활성화');
  }

  void _startKeepAliveTimer() {
    if (_keepAliveTimer != null) return;
    debugPrint('🔄 AppLifecycleService: keep-alive 타이머 시작 (30초 주기)');
    _keepAliveTimer = Timer.periodic(_keepAliveInterval, (_) {
      // 결과는 사용하지 않음. OS가 위치 콜백을 발생시키도록 트리거하는 게 목적.
      _triggerKeepAlivePosition();
    });
  }

  /// keep-alive용 위치 조회 — 성공/실패 무관하게 OS suspend만 방지
  Future<void> _triggerKeepAlivePosition() async {
    try {
      await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
        ),
      );
    } catch (e) {
      debugPrint('[keep-alive] 위치 조회 실패: $e');
    }
  }

  void _stopKeepAliveTimer() {
    if (_keepAliveTimer == null) return;
    _keepAliveTimer!.cancel();
    _keepAliveTimer = null;
    debugPrint('🔚 AppLifecycleService: keep-alive 타이머 종료');
  }

  /// Private 생성자
  AppLifecycleService._();

  /// 싱글톤 인스턴스 반환
  ///
  /// 앱 전체에서 하나의 인스턴스만 사용합니다.
  static AppLifecycleService instance() {
    _instance ??= AppLifecycleService._();
    return _instance!;
  }

  /// 생명주기 상태 Stream
  ///
  /// 상태가 변경될 때마다 새로운 값을 방출합니다.
  /// StreamController가 닫혔거나 null이면 자동으로 재생성합니다.
  Stream<AppLifecycleState> get stateStream {
    // StreamController가 null이거나 닫혔으면 새로 생성
    if (_stateController == null || _stateController!.isClosed) {
      _stateController = StreamController<AppLifecycleState>.broadcast();
      debugPrint('🔄 AppLifecycleService: StreamController 재생성');
    }
    return _stateController!.stream;
  }

  /// 상태 변화 이력 (읽기 전용)
  ///
  /// 최근 50개의 상태 변화 기록을 반환합니다.
  List<LifecycleLog> get logs => List.unmodifiable(_logs);

  /// 현재 생명주기 상태
  ///
  /// 아직 상태 변화가 없으면 null을 반환합니다.
  AppLifecycleState? get currentState => _currentState;

  /// 생명주기 감지 활성화 여부
  bool get isActive => _isActive;

  /// 생명주기 감지 시작
  ///
  /// WidgetsBinding에 Observer를 등록하여 생명주기 상태 변화를 감지합니다.
  /// 이미 활성화되어 있으면 아무 작업도 수행하지 않습니다.
  ///
  /// 게임 시작 시 호출하여 위치 추적 등의 최적화에 사용할 수 있습니다.
  void activate() {
    if (_isActive) {
      debugPrint('⚠️ AppLifecycleService: 이미 활성화되어 있습니다');
      return;
    }

    WidgetsBinding.instance.addObserver(this);
    _isActive = true;
    debugPrint('✅ AppLifecycleService: 생명주기 감지 시작');
  }

  /// 생명주기 감지 중지
  ///
  /// WidgetsBinding에서 Observer를 제거하여 더 이상 생명주기 상태를 감지하지 않습니다.
  /// 이미 비활성화되어 있으면 아무 작업도 수행하지 않습니다.
  ///
  /// 게임 종료 시 호출하여 불필요한 리소스 사용을 방지합니다.
  void deactivate() {
    if (!_isActive) {
      debugPrint('⚠️ AppLifecycleService: 이미 비활성화되어 있습니다');
      return;
    }

    try {
      WidgetsBinding.instance.removeObserver(this);
      _isActive = false;
      debugPrint('✅ AppLifecycleService: 생명주기 감지 중지');
    } catch (e, stack) {
      debugPrint('❌ AppLifecycleService: deactivate 에러 - $e');
      debugPrint('Stack: $stack');
      _isActive = false; // 에러 발생해도 상태는 비활성화로 설정
    }
  }

  /// WidgetsBindingObserver 메서드 오버라이드
  ///
  /// 생명주기 상태가 변경될 때 Flutter 프레임워크에서 자동으로 호출됩니다.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // ✅ StreamController가 null이거나 닫혔으면 stateStream getter로 재생성
    // getter를 통해 접근하면 자동으로 재생성됨
    if (_stateController == null || _stateController!.isClosed) {
      // stateStream getter를 호출하여 StreamController 재생성
      stateStream; // ignore: unnecessary_statements
    }

    _currentState = state;

    // 상태 변화 로깅
    _addLog(state);

    // Stream으로 브로드캐스트 (이제 null이 아님을 보장)
    _stateController!.add(state);

    // 디버그 로그
    debugPrint(
      '🔄 AppLifecycleState: ${state.name} (${_getStateDescription(state)})',
    );

    // keep-alive 타이머 라이프사이클: paused 진입 시 켜고, resumed 시 끔
    if (_keepAliveEnabled) {
      if (state == AppLifecycleState.paused) {
        _startKeepAliveTimer();
      } else if (state == AppLifecycleState.resumed) {
        _stopKeepAliveTimer();
      }
    }
  }

  /// 상태 변화를 로그에 추가
  ///
  /// 최대 [_maxLogs]개까지 저장하며, 초과 시 가장 오래된 로그를 삭제합니다.
  void _addLog(AppLifecycleState state) {
    final log = LifecycleLog(state: state, timestamp: DateTime.now());

    _logs.add(log);

    // 최대 개수 초과 시 가장 오래된 로그 삭제
    if (_logs.length > _maxLogs) {
      _logs.removeAt(0);
    }
  }

  /// 상태에 대한 한글 설명 반환
  String _getStateDescription(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        return '포그라운드 (화면에 보임)';
      case AppLifecycleState.inactive:
        return '전환 중 (잠깐)';
      case AppLifecycleState.hidden:
        return '숨김 상태 (백그라운드 전환)';
      case AppLifecycleState.paused:
        return '백그라운드 진입';
      case AppLifecycleState.detached:
        return '앱 종료 직전';
    }
  }

  /// 모든 로그 삭제
  ///
  /// 테스트 목적으로 로그를 초기화할 때 사용합니다.
  void clearLogs() {
    _logs.clear();
    debugPrint('🗑️ AppLifecycleService: 로그 초기화');
  }

  /// 서비스 정리
  ///
  /// 생명주기 감지를 중지하고 Stream을 닫습니다.
  /// 앱 종료 시 호출해야 합니다.
  void dispose() {
    // keep-alive 정리 먼저 수행
    _stopKeepAliveTimer();
    _keepAliveEnabled = false;

    // 아직 활성화 상태면 자동으로 deactivate 호출
    if (_isActive) {
      deactivate();
    }

    // StreamController가 존재하고 닫히지 않았으면 close
    if (_stateController != null && !_stateController!.isClosed) {
      _stateController!.close();
    }

    debugPrint('🔚 AppLifecycleService: 서비스 종료');
  }
}
