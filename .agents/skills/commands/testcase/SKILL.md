---
name: testcase
description: "경찰과 도둑 프로젝트: GitHub 이슈를 분석해 QA 테스트케이스와 체크리스트를 작성할 때 사용."
---

# testcase

프로젝트 내부용 Claude 커맨드의 Codex 진입점.

1. 실행 전에 [Codex 호환 규칙](../COMPATIBILITY.md)을 읽는다.
2. [원본 커맨드](../../../../.claude/commands/testcase.md)를 읽고 사용자 입력을 적용해 수행한다. 원본을 읽지 못하면 해당 작업을 중단하고 경로를 알린다.
3. 완료 전에 원본이 요구한 산출물·검증 결과를 확인하고 실제 수행한 결과만 보고한다.
