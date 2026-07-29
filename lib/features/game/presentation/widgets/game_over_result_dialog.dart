import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cops_and_robbers/core/constants/game_team.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/character_assets.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/i18n/locale_brand_assets.dart';
import '../../../../core/utils/share_util.dart';
import '../../../../core/utils/widget_capture_util.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/dialogs/dialog_animation.dart';
import '../../../../core/widgets/snackbars/app_snackbar.dart';
import '../../domain/entities/game_result_entity.dart';
import '../providers/game_result_provider.dart';
import '../providers/player_game_record_provider.dart';
import 'record_format.dart';
import 'record_route_map.dart';

// ============================================================
// 순수 함수
// ============================================================

/// 본인 팀과 승리 팀을 비교하여 승/패에 맞는 캐릭터 **몸통** SVG 경로 반환.
///
/// 몸통은 다이얼로그 **뒤**에 배치되어 상단 튀어나온 부분만 보임.
String resolveBodyAsset({required String myTeam, required String winnerTeam}) {
  final teamSlug = myTeam.toLowerCase();
  final resultSlug = myTeam == winnerTeam ? 'win' : 'lose';
  return resultCharacterAssetPath(
    team: teamSlug,
    result: resultSlug,
    part: 'body',
  );
}

/// 본인 팀과 승리 팀을 비교하여 승/패에 맞는 **왼쪽 팔** SVG 경로 반환.
///
/// 팔은 다이얼로그 **앞**에 배치되어 다이얼로그를 잡고 있는 입체감을 준다.
String resolveLeftArmAsset({
  required String myTeam,
  required String winnerTeam,
}) {
  final teamSlug = myTeam.toLowerCase();
  final resultSlug = myTeam == winnerTeam ? 'win' : 'lose';
  return resultCharacterAssetPath(
    team: teamSlug,
    result: resultSlug,
    part: 'arm_left',
  );
}

/// 본인 팀과 승리 팀을 비교하여 승/패에 맞는 **오른쪽 팔** SVG 경로 반환.
String resolveRightArmAsset({
  required String myTeam,
  required String winnerTeam,
}) {
  final teamSlug = myTeam.toLowerCase();
  final resultSlug = myTeam == winnerTeam ? 'win' : 'lose';
  return resultCharacterAssetPath(
    team: teamSlug,
    result: resultSlug,
    part: 'arm_right',
  );
}

// ============================================================
// 위젯
// ============================================================

/// 게임 종료 결과 다이얼로그
///
/// 프로젝트 표준 `AppDialog` 레이아웃(margin/padding/radius/버튼 스타일/애니메이션)을
/// 그대로 따르며, 다이얼로그 상단 위에 팀/결과에 맞는 캐릭터 SVG를 오버레이로 얹는다.
///
/// - 승/패 타이틀 + 통계 3행 + 액션 버튼 2개
/// - `gameResultProvider(gameResultId)` 구독 → AsyncValue로 통계 분기
/// - 캐릭터 오버레이는 Stack + Positioned + Clip.none으로 다이얼로그 위로 튀어나옴
class GameOverResultDialog extends ConsumerWidget {
  const GameOverResultDialog({
    super.key,
    required this.isDarkMode,
    required this.myTeam,
    required this.winnerTeam,
    required this.gameResultId,
    required this.onGoHome,
    required this.onRematch,
  });

  /// 팀 테마 (도둑=true, 경찰=false)
  final bool isDarkMode;

  /// 본인 팀 ('POLICE' | 'ROBBER')
  final String myTeam;

  /// 승리 팀 ('POLICE' | 'ROBBER')
  final String winnerTeam;

  /// 결과 조회 대상 ID
  final int gameResultId;

  /// "홈으로" 버튼 콜백
  final VoidCallback onGoHome;

  /// "한 번 더" 버튼 콜백
  final VoidCallback onRematch;

  // ============================================================
  // 캐릭터 레이어 상수 — 실제 SVG 크기에 맞춰 시각 QA 후 미세조정 필요
  // ============================================================

  // --- 경찰 몸통 ---
  /// 경찰 몸통 렌더 높이.
  static const double _policeBodyHeight = 118;

  /// 경찰 몸통 하단이 다이얼로그 상단에 겹쳐지는 깊이.
  /// 다이얼로그 radius와 비슷하게 두어 경계가 자연스럽게 보이도록.
  static const double _policeBodyOverlapIntoDialog = 14;

  /// 경찰 몸통 가로 오프셋. 양수 = 우측으로 이동.
  static const double _policeBodyHorizontalShift = 0;

  /// 등장 애니메이션 **시작** 시 경찰 몸통이 카드 위로 나와 있는 높이(귀만 보일 만큼).
  /// 0이면 카드 뒤에 완전히 숨었다가 올라오고, 값이 클수록 처음부터 많이 보인다.
  static const double _policeBodyPeekHeight = 4;

  /// 경찰 몸통이 최고점에서 최종 위치를 지나치는 높이. 0이면 튕김 없이 올라와 멈춘다.
  static const double _policeBodyOvershoot = 8;

  // --- 도둑 몸통 ---
  /// 도둑 몸통 렌더 높이 (경찰과 별개로 조절 가능).
  static const double _robberBodyHeight = 100;

  /// 도둑 몸통 하단이 다이얼로그 상단에 겹쳐지는 깊이.
  static const double _robberBodyOverlapIntoDialog = 6;

  /// 도둑 몸통 가로 오프셋 — SVG 비대칭(두건 매듭 등) 시각 보정.
  /// 양수 = 우측으로 이동.
  static const double _robberBodyHorizontalShift = 0;

  /// 등장 애니메이션 **시작** 시 도둑 몸통이 카드 위로 나와 있는 높이(귀만 보일 만큼).
  static const double _robberBodyPeekHeight = 20;

  /// 도둑 몸통이 최고점에서 최종 위치를 지나치는 높이 (경찰과 별개로 조절 가능).
  static const double _robberBodyOvershoot = 3;

  /// 팔 공통 top 오프셋 (다이얼로그 상단 기준).
  /// 음수 = 다이얼로그 위로, 양수 = 다이얼로그 안쪽으로.
  static const double _armTopOffset = -12;

  /// 다이얼로그 전체(캐릭터 포함)를 화면 중앙에서 아래로 내리는 양.
  /// 캐릭터가 카드 위로 튀어나와 시각 무게중심이 위로 쏠리는 것을 보정한다.
  static const double _dialogVerticalShift = 28;

  // --- 경찰 팔 ---
  /// 경찰 팔 렌더 크기 (원본 viewBox 47 × 26).
  static const double _policeArmWidth = 30;
  static const double _policeArmHeight = 24;

  /// 경찰 팔 좌/우 여백 (다이얼로그 가장자리 기준 안쪽).
  /// 값 ↑ = 팔 사이 좁아짐, 값 ↓ = 다이얼로그 모서리 가까이.
  static const double _policeArmLeftInset = 80;
  static const double _policeArmRightInset = 80;

  // --- 도둑 팔 ---
  /// 도둑 팔 렌더 크기 (경찰과 별개로 조절 가능).
  static const double _robberArmWidth = 30;
  static const double _robberArmHeight = 18;

  /// 도둑 팔 좌/우 여백 (경찰과 별개로 조절 가능).
  static const double _robberArmLeftInset = 94;
  static const double _robberArmRightInset = 94;

  /// 다이얼로그 호출 헬퍼 — `AppDialog`의 barrier 스타일을 따르되,
  /// 테스트 호환성 유지를 위해 `showDialog`의 기본 라우트를 사용한다.
  static Future<void> show({
    required BuildContext context,
    required bool isDarkMode,
    required String myTeam,
    required String winnerTeam,
    required int gameResultId,
    required VoidCallback onGoHome,
    required VoidCallback onRematch,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: DialogAnimation.barrierColor,
      builder: (dialogContext) => PopScope(
        canPop: false,
        child: GameOverResultDialog(
          isDarkMode: isDarkMode,
          myTeam: myTeam,
          winnerTeam: winnerTeam,
          gameResultId: gameResultId,
          onGoHome: onGoHome,
          onRematch: onRematch,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isRobber = GameTeam.isRobber(myTeam);
    final bodyAsset = resolveBodyAsset(myTeam: myTeam, winnerTeam: winnerTeam);
    final leftArmAsset = resolveLeftArmAsset(
      myTeam: myTeam,
      winnerTeam: winnerTeam,
    );
    final rightArmAsset = resolveRightArmAsset(
      myTeam: myTeam,
      winnerTeam: winnerTeam,
    );

    // 팀별 몸통 크기 / 겹침 깊이 / 가로 오프셋 선택
    final bodyHeight = isRobber ? _robberBodyHeight : _policeBodyHeight;
    final bodyOverlap = isRobber
        ? _robberBodyOverlapIntoDialog
        : _policeBodyOverlapIntoDialog;
    final bodyHorizontalShift = isRobber
        ? _robberBodyHorizontalShift
        : _policeBodyHorizontalShift;
    final bodyPeekHeight = isRobber
        ? _robberBodyPeekHeight
        : _policeBodyPeekHeight;
    final bodyOvershoot = isRobber
        ? _robberBodyOvershoot
        : _policeBodyOvershoot;

    // 팀별 팔 크기 / 여백 선택 (사이즈·위치 팀 독립 조절)
    final armWidth = isRobber ? _robberArmWidth : _policeArmWidth;
    final armHeight = isRobber ? _robberArmHeight : _policeArmHeight;
    final armLeftInset = isRobber ? _robberArmLeftInset : _policeArmLeftInset;
    final armRightInset = isRobber
        ? _robberArmRightInset
        : _policeArmRightInset;

    // `Dialog(backgroundColor: transparent)`로 감싸서 showDialog의 기본 레이아웃
    // (중앙정렬 + 최대 폭 제한)을 활용하고, Stack 4-레이어 구조로
    // [몸통(뒤) → 다이얼로그(중간) → 왼쪽 팔 → 오른쪽 팔] 순서로 그려 입체감을 준다.
    // 팔은 좌/우 SVG를 분리해 각각 `left`/`right` 기준으로 독립 배치한다.
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      elevation: 0,
      // Dialog는 insetPadding을 준 뒤 중앙 정렬하므로 top 패딩으로 내리면
      // 실제 이동량이 절반이 된다. 의도한 값이 그대로 보이도록 직접 옮긴다.
      child: Transform.translate(
        offset: Offset(0, _dialogVerticalShift.h),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            // 1) 몸통 — 맨 뒤, 다이얼로그에 가려져 상단(머리) 부분만 보임.
            //    크기·겹침·가로 오프셋 모두 팀별 상수에서 선택된 지역 변수 사용.
            //
            //    top을 최종 위치가 아니라 0(카드 뒤에 완전히 숨는 자리)에 두고
            //    [_RiseIn]이 위로 끌어올린다. Positioned를 직접 애니메이션하려면
            //    이 위젯이 Stateful이 되어야 하는데, 그 대가가 연출 하나보다 크다.
            Positioned(
              top: 0,
              child: _RiseIn(
                startRise: bodyPeekHeight.h,
                endRise: (bodyHeight - bodyOverlap).h,
                overshoot: bodyOvershoot.h,
                horizontalShift: bodyHorizontalShift.w,
                child: SvgPicture.asset(
                  bodyAsset,
                  height: bodyHeight.h,
                  fit: BoxFit.contain,
                ),
              ),
            ),

            // 2) 카드 본체 — 몸통을 가리고 팔 아래에 깔림.
            //    캡처용 GlobalKey를 쥐어야 해서 별도 Stateful 위젯으로 분리했다.
            _GameOverCard(
              isDarkMode: isDarkMode,
              myTeam: myTeam,
              winnerTeam: winnerTeam,
              gameResultId: gameResultId,
              onGoHome: onGoHome,
              onRematch: onRematch,
            ),

            // 3) 왼쪽 팔 — 맨 앞. SizedBox로 크기를 고정해 inset에 영향 받지 않게.
            //    크기/위치는 팀별 상수에서 선택된 지역 변수 사용.
            Positioned(
              top: _armTopOffset.h,
              left: armLeftInset.w,
              child: SizedBox(
                width: armWidth.w,
                height: armHeight.h,
                child: SvgPicture.asset(leftArmAsset),
              ),
            ),

            // 4) 오른쪽 팔 — 왼쪽 팔과 동일 구조, `right` 기준 배치.
            Positioned(
              top: _armTopOffset.h,
              right: armRightInset.w,
              child: SizedBox(
                width: armWidth.w,
                height: armHeight.h,
                child: SvgPicture.asset(rightArmAsset),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// 내부 위젯
// ============================================================

/// 카드 뒤에서 위로 솟아올랐다가 제자리로 내려앉는 등장 연출.
///
/// `Curves.easeOutBack` 한 줄로도 비슷한 움직임이 나오지만, 그 커브는 넘어가는
/// 양이 이동 거리에 비례해 정해져서 팀별로 조절할 수 없다. 최고점을 [overshoot]
/// px로 명시하는 2구간 [TweenSequence]로 두어 값만 만지면 되게 했다.
class _RiseIn extends StatefulWidget {
  const _RiseIn({
    required this.startRise,
    required this.endRise,
    required this.overshoot,
    required this.horizontalShift,
    required this.child,
  });

  /// 시작 시 올라와 있는 높이(양수). 0이면 카드 뒤에 완전히 가려진 상태에서 출발한다.
  final double startRise;

  /// 최종적으로 올라갈 높이(양수).
  final double endRise;

  /// 최고점에서 [endRise]를 지나치는 높이(양수). 0이면 튕김 없이 올라와 멈춘다.
  final double overshoot;

  /// 팀별 SVG 비대칭 보정용 가로 오프셋 — 애니메이션과 무관하게 항상 적용된다.
  final double horizontalShift;

  final Widget child;

  @override
  State<_RiseIn> createState() => _RiseInState();
}

class _RiseInState extends State<_RiseIn> with SingleTickerProviderStateMixin {
  /// 되돌아오는 구간까지 포함한 전체 길이.
  static const Duration _duration = Duration(milliseconds: 500);

  /// 전체 길이 중 올라가는 구간이 차지하는 비율(나머지는 내려앉는 구간).
  static const double _riseWeight = 70;
  static const double _settleWeight = 30;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: _duration,
  )..forward();

  late final Animation<double> _rise = TweenSequence<double>([
    // 1) 시작 위치 → 최고점(최종 위치를 overshoot만큼 지나침)
    TweenSequenceItem(
      tween: Tween<double>(
        begin: widget.startRise,
        end: widget.endRise + widget.overshoot,
      ).chain(CurveTween(curve: Curves.easeOutCubic)),
      weight: _riseWeight,
    ),
    // 2) 최고점 → 최종 위치
    TweenSequenceItem(
      tween: Tween<double>(
        begin: widget.endRise + widget.overshoot,
        end: widget.endRise,
      ).chain(CurveTween(curve: Curves.easeOutCubic)),
      weight: _settleWeight,
    ),
  ]).animate(_controller);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _rise,
      // child를 밖에서 넘겨 프레임마다 SVG를 다시 만들지 않게 한다.
      child: widget.child,
      builder: (context, child) => Transform.translate(
        offset: Offset(widget.horizontalShift, -_rise.value),
        child: child,
      ),
    );
  }
}

/// 결과 카드 본체 — 공유 캡처 대상.
///
/// 공유 시 이 카드만 PNG로 뜬다(캐릭터는 Stack 형제라 캡처 영역 밖).
/// 캡처 순간 버튼·공유 아이콘을 숨기려면 상태가 필요해서 바깥 다이얼로그와 분리했다.
class _GameOverCard extends ConsumerStatefulWidget {
  const _GameOverCard({
    required this.isDarkMode,
    required this.myTeam,
    required this.winnerTeam,
    required this.gameResultId,
    required this.onGoHome,
    required this.onRematch,
  });

  final bool isDarkMode;
  final String myTeam;
  final String winnerTeam;
  final int gameResultId;
  final VoidCallback onGoHome;
  final VoidCallback onRematch;

  @override
  ConsumerState<_GameOverCard> createState() => _GameOverCardState();
}

class _GameOverCardState extends ConsumerState<_GameOverCard> {
  final GlobalKey _captureKey = GlobalKey();

  /// 지도 스냅샷 준비/해제 호출용 — GoogleMap은 플랫폼 뷰라 toImage에 안 찍혀서
  /// 캡처 전 네이티브 스냅샷으로 덮어야 한다.
  final GlobalKey<RecordRouteMapState> _mapKey =
      GlobalKey<RecordRouteMapState>();

  /// 캡처 중에는 버튼·공유 아이콘을 숨긴다(공유 이미지에 찍히면 안 됨).
  bool _capturing = false;

  /// 카드 폭 — 지도(콘텐츠 폭)가 좌우 패딩과 함께 이 값에 맞춰진다.
  static const double _cardWidth = 320;

  /// 카드를 PNG로 떠서 OS 공유 시트로 넘긴다.
  ///
  /// 버튼·아이콘은 숨김이 실제로 그려진 다음 프레임에 캡처해야 이미지에서 빠진다.
  Future<void> _onShare() async {
    if (_capturing) return; // 연타 방지

    final l10n = AppLocalizations.of(context);

    // 지도 네이티브 스냅샷을 먼저 준비해 캡처 프레임에 동기로 그려지게 한다.
    await _mapKey.currentState?.prepareForCapture();
    if (!mounted) return;

    setState(() => _capturing = true);
    await WidgetsBinding.instance.endOfFrame;
    final bytes = await captureBoundaryToPng(_captureKey);
    _mapKey.currentState?.endCapture();
    if (mounted) setState(() => _capturing = false);

    if (bytes == null) {
      if (!mounted) return;
      AppSnackbar.show(
        context,
        message: l10n.messageSaveFailed,
        backgroundColor: AppColors.red,
        isDarkMode: widget.isDarkMode,
      );
      return;
    }

    // 공유 시트에서 실제로 공유/저장을 완료했을 때만 확인 스낵바(취소 시 무반응).
    final shared = await shareImageBytes(bytes);
    if (!mounted || !shared) return;
    AppSnackbar.show(
      context,
      message: l10n.messageShareComplete,
      isDarkMode: widget.isDarkMode,
    );
  }

  @override
  Widget build(BuildContext context) {
    final resultAsync = ref.watch(gameResultProvider(widget.gameResultId));
    final record = ref.watch(playerGameRecordNotifierProvider);

    final isWin = widget.myTeam == widget.winnerTeam;
    final isRobber = GameTeam.isRobber(widget.myTeam);

    // 거리·폴리라인은 승패와 무관하게 팀 컬러를 쓴다.
    final accent = isRobber ? AppColors.green : AppColors.blue;
    final distance = formatDistanceParts(record.distanceMeters);

    return RepaintBoundary(
      key: _captureKey,
      child: Container(
        width: _cardWidth.w,
        padding: EdgeInsets.only(
          top: AppSpacing.vertical20,
          bottom: AppSpacing.vertical18,
          left: AppSpacing.horizontal16,
          right: AppSpacing.horizontal16,
        ),
        decoration: BoxDecoration(
          color: widget.isDarkMode ? AppColors.black : AppColors.white,
          borderRadius: AppRadius.xxlarge,
        ),
        child: Material(
          color: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ResultTitleRow(
                isDarkMode: widget.isDarkMode,
                isWin: isWin,
                hideShareIcon: _capturing,
                onShare: _onShare,
              ),
              SizedBox(height: AppSpacing.vertical12),
              // 본문(날짜·거리·지도·통계)만 좌우로 한 단계 더 들여쓴다.
              // 타이틀 행과 버튼은 카드 콘텐츠 폭을 그대로 쓴다.
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.horizontal8,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 날짜는 통계와 같은 들여쓰기(본문 8 + 8) — 거리·지도는 본문 폭 그대로.
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.horizontal8,
                      ),
                      child: Text(
                        record.endedAt == null
                            ? ''
                            : formatRecordDate(record.endedAt!),
                        style: AppTextStyles.paragraph_14_100.copyWith(
                          color: widget.isDarkMode
                              ? AppColors.black200
                              : AppColors.black600,
                        ),
                      ),
                    ),
                    SizedBox(height: AppSpacing.vertical4),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: distance.value,
                            style: AppTextStyles.semibold_56.copyWith(
                              color: accent,
                            ),
                          ),
                          const TextSpan(text: ' '),
                          TextSpan(
                            text: distance.unit,
                            style: AppTextStyles.heading_24.copyWith(
                              color: accent,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: AppSpacing.vertical4),
                    RecordRouteMap(
                      key: _mapKey,
                      route: record.route,
                      // 경찰은 체포한 곳, 도둑은 잡힌 곳을 표시한다.
                      markerPoints: isRobber
                          ? record.caughtLocations
                          : record.arrestLocations,
                      lineColor: accent,
                      isDarkMode: widget.isDarkMode,
                    ),
                    SizedBox(height: AppSpacing.vertical16),
                    // 통계 3행만 한 단계 더 들여쓴다(카드 16 + 본문 8 + 8).
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.horizontal8,
                      ),
                      child: _StatsSection(
                        isDarkMode: widget.isDarkMode,
                        resultAsync: resultAsync,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppSpacing.vertical20),
              // 버튼은 공유 이미지에 들어가면 안 되고, 대신 그 자리에 브랜드 로고가 들어간다.
              // if/else 교체가 아니라 Offstage 토글인 이유: 캡처 프레임에 처음
              // 마운트된 SVG는 비동기 로딩 때문에 그 프레임에 그려지지 못한다.
              // 로고를 미리 마운트해 디코딩을 끝내 두고 그리기만 켜고 끈다.
              Offstage(
                offstage: _capturing,
                child: _ActionButtons(
                  isDarkMode: widget.isDarkMode,
                  onGoHome: widget.onGoHome,
                  onRematch: widget.onRematch,
                ),
              ),
              Offstage(
                offstage: !_capturing,
                // 캡처 이미지 전용 하단 여백 — 카드 bottom 패딩 18과 합쳐
                // 로고 아래 총 54를 만든다. 라이브 버튼 상태에는 영향 없다.
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: AppSpacing.vertical14),
                    Center(child: _BrandLockup(isDarkMode: widget.isDarkMode)),
                    SizedBox(height: AppSpacing.vertical18),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 공유 이미지 하단의 브랜드 워터마크 — 캡처 중에만 노출된다.
///
/// 라이브 다이얼로그에는 버튼이 있어야 하므로 화면에는 띄우지 않고,
/// 앱 밖으로 나가는 이미지에만 넣어 출처를 남긴다.
class _BrandLockup extends StatelessWidget {
  const _BrandLockup({required this.isDarkMode});

  final bool isDarkMode;

  /// 에셋 viewBox 높이가 로케일 공통 560이라 높이만 주면 폭은 비율대로 따라온다.
  static const double _height = 18;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      key: const ValueKey('game_over_brand_lockup'),
      localizedAppLogoLockup(
        Localizations.localeOf(context),
        isDarkMode: isDarkMode,
      ),
      height: _height.h,
    );
  }
}

/// 타이틀 + 우상단 공유 아이콘 한 줄.
///
/// 타이틀은 카드 정중앙, 아이콘은 오른쪽 고정이라 서로 위치가 독립적이어야 한다.
/// Row로 묶으면 아이콘 폭이 타이틀 중심을 밀어내므로 Stack으로 겹쳐 놓는다.
/// 캡처 중에는 아이콘만 투명 처리한다 — 자리를 유지해야 타이틀이 흔들리지 않는다.
class _ResultTitleRow extends StatelessWidget {
  const _ResultTitleRow({
    required this.isDarkMode,
    required this.isWin,
    required this.hideShareIcon,
    required this.onShare,
  });

  final bool isDarkMode;
  final bool isWin;
  final bool hideShareIcon;
  final VoidCallback onShare;

  /// 공유 아이콘 한 변
  static const double _iconSize = 20;

  /// 아이콘과 콘텐츠 영역 오른쪽 끝 사이 여백.
  /// 시안 기준은 카드 바깥 가장자리에서 28이고, 카드 좌우 패딩이 16이라 여기서는 12다.
  static const double _iconRightInset = 28 - 16;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          _ResultTitle(isDarkMode: isDarkMode, isWin: isWin),
          Positioned(
            right: _iconRightInset.w,
            child: Opacity(
              opacity: hideShareIcon ? 0 : 1,
              child: IgnorePointer(
                ignoring: hideShareIcon,
                child: GestureDetector(
                  key: const ValueKey('game_over_share_button'),
                  onTap: onShare,
                  behavior: HitTestBehavior.opaque,
                  child: SvgPicture.asset(
                    'assets/icons/icon_upload.svg',
                    width: _iconSize.w,
                    height: _iconSize.w,
                    // 에셋 원본 fill이 black400이라 라이트는 틴트가 필요 없다.
                    colorFilter: isDarkMode
                        ? const ColorFilter.mode(
                            AppColors.black200,
                            BlendMode.srcIn,
                          )
                        : null,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultTitle extends StatelessWidget {
  const _ResultTitle({required this.isDarkMode, required this.isWin});

  final bool isDarkMode;
  final bool isWin;

  @override
  Widget build(BuildContext context) {
    // 경찰 승리: 파랑 / 경찰 패배: 빨강
    // 도둑 승리: 초록 / 도둑 패배: 빨강
    final color = isDarkMode
        ? (isWin ? AppColors.green : AppColors.red)
        : (isWin ? AppColors.blue : AppColors.red);

    final baseStyle = isDarkMode
        ? AppTextStyles.robberHeading24
        : AppTextStyles.heading_24;

    final l10n = AppLocalizations.of(context);
    return Text(
      isWin ? l10n.gameResultWin : l10n.gameResultLose,
      style: baseStyle.copyWith(color: color),
      textAlign: TextAlign.center,
    );
  }
}

class _StatsSection extends StatelessWidget {
  const _StatsSection({required this.isDarkMode, required this.resultAsync});

  final bool isDarkMode;
  final AsyncValue<GameResultEntity> resultAsync;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return resultAsync.when(
      // 순서는 시안 기준: 게임 진행 시간 → 체포 횟수 → 남은 도둑.
      // placeholder 분기도 같은 순서를 유지해야 로딩→완료 전환에서 행이 튀지 않는다.
      data: (entity) => Column(
        children: [
          _StatRow(
            isDarkMode: isDarkMode,
            label: l10n.fieldGamePlaytime,
            value: formatDuration(entity.durationSeconds),
          ),
          SizedBox(height: AppSpacing.vertical12),
          // 단위(회·명)는 시안에 없어 숫자만 노출한다. 라벨이 이미 의미를 말해준다.
          _StatRow(
            isDarkMode: isDarkMode,
            label: l10n.labelArrestCount,
            value: '${entity.totalArrestCount}',
          ),
          SizedBox(height: AppSpacing.vertical12),
          _StatRow(
            isDarkMode: isDarkMode,
            label: l10n.fieldRemainingRobbers,
            value: '${entity.remainingRobberCount}',
          ),
        ],
      ),
      loading: () => _placeholderRows(context),
      error: (_, _) => _placeholderRows(context),
    );
  }

  Widget _placeholderRows(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        _StatRow(
          isDarkMode: isDarkMode,
          label: l10n.fieldGamePlaytime,
          value: '-',
        ),
        SizedBox(height: AppSpacing.vertical12),
        _StatRow(
          isDarkMode: isDarkMode,
          label: l10n.labelArrestCount,
          value: '-',
        ),
        SizedBox(height: AppSpacing.vertical12),
        _StatRow(
          isDarkMode: isDarkMode,
          label: l10n.fieldRemainingRobbers,
          value: '-',
        ),
      ],
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({
    required this.isDarkMode,
    required this.label,
    required this.value,
  });

  final bool isDarkMode;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    // 이 영역만 다크에서도 Pretendard를 쓴다(다른 도둑 테마 영역은 Moneygraphy).
    // 좌우 여백은 카드 패딩이 담당하므로 행 자체에는 두지 않는다.
    final labelStyle = AppTextStyles.label16Medium.copyWith(
      color: isDarkMode ? AppColors.white : AppColors.black800,
    );
    final valueStyle = AppTextStyles.subHeading_18.copyWith(
      color: isDarkMode ? AppColors.white : AppColors.black,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: labelStyle),
        Text(value, style: valueStyle),
      ],
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({
    required this.isDarkMode,
    required this.onGoHome,
    required this.onRematch,
  });

  final bool isDarkMode;
  final VoidCallback onGoHome;
  final VoidCallback onRematch;

  @override
  Widget build(BuildContext context) {
    // AppDialog의 cancel/confirm 버튼 색상 규칙을 그대로 따름.
    // "한 번 더"는 feature 테마 유지를 위해 경찰 승리 시 blue 사용
    // (AppDialog 기본 confirm black 대신).
    final cancelBg = isDarkMode ? AppColors.black900 : AppColors.black100;
    final cancelFg = isDarkMode ? AppColors.black400 : AppColors.black600;
    final confirmBg = isDarkMode ? AppColors.green : AppColors.blue;
    final confirmFg = isDarkMode ? AppColors.black : AppColors.white;
    final l10n = AppLocalizations.of(context);

    return Row(
      children: [
        Expanded(
          child: AppButton(
            key: const ValueKey('game_over_go_home_button'),
            text: l10n.buttonGoHome,
            onPressed: onGoHome,
            backgroundColor: cancelBg,
            foregroundColor: cancelFg,
            borderRadius: AppRadius.medium,
            showBorder: false,
            height: 48.h,
            textStyle: isDarkMode ? AppTextStyles.robberLabel : null,
          ),
        ),
        SizedBox(width: AppSpacing.horizontal8),
        Expanded(
          child: AppButton(
            key: const ValueKey('game_over_rematch_button'),
            text: l10n.buttonPlayAgain,
            onPressed: onRematch,
            backgroundColor: confirmBg,
            foregroundColor: confirmFg,
            borderRadius: AppRadius.medium,
            showBorder: false,
            height: 48.h,
            textStyle: isDarkMode ? AppTextStyles.robberLabel : null,
          ),
        ),
      ],
    );
  }
}
