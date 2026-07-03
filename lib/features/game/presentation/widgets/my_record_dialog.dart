import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/constants/character_assets.dart';
import '../../../../core/theme/character_skin_provider.dart';
import '../../../../core/utils/share_util.dart';
import '../../../../core/utils/widget_capture_util.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/dialogs/dialog_animation.dart';
import '../../../../core/widgets/snackbars/app_snackbar.dart';
import 'package:cops_and_robbers/core/constants/game_team.dart';
import '../providers/game_result_provider.dart';
import '../providers/player_game_record_provider.dart';
import 'record_format.dart';
import 'route_painter.dart';
import 'route_map_snapshot.dart';

/// 내 기록 다이얼로그 — 거리/경로/개인 카운트/플레이시간/승패 + 공유·저장.
class MyRecordDialog extends StatelessWidget {
  const MyRecordDialog({
    super.key,
    required this.isDarkMode,
    required this.myTeam,
    required this.winnerTeam,
    required this.gameResultId,
  });

  final bool isDarkMode;
  final String myTeam;
  final String winnerTeam;
  final int gameResultId;

  static Future<void> show({
    required BuildContext context,
    required bool isDarkMode,
    required String myTeam,
    required String winnerTeam,
    required int gameResultId,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierColor: DialogAnimation.barrierColor,
      builder: (_) => MyRecordDialog(
        isDarkMode: isDarkMode,
        myTeam: myTeam,
        winnerTeam: winnerTeam,
        gameResultId: gameResultId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: AppPadding.horizontal36,
      elevation: 0,
      child: _MyRecordBody(
        isDarkMode: isDarkMode,
        myTeam: myTeam,
        winnerTeam: winnerTeam,
        gameResultId: gameResultId,
      ),
    );
  }
}

/// 캡처 대상 + 액션 버튼을 담는 본문(스낵바·캡처 키 보유).
class _MyRecordBody extends ConsumerStatefulWidget {
  const _MyRecordBody({
    required this.isDarkMode,
    required this.myTeam,
    required this.winnerTeam,
    required this.gameResultId,
  });

  final bool isDarkMode;
  final String myTeam;
  final String winnerTeam;
  final int gameResultId;

  @override
  ConsumerState<_MyRecordBody> createState() => _MyRecordBodyState();
}

class _MyRecordBodyState extends ConsumerState<_MyRecordBody> {
  final GlobalKey _captureKey = GlobalKey();
  bool _mapReady = false;

  Future<void> _onShare() async {
    final l10n = AppLocalizations.of(context);
    final bytes = await captureBoundaryToPng(_captureKey);
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
    final l10n = AppLocalizations.of(context);
    final durationAsync = ref.watch(gameResultProvider(widget.gameResultId));
    final durationSeconds = durationAsync.maybeWhen(
      data: (e) => e.durationSeconds,
      orElse: () => 0,
    );

    // 경로가 있으면 지도 스냅샷/폴백이 확정(_mapReady)되기 전엔 캡처 금지
    // (라이브 플랫폼 뷰가 빈 이미지로 캡처되는 것 방지). 빈 경로면 즉시 가능.
    final record = ref.watch(playerGameRecordNotifierProvider);
    final canCapture = record.route.isEmpty || _mapReady;
    // 지도 로딩 중에는 카드 전체를 로딩 오버레이로 가린다(빈 경로면 즉시 공개).
    final loading = record.route.isNotEmpty && !_mapReady;
    final spinnerColor = GameTeam.isRobber(widget.myTeam)
        ? AppColors.green
        : AppColors.blue;

    // 로딩 중 disabled 버튼 톤 — 기본 disabled(black100+white)는 다크에서 튀고
    // 텍스트가 안 보이므로 팀 테마에 맞춰 회색 처리.
    final disabledBg = widget.isDarkMode
        ? AppColors.black900
        : AppColors.black100;
    final disabledFg = widget.isDarkMode
        ? AppColors.black600
        : AppColors.black400;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 로딩 오버레이는 캡처 카드만 덮는다 — 버튼까지 덮으면 오버레이의
        // xxlarge 라운드 모서리 밖으로 밑에 깔린 버튼 모서리가 삐져나온다.
        Stack(
          children: [
            RepaintBoundary(
              key: _captureKey,
              child: MyRecordCard(
                isDarkMode: widget.isDarkMode,
                myTeam: widget.myTeam,
                winnerTeam: widget.winnerTeam,
                durationSeconds: durationSeconds,
                onMapResolved: () {
                  if (mounted && !_mapReady) setState(() => _mapReady = true);
                },
              ),
            ),
            // 로딩 중에는 지도·정보를 모두 가리고 스피너만 표시 → 확정 시 한 번에 공개.
            // (지도는 가려진 채 백그라운드에서 렌더·스냅샷되어야 하므로 트리에는 유지)
            if (loading)
              Positioned.fill(
                child: _LoadingCard(
                  isDarkMode: widget.isDarkMode,
                  spinnerColor: spinnerColor,
                ),
              ),
          ],
        ),
        SizedBox(height: AppSpacing.vertical12),
        Row(
          children: [
            Expanded(
              child: AppButton(
                text: l10n.buttonClose,
                // 저장은 공유 시트의 "이미지 저장"으로 대체 — 닫기는 로딩 중에도 가능.
                onPressed: () => Navigator.of(context).pop(),
                backgroundColor: widget.isDarkMode
                    ? AppColors.black900
                    : AppColors.black100,
                foregroundColor: widget.isDarkMode
                    ? AppColors.black400
                    : AppColors.black600,
                borderRadius: AppRadius.medium,
                showBorder: false,
                height: 48.h,
                textStyle: widget.isDarkMode ? AppTextStyles.robberLabel : null,
              ),
            ),
            SizedBox(width: AppSpacing.horizontal8),
            Expanded(
              child: AppButton(
                text: l10n.buttonShare,
                onPressed: canCapture ? _onShare : null,
                backgroundColor: widget.isDarkMode
                    ? AppColors.green
                    : AppColors.blue,
                foregroundColor: widget.isDarkMode
                    ? AppColors.black
                    : AppColors.white,
                disabledBackgroundColor: disabledBg,
                disabledForegroundColor: disabledFg,
                borderRadius: AppRadius.medium,
                showBorder: false,
                height: 48.h,
                textStyle: widget.isDarkMode ? AppTextStyles.robberLabel : null,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// 캡처 대상 카드(역할별 통계 + 거리 + 경로 + 캐릭터). 테스트가 직접 검증.
class MyRecordCard extends ConsumerWidget {
  const MyRecordCard({
    super.key,
    required this.isDarkMode,
    required this.myTeam,
    required this.winnerTeam,
    required this.durationSeconds,
    this.onMapResolved,
  });

  final bool isDarkMode;
  final String myTeam;
  final String winnerTeam;
  final int durationSeconds;

  /// 지도 스냅샷/폴백 확정 시 호출(부모의 저장·공유 버튼 게이팅용). 빈 경로면 미호출.
  final VoidCallback? onMapResolved;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final record = ref.watch(playerGameRecordNotifierProvider);
    final skinId = ref.watch(characterSkinProvider);
    final isRobber = GameTeam.isRobber(myTeam);
    final isWin = myTeam == winnerTeam;

    final fg = isDarkMode ? AppColors.white : AppColors.black;
    final subFg = isDarkMode ? AppColors.black400 : AppColors.black600;
    final lineColor = isRobber ? AppColors.green : AppColors.blue;

    // 마커 색 범례 — 데이터가 있는 항목만 표시.
    final legend = <Widget>[
      if (!isRobber && record.arrestLocations.isNotEmpty)
        _LegendDot(
          color: AppColors.red,
          label: l10n.legendArrestSpot,
          subFg: subFg,
        ),
      if (isRobber && record.caughtLocations.isNotEmpty)
        _LegendDot(
          color: AppColors.red,
          label: l10n.legendCaughtSpot,
          subFg: subFg,
        ),
    ];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.horizontal20,
        vertical: AppSpacing.vertical24,
      ),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.black : AppColors.white,
        borderRadius: AppRadius.xxlarge,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 헤더 — 승패 배지(기존 "결과" 행 승격) + 종료 일시
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _ResultBadge(isDarkMode: isDarkMode, isWin: isWin),
              if (record.endedAt != null)
                Text(
                  formatRecordDate(record.endedAt!),
                  style: AppTextStyles.tag_12.copyWith(color: subFg),
                ),
            ],
          ),
          SizedBox(height: AppSpacing.vertical16),
          // 대표 숫자 — 라벨 위 + 값 아래, 좌측 정렬
          Text(
            l10n.labelTravelDistance,
            style: AppTextStyles.label16Medium.copyWith(color: subFg),
          ),
          SizedBox(height: AppSpacing.vertical4),
          Text(
            formatDistance(record.distanceMeters),
            style: AppTextStyles.semibold_44.copyWith(color: fg),
          ),
          SizedBox(height: AppSpacing.vertical16),
          // 경로 블록(실제 지도 스냅샷, 실패 시 스타일라이즈드 폴백) + 캐릭터.
          // 빈 경로여도 타일 배경을 깔아 카드 내 블록 경계를 유지한다.
          ClipRRect(
            borderRadius: AppRadius.large,
            child: Container(
              height: 160.h,
              color: isDarkMode ? AppColors.black900 : AppColors.black100,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (record.route.isEmpty)
                    Text(
                      l10n.labelNoRoute,
                      style: AppTextStyles.tag_12.copyWith(color: subFg),
                    )
                  else
                    Positioned.fill(
                      child: RouteMapSnapshot(
                        route: record.route,
                        markerPoints: isRobber
                            ? record.caughtLocations
                            : record.arrestLocations,
                        isDarkMode: isDarkMode,
                        lineColor: lineColor,
                        onResolved: onMapResolved ?? () {},
                        fallback: CustomPaint(
                          size: Size(double.infinity, 160.h),
                          painter: RoutePainter(
                            route: record.route,
                            lineColor: lineColor,
                            startColor: isDarkMode
                                ? AppColors.white
                                : AppColors.black600,
                            endColor: lineColor,
                            // 경찰=체포 지점 / 도둑=잡힌 지점 (둘 다 빨강)
                            markers: [
                              RouteMarker(
                                isRobber
                                    ? record.caughtLocations
                                    : record.arrestLocations,
                                AppColors.red,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: SvgPicture.asset(
                      resultCharacterAssetPath(
                        team: myTeam.toLowerCase(),
                        skinId: skinId,
                        result: isWin ? 'win' : 'lose',
                        part: 'body',
                      ),
                      height: (isRobber ? 64 : 80).h,
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (legend.isNotEmpty) ...[
            SizedBox(height: AppSpacing.vertical12),
            Wrap(
              spacing: AppSpacing.horizontal12,
              runSpacing: AppSpacing.vertical8,
              alignment: WrapAlignment.center,
              children: legend,
            ),
          ],
          SizedBox(height: AppSpacing.vertical16),
          // 통계 타일 그리드 (승패는 상단 배지로 이동)
          Row(
            children: [
              Expanded(
                child: _StatTile(
                  label: l10n.fieldGamePlaytime,
                  value: formatDuration(durationSeconds),
                  isDarkMode: isDarkMode,
                ),
              ),
              SizedBox(width: AppSpacing.horizontal8),
              // 단위 재사용: 잡은 도둑은 "N명"(gameResultRemainingRobberCount),
              // 탈옥은 "N회"(gameResultArrestCount) — 표면 단위만 차용(렌더 텍스트 정확).
              Expanded(
                child: _StatTile(
                  label: isRobber
                      ? l10n.labelMyEscapeCount
                      : l10n.labelMyArrestCount,
                  value: isRobber
                      ? l10n.gameResultArrestCount(record.myEscapeCount)
                      : l10n.gameResultRemainingRobberCount(
                          record.myArrestCount,
                        ),
                  isDarkMode: isDarkMode,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.vertical16),
          // 브랜드 워터마크 — 공유 이미지에서 앱 식별용
          Center(child: _BrandWatermark(color: subFg)),
        ],
      ),
    );
  }
}

/// 마커 색 범례 한 칸 (색 점 + 라벨).
class _LegendDot extends StatelessWidget {
  const _LegendDot({
    required this.color,
    required this.label,
    required this.subFg,
  });

  final Color color;
  final String label;
  final Color subFg;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8.w,
          height: 8.w,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: AppSpacing.horizontal4),
        Text(label, style: AppTextStyles.tag_12.copyWith(color: subFg)),
      ],
    );
  }
}

/// 지도 스냅샷이 준비될 때까지 카드 전체를 덮는 로딩 인디케이터.
class _LoadingCard extends StatelessWidget {
  const _LoadingCard({required this.isDarkMode, required this.spinnerColor});

  final bool isDarkMode;
  final Color spinnerColor;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.black : AppColors.white,
        borderRadius: AppRadius.xxlarge,
      ),
      child: Center(
        child: SizedBox(
          width: 40.w,
          height: 40.w,
          child: CircularProgressIndicator(strokeWidth: 3, color: spinnerColor),
        ),
      ),
    );
  }
}

/// 승패 배지 칩 — 승리 시 팀 컬러, 패배 시 중립 톤.
class _ResultBadge extends StatelessWidget {
  const _ResultBadge({required this.isDarkMode, required this.isWin});

  final bool isDarkMode;
  final bool isWin;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final bg = isDarkMode
        ? AppColors.black900
        : (isWin ? AppColors.blue100 : AppColors.black100);
    final fg = isDarkMode
        ? (isWin ? AppColors.green : AppColors.black400)
        : (isWin ? AppColors.blue : AppColors.black600);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.horizontal12,
        vertical: AppSpacing.vertical6,
      ),
      decoration: BoxDecoration(color: bg, borderRadius: AppRadius.pill),
      child: Text(
        isWin ? l10n.gameResultWin : l10n.gameResultLose,
        style: AppTextStyles.tag12Semibold.copyWith(color: fg),
      ),
    );
  }
}

/// 통계 타일 한 칸 — 라벨(위) + 값(아래).
class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    required this.isDarkMode,
  });

  final String label;
  final String value;
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    final subFg = isDarkMode ? AppColors.black400 : AppColors.black600;
    final fg = isDarkMode ? AppColors.white : AppColors.black;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.horizontal12,
        vertical: AppSpacing.vertical12,
      ),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.black900 : AppColors.black100,
        borderRadius: AppRadius.large,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.tag_12.copyWith(color: subFg)),
          SizedBox(height: AppSpacing.vertical4),
          Text(
            value,
            style: isDarkMode
                ? AppTextStyles.robberSubHeading.copyWith(color: fg)
                : AppTextStyles.subHeading_18.copyWith(color: fg),
          ),
        ],
      ),
    );
  }
}

/// 로케일별 앱 로고 워터마크 — 카드 톤에 맞게 단색 틴트.
class _BrandWatermark extends StatelessWidget {
  const _BrandWatermark({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode;
    final asset = switch (lang) {
      'ko' => 'assets/app_logos/app_logo_ko.svg',
      'ja' => 'assets/app_logos/app_logo_ja.svg',
      _ => 'assets/app_logos/app_logo_en.svg',
    };
    return SvgPicture.asset(
      asset,
      height: 14.h,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }
}
