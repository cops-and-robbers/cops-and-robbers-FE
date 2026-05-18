#!/usr/bin/env python3
"""i18n 메시지 통합 추출 스크립트
- lib/ 전체에서 한국어 string literal 추출 (사용자 노출만)
- assets/messages/*.json도 포함
- docs/i18n/messages_all.md로 통합 출력
"""
import json
import re
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent.parent
LIB = ROOT / "lib"
ASSETS = ROOT / "assets" / "messages"
OUTPUT = ROOT / "docs" / "i18n" / "messages_all.md"

# 사용자 미노출 패턴 (debugPrint, AppLogger, assert, 주석)
# 주의: throw는 제외 안 함 - Custom Exception 메시지는 사용자 노출 가능성 있음
SKIP_LINE_PATTERNS = [
    re.compile(r"\bdebugPrint\s*\("),
    re.compile(r"\bAppLogger\."),
    re.compile(r"^\s*print\s*\("),
    re.compile(r"\bassert\s*\("),
    re.compile(r"^\s*///"),
    re.compile(r"^\s*//"),
]

# 메시지 자체가 디버그성으로 강한 신호 (한국어 string 내용으로 판정)
DEBUG_MESSAGE_PATTERNS = [
    # 이모지 prefix (한국어 메시지 시작이 이모지면 거의 디버그)
    re.compile(r"^[\U0001F300-\U0001FAFF☀-➿✅❌🔄📱⚠🔍💡🚨🎯🔥🎮❓📍📤📥🔵🟢🟡🔴🚀⏳]"),
    # [Service]/[Notifier]/[Module] 같은 대괄호 prefix
    re.compile(r"^\s*\[[A-Z][A-Za-z0-9_]+\]"),
]

# 멀티라인 함수 호출의 인자로 string만 있는 패턴 (콤마 끝)
ARG_ONLY_LINE_RE = re.compile(r"""^\s*(['"])[^'"]*[가-힣][^'"]*\1,?\s*$""")

# 디버그/로그 함수 호출 시작 패턴 (함수명만)
DEBUG_FUNC_RE = re.compile(r"\b(debugPrint|print|AppLogger\.\w+)\s*\(")

# 무시할 파일 (테스트, 예제, 생성 파일)
SKIP_FILE_PATTERNS = [
    re.compile(r"\.g\.dart$"),
    re.compile(r"\.freezed\.dart$"),
    re.compile(r"/lifecycle_test/"),
    re.compile(r"/test_widget_page\.dart$"),
    re.compile(r"_example\.dart$"),
    re.compile(r"_test_page\.dart$"),
    re.compile(r"/profanity_filter\.dart$"),  # 욕설 필터 리스트
]

# 한국어 string literal (single/double quote)
KOREAN_STRING_RE = re.compile(r"""(['"])([^'"]*?[가-힣][^'"]*?)\1""")

# placeholder 검출
PLACEHOLDER_RE = re.compile(r"\$\{[\w.]+\}|\$\w+|\{[\w]+\}")


def relpath(p: Path) -> str:
    return str(p.relative_to(ROOT))


def should_skip_file(filepath: str) -> bool:
    return any(p.search(filepath) for p in SKIP_FILE_PATTERNS)


def should_skip_line(line: str) -> bool:
    return any(p.search(line) for p in SKIP_LINE_PATTERNS)


def is_debug_message(ko_text: str) -> bool:
    """메시지 자체가 디버그/로그성인지 판정 (이모지/대괄호 prefix)"""
    return any(p.search(ko_text) for p in DEBUG_MESSAGE_PATTERNS)


def is_in_debug_call(lines: list[str], line_idx: int) -> bool:
    """현재 라인이 멀티라인 debugPrint/AppLogger 호출 안에 있는지 판정.

    예:
        AppLogger.info(
          '한국어 메시지',  ← 이 라인
          e, stack,
        );

    위로 거슬러 올라가면서 괄호 균형을 추적하고,
    아직 열린 함수 호출을 만나면 그 함수명이 디버그 패턴인지 확인
    """
    line = lines[line_idx]
    stripped = line.strip()
    # 현재 라인이 "string only" 형태가 아니면 단일 라인 함수 호출일 가능성 높음
    if not ARG_ONLY_LINE_RE.match(stripped):
        return False

    paren_balance = 0
    # 현재 라인의 괄호도 포함
    for i in range(line_idx, max(-1, line_idx - 15), -1):
        l = lines[i]
        # 라인 단위로 괄호 카운트 (문자열 내부 괄호도 세지만, 단순화)
        paren_balance += l.count(")") - l.count("(")
        if paren_balance < 0:
            # 열린 함수 호출 발견
            if DEBUG_FUNC_RE.search(l):
                return True
            return False  # 다른 함수 호출 — 디버그 아님
    return False


def derive_feature(filepath: str) -> str:
    """파일 경로에서 feature/scope 도출"""
    p = filepath.replace("lib/", "")
    if p.startswith("core/"):
        # core/widgets/dialogs/app_dialog.dart → core_dialogs
        parts = p.split("/")
        if "widgets" in parts:
            idx = parts.index("widgets")
            if idx + 1 < len(parts):
                return f"core_{parts[idx+1]}"
        if "constants" in parts:
            return "core_constants"
        if "errors" in parts:
            return "core_errors"
        if "network" in parts:
            return "core_network"
        if "services" in parts:
            return "core_services"
        return "core"
    if p.startswith("features/"):
        # features/auth/... → auth
        return p.split("/")[1]
    if p.startswith("router/"):
        return "router"
    return "misc"


def filename_to_camel(filename: str) -> str:
    """home_page.dart → homePage"""
    stem = filename.replace(".dart", "")
    parts = stem.split("_")
    return parts[0] + "".join(w.capitalize() for w in parts[1:])


def make_key(feature: str, filepath: str, line_no: int, idx: int) -> str:
    filename = filepath.split("/")[-1]
    base = filename_to_camel(filename)
    suffix = f"L{line_no}" + (f"_{idx}" if idx > 0 else "")
    # ARB 키는 영문 시작 권장
    return f"{feature}_{base}_{suffix}"


def escape_md_cell(s: str) -> str:
    """마크다운 표 셀용 이스케이프"""
    return (
        s.replace("\\", "\\\\")
        .replace("|", "\\|")
        .replace("\n", "\\n")
        .replace("\r", "")
    )


def extract_placeholders(s: str) -> str:
    matches = PLACEHOLDER_RE.findall(s)
    if not matches:
        return "-"
    # 중복 제거, 등장 순서 유지
    seen = []
    for m in matches:
        if m not in seen:
            seen.append(m)
    return ", ".join(seen)


def trim_trailing_period(s: str) -> str:
    """문장 끝 마침표 제거 (컨벤션). 단 ... 는 유지"""
    if s.endswith("..."):
        return s
    if s.endswith("."):
        return s[:-1]
    return s


# ===== 추출 =====
rows_by_feature: dict[str, list[dict]] = {}

dart_files = sorted(LIB.rglob("*.dart"))
for fp in dart_files:
    rel = relpath(fp)
    if should_skip_file(rel):
        continue
    try:
        content = fp.read_text(encoding="utf-8")
    except Exception:
        continue

    feature = derive_feature(rel)
    rows_by_feature.setdefault(feature, [])

    all_lines = content.splitlines()
    for line_no, line in enumerate(all_lines, start=1):
        if should_skip_line(line):
            continue
        matches = list(KOREAN_STRING_RE.finditer(line))
        if not matches:
            continue
        # 멀티라인 디버그 호출 컨텍스트 체크 (한 번만)
        if is_in_debug_call(all_lines, line_no - 1):
            continue
        for idx, m in enumerate(matches):
            raw = m.group(2)
            # 메시지 자체가 디버그성이면 제외
            if is_debug_message(raw):
                continue
            ko_cleaned = trim_trailing_period(raw)
            code_snippet = line.strip()[:120]
            placeholders = extract_placeholders(raw)
            key = make_key(feature, rel, line_no, idx)
            rows_by_feature[feature].append({
                "key": key,
                "location": f"{rel}:{line_no}",
                "code": code_snippet,
                "placeholders": placeholders,
                "ko": ko_cleaned,
            })


# ===== assets/messages/*.json 처리 =====
json_rows: list[dict] = []


def walk_json(obj, path_parts, source_file):
    if isinstance(obj, dict):
        for k, v in obj.items():
            walk_json(v, path_parts + [k], source_file)
    elif isinstance(obj, list):
        for i, v in enumerate(obj):
            walk_json(v, path_parts + [str(i)], source_file)
    elif isinstance(obj, str):
        if not any("가" <= c <= "힣" for c in obj):
            return  # 한글 없으면 스킵
        key_path = ".".join(path_parts)
        # ARB 키: 파일명 + 경로 (camelCase)
        file_stem = source_file.stem.replace("_messages", "").replace("_", "")
        sanitized = "".join(
            (p if p.isalnum() else "_") for p in key_path
        )
        # camelCase로
        parts = re.split(r"[._\d]+", sanitized)
        parts = [p for p in parts if p]
        camel = parts[0].lower() + "".join(p.capitalize() for p in parts[1:])
        key = f"asset_{file_stem}_{camel}"
        placeholders = extract_placeholders(obj)
        json_rows.append({
            "key": key,
            "location": f"assets/messages/{source_file.name} :: {key_path}",
            "code": f'"{key_path}": "{obj[:80]}..."' if len(obj) > 80 else f'"{key_path}": "{obj}"',
            "placeholders": placeholders,
            "ko": trim_trailing_period(obj),
        })


for json_file in sorted(ASSETS.glob("*.json")):
    with open(json_file, encoding="utf-8") as f:
        data = json.load(f)
    walk_json(data, [], json_file)


# ===== 통계 =====
total_lib = sum(len(r) for r in rows_by_feature.values())
total_json = len(json_rows)
print(f"lib/ 추출: {total_lib}건")
print(f"assets/messages 추출: {total_json}건")
print(f"총: {total_lib + total_json}건")
print()
print("feature별 분포:")
for f in sorted(rows_by_feature.keys(), key=lambda k: -len(rows_by_feature[k])):
    print(f"  {f}: {len(rows_by_feature[f])}")


# ===== .md 작성 =====
out = []
out.append("# 전체 한국어 메시지 인벤토리 (LLM 번역용)")
out.append("")
out.append("> **자동 생성된 파일** — `docs/i18n/_extract.py` 실행 결과")
out.append(f"> **총 {total_lib + total_json}건** (lib/ {total_lib} + assets/messages/ {total_json})")
out.append("> 관련 문서: [README.md](README.md), [glossary.md](glossary.md)")
out.append("")
out.append("## LLM에게 번역 요청 시")
out.append("")
out.append("1. 본 파일과 [glossary.md](glossary.md)를 **함께** 전달")
out.append("2. 사용 프롬프트는 [README.md의 프롬프트 템플릿](README.md#llm에게-보낼-때-사용할-프롬프트-템플릿) 참조")
out.append("3. **표 구조 유지**, `en`/`ja` 컬럼만 채워서 반환")
out.append("4. `key` 컬럼은 임시 자동 키 — 번역 후 ARB 가공 단계에서 의미 기반 키로 다듬어짐 (LLM은 건드릴 필요 없음)")
out.append("")
out.append("## 컬럼 설명")
out.append("")
out.append("| 컬럼 | 설명 |")
out.append("|---|---|")
out.append("| `key` | 임시 ARB 키 (자동 생성: `<feature>_<filename>_L<line>`) |")
out.append("| `location` | 원본 파일:라인 (추적용) |")
out.append("| `code` | 원본 코드 스니펫 (번역 컨텍스트 단서) |")
out.append("| `placeholders` | 보호해야 할 변수 (`{name}`, `$count` 등) — 절대 번역/변형 금지 |")
out.append("| `ko` | 원본 한국어 (문장 끝 마침표 자동 제거됨) |")
out.append("| `en` | **번역 대상** — sentence case, 마침표 없음 |")
out.append("| `ja` | **번역 대상** — です/ます체, 마침표 없음 |")
out.append("")
out.append("---")
out.append("")

# 섹션 1: assets/messages (먼저 — 핵심 외부화 메시지)
out.append("## 섹션 1: assets/messages/*.json (이미 외부화된 메시지)")
out.append("")
out.append(f"**{total_json}건** — `loading_messages.json`, `location_permission_messages.json`")
out.append("")
out.append("| key | location | code | placeholders | ko | en | ja |")
out.append("|---|---|---|---|---|---|---|")
for r in json_rows:
    out.append(
        f"| {r['key']} | {escape_md_cell(r['location'])} | {escape_md_cell(r['code'])} | "
        f"{escape_md_cell(r['placeholders'])} | {escape_md_cell(r['ko'])} | TODO | TODO |"
    )
out.append("")

# 섹션 2~: feature별
sorted_features = sorted(rows_by_feature.keys(), key=lambda k: -len(rows_by_feature[k]))
for idx, feature in enumerate(sorted_features, start=2):
    rows = rows_by_feature[feature]
    if not rows:
        continue
    out.append(f"## 섹션 {idx}: `{feature}` ({len(rows)}건)")
    out.append("")
    out.append("| key | location | code | placeholders | ko | en | ja |")
    out.append("|---|---|---|---|---|---|---|")
    for r in rows:
        out.append(
            f"| {r['key']} | {escape_md_cell(r['location'])} | {escape_md_cell(r['code'])} | "
            f"{escape_md_cell(r['placeholders'])} | {escape_md_cell(r['ko'])} | TODO | TODO |"
        )
    out.append("")

OUTPUT.write_text("\n".join(out), encoding="utf-8")
print(f"\n✅ 생성: {relpath(OUTPUT)}")
print(f"   행 수: {sum(1 for _ in OUTPUT.open())}")
