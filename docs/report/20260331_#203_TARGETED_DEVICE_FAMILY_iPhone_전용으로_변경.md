### 📌 작업 개요
`TARGETED_DEVICE_FAMILY` 설정을 iPhone + iPad(`"1,2"`)에서 iPhone 전용(`1`)으로 변경. iPad 지원이 불필요하므로 빌드 대상 디바이스를 iPhone으로 한정

### 🎯 구현 목표
- Xcode 프로젝트의 `TARGETED_DEVICE_FAMILY` 값을 iPhone 전용으로 변경
- Debug, Release, Profile 3개 빌드 구성 모두 일괄 적용

### ✅ 구현 내용

#### TARGETED_DEVICE_FAMILY 값 변경
- **파일**: `ios/Runner.xcodeproj/project.pbxproj`
- **변경 내용**: `TARGETED_DEVICE_FAMILY = "1,2"` → `TARGETED_DEVICE_FAMILY = 1` (3곳)
- **적용 대상**: Debug / Release / Profile 빌드 설정 전체

### 🔧 주요 변경사항 상세

#### project.pbxproj
`TARGETED_DEVICE_FAMILY` 값이 `"1,2"`(iPhone + iPad)에서 `1`(iPhone only)로 변경

- `1` = iPhone
- `2` = iPad
- `1,2` = iPhone + iPad

`Info.plist`에는 이미 `LSRequiresIPhoneOS = true`가 설정되어 있어 별도 수정 불필요. Xcode가 빌드 시 `TARGETED_DEVICE_FAMILY` 값으로 `UIDeviceFamily`를 자동 생성

### 🧪 테스트 및 검증
- Xcode에서 빌드 대상이 iPhone으로만 표시되는지 확인
- iPad 시뮬레이터에서 앱이 표시되지 않는지 확인

### 📌 참고사항
- 아직 App Store 미배포 상태이므로 iPad 관련 별도 심사 불필요
- 첫 제출 시 iPhone 전용으로 심사 진행
