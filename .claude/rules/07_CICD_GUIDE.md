# CI/CD 가이드

## 워크플로우 파일 목록

| 파일 | 용도 | 트리거 |
|------|------|--------|
| `PROJECT-FLUTTER-ANDROID-PLAYSTORE-CICD.yaml` | Android Play Store 내부 테스트 배포 | `deploy` 브랜치 push, CHANGELOG 워크플로우 완료 |
| `PROJECT-FLUTTER-ANDROID-TEST-APK.yaml` | Android 테스트 APK 빌드 | PR 이벤트 |
| `PROJECT-FLUTTER-IOS-TESTFLIGHT.yaml` | iOS TestFlight 배포 | `deploy` 브랜치 push, CHANGELOG 워크플로우 완료 |
| `PROJECT-FLUTTER-IOS-TEST-TESTFLIGHT.yaml` | iOS 테스트 TestFlight 빌드 | PR 이벤트 |

---

## Fastlane 설치 방식: Bundler

### 배경 (문제)

GitHub Actions 러너(ubuntu-latest, macos-15)에 사전 설치된 Ruby gem이 Fastlane 의존성과 충돌하는 문제가 발생했습니다.

**에러 1 - CFPropertyList 충돌:**
```
Unable to satisfy the following requirements:
- `CFPropertyList (= 3.0.9)` required by `user-specified dependency`
```

**에러 2 - retriable 실행파일 충돌:**
```
ERROR: Error installing fastlane:
    "console" from fastlane conflicts with installed executable from retriable
```

이 문제는 러너 이미지 버전에 따라 발생 여부가 달라져서, `gem install fastlane --force`로는 안정적으로 해결되지 않았습니다.

### 해결 방법

**Bundler를 사용한 격리된 gem 환경** 으로 전환하여 근본적으로 해결했습니다.

```yaml
# Ruby 설정
- name: Set up Ruby
  uses: ruby/setup-ruby@v1
  with:
    ruby-version: "3.3"
    bundler-cache: false

# Fastlane 설치 (Bundler 방식으로 CFPropertyList 의존성 충돌 방지)
- name: Install Fastlane
  run: |
    printf 'source "https://rubygems.org"\ngem "fastlane"\n' > Gemfile
    bundle install
    echo "✅ Fastlane 설치 완료"
    bundle exec fastlane --version
```

### 핵심 포인트

| 항목 | 설명 |
|------|------|
| `printf > Gemfile` | Bundler용 Gemfile을 동적으로 생성 |
| `bundle install` | Gemfile 기반으로 격리된 환경에 gem 설치 |
| `bundle exec fastlane` | Bundler 환경 내에서 fastlane 실행 (시스템 gem과 충돌 없음) |
| `bundler-cache: false` | 동적 Gemfile이므로 캐시 비활성화 |

### 주의사항

- **모든 fastlane 호출은 반드시 `bundle exec`를 붙여야 합니다.**
  ```yaml
  # ✅ 올바른 사용법
  bundle exec fastlane deploy_internal
  bundle exec fastlane upload_testflight
  bundle exec fastlane build --verbose

  # ❌ 잘못된 사용법 (시스템 gem 충돌 발생 가능)
  fastlane deploy_internal
  ```

- Ruby 버전은 **3.3**을 사용합니다. (Android/iOS 공통)
- iOS의 CocoaPods용 Ruby 설정(ruby 3.2, bundler-cache: true)은 별도이며, Fastlane 설치와 무관합니다. (i18n 1.15.0/activesupport 7.2가 Ruby 3.2+ `Fiber[]` API를 요구하여 3.1에서 `pod install` crash 발생 → 3.2로 상향)

---

## 버전 관리

버전 정보는 `version.yml`에서 관리됩니다.

```yaml
version: "x.y.z"       # 사용자에게 표시되는 버전
version_code: N         # app build number (단순 증가)
project_type: "flutter"
```

- `.github/scripts/version_manager.sh` - 버전 읽기/쓰기 스크립트
- `.github/scripts/changelog_manager.py` - CHANGELOG.json 관리 스크립트

---

## 필수 GitHub Secrets

### 공통
| Secret | 설명 |
|--------|------|
| `ENV_FILE` | `.env` 파일 내용 |
| `GOOGLE_MAPS_API_KEY` | Google Maps API Key (Android/iOS 공통) |

### Android
| Secret | 설명 |
|--------|------|
| `RELEASE_KEYSTORE_BASE64` | Release keystore (base64 인코딩) |
| `RELEASE_KEYSTORE_PASSWORD` | Keystore 비밀번호 |
| `RELEASE_KEY_ALIAS` | Key alias |
| `RELEASE_KEY_PASSWORD` | Key 비밀번호 |
| `GOOGLE_SERVICES_JSON` | Firebase google-services.json 내용 |
| `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON_BASE64` | Play Store API 서비스 계정 (base64) |

### iOS
| Secret | 설명 |
|--------|------|
| `APP_STORE_CONNECT_API_KEY_ID` | App Store Connect API Key ID |
| `APP_STORE_CONNECT_ISSUER_ID` | App Store Connect Issuer ID |
| `APP_STORE_CONNECT_P8_BASE64` | API Key (.p8 파일, base64) |
| `CERTIFICATES_P12_BASE64` | 코드 서명 인증서 (base64) |
| `CERTIFICATES_P12_PASSWORD` | 인증서 비밀번호 |
| `PROVISIONING_PROFILE_BASE64` | 프로비저닝 프로파일 (base64) |

---

**Last Updated:** 2026-02-19
