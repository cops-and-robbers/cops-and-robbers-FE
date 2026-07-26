#!/usr/bin/env python3
"""app_ko.arb 문구 톤 검사 — docs/i18n/UX_WRITING.md 회귀 알람.

사용법:
    python3 docs/i18n/_lint_tone.py

품질 게이트가 아니라 회귀 알람이다. 어미·마침표처럼 정규식으로 확실히
잡히는 것만 본다. 능동형/긍정형/명사+명사는 문맥 판단이라 검출하지 않는다.
"""
import json
import re
import sys
from pathlib import Path

ARB = Path(__file__).resolve().parents[2] / "lib" / "l10n" / "app_ko.arb"

RULES = [
    ("해요체", r"(습니다|입니다|십시오)"),
    ("과도한 경어", r"(하시겠|시겠어요|시나요|하십|께서|님께)"),
]


def find_violations(items):
    """(규칙명, 키, 값) 튜플을 순서대로 내보낸다."""
    for key, value in sorted(items.items()):
        for name, pattern in RULES:
            if re.search(pattern, value):
                yield name, key, value
        stripped = value.rstrip()
        # '...' 로딩 문구는 마침표 규칙 대상이 아니다
        if stripped.endswith(".") and not stripped.endswith("..."):
            yield "끝 마침표", key, value
    # 다이얼로그 왼쪽 버튼은 '닫기' — '취소'는 진행 중 작업이 취소된다는 오해를 부른다
    if items.get("buttonCancel") == "취소":
        yield "다이얼로그 부정 버튼", "buttonCancel", items["buttonCancel"]


def main():
    data = json.loads(ARB.read_text(encoding="utf-8"))
    items = {
        k: v
        for k, v in data.items()
        if not k.startswith("@") and isinstance(v, str)
    }

    found = list(find_violations(items))
    if not found:
        print(f"✅ 톤 위반 없음 ({len(items)}개 문구 검사)")
        return 0

    print(f"❌ 톤 위반 {len(found)}건\n")
    for name, key, value in found:
        print(f"  [{name}] {key}: {value}")
    return 1


if __name__ == "__main__":
    sys.exit(main())
