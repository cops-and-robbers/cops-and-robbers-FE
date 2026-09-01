/// 게임 설정 4개 항목의 숫자 편집 규칙
///
/// 기본 정보 화면(생성)과 설정 수정 화면(대기실)이 같은 규칙을 공유한다.
/// 위젯이 아니라 순수 상태라 화면은 mutate 후 setState 만 하면 된다.
library;

import '../../../../l10n/app_localizations.dart';

/// 방 생성 시 정하는 설정 항목. 선언 순서가 곧 입력 순서다.
enum GameSettingField {
  /// 참여 인원 (2~150명)
  participants(min: 2, max: 150, quickAmounts: [5, 10, 20]),

  /// 게임 시간 (10~180분)
  roundDuration(min: 10, max: 180, quickAmounts: [5, 10, 30]),

  /// 도둑 위치 공유 간격 (0~30분, 0이면 공유하지 않음)
  locationShare(min: 0, max: 30, quickAmounts: [3, 5, 10]),

  /// 경찰 시작 시간 (도둑 시작 후 1~10분 뒤)
  policeWait(min: 1, max: 10, quickAmounts: [1, 3, 5]);

  const GameSettingField({
    required this.min,
    required this.max,
    required this.quickAmounts,
  });

  final int min;
  final int max;

  /// 키패드 빠른 추가 칩의 증가량 3개
  final List<int> quickAmounts;
}

/// 설정 값 4개와 입력 상태
///
/// 입력 규칙:
/// - 항목이 활성화된 직후의 첫 숫자는 기존 값을 지우고 새로 시작한다
/// - 이어치기로 상한을 넘는 입력은 무시한다
/// - 빠른 추가는 현재 값에 더하되 상한에서 멈춘다
/// - 지우기는 한 자리씩 줄인다 (5 → 0, 50 → 5)
///
/// 위치 공유 간격과 경찰 시작 시간은 게임 시간보다 짧아야 한다. 서버도 같은
/// 조합을 거절하지만(INVALID_LOCATION_INTERVAL 등) 여기서 먼저 잡는다.
class GameSettingValues {
  GameSettingValues({
    required int participants,
    required int roundDuration,
    required int locationShare,
    required int policeWait,
    bool touched = false,
  }) : _values = [participants, roundDuration, locationShare, policeWait],
       _touched = List.filled(GameSettingField.values.length, touched);

  final List<int> _values;

  /// 항목별로 사용자의 입력이 한 번이라도 닿았는지 (제안값 연한 표시용)
  final List<bool> _touched;

  /// 현재 키패드가 겨냥하는 항목
  GameSettingField active = GameSettingField.participants;

  /// 활성화 직후인지 — 첫 숫자 입력이 값을 교체해야 하는 상태
  bool _freshEntry = true;

  /// 직전 입력이 상한 때문에 막혔는지 (안내 문구용)
  ///
  /// 다음 입력이 받아들여지거나 항목이 바뀌면 풀린다.
  bool lastInputExceededMax = false;

  int operator [](GameSettingField field) => _values[field.index];

  bool isTouched(GameSettingField field) => _touched[field.index];

  /// 항목을 키패드의 과녁으로 만든다. 다음 첫 숫자는 값을 교체한다.
  void activate(GameSettingField field) {
    active = field;
    _freshEntry = true;
    lastInputExceededMax = false;
  }

  void inputDigit(int digit) {
    assert(digit >= 0 && digit <= 9);
    final next = _freshEntry ? digit : this[active] * 10 + digit;
    _freshEntry = false;
    _touched[active.index] = true;
    if (next > active.max) {
      // 상한을 넘는 이어치기는 무시하고 안내만 남긴다
      lastInputExceededMax = true;
      return;
    }
    lastInputExceededMax = false;
    _values[active.index] = next;
  }

  void backspace() {
    _freshEntry = false;
    _touched[active.index] = true;
    lastInputExceededMax = false;
    _values[active.index] = this[active] ~/ 10;
  }

  void quickAdd(int amount) {
    _freshEntry = false;
    _touched[active.index] = true;
    final next = this[active] + amount;
    // 이미 상한이면 안내를, 상한을 지나치면 상한에서 멈춘다
    lastInputExceededMax = this[active] >= active.max;
    _values[active.index] = next > active.max ? active.max : next;
  }

  /// 게임 시간과의 관계까지 반영한 항목별 실질 상한
  int effectiveMax(GameSettingField field) {
    final round = this[GameSettingField.roundDuration];
    return switch (field) {
      GameSettingField.locationShare ||
      GameSettingField.policeWait => field.max < round ? field.max : round - 1,
      _ => field.max,
    };
  }

  bool isValid(GameSettingField field) {
    final value = this[field];
    return value >= field.min && value <= effectiveMax(field);
  }

  /// 게임 시간보다 짧아야 하는 제약에 걸렸는지 (하한 미달과 구분해 문구를 가른다)
  bool violatesRoundDuration(GameSettingField field) {
    return this[field] >= field.min && this[field] > effectiveMax(field);
  }

  bool get allValid => GameSettingField.values.every(isValid);
}

/// 항목 이름 (카드 라벨)
String settingFieldLabel(AppLocalizations l10n, GameSettingField field) {
  return switch (field) {
    GameSettingField.participants => l10n.labelParticipantCount,
    GameSettingField.roundDuration => l10n.fieldRoundTimeLimit,
    GameSettingField.locationShare => l10n.fieldLocationShareInterval,
    GameSettingField.policeWait => l10n.fieldPoliceDispatchTime,
  };
}

/// 값 뒤에 붙는 단위
String settingFieldUnit(AppLocalizations l10n, GameSettingField field) {
  return field == GameSettingField.participants
      ? l10n.unitPerson
      : l10n.unitMinutes;
}

/// 카드에 띄울 안내 문구와 경고 여부. 없으면 null.
///
/// 인원은 하한 안내를 상시 노출하고 위반 시 경고로 바꾼다. 나머지는 위반했을
/// 때만 띄운다. 위치 공유 0은 위반이 아니라 "공유하지 않음" 안내다.
(String, bool)? settingFieldHint(
  AppLocalizations l10n,
  GameSettingValues values,
  GameSettingField field,
) {
  // 방금 상한 때문에 입력이 막혔으면 그 이유를 먼저 알린다
  if (field == values.active && values.lastInputExceededMax) {
    return (
      l10n.warnMaxReached('${field.max}${settingFieldUnit(l10n, field)}'),
      true,
    );
  }
  final invalid = !values.isValid(field);
  switch (field) {
    case GameSettingField.participants:
      return (l10n.sessionCreationStepParticipantsHint, invalid);
    case GameSettingField.roundDuration:
      return invalid ? (l10n.warnRoundDurationRange, true) : null;
    case GameSettingField.locationShare:
      if (values.violatesRoundDuration(field)) {
        return (l10n.warnShorterThanRoundDuration, true);
      }
      if (values[field] == 0) {
        return (l10n.gameSettingNoLocationShareWarning, false);
      }
      return null;
    case GameSettingField.policeWait:
      if (values.violatesRoundDuration(field)) {
        return (l10n.warnShorterThanRoundDuration, true);
      }
      return invalid ? (l10n.warnPoliceWaitMin, true) : null;
  }
}
