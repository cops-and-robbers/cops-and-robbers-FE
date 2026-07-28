## 제목

🚀 [기능개선][Firebase] 사용하지 않는 firebase_options.dart 및 stale firebase.json 정리

## 본문

## 📝 현재 문제점

- `lib/firebase_options.dart` 파일이 코드베이스에 존재하지만 어디서도 import되지 않는 dead code 상태
- `main.dart`의 Firebase 초기화는 옵션 인자 없이 호출되어 네이티브 설정 파일(GoogleService-Info.plist / google-services.json)을 자동으로 사용하므로 위 파일은 실제 동작에 사용되지 않음
- 더 큰 문제: 루트의 `firebase.json` 파일이 옛 Firebase 프로젝트(`copsandrobbers-c2281`)를 가리키고 있음. 현재 실사용 중인 프로젝트는 App Transfer 후 새로 만든 `copsandrobbers-8c026`인데도 메타데이터는 옛 프로젝트 정보 그대로 남아있음
- 누군가 추후 `flutterfire configure`를 옵션 없이 실행하면 `firebase.json`을 참조하여 옛 프로젝트(c2281)로 재구성하려 시도하고, 그 과정에서 GoogleService-Info.plist / google-services.json이 옛 프로젝트 거로 덮어써질 위험이 있음
- 현재는 동작하지만 잠재적 시한폭탄 상태

## 🛠️ 해결 방안 / 제안 기능

- `lib/firebase_options.dart` 삭제 (현재 사용처 0)
- 루트의 `firebase.json` 삭제 (옛 프로젝트 정보를 가진 메타데이터 파일)
- 두 파일 모두 모바일 전용 앱(iOS/Android만 지원)인 본 프로젝트에서는 불필요
- 향후 웹 지원이나 명시적 Firebase 옵션 주입이 필요해지는 시점이 오면 그때 새 프로젝트(8c026) 기준으로 `flutterfire configure`를 다시 실행

## ⚙️ 작업 내용

- `lib/firebase_options.dart` 파일 제거
- 루트 `firebase.json` 파일 제거
- `flutter analyze` 통과 확인
- 실기기에서 앱 실행 후 Firebase 정상 초기화 확인 (콘솔 로그)
- FCM 토큰 정상 발급 확인 (콘솔 로그)
- Firebase Console에서 테스트 푸시 메시지 도달 확인
- 변경 사항 커밋

## 🙋‍♂️ 담당자

- 백엔드: 이름
- 프론트엔드: 이름
- 디자인: 이름
