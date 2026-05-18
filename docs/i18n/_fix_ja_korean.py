#!/usr/bin/env python3
"""messages_all.md의 ja 컬럼에 잔존한 한글 일괄 치환

LLM 번역 시 일부 한국어 조사/단어가 일본어 문장에 섞인 케이스 수정.
"""
import re
from pathlib import Path

MD = Path(__file__).parent / "messages_all.md"

# (검색 문자열, 치환 문자열) — ja 컬럼 전체 텍스트 기준 매칭
# 일부는 단어 단위, 일부는 부분 문자열
REPLACEMENTS = [
    # 1) 가장 흔한 잔존: 한국어 조사/연결어
    ("秘密을隠した", "秘密を隠した"),
    ("아직 ネットワークに", "まだネットワークに"),

    # 2) 단독 한국어 단어
    # ja 셀에 다른 텍스트 없이 한국어만 있는 케이스는 셀 전체 비교 필요
    # → 아래 EXACT_REPLACEMENTS로 처리

    # 3) "게임" 한국어 잔존 → "ゲーム"
    ("게임중、", "ゲーム中、"),
    ("게임중, ", "ゲーム中、"),
    ("게임中、", "ゲーム中、"),
    ("게임이進行", "ゲームが進行"),
    ("게임開始", "ゲーム開始"),
    ("게임進行", "ゲーム進行"),
    ("게임終了", "ゲーム終了"),

    # 4) 부분 단어 한국어
    ("照회중에", "照会中に"),
    ("泥棒가逃げた", "泥棒が逃げた"),
    ("分 뒤", "分後"),
    ("분 뒤", "分後"),  # $placeholder분 뒤 패턴 ($placeholder는 별도 보존)
    ("기본정보を", "基本情報を"),
    ("逃게切れば", "逃げ切れば"),
    ("Cops出동時間", "Cops出動時間"),
    ("ログイン 정보를取得", "ログイン情報を取得"),
    ("위치정보利用規約", "位置情報利用規約"),
    ("マー케팅情報", "マーケティング情報"),
    ("マーケ팅情報", "マーケティング情報"),
    ("「탈퇴하기」", "「退会する」"),
    ("리퀘스트가現在", "リクエストが現在"),
    ("規약同意", "規約同意"),  # 規약 → 規約 (사실 規약은 이미 規+약. 規約로)
    ("知らせ를読み込め", "お知らせを読み込め"),
]

# ja 셀 전체가 정확히 일치하는 경우만 치환 (단독 단어)
EXACT_REPLACEMENTS = [
    ("닉네임", "ニックネーム"),
    ("뒤", "後"),
    ("탈퇴하기 または delete", "退会する または delete"),
    ("탈퇴하기", "退会する"),
    ("현재", "現在"),
]


def fix_line(line: str) -> tuple[str, int]:
    """한 라인의 ja 컬럼만 치환. (수정된 라인, 치환 횟수) 반환"""
    if not line.startswith("| ") or "|---|" in line:
        return line, 0
    cells = line.split("|")
    if len(cells) < 9:
        return line, 0
    # 마지막에서 두 번째가 ja (마지막 cell은 trailing newline 포함 빈 셀)
    ja_idx = -2
    ja = cells[ja_idx]
    original = ja
    changed = 0

    for old, new in REPLACEMENTS:
        if old in ja:
            ja = ja.replace(old, new)
            changed += 1

    ja_stripped = ja.strip()
    for old, new in EXACT_REPLACEMENTS:
        if ja_stripped == old:
            # 앞뒤 공백 유지하며 치환
            leading = len(ja) - len(ja.lstrip())
            trailing = len(ja) - len(ja.rstrip())
            ja = " " * leading + new + " " * trailing
            changed += 1
            break

    if ja != original:
        cells[ja_idx] = ja
        return "|".join(cells), changed
    return line, 0


def main():
    lines = MD.read_text(encoding="utf-8").splitlines(keepends=True)
    fixed_lines = []
    total_changes = 0
    affected_lines = 0
    for line in lines:
        new_line, changes = fix_line(line)
        fixed_lines.append(new_line)
        if changes:
            total_changes += changes
            affected_lines += 1
    MD.write_text("".join(fixed_lines), encoding="utf-8")
    print(f"✅ 수정 완료")
    print(f"   영향 받은 라인: {affected_lines}")
    print(f"   총 치환 횟수: {total_changes}")


if __name__ == "__main__":
    main()
