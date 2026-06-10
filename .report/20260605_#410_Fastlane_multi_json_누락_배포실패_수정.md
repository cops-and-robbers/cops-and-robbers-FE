# Fastlane 배포 시 multi_json 누락으로 fastlane 실행 실패 수정

### 📌 작업 개요

Play Store(Android) / TestFlight(iOS) 배포 워크플로우의 `Install Fastlane` 스텝에서 `bundle exec fastlane`이 간헐적으로 `multi_json is not part of the bundle` 에러로 실패하던 문제 수정. 4개 Gemfile에 `gem "multi_json"`을 직접 명시하여 해결.

### 🔍 문제 분석

**증상**
- `bundle install`은 `Bundle complete! ... 96 gems now installed`로 정상 종료되지만, 직후 `bundle exec fastlane --version`(또는 `deploy_internal`)에서 아래 에러로 중단.
  ```
  multi_json is not part of the bundle. Add it to your Gemfile. (Gem::LoadError)
  ```
- 같은 명령이 어떤 실행에서는 성공(`fastlane 2.235.0` 출력)하고 어떤 실행에서는 실패하는 비결정적(flaky) 양상.

**근본 원인**
1. fastlane은 `multi_json`을 직접 의존하지 않음. 과거에는 `signet`/`googleauth`가 transitive 의존으로 끌어왔으나, 최신 버전(signet 0.22.0 등)에서 그 의존이 끊겨 더 이상 번들에 자동 포함되지 않음. 반면 `representable/json`은 여전히 런타임에 `require "multi_json"`을 시도.
2. 워크플로우가 Gemfile을 `gem "fastlane"`(버전 미고정)으로 매 실행마다 동적 생성하고 `Gemfile.lock`도 없어, fresh resolve 때마다 의존성이 달라짐. signet 의존이 끊긴 시점부터 multi_json이 번들에서 빠지기 시작(그 전에는 우연히 포함되어 성공).
3. fastlane은 `--version` 호출만으로도 모든 기본 액션을 로드(`load_default_actions`). 이때 `create_app_on_managed_play_store → google-apis-playcustomapp → representable/json → require "multi_json"` 경로를 탐.
4. 실행 환경의 Bundler가 Gemfile에 명시되지 않은 gem의 require를 차단하여 `Gem::LoadError`로 표면화.

> 처음 보고된 실패 로그는 경로가 `/opt/hostedtoolcache/.../x64`(Linux)로 Android(ubuntu) job에서 발생. iOS(macos-26) job도 동일 구조라 다음 fresh resolve 시 동일하게 실패할 잠재 버그였음.

### ✅ 구현 내용

핵심은 `gem "multi_json"` 직접 명시. signet/googleauth가 더 이상 끌어오지 않으므로 4곳 모두에 선언.

#### Android Gemfile
- **파일**: `android/Gemfile`
- **변경 내용**: `gem "multi_json"` 추가
- **이유**: `cd android && bundle exec fastlane deploy_internal` 단계가 이 Gemfile을 사용하므로 누락 방지

#### iOS Gemfile
- **파일**: `ios/Gemfile`
- **변경 내용**: `gem "multi_json"` 추가
- **이유**: `cd ios && bundle exec fastlane upload_testflight` 단계가 이 Gemfile을 사용하므로 누락 방지

#### Android 배포 워크플로우 동적 Gemfile
- **파일**: `.github/workflows/PROJECT-FLUTTER-ANDROID-PLAYSTORE-CICD.yaml` (565줄)
- **변경 내용**: `Install Fastlane` 스텝의 동적 생성 Gemfile에 `\ngem "multi_json"` 추가
- **이유**: `bundle install` + `fastlane --version` 검증이 실패하던 실제 지점

#### iOS 배포 워크플로우 동적 Gemfile
- **파일**: `.github/workflows/PROJECT-FLUTTER-IOS-TESTFLIGHT.yaml` (483줄)
- **변경 내용**: 동일하게 `\ngem "multi_json"` 추가
- **이유**: Android와 동일한 잠재 실패 지점 사전 차단

### 🔧 주요 변경사항 상세

동적 Gemfile 생성 라인 변경:
```diff
- printf 'source "https://rubygems.org"\ngem "fastlane"\n' > Gemfile
+ printf 'source "https://rubygems.org"\ngem "fastlane"\ngem "multi_json"\n' > Gemfile
```

정적 Gemfile(android/ios)에는 주석과 함께 명시:
```ruby
# multi_json - fastlane 액션(create_app_on_managed_play_store → google-apis →
# representable)이 런타임에 require하지만, signet/googleauth가 더 이상 transitive
# 의존으로 끌어오지 않아 직접 명시해야 번들에서 누락되지 않음
gem "multi_json"
```

**특이사항**
- fastlane 버전 고정(`gem "fastlane", "2.235.0"`)은 root cause가 아니라 부차적 안정화라 적용하지 않음. 의존성 재현성을 더 높이려면 별도로 `Gemfile.lock` 커밋이 정석.

### 📦 의존성 변경
- `multi_json` 명시 추가 (이전에도 transitive로 설치되긴 했으나 보장되지 않던 것을 명시화)

### 🧪 테스트 및 검증
- 로컬 `bundle install`은 `Gemfile.lock` 생성 등 부작용이 있어 실행하지 않음.
- 최종 검증은 `deploy` 브랜치 배포 시 Android/iOS `Install Fastlane` 스텝이 `multi_json` 에러 없이 통과하는지로 확인.

### 📌 참고사항
- 4개 파일이 동일 목적이라 단일 커밋(`fix : Fastlane 배포 시 multi_json 누락 수정 #410`)으로 처리.
- 동일 패턴이 다른 fastlane 기반 워크플로우에도 있다면 같은 방식으로 `multi_json` 명시 필요.
