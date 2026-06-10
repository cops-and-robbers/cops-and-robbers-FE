### 📌 작업 개요
외부 URL 상수가 `app_config.dart`와 `app_urls.dart` 두 파일에 분산 관리되던 구조를 `app_urls.dart` 하나로 통합.
스토어 URL을 콘솔 주소(App Store Connect / Play Console)에서 실제 다운로드 주소로 변경.

### 🎯 구현 목표
- URL 상수 파일 이원화로 인한 혼동 해소
- 스토어 URL을 실제 사용자 다운로드 링크로 교체
- 테스트 위젯 페이지에 점검/강제 업데이트 페이지 이동 버튼 추가

### ✅ 구현 내용

#### 1. AppConfig → AppUrls 통합
- **삭제 파일**: `lib/core/constants/app_config.dart`
- **수정 파일**: `lib/core/constants/app_urls.dart`
- **변경 내용**: `AppConfig.storeUrl` getter를 `AppUrls`로 이전, 플랫폼별 분기 로직 유지
- **이유**: URL 상수를 한 곳에서 관리하여 유지보수성 향상

#### 2. 스토어 URL 실제 다운로드 주소로 변경
- **Android**: `https://play.google.com/store/apps/details?id=com.elipair.copsandrobbers`
- **iOS**: `https://apps.apple.com/us/app/id6756843948`
- **이유**: 기존 URL이 개발자 콘솔 주소(App Store Connect, Play Console)로 되어 있어 사용자가 접근 불가

#### 3. 참조 코드 일괄 수정
- **파일**: `lib/core/widgets/pages/force_update_page.dart`
- **파일**: `lib/core/services/remote_config/update_dialog_helper.dart`
- **변경 내용**: `AppConfig` import → `AppUrls` import, `AppConfig.storeUrl` → `AppUrls.storeUrl`으로 변경

#### 4. 테스트 위젯 페이지에 페이지 이동 버튼 추가
- **파일**: `lib/test_widget_page.dart`
- **변경 내용**: 하단에 "페이지 이동 테스트" 섹션 추가 — 점검 페이지, 강제 업데이트 페이지로 이동하는 버튼 2개
- **이유**: 시뮬레이터에서 점검/강제 업데이트 페이지를 직접 확인할 수 있도록 지원

### 📌 참고사항
- iOS 시뮬레이터에는 App Store 앱이 없어 `canLaunchUrl`이 `false`를 반환함. 실제 기기에서는 정상 동작
- iOS URL에서 한글 앱 이름 부분을 제거하고 `id`만 사용하여 인코딩 이슈 방지 (`/us/app/id6756843948`)
