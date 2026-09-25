# ❗[버그][CICD] Fastlane 배포 시 multi_json 누락으로 fastlane 실행 실패

- **라벨**: 작업전
- **담당자**: (미지정)

---

🗒️ 설명
---

Play Store(Android) / TestFlight(iOS) 배포 워크플로우의 `Install Fastlane` 스텝에서 `bundle exec fastlane` 실행이 **간헐적으로 실패**한다.

- `bundle install`은 `Bundle complete! ... 96 gems now installed`로 정상 종료되지만, 직후 `bundle exec fastlane --version`에서 아래 에러로 중단된다.
  ```
  multi_json is not part of the bundle. Add it to your Gemfile. (Gem::LoadError)
  ```
- **같은 명령**이 어떤 실행에서는 성공(`fastlane 2.235.0` 출력)하고, 어떤 실행에서는 실패하는 **비결정적(flaky)** 현상이다.

**원인 분석**

1. 워크플로우가 Gemfile을 `gem "fastlane"`(버전 미고정)으로 매 실행마다 동적 생성하고, `Gemfile.lock`도 레포에 없어 **실행할 때마다 의존성을 새로 해석**한다 (비결정적).
2. fastlane은 `multi_json`을 직접 의존하지 않는다. `representable`이 런타임에 lazy require할 뿐이라 의존성 해석 결과에 따라 `multi_json`이 번들에서 누락될 수 있다.
3. fastlane 2.235.0은 `--version`만 호출해도 모든 기본 액션을 로드한다 (`load_default_actions`). 이때 `create_app_on_managed_play_store` → `google-apis-playcustomapp` → `representable/json` → `require "multi_json"` 경로를 탄다.
4. 실행 환경의 **Bundler 4.x**가 Gemfile에 명시되지 않은 transitive gem의 require를 엄격히 차단하여 LoadError로 표면화된다.

🔄 재현 방법
---

1. `deploy` 브랜치 push 또는 CHANGELOG 워크플로우 완료로 배포 워크플로우 트리거
2. `Install Fastlane` 스텝 진입 → 동적 Gemfile 생성 후 `bundle install`
3. `bundle exec fastlane --version` 실행 시점에 번들에 `multi_json`이 누락된 경우 LoadError 발생 (누락 여부는 그 시점 의존성 해석에 따라 달라짐)

📸 참고 자료
---

**에러 로그**
```
bundler: failed to load command: fastlane (/opt/homebrew/lib/ruby/gems/3.4.0/bin/fastlane)
.../bundler/rubygems_integration.rb:215:in 'Kernel#replace_gem':
    multi_json is not part of the bundle. Add it to your Gemfile. (Gem::LoadError)
    from .../representable-3.2.0/lib/representable/json.rb:1
    from .../google-apis-core-0.18.0/lib/google/apis/core/json_representation.rb:15
    from .../google-apis-playcustomapp_v1-0.17.0/lib/google/apis/playcustomapp_v1/service.rb:16
    from .../fastlane/actions/create_app_on_managed_play_store.rb:1
    from .../fastlane/actions/actions_helper.rb:112:in 'load_default_actions'
    from .../fastlane/cli_tools_distributor.rb:132:in 'take_off'
```

**영향 파일**
- `.github/workflows/PROJECT-FLUTTER-ANDROID-PLAYSTORE-CICD.yaml` (565줄, `Install Fastlane`)
- `.github/workflows/PROJECT-FLUTTER-IOS-TESTFLIGHT.yaml` (483줄, `Install Fastlane`)
- `android/Gemfile` — `multi_json` 미명시, `Gemfile.lock` 부재
- `ios/Gemfile` — `multi_json` 미명시, `Gemfile.lock` 부재

✅ 예상 동작
---

- 배포 워크플로우의 `Install Fastlane` 스텝이 매 실행마다 동일하게 성공해야 한다.
- `bundle exec fastlane`이 `multi_json` LoadError 없이 정상 로드되어 배포가 진행되어야 한다.

**해결 방향**
- Android/iOS Gemfile 및 워크플로우 동적 생성 Gemfile에 `gem "multi_json"` 명시
- fastlane 버전 고정(`gem "fastlane", "2.235.0"`)으로 의존성 해석 재현성 확보
- (선택) `Gemfile.lock` 커밋으로 의존성 완전 고정

⚙️ 환경 정보
---

- **CI**: GitHub Actions (배포 job `runs-on: ubuntu-latest`)
- **Ruby/Bundler**: 로그 기준 Ruby 3.4.9 + Bundler 4.0.12 (경로가 `/opt/homebrew` → 로컬 macOS 또는 self-hosted 러너 재현으로 추정)
- **Fastlane**: 2.235.0

🙋‍♂️ 담당자
---

- **백엔드**:
- **프론트엔드**:
- **디자인**:
