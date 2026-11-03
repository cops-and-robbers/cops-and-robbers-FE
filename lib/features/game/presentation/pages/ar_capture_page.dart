import 'dart:async';
import 'dart:math';

import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/services/vibration_service.dart';
import '../../../../core/widgets/dialogs/app_dialog.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/ar_capture_state.dart';
import '../widgets/ar_capture_scene.dart';

/// AR 포착 화면 시안 (#655). 지금은 홈의 시험용 버튼에서만 열린다.
///
/// 카메라는 배경일 뿐 찍힌 내용은 판정하지 않는다.
/// 위치 조건과 포착 API는 게임에 붙일 때 연결한다.
class ArCapturePage extends StatefulWidget {
  const ArCapturePage({super.key});

  @override
  State<ArCapturePage> createState() => _ArCapturePageState();
}

class _ArCapturePageState extends State<ArCapturePage> {
  /// 이벤트가 끊겼다 이어질 때 한 번에 크게 튀지 않게 막는 상한
  static const double _maxDt = 0.1;

  /// 실기기에서 조정할 값: 그림이 움직이는 속도 (라디안/초, 좌우 약 20도, 위아래 약 3도)
  static const double _wanderYawSpeed = 0.35;
  static const double _wanderPitchSpeed = 0.05;

  final MobileScannerController _camera = MobileScannerController();
  final Random _random = Random();

  StreamSubscription<GyroscopeEvent>? _gyro;
  StreamSubscription<AccelerometerEvent>? _accelerometer;
  bool _aligned = false;
  double _targetYawRate = _wanderYawSpeed;
  double _targetPitchRate = 0;
  double _untilTurn = 0;
  Timer? _noGyroTimer;
  DateTime? _lastEventAt;
  late ArCaptureState _state = _randomTarget();
  bool _hasGyro = true;
  bool _hasShownPermissionDialog = false;

  @override
  void initState() {
    super.initState();
    _gyro = gyroscopeEventStream(
      samplingPeriod: SensorInterval.gameInterval,
    ).listen(_onGyro, onError: (_) => _startWithoutGyro());
    _accelerometer =
        accelerometerEventStream(
          samplingPeriod: SensorInterval.gameInterval,
        ).listen(
          _onAccelerometer,
          onError: (_) => debugPrint('AR 포착: 가속도 값을 읽지 못함'),
        );
  }

  @override
  void dispose() {
    _gyro?.cancel();
    _accelerometer?.cancel();
    _noGyroTimer?.cancel();
    _camera.dispose();
    super.dispose();
  }

  /// 좌우는 시작 방향에서 20~35도, 위아래는 폰을 똑바로 세웠을 때(90도) 정면이다.
  /// [pitch]는 지금 카메라의 실제 각도다.
  ArCaptureState _randomTarget({double pitch = 0}) {
    final side = _random.nextBool() ? 1 : -1;
    return ArCaptureState(
      targetYaw: side * (0.35 + _random.nextDouble() * 0.25),
      targetPitch: 0,
      pitch: pitch,
    );
  }

  /// 첫 값으로 시작 각도를 맞추고, 이후엔 자이로 오차를 계속 되돌린다.
  /// 값을 못 읽으면 연 순간의 방향을 수평으로 보고 자이로만으로 진행한다.
  void _onAccelerometer(AccelerometerEvent event) {
    final elevation = cameraElevation(y: event.y, z: event.z);
    setState(() {
      _state = _aligned
          ? _state.correctPitch(elevation)
          : _randomTarget(pitch: elevation);
      _aligned = true;
    });
  }

  /// 왕복 패턴이 읽히지 않도록 0.6~1.4초마다 방향을 무작위로 바꾼다.
  void _wander(double dt) {
    _untilTurn -= dt;
    if (_untilTurn > 0) return;
    _untilTurn = 0.6 + _random.nextDouble() * 0.8;
    _targetYawRate = _random.nextBool() ? _wanderYawSpeed : -_wanderYawSpeed;
    _targetPitchRate = _random.nextBool()
        ? _wanderPitchSpeed
        : -_wanderPitchSpeed;
  }

  void _onGyro(GyroscopeEvent event) {
    final last = _lastEventAt;
    _lastEventAt = event.timestamp;
    if (last == null) return;

    final elapsed = event.timestamp.difference(last).inMicroseconds / 1e6;
    final dt = elapsed.clamp(0.0, _maxDt);
    setState(() {
      // 세로로 든 폰에서 y축은 좌우 회전, x축은 위아래 기울임이다.
      _wander(dt);
      final previous = _state;
      _state = previous.advance(
        yawRate: event.y,
        pitchRate: event.x,
        dt: dt,
        targetYawRate: _targetYawRate,
        targetPitchRate: _targetPitchRate,
      );
      if (!previous.isCaptured && _state.isCaptured) {
        VibrationService.instance().escaped();
      } else if (!previous.inFrame && _state.inFrame) {
        VibrationService.instance().buttonTap();
      }
    });
  }

  /// 자이로가 없는 기기(Android NO_SENSOR)는 그림을 가운데 고정하고 시간만 잰다.
  void _startWithoutGyro() {
    _gyro?.cancel();
    _accelerometer?.cancel();
    _noGyroTimer?.cancel();
    const tick = Duration(milliseconds: 100);
    setState(() {
      _hasGyro = false;
      _state = const ArCaptureState(targetYaw: 0, targetPitch: 0);
    });
    _noGyroTimer = Timer.periodic(tick, (_) {
      setState(() {
        _state = _state.advance(yawRate: 0, pitchRate: 0, dt: 0.1);
      });
    });
  }

  void _restart() {
    setState(() {
      _state = _hasGyro
          ? _randomTarget(pitch: _state.pitch)
          : const ArCaptureState(targetYaw: 0, targetPitch: 0);
    });
  }

  void _showPermissionDeniedDialog() {
    final l10n = AppLocalizations.of(context);
    AppDialog.show(
      context: context,
      title: l10n.dialogCameraPermissionTitle,
      message: l10n.dialogCameraPermissionMessage,
      confirmText: l10n.buttonGoToSettings,
      cancelText: l10n.buttonClose,
      onConfirm: () => AppSettings.openAppSettings(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ArCaptureScene(
      camera: MobileScanner(
        controller: _camera,
        errorBuilder: (context, error) {
          if (error.errorCode == MobileScannerErrorCode.permissionDenied) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && !_hasShownPermissionDialog) {
                _hasShownPermissionDialog = true;
                _showPermissionDeniedDialog();
              }
            });
          }
          return Center(
            child: Text(
              l10n.errorCameraUnavailable,
              style: AppTextStyles.paragraph_14.copyWith(
                color: AppColors.white,
              ),
            ),
          );
        },
      ),
      state: _state,
      flipPicture: _hasGyro && _state.hasEntered && _targetYawRate > 0,
      // 시험 화면이라 미션 진행도는 예시 값이다. 게임에 붙일 때 서버 값으로 바꾼다.
      missionCurrent: 3,
      missionTotal: 5,
      onClose: () => Navigator.of(context).pop(),
      onRetry: _restart,
    );
  }
}
