## 제목

🚀 [기능개선][Android] Android 15 Edge-to-Edge 대응

## 본문

## 📝 현재 문제점

- Google Play Console에서 Android 15(API 35) 관련 권장 조치 경고 2개 발생 (출시 1.8.32 기준)
- MainActivity에 enableEdgeToEdge() 호출이 없어 Android 15에서 앱이 edge-to-edge를 올바르게 처리하지 않는다고 감지됨
- 앱 내부에서 지원 중단된 다음 API 사용이 감지됨
  - android.view.Window.setStatusBarColor
  - android.view.Window.setNavigationBarColor
  - android.view.Window.setNavigationBarDividerColor

## 🛠️ 해결 방안 / 제안 기능

- MainActivity에 enableEdgeToEdge() 호출 추가하여 Play Console 경고 1번 해소
- deprecated API 경고는 Flutter 프레임워크 내부에서 호출하는 것으로 확인됨 — enableEdgeToEdge() 적용 후 경고 완화 여부 확인

## ⚙️ 작업 내용

- MainActivity에 onCreate() override 및 enableEdgeToEdge() 호출 추가
- Android 15 기기에서 레이아웃 깨짐 여부 확인
  - 상태바/네비게이션바 영역 UI 가려짐 없는지 점검
  - SafeArea 미적용 페이지(settings_page, game_settings_page 등) 중점 확인

## 🙋‍♂️ 담당자

- 백엔드: 이름
- 프론트엔드: 이름
- 디자인: 이름
