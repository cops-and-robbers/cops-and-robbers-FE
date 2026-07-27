#!/usr/bin/env python3
"""ARB 문구 톤·마침표 검사 — docs/i18n/UX_WRITING.md 회귀 알람.

사용법:
    python3 docs/i18n/_lint_tone.py

품질 게이트가 아니라 회귀 알람이다. 어미·마침표처럼 정규식으로 확실히
잡히는 것만 본다. 능동형/긍정형/명사+명사는 문맥 판단이라 검출하지 않는다.
해요체·경어 규칙은 한국어 전용이고, 끝 마침표 규칙만 ko/en/ja 3개 로케일
전부에 적용한다.
"""
import json
import re
import sys
from pathlib import Path

L10N_DIR = Path(__file__).resolve().parents[2] / "lib" / "l10n"
LOCALES = ("ko", "en", "ja")

# 어미 규칙 — 한국어 전용
KO_RULES = [
    ("해요체", r"(니다|니까)"),
    ("과도한 경어", r"(하시겠|시겠어요|시나요|하십|께서|님께)"),
]

# 로케일별 문장 종결 부호. '...'/'…' 로 끝나는 로딩 문구는 대상 아님
TERMINAL_PUNCTUATION = {"ko": ".", "en": ".", "ja": "。"}
ELLIPSES = ("...", "…")


def load_items(locale):
    path = L10N_DIR / f"app_{locale}.arb"
    data = json.loads(path.read_text(encoding="utf-8"))
    return {k: v for k, v in data.items() if not k.startswith("@") and isinstance(v, str)}


def find_violations(locale, items):
    """(로케일, 규칙명, 키, 값) 튜플을 순서대로 내보낸다."""
    for key, value in sorted(items.items()):
        for name, pattern in KO_RULES if locale == "ko" else []:
            if re.search(pattern, value):
                yield locale, name, key, value
        stripped = value.rstrip()
        if stripped.endswith(TERMINAL_PUNCTUATION[locale]) and not stripped.endswith(ELLIPSES):
            yield locale, "끝 마침표", key, value
    # 다이얼로그 왼쪽 버튼은 '닫기' — '취소'는 진행 중 작업이 취소된다는 오해를 부른다 (ko 전용)
    if locale == "ko" and items.get("buttonCancel") == "취소":
        yield locale, "다이얼로그 부정 버튼", "buttonCancel", items["buttonCancel"]


def main():
    found = [v for locale in LOCALES for v in find_violations(locale, load_items(locale))]

    if not found:
        total = sum(len(load_items(locale)) for locale in LOCALES)
        print(f"✅ 톤 위반 없음 (ko/en/ja {total}개 문구 검사)")
        return 0

    print(f"❌ 톤 위반 {len(found)}건\n")
    for locale, name, key, value in found:
        print(f"  [{locale}][{name}] {key}: {value}")
    return 1


if __name__ == "__main__":
    sys.exit(main())
