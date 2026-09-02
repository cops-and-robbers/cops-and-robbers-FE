import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/services/vibration_service.dart';
import '../../../../l10n/app_localizations.dart';
import 'community_sheet_scaffold.dart';

/// 어느 휠이 펼쳐져 있는지. 한 번에 하나만 열린다 — 둘 다 열면 시트가
/// 화면을 넘고, iOS 기본 날짜 입력도 같은 방식이다.
enum _OpenWheel { none, date, time }

/// 모임 일시 선택 바텀시트
///
/// 날짜·시간을 각각 한 행으로 보여주고, 행을 탭하면 그 아래에 해당 휠이 펼쳐진다.
/// 두 휠을 나란히 세우면(= `CupertinoDatePickerMode.dateAndTime`) 좁은 폭에서
/// 날짜 열이 뭉개져 읽기 어렵다.
///
/// 선택 결과는 [Navigator.pop]으로 돌려준다. 바깥을 탭해 닫으면 null.
class CommunityDateSheet extends StatefulWidget {
  const CommunityDateSheet({super.key, required this.initial});

  /// 이미 고른 값. 처음 여는 경우 null.
  final DateTime? initial;

  static Future<DateTime?> show(BuildContext context, {DateTime? initial}) {
    return CommunitySheetScaffold.show<DateTime>(
      context,
      builder: (_) => CommunityDateSheet(initial: initial),
    );
  }

  @override
  State<CommunityDateSheet> createState() => _CommunityDateSheetState();
}

class _CommunityDateSheetState extends State<CommunityDateSheet> {
  late DateTime _current;
  _OpenWheel _open = _OpenWheel.none;

  /// 분 휠 간격. 모임 시간을 1분 단위로 고를 일은 없고, 그만큼 휠이 길어진다.
  static const int _minuteInterval = 10;

  /// 시트 높이 — 다른 바텀시트와 맞춘 고정값. 휠을 펼쳐도 시트가 커지지 않는다.
  static double get _sheetHeight => 340.h;

  /// 행 높이 — 인원 시트의 빠른 증가 칩과 같은 값으로 맞춘다.
  static double get _rowHeight => 34.h;

  /// 펼쳐진 휠 높이 — [_sheetHeight]에서 헤더·구분선·두 행·여백을 뺀 나머지다.
  /// 24+16+12+1+20 + 34+12+34 + 8 + 20(하단) = 181, 340−181 = 159.
  static double get _wheelHeight => 156.h;

  /// 날짜 휠 하한. 열려 있는 동안 고정한다 — `build`마다 다시 계산하면
  /// 하한이 앞으로 밀려 이미 고른 값이 범위 밖으로 떨어진다.
  late final DateTime _minimumDate;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _minimumDate = DateTime(now.year, now.month, now.day);

    final initial = widget.initial ?? _ceilToInterval(now);
    _current = initial.isBefore(_minimumDate) ? _ceilToInterval(now) : initial;
  }

  /// [_minuteInterval]의 배수로 올림한다.
  ///
  /// `CupertinoDatePicker`는 `initialDateTime.minute`이 간격의 배수가 아니면
  /// assert로 죽는다.
  static DateTime _ceilToInterval(DateTime value) {
    final floored = DateTime(
      value.year,
      value.month,
      value.day,
      value.hour,
      value.minute,
    );
    final remainder = floored.minute % _minuteInterval;
    if (remainder == 0) return floored;
    return floored.add(Duration(minutes: _minuteInterval - remainder));
  }

  void _toggle(_OpenWheel target) {
    VibrationService.instance().buttonTap();
    setState(() => _open = _open == target ? _OpenWheel.none : target);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return CommunitySheetScaffold(
      title: l10n.communityDateSheetTitle,
      onDone: () => Navigator.of(context).pop(_current),
      height: _sheetHeight,
      showDivider: true,
      children: [
        _buildRow(
          label: l10n.communityCreateLabelDate,
          value: _formatDate(l10n),
          target: _OpenWheel.date,
        ),
        if (_open == _OpenWheel.date) _buildDateWheel(),
        SizedBox(height: AppSpacing.vertical12),
        _buildRow(
          label: l10n.communityDateSheetRowTime,
          value: _formatTime(),
          target: _OpenWheel.time,
        ),
        if (_open == _OpenWheel.time) _buildTimeWheel(),
      ],
    );
  }

  /// 라벨과 값이 같은 스타일을 쓴다 — 시안에서 둘의 무게 차이가 없다.
  static TextStyle get _rowTextStyle =>
      AppTextStyles.paragraph_14.copyWith(color: AppColors.black700);

  /// 라벨은 왼쪽, 값은 오른쪽. 행 전체가 탭 영역이다.
  Widget _buildRow({
    required String label,
    required String value,
    required _OpenWheel target,
  }) {
    return Semantics(
      button: true,
      label: '$label $value',
      excludeSemantics: true,
      onTap: () => _toggle(target),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _toggle(target),
        child: Container(
          height: _rowHeight,
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.horizontal18),
          decoration: BoxDecoration(
            color: AppColors.black100,
            borderRadius: AppRadius.medium,
          ),
          child: Row(
            children: [
              Text(label, style: _rowTextStyle),
              const Spacer(),
              Text(value, style: _rowTextStyle),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateWheel() {
    return _wrapWheel(
      CupertinoDatePicker(
        key: const ValueKey(_OpenWheel.date),
        mode: CupertinoDatePickerMode.date,
        initialDateTime: _current,
        minimumDate: _minimumDate,
        // 고른 날짜만 갈아끼우고 시각은 그대로 둔다 — 날짜 휠은 시·분을
        // 자정으로 돌려주므로 그대로 쓰면 시간 선택이 지워진다.
        onDateTimeChanged: (value) => setState(() {
          _current = DateTime(
            value.year,
            value.month,
            value.day,
            _current.hour,
            _current.minute,
          );
        }),
      ),
    );
  }

  Widget _buildTimeWheel() {
    return _wrapWheel(
      CupertinoDatePicker(
        key: const ValueKey(_OpenWheel.time),
        mode: CupertinoDatePickerMode.time,
        initialDateTime: _current,
        // 휠은 오전/오후 12시간제. 위 행의 값은 24시간(14:30) 그대로다 —
        // 시안이 그렇고, 값은 짧게 읽히는 편이 목록 카드 표기와도 맞는다.
        // 오전/오후 라벨은 GlobalCupertinoLocalizations가 로케일별로 준다.
        use24hFormat: false,
        minuteInterval: _minuteInterval,
        onDateTimeChanged: (value) => setState(() {
          _current = DateTime(
            _current.year,
            _current.month,
            _current.day,
            value.hour,
            value.minute,
          );
        }),
      ),
    );
  }

  /// 휠도 행과 같은 회색 카드 위에 올린다 — 시안에서 둘이 이어진 한 덩어리로 보인다.
  Widget _wrapWheel(Widget wheel) {
    return Container(
      height: _wheelHeight,
      margin: EdgeInsets.only(top: AppSpacing.vertical8),
      decoration: BoxDecoration(
        color: AppColors.black100,
        borderRadius: AppRadius.medium,
      ),
      // 휠 글꼴은 Cupertino 테마에서 온다 — 덮지 않으면 이 시트만 시스템 서체다.
      child: CupertinoTheme(
        data: CupertinoThemeData(
          textTheme: CupertinoTextThemeData(
            dateTimePickerTextStyle: AppTextStyles.label16Medium.copyWith(
              color: AppColors.black700,
            ),
          ),
        ),
        child: wheel,
      ),
    );
  }

  /// `26.08.29 목`
  ///
  /// `DateFormat`에 로케일을 넘기려면 `initializeDateFormatting`이 필요한데 이 앱은
  /// 그걸 호출하지 않는다. 요일을 ARB에서 꺼내 조립한다
  /// (`community_post_card.dart:196`과 같은 방식).
  String _formatDate(AppLocalizations l10n) {
    final weekdays = [
      l10n.weekdayMon,
      l10n.weekdayTue,
      l10n.weekdayWed,
      l10n.weekdayThu,
      l10n.weekdayFri,
      l10n.weekdaySat,
      l10n.weekdaySun,
    ];
    return l10n.communityDateSheetRowDateValue(
      _pad(_current.year % 100),
      _pad(_current.month),
      _pad(_current.day),
      weekdays[_current.weekday - 1],
    );
  }

  /// `14:30`
  String _formatTime() => '${_pad(_current.hour)}:${_pad(_current.minute)}';

  static String _pad(int value) => value.toString().padLeft(2, '0');
}
