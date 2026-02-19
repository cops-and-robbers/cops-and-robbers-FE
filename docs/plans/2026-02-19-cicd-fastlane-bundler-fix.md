# CI/CD Fastlane Bundler 방식 통일 Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** 4개 CI/CD 워크플로우의 Fastlane 설치를 `gem install --force`에서 Bundler 방식으로 통일하여 GitHub Actions 러너 gem 충돌 문제를 근본적으로 해결한다.

**Architecture:** `docs/07_CICD_GUIDE.md`에 명시된 Bundler 기반 Fastlane 설치 패턴을 모든 워크플로우에 일관 적용. Ruby 3.3 + `bundler-cache: false` + 동적 Gemfile 생성 + `bundle exec fastlane` 호출 패턴.

**Tech Stack:** GitHub Actions, Ruby 3.3, Bundler, Fastlane

---

## 현재 문제 요약

`docs/07_CICD_GUIDE.md`에서 Bundler 방식을 표준으로 정의했지만, 실제 4개 워크플로우 중 **모든 워크플로우**가 아직 `gem install fastlane --force` 방식을 사용 중.

| 워크플로우 | Ruby 버전 | Fastlane 설치 | fastlane 호출 | bundler-cache |
|------------|-----------|---------------|---------------|---------------|
| PLAYSTORE-CICD | 3.3 (수정됨) | ❌ gem install | ❌ bare | 미설정 |
| TEST-APK | 3.3 (수정됨) | ❌ gem install | ❌ bare | ❌ true |
| IOS-TESTFLIGHT | N/A (deploy job) | ❌ gem install | ❌ bare | 미설정 |
| IOS-TEST-TESTFLIGHT | N/A (deploy job) | ❌ gem install | ❌ bare | 미설정 |

**참고:** iOS 워크플로우에는 CocoaPods용 Ruby 설정(3.1, bundler-cache: true)이 별도 존재. 이는 Fastlane과 무관하며 변경하지 않음.

---

### Task 1: Android Play Store CICD — Fastlane Bundler 전환

**Files:**
- Modify: `.github/workflows/PROJECT-FLUTTER-ANDROID-PLAYSTORE-CICD.yaml:552-561` (deploy-playstore job의 Ruby/Fastlane 설정)
- Modify: `.github/workflows/PROJECT-FLUTTER-ANDROID-PLAYSTORE-CICD.yaml:680` (fastlane 호출)

**Step 1: deploy-playstore job의 Ruby 설정에 `bundler-cache: false` 추가**

현재 (line 552-556):
```yaml
      - name: Set up Ruby
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: "3.3"
```

변경:
```yaml
      - name: Set up Ruby
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: "3.3"
          bundler-cache: false
```

**Step 2: Fastlane 설치를 Bundler 방식으로 변경**

현재 (line 557-561):
```yaml
      - name: Install Fastlane
        run: |
          gem install fastlane --force
          echo "✅ Fastlane 설치 완료"
          fastlane --version
```

변경:
```yaml
      - name: Install Fastlane
        run: |
          printf 'source "https://rubygems.org"\ngem "fastlane"\n' > Gemfile
          bundle install
          echo "✅ Fastlane 설치 완료"
          bundle exec fastlane --version
```

**Step 3: fastlane deploy_internal 호출을 bundle exec로 변경**

현재 (line 680):
```yaml
          fastlane deploy_internal
```

변경:
```yaml
          bundle exec fastlane deploy_internal
```

**Step 4: Commit**

```bash
git add .github/workflows/PROJECT-FLUTTER-ANDROID-PLAYSTORE-CICD.yaml
git commit -m "fix(cicd): Android Playstore 워크플로우 Fastlane Bundler 방식 전환"
```

---

### Task 2: Android Test APK — Fastlane Bundler 전환

**Files:**
- Modify: `.github/workflows/PROJECT-FLUTTER-ANDROID-TEST-APK.yaml:490-506` (Ruby/Fastlane 설정)
- Modify: `.github/workflows/PROJECT-FLUTTER-ANDROID-TEST-APK.yaml:525` (fastlane 호출)
- Modify: `.github/workflows/PROJECT-FLUTTER-ANDROID-TEST-APK.yaml:472` (actions/setup-java 버전)

**Step 1: Ruby 설정의 `bundler-cache`를 `false`로 변경**

현재 (line 490-494):
```yaml
      - name: Set up Ruby
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: "3.3"
          bundler-cache: true
```

변경:
```yaml
      - name: Set up Ruby
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: "3.3"
          bundler-cache: false
```

**Step 2: Fastlane 설치를 Bundler 방식으로 변경**

현재 (line 502-506):
```yaml
      - name: Install Fastlane
        run: |
          gem install fastlane --force
          echo "✅ Fastlane installed"
          fastlane --version
```

변경:
```yaml
      - name: Install Fastlane
        run: |
          printf 'source "https://rubygems.org"\ngem "fastlane"\n' > Gemfile
          bundle install
          echo "✅ Fastlane installed"
          bundle exec fastlane --version
```

**Step 3: fastlane build 호출을 bundle exec로 변경**

현재 (line 522-529):
```yaml
          if [ -f "android/fastlane/Fastfile" ]; then
            echo "📦 Fastlane을 사용하여 빌드..."
            cd android
            fastlane build --verbose || flutter build apk --release
          else
```

변경:
```yaml
          if [ -f "android/fastlane/Fastfile" ]; then
            echo "📦 Fastlane을 사용하여 빌드..."
            cd android
            bundle exec fastlane build --verbose || flutter build apk --release
          else
```

**Step 4: actions/setup-java를 v4로 업데이트 (일관성)**

현재 (line 472-475):
```yaml
      - name: Set up Java
        uses: actions/setup-java@v3
```

변경:
```yaml
      - name: Set up Java
        uses: actions/setup-java@v4
```

**Step 5: Commit**

```bash
git add .github/workflows/PROJECT-FLUTTER-ANDROID-TEST-APK.yaml
git commit -m "fix(cicd): Android Test APK 워크플로우 Fastlane Bundler 방식 전환"
```

---

### Task 3: iOS TestFlight — Fastlane Bundler 전환

**Files:**
- Modify: `.github/workflows/PROJECT-FLUTTER-IOS-TESTFLIGHT.yaml:456-457` (deploy-testflight job의 Fastlane 설치)
- Modify: `.github/workflows/PROJECT-FLUTTER-IOS-TESTFLIGHT.yaml:497` (fastlane 호출)

**Step 1: deploy-testflight job에 Ruby 설정 추가 및 Fastlane Bundler 전환**

현재 (line 456-457):
```yaml
      - name: Install Fastlane
        run: gem install fastlane --force
```

변경 (Ruby 설정 step 추가 + Fastlane Bundler 방식):
```yaml
      - name: Set up Ruby
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: "3.3"
          bundler-cache: false

      - name: Install Fastlane
        run: |
          printf 'source "https://rubygems.org"\ngem "fastlane"\n' > Gemfile
          bundle install
          echo "✅ Fastlane 설치 완료"
          bundle exec fastlane --version
```

**Step 2: fastlane upload_testflight 호출을 bundle exec로 변경**

현재 (line 497):
```yaml
          fastlane upload_testflight
```

변경:
```yaml
          bundle exec fastlane upload_testflight
```

**Step 3: Commit**

```bash
git add .github/workflows/PROJECT-FLUTTER-IOS-TESTFLIGHT.yaml
git commit -m "fix(cicd): iOS TestFlight 워크플로우 Fastlane Bundler 방식 전환"
```

---

### Task 4: iOS Test TestFlight — Fastlane Bundler 전환

**Files:**
- Modify: `.github/workflows/PROJECT-FLUTTER-IOS-TEST-TESTFLIGHT.yaml:735-736` (deploy-testflight-test job의 Fastlane 설치)
- Modify: `.github/workflows/PROJECT-FLUTTER-IOS-TEST-TESTFLIGHT.yaml:774` (fastlane 호출)

**Step 1: deploy-testflight-test job에 Ruby 설정 추가 및 Fastlane Bundler 전환**

현재 (line 735-736):
```yaml
      - name: Install Fastlane
        run: gem install fastlane --force
```

변경 (Ruby 설정 step 추가 + Fastlane Bundler 방식):
```yaml
      - name: Set up Ruby
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: "3.3"
          bundler-cache: false

      - name: Install Fastlane
        run: |
          printf 'source "https://rubygems.org"\ngem "fastlane"\n' > Gemfile
          bundle install
          echo "✅ Fastlane 설치 완료"
          bundle exec fastlane --version
```

**Step 2: fastlane upload_testflight 호출을 bundle exec로 변경**

현재 (line 774):
```yaml
          fastlane upload_testflight
```

변경:
```yaml
          bundle exec fastlane upload_testflight
```

**Step 3: Commit**

```bash
git add .github/workflows/PROJECT-FLUTTER-IOS-TEST-TESTFLIGHT.yaml
git commit -m "fix(cicd): iOS Test TestFlight 워크플로우 Fastlane Bundler 방식 전환"
```

---

### Task 5: CI/CD 가이드 문서 업데이트

**Files:**
- Modify: `docs/07_CICD_GUIDE.md`

**Step 1: 워크플로우 파일 목록 테이블에 누락된 워크플로우 추가 (있으면)**

현재 테이블에 4개 워크플로우가 이미 있으므로 확인만 수행.

**Step 2: 필수 GitHub Secrets 테이블에 `GOOGLE_MAPS_API_KEY` 추가**

현재 Secrets 목록에 빠져 있지만 모든 워크플로우에서 사용 중인 `GOOGLE_MAPS_API_KEY`를 추가.

공통 섹션에 추가:
```markdown
| `GOOGLE_MAPS_API_KEY` | Google Maps API Key (Android/iOS 공통) |
```

**Step 3: Commit**

```bash
git add docs/07_CICD_GUIDE.md
git commit -m "docs(cicd): CI/CD 가이드에 GOOGLE_MAPS_API_KEY 시크릿 추가"
```

---

## 변경 요약 체크리스트

- [ ] Task 1: PLAYSTORE-CICD — `bundler-cache: false`, Bundler 설치, `bundle exec fastlane deploy_internal`
- [ ] Task 2: TEST-APK — `bundler-cache: false`, Bundler 설치, `bundle exec fastlane build`, setup-java v4
- [ ] Task 3: IOS-TESTFLIGHT — Ruby 설정 추가, Bundler 설치, `bundle exec fastlane upload_testflight`
- [ ] Task 4: IOS-TEST-TESTFLIGHT — Ruby 설정 추가, Bundler 설치, `bundle exec fastlane upload_testflight`
- [ ] Task 5: CI/CD 가이드 문서에 `GOOGLE_MAPS_API_KEY` 추가

## 주의사항

- **iOS CocoaPods용 Ruby 설정(3.1, bundler-cache: true)은 변경하지 않음** — Fastlane과 별개
- Bundler Gemfile은 동적 생성(`printf`)이므로 `bundler-cache: false` 필수
- 모든 `fastlane` 호출은 반드시 `bundle exec fastlane`으로
