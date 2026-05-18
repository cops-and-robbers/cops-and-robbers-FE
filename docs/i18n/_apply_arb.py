#!/usr/bin/env python3
"""매핑 결과(_arb_mapping_*.md)를 읽어 ARB 파일 3종(ko/en/ja)에 키-값 추가.

사용법:
    python3 docs/i18n/_apply_arb.py <prefix>
    예: python3 docs/i18n/_apply_arb.py core_
"""
import json
import re
import sys
from collections import OrderedDict
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent.parent
MD = ROOT / "docs" / "i18n" / "messages_all.md"
ARB_DIR = ROOT / "lib" / "l10n"


def parse_messages_md():
    """원본 messages_all.md 파싱 (translated/code 포함)"""
    rows = []
    with MD.open(encoding="utf-8") as f:
        for line in f:
            if not line.startswith("| ") or "|---|" in line or "| key" in line or "| ko " in line:
                continue
            protected = line.replace(r"\|", "\x00")
            cells = [c.replace("\x00", "|").strip() for c in protected.split("|")]
            if len(cells) < 8:
                continue
            key = cells[1]
            if not key or "_" not in key:
                continue
            rows.append({
                "auto_key": key,
                "location": cells[2],
                "code": cells[3],
                "placeholders": cells[4],
                "ko": cells[5],
                "en": cells[6],
                "ja": cells[7],
            })
    return rows


def dart_to_icu_placeholder(text):
    """Dart string interpolation을 ICU MessageFormat으로 변환

    핵심: ARB placeholder 이름은 **ASCII 영문/숫자/언더스코어만** 허용
    (한국어/일본어가 \\w에 포함되지 않도록 명시적 패턴 사용)

    예:
    - $minutes분입니다       → {minutes}분입니다       (ko)
    - $count人 逃走中        → {count}人 逃走中        (ja)
    - ${response.gameId}     → {gameId}                (마지막 식별자)
    - ${radiusMeters!.toInt()} → {radiusMeters}        (메서드 토큰 제거)
    """
    # ${복합.표현} → {대표 식별자} — 메서드 호출 토큰 제거 후 마지막 식별자 사용
    def replace_complex(m):
        expr = m.group(1)
        # `.`으로 분리, 괄호 있는 토큰은 메서드 호출이므로 제외
        tokens = [t for t in expr.split(".") if "(" not in t]
        if not tokens:
            return "{value}"
        last = tokens[-1]
        # 영문 식별자만 추출 (`!`, 공백, [] 등 부착물 제거)
        ident = re.search(r"[a-zA-Z_][a-zA-Z0-9_]*", last)
        return "{" + (ident.group(0) if ident else "value") + "}"

    text = re.sub(r"\$\{([^}]+)\}", replace_complex, text)
    # $simpleVar → {simpleVar} — ASCII 식별자 한정 (한글/일본어 문자는 매칭 안 함)
    text = re.sub(r"\$([a-zA-Z_][a-zA-Z0-9_]*)", r"{\1}", text)
    return text


def extract_placeholder_names(text):
    """ICU {name} 패턴에서 placeholder 이름 추출"""
    return list(dict.fromkeys(re.findall(r"\{(\w+)\}", text)))


def normalize_escapes(text):
    """messages_all.md에 텍스트로 들어간 escape 시퀀스를 실제 문자로 변환.

    md 추출 시 백슬래시가 1배~4배로 누적될 수 있어 정규식으로 일괄 처리.
    `\\+n` → 줄바꿈, `\\+t` → 탭
    """
    text = re.sub(r"\\+n", "\n", text)
    text = re.sub(r"\\+t", "\t", text)
    return text


def infer_placeholder_type(name):
    """이름으로 타입 추정 (count/minutes/gameId/seconds → int, 나머지 String)"""
    int_hints = ["count", "minutes", "seconds", "hours", "days", "num", "id",
                 "amount", "size", "length", "index", "page"]
    name_lower = name.lower()
    for hint in int_hints:
        if hint in name_lower:
            return "int"
    return "String"


def import_build_arb():
    """_build_arb.py의 derive_semantic_key 재사용"""
    sys.path.insert(0, str(ROOT / "docs" / "i18n"))
    import importlib.util
    spec = importlib.util.spec_from_file_location(
        "_build_arb", ROOT / "docs" / "i18n" / "_build_arb.py"
    )
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod


def main():
    if len(sys.argv) < 2:
        print("Usage: _apply_arb.py <prefix1> [prefix2 ...]")
        sys.exit(1)
    prefixes = sys.argv[1:]

    build_arb = import_build_arb()
    rows = parse_messages_md()
    filtered = [r for r in rows if any(r["auto_key"].startswith(p) for p in prefixes)]
    filtered = [r for r in filtered if "[SKIP" not in r["en"] and "[SKIP" not in r["ja"]]

    # 의미 키 적용 + 중복 통합
    mappings = OrderedDict()
    for r in filtered:
        sem_key = build_arb.derive_semantic_key(r)
        if sem_key in mappings:
            existing = mappings[sem_key]
            if existing["ko"] != r["ko"]:
                # 같은 키인데 다른 메시지 — hash suffix 추가
                sem_key = sem_key + build_arb._hash_short(r["ko"])
                mappings[sem_key] = r
        else:
            mappings[sem_key] = r

    # ARB용 placeholders 메타데이터 생성
    arb_entries = []  # (key, ko_value, en_value, ja_value, placeholders_meta)
    for sem_key, r in mappings.items():
        ko_icu = dart_to_icu_placeholder(normalize_escapes(r["ko"]))
        en_icu = dart_to_icu_placeholder(normalize_escapes(r["en"]))
        ja_icu = dart_to_icu_placeholder(normalize_escapes(r["ja"]))
        ph_names = extract_placeholder_names(ko_icu)
        ph_meta = None
        if ph_names:
            ph_meta = {
                name: {"type": infer_placeholder_type(name)}
                for name in ph_names
            }
        arb_entries.append((sem_key, ko_icu, en_icu, ja_icu, ph_meta, r["location"]))

    # ARB 파일에 추가 (기존 키 유지)
    for locale, value_idx in [("ko", 1), ("en", 2), ("ja", 3)]:
        arb_path = ARB_DIR / f"app_{locale}.arb"
        with arb_path.open(encoding="utf-8") as f:
            data = json.load(f, object_pairs_hook=OrderedDict)

        added = 0
        skipped = 0
        for entry in arb_entries:
            key = entry[0]
            value = entry[value_idx]
            ph_meta = entry[4]
            location = entry[5]
            if key in data:
                skipped += 1
                continue
            data[key] = value
            # 메타데이터는 template (ko)에만 작성 (ARB 표준)
            if locale == "ko":
                meta = OrderedDict()
                meta["description"] = f"auto-imported from {location}"
                if ph_meta:
                    meta["placeholders"] = ph_meta
                data[f"@{key}"] = meta
            added += 1

        with arb_path.open("w", encoding="utf-8") as f:
            json.dump(data, f, ensure_ascii=False, indent=2)
            f.write("\n")
        print(f"  app_{locale}.arb: +{added}건 추가, {skipped}건 스킵 (이미 존재)")

    print(f"\n✅ ARB 업데이트 완료: {len(arb_entries)}개 키 처리")
    print(f"   적용 prefix: {prefixes}")


if __name__ == "__main__":
    main()
