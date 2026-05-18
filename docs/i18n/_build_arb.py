#!/usr/bin/env python3
"""messages_all.md의 특정 섹션을 ARB 키-값 매핑으로 변환.

사용법:
    python3 docs/i18n/_build_arb.py <section_prefix> [...]
    예: python3 docs/i18n/_build_arb.py core_
"""
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent.parent
MD = ROOT / "docs" / "i18n" / "messages_all.md"
ARB_DIR = ROOT / "lib" / "l10n"


def parse_messages_md():
    """messages_all.md 파싱 → row dict 리스트"""
    rows = []
    with MD.open(encoding="utf-8") as f:
        for line in f:
            if not line.startswith("| ") or "|---|" in line or "| key" in line or "| ko " in line:
                continue
            # escape된 \|를 토큰으로 보호 후 split
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


def derive_semantic_key(row):
    """code 컨텍스트로 의미 기반 ARB 키 추론.

    규칙:
    - 파일 경로의 도메인/feature로 prefix 결정 (button/dialog/error/page/chat/loading 등)
    - code 패턴(title:/message:/confirmText:/throw Xxx(message:/Text() 등)으로 suffix 보강
    """
    auto = row["auto_key"]
    loc = row["location"]
    code = row["code"]
    ko = row["ko"]

    # 파일 경로 기반 도메인 추정
    path = loc.split(":")[0] if ":" in loc else loc

    # 1) 특수 파일 우선 처리
    if "game_event_messages.dart" in path:
        # chat 시스템 메시지 — 한국어 키워드로 우선 분류 (의미 명확화)
        if "체포했습니다" in ko or "체포" in ko and "님이" in ko:
            return "chatSystemArrest"
        if "탈옥했습니다" in ko:
            return "chatSystemEscapeNotice"
        # 일반: 코드의 변수/함수명에서 키 추출
        m = re.search(r"(?:get|static\s+(?:const|String))\s+(\w+)\s*[=(]", code)
        if not m:
            m = re.search(r"static\s+(?:const|String)\s+(\w+)\s*[=(]", code)
        suffix = m.group(1) if m else _camel_from_ko(ko)
        return f"chatSystem{_capitalize(suffix)}"

    if "dio_exception_handler.dart" in path:
        # API 에러
        # code: "message: detail.isNotEmpty ? detail : '서버에 문제가 발생했습니다.'," 같은 형태
        # 인접 라인의 case 패턴으로 추정 (한국어 메시지 내용 기반)
        hint = _classify_error(ko)
        return f"error{hint}"

    if "app_exception.dart" in path:
        return "errorAuthLoginCancelled"

    if "social_login_button.dart" in path:
        if "google" in code.lower() or "Google" in ko:
            return "buttonGoogleSignIn"
        if "apple" in code.lower() or "Apple" in ko:
            return "buttonAppleSignIn"

    if "app_dialog.dart" in path:
        if ko == "확인":
            return "buttonConfirm"
        if ko == "취소":
            return "buttonCancel"

    if "reconnect_modal.dart" in path:
        if "끊어졌" in ko or "재연결이 필요" in ko:
            return "dialogReconnectMessage"
        if "연결 중" in ko or "연결중" in ko or "..." in ko:
            return "dialogReconnectButtonConnecting"
        if ko == "재연결":
            return "dialogReconnectButtonRetry"

    if "force_update_page.dart" in path:
        if ko == "업데이트 필요":
            return "pageForceUpdateTitle"
        if "새로운 버전" in ko or "업데이트 후" in ko:
            return "pageForceUpdateMessage"
        if ko == "업데이트":
            return "pageForceUpdateButton"

    if "maintenance_page.dart" in path:
        if ko == "서버 점검 중":
            return "pageMaintenanceTitle"
        if "점검 중이에요" in ko or "다시 접속" in ko:
            return "pageMaintenanceMessage"

    if "update_dialog_helper.dart" in path:
        # optional vs mandatory 구분: "새 버전" vs "업데이트 안내"
        # 같은 라인 그룹별 추정 — 라인번호 기반
        line_no = int(loc.rsplit(":", 1)[1]) if ":" in loc else 0
        is_optional = line_no < 60
        prefix = "dialogUpdateOptional" if is_optional else "dialogUpdateMandatory"
        if ko == "새 버전 안내" or ko == "업데이트 안내":
            return f"{prefix}Title"
        if "더 좋아진" in ko or "새로운 버전이 출시" in ko:
            return f"{prefix}Message"
        if ko == "업데이트":
            return f"{prefix}Confirm"
        if ko == "나중에":
            return f"{prefix}Cancel"

    if "loading_message_service.dart" in path:
        return "loadingDefault"

    if "agreement_error_handler.dart" in path:
        return "dialogAgreementRequiredTermsTitle"

    # game_event_messages.dart의 hash 키 보정
    if "game_event_messages.dart" in path and "체포했습니다" in ko:
        return "chatSystemArrest"

    if "location_permission_messages.dart" in path:
        if "위치 권한 안내" in ko:
            return "permissionLocationFallbackTitle"
        if "허용해주세요" in ko:
            return "permissionLocationFallbackMessage"

    if "zone_setting_button.dart" in path or "zone_setting_widget.dart" in path:
        if "km" in code:
            return "zoneRadiusKm"
        if "m'" in code or "${radiusMeters" in code:
            return "zoneRadiusMeter"
        if ko == "반경":
            return "zoneRadiusLabel"

    # 2) 일반 규칙 (code 패턴 분석)
    # title: 'xxx' → ...Title
    if re.search(r"\btitle\s*:\s*['\"]", code):
        return f"dialog{_camel_from_path(path)}Title"
    if re.search(r"\bmessage\s*:\s*['\"]", code):
        return f"dialog{_camel_from_path(path)}Message"
    if re.search(r"\bconfirmText\s*:\s*['\"]", code):
        return f"dialog{_camel_from_path(path)}Confirm"
    if re.search(r"\bcancelText\s*:\s*['\"]", code):
        return f"dialog{_camel_from_path(path)}Cancel"
    if re.search(r"\bhintText\s*:\s*['\"]", code):
        return f"field{_camel_from_path(path)}Hint"
    if re.search(r"\blabel\s*:\s*['\"]", code):
        return f"field{_camel_from_path(path)}Label"
    if re.search(r"throw\s+\w+Exception\s*\(\s*message\s*:\s*['\"]", code):
        return f"error{_camel_from_path(path)}{_hash_short(ko)}"

    # Fallback: auto_key 그대로 (의미 기반 변환 실패 시)
    return auto


def _camel_from_path(path):
    """파일 경로에서 camelCase prefix 추출 (예: home_page → homePage)"""
    name = path.split("/")[-1].replace(".dart", "")
    parts = name.split("_")
    return parts[0] + "".join(p.capitalize() for p in parts[1:])


def _camel_from_ko(ko):
    """한국어 텍스트로부터 간단한 라틴 식별자 생성 (해시 기반 — 안정성 위해)"""
    import hashlib
    h = hashlib.md5(ko.encode("utf-8")).hexdigest()[:6]
    return f"msg{h}"


def _capitalize(s):
    return s[0].upper() + s[1:] if s else s


def _hash_short(ko):
    import hashlib
    return hashlib.md5(ko.encode("utf-8")).hexdigest()[:4].capitalize()


def _classify_error(ko):
    """API 에러 메시지 한국어 내용으로 분류"""
    if "시간이 초과" in ko: return "NetworkTimeout"
    if "네트워크 연결을 확인" in ko: return "NetworkOffline"
    if "서버에 문제" in ko: return "ServerInternal"
    if "잘못된 요청" in ko: return "BadRequest"
    if "인증에 실패" in ko: return "Unauthorized"
    if "접근 권한이 없" in ko: return "Forbidden"
    if "찾을 수 없" in ko: return "NotFound"
    if "충돌" in ko: return "Conflict"
    return f"NetworkUnknown{_hash_short(ko)}"


def main():
    if len(sys.argv) < 2:
        print("Usage: _build_arb.py <prefix1> [prefix2 ...]")
        sys.exit(1)
    prefixes = sys.argv[1:]

    rows = parse_messages_md()
    # prefix로 필터
    filtered = [r for r in rows if any(r["auto_key"].startswith(p) for p in prefixes)]
    # LLM이 "[SKIP - debug message]" 표시한 행 제외 (i18n 대상 아님)
    before = len(filtered)
    filtered = [r for r in filtered if "[SKIP" not in r["en"] and "[SKIP" not in r["ja"]]
    skipped = before - len(filtered)
    print(f"필터된 메시지: {before}건 → 디버그 {skipped}건 제외 → 최종 {len(filtered)}건 (prefixes={prefixes})")

    # 키 매핑 생성
    mappings = []
    key_count = {}
    for r in filtered:
        semantic = derive_semantic_key(r)
        # 중복 키 처리 — 같은 메시지면 OK, 다른 메시지면 suffix 추가
        if semantic in key_count:
            # 기존 행 비교
            existing = next(m for m in mappings if m["semantic_key"] == semantic)
            if existing["ko"] == r["ko"]:
                # 중복 — 같은 키로 통합
                r["_duplicate_of"] = semantic
            else:
                # 다른 메시지인데 키 충돌 — 라인번호 suffix
                semantic = f"{semantic}{_hash_short(r['ko'])}"
        key_count[semantic] = key_count.get(semantic, 0) + 1
        mappings.append({**r, "semantic_key": semantic})

    # 결과 출력 (.md 형식)
    out = []
    out.append("# ARB 키 매핑 결과")
    out.append("")
    out.append(f"prefix: {prefixes} — {len(filtered)}건 → {len(set(m['semantic_key'] for m in mappings))}개 유니크 키")
    out.append("")
    out.append("| 의미 키 | 임시 키 | ko | en | ja | location |")
    out.append("|---|---|---|---|---|---|")
    for m in mappings:
        dup = " 🔄(통합)" if m.get("_duplicate_of") else ""
        out.append(f"| **{m['semantic_key']}**{dup} | {m['auto_key']} | {m['ko'][:50]} | {m['en'][:50]} | {m['ja'][:50]} | {m['location']} |")

    output_file = ROOT / "docs" / "i18n" / f"_arb_mapping_{'_'.join(prefixes).rstrip('_')}.md"
    output_file.write_text("\n".join(out), encoding="utf-8")
    print(f"✅ 매핑 결과: {output_file.relative_to(ROOT)}")
    print(f"   유니크 키: {len(set(m['semantic_key'] for m in mappings))}")
    print(f"   중복 통합: {sum(1 for m in mappings if m.get('_duplicate_of'))}건")


if __name__ == "__main__":
    main()
