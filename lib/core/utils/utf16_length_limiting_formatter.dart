import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// 서버와 같은 단위로 길이를 제한하는 포매터
///
/// 서버는 자바 문자열 길이(UTF-16 단위)로 센다. Flutter 기본 `maxLength`는 자소
/// 묶음 단위라, 이모지가 섞이면 앱은 300자로 보고 통과시키는데 서버는 그보다 길게
/// 세어 400을 준다 — 입력창 아래 "몇 자 남음"도 같은 이유로 어긋난다.
///
/// 잘라낼 때는 자소 경계를 지킨다. UTF-16 한복판에서 자르면 이모지가 깨진 조각으로
/// 남는다.
class Utf16LengthLimitingFormatter extends TextInputFormatter {
  const Utf16LengthLimitingFormatter(this.maxLength);

  final int maxLength;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.length <= maxLength) return newValue;

    final buffer = StringBuffer();
    var used = 0;
    for (final grapheme in newValue.text.characters) {
      if (used + grapheme.length > maxLength) break;
      buffer.write(grapheme);
      used += grapheme.length;
    }
    final truncated = buffer.toString();

    return TextEditingValue(
      text: truncated,
      selection: TextSelection.collapsed(offset: truncated.length),
    );
  }
}
