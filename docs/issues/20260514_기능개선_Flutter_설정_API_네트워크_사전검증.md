## 제목

🚀 [기능개선][Flutter][설정] 설정 페이지 API 호출부 네트워크 사전 검증 적용

## 본문

## 📝 현재 문제점

- 설정 페이지의 닉네임 변경, 버그 제보, 회원 탈퇴 기능이 오프라인 상태에서도 API 요청을 시도함
- 요청 실패 후 에러 스낵바가 뜨는 방식이라 불필요한 로딩 팝업 표시 및 대기 시간이 발생함
- 이미 게임 알림 토글과 이용약관 변경 저장에는 네트워크 사전 검증이 적용되어 있으나, 나머지 호출부에는 미적용 상태

## 🛠️ 해결 방안 / 제안 기능

- API 호출 직전 ConnectivityService.isConnected()로 네트워크 상태를 확인함
- 오프라인이면 API를 보내지 않고 즉시 안내 스낵바를 표시함
- 이미 앱에 connectivityServiceProvider가 구현되어 있으므로 동일 패턴으로 재사용함

## ⚙️ 작업 내용

- settings_page.dart의 _onNicknameChange: 프로필 조회 API 호출 전 네트워크 검증 추가
- settings_page.dart의 _submitBugReport: 버그 제보 API 호출 전 네트워크 검증 추가
- settings_page.dart의 _executeDeleteAccount: 회원 탈퇴 API 호출 전 네트워크 검증 추가
- 안내 메시지 문구: '네트워크가 연결되지 않았어요' (기존 게임 알림 토글과 동일)

## 🙋‍♂️ 담당자

- 백엔드: 이름
- 프론트엔드: 이름
- 디자인: 이름
