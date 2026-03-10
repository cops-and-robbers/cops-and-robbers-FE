이벤트 동기화 설계

- **이벤트 전송** – 게임 주요 이벤트(시작, 체포, 위치 공개 등)를 전송한다.
  > 게임 내 이벤트가 발생하면 서버가 메세지를 발행
  - 이러한 이벤트채널은 각 클라이언트에서 게임 상태의 실시간 동기화를 위한 것
    (채팅처럼 이벤트 알림을 위한 것이 아님, 이벤트 알림은 전체 채팅에서 알리기)
  - 이벤트 요청은 http
  - 서버 내부적 처리(유효성 검사 및 DB업데이트)
  - 트랜잭션 성공시 해당 이벤트 내용을 Publish
  [엔드포인트]
  | **기능**             | **Client Action**    | **URI**                           | **비고**                  |
  | -------------------- | -------------------- | --------------------------------- | ------------------------- |
  | **이벤트 전송**      | **없음** (HTTP 요청) | - 없음                            | API 호출 처리 후          |
  | 서버 내부적으로 전송 |
  | **이벤트 결과 수신** | **Sub**              | `/subscribe/game/{gameId}/system` | 게임의 모든 참여자가 구독 |
  - Response Payload
    ```jsx
    {
      "eventId": "uuid-random-string", // 프론트 중복 처리용 고유 키
      "type": "EVENT_TYPE_NAME",       // 이벤트 종류 (Enum)
      "timestamp": "2024-01-08T14:30:00",
      "data": { ... }                  // 이벤트별로 달라지는 상세 정보 (Generic)
    }
    ```

    - 이벤트 종류: `ARREST`, `ESCAPE` , `GAME_OVER` , `START` , `POLICE_MOVE_START` , `LOCATION_REVEAL`
    1. 체포 이벤트 data

       ```jsx
       {
       		"police": {               // 잡은 경찰 ID
             "participantId": 101,
             "nickname": "경찰1",
             "team": "ROBBER"
           },
           "lobber": {                // 잡힌 도둑 ID
             "participantId": 505,
             "nickname": "창희도둑",
             "team": "ROBBER"
           },
           "remainingThieves": 2     // 남은 도둑 수 (UI 상단 표시용)
       }
       ```

    2. 탈출이벤트 data

       ```jsx
       {
         "savior": {
           "participantId": 101,
           "nickname": "슈퍼도둑",
           "team": "ROBBER"
         },
         "escapedThieves": [
           {
             "participantId": 505,
             "nickname": "창희도둑",
             "team": "ROBBER"
           },
           {
             "participantId": 506,
             "nickname": "도둑2",
             "team": "ROBBER"
           }
         ],
         "escapedCount": 2
       }

       ```

    3. 게임 종료 이벤트

       ```jsx
       {
         "winnerTeam": "POLICE",    // 승리 팀 ("POLICE" | "ROBBER")
         "reason": "ALL_ARRESTED"  // 승리 원인 ("TIME_OVER" | "ALL_ARRESTED")
         ....
       }
       ```

    4. 경찰 이동 시작 data
       - 딱히 추가로 필요한 데이터는 없는것 같음
    5. 도둑 위치 공개 이벤트 data

       ```json
       {
         "locations": [
           {
             "participantId": 505,
             "nickname": "창희도둑",
             "latitude": 37.5665,
             "longitude": 126.978
           },
           {
             "participantId": 506,
             "nickname": "도둑2",
             "latitude": 37.567,
             "longitude": 126.979
           }
         ]
       }
       ```

## 1. 이벤트 전송 개요

게임 중 발생하는 주요 이벤트 → 서버에서 처리 후 WebSocket을 통해 모든 참여자에게 전송

채팅과 달리 **~~알림 목적~~**이 아니라, 모든 클라이언트의 게임 상태를 **동기화하는 목적**을 가짐

### 이벤트 발생 흐름

<aside>
💡

1. 이벤트 트리거는 HTTP 요청으로 시작
2. 서버에서 유효성 검증 및 DB 업데이트를 트랜잭션으로 처리
3. 트랜잭션이 성공하면, 해당 이벤트를 STOMP 토픽으로 Publish
4. 게임에 참여 중인 모든 클라이언트가 이벤트를 수신
</aside>

## 2. 이벤트 수신 채널

[엔드포인트]

| **기능**             | **Client Action**    | **URI**                           | **비고**                  |
| -------------------- | -------------------- | --------------------------------- | ------------------------- |
| **이벤트 전송**      | **없음** (HTTP 요청) | - 없음                            | API 호출 처리 후          |
| 서버 내부적으로 전송 |
| **이벤트 결과 수신** | **Sub**              | `/subscribe/game/{gameId}/system` | 게임의 모든 참여자가 구독 |

## 3. 이벤트 상세 payload 명세

### 체포 이벤트 (ARREST)

```json
{
  "eventId": "uuid-arrest-001",
  "type": "ARREST",
  "timestamp": "2024-01-08T14:30:00",
  "data": {
    "police": {
      "participantId": 101,
      "nickname": "경찰",
      "team": "POLICE"
    },
    "robber": {
      "participantId": 505,
      "nickname": "도둑킹",
      "team": "ROBBER"
    },
    "remainingThieves": 2
  }
}
```

### 탈출 이벤트 (ESCAPE)

```json
{
  "eventId": "uuid-escape-001",
  "type": "ESCAPE",
  "timestamp": "2024-01-08T14:35:00",
  "data": {
    "savior": {
      "userId": 101,
      "nickname": "슈퍼도둑",
      "team": "ROBBER"
    },
    "escapedThieves": [
      {
        "userId": 505,
        "nickname": "도둑킹",
        "team": "ROBBER"
      },
      {
        "userId": 506,
        "nickname": "도둑이게아니게",
        "team": "ROBBER"
      }
    ],
    "escapedCount": 2
  }
}
```

### 게임 종료 이벤트 (GAME_OVER)

```json
{
  "eventId": "uuid-gameover-001",
  "gameId": 1,
  "type": "GAME_OVER",
  "timestamp": "2024-01-08T15:00:00",
  "data": {
    "gameResultId": 8,
    "winnerTeam": "POLICE",
    "reason": "ALL_ARRESTED"
  }
}
```

### 경찰 이동 시작 이벤트 (POLICE_MOVE_START)

```json
{
  "eventId": "uuid-police-move-001",
  "type": "POLICE_MOVE_START",
  "timestamp": "2024-01-08T14:40:00",
  "data": {}
}
```

### 도둑 위치 공개 이벤트 (ROBBER_LOCATION_REVEAL)

```json
{
  "eventId": "uuid-location-reveal-001",
  "type": "ROBBER_LOCATION_REVEAL",
  "timestamp": "2024-01-08T14:45:00",
  "data": {
    "locations": [
      {
        "participantId": 505,
        "nickname": "도둑킹",
        "latitude": 37.5665,
        "longitude": 126.978
      },
      {
        "participantId": 506,
        "nickname": "도둑이게아니게",
        "latitude": 37.567,
        "longitude": 126.979
      }
    ]
  }
}
```

## 4. 게임 시간 동기화

→ 이 부분이 제일 중요한 부분이라고 생각!

### 두 가지 고민에서 출발

> 1. 서버는 어떤 방식으로 시간을 관리할까
> 2. 서버가 관리하는 시간을 클라이언트에게 어떤 형태로 전달할까

### 1️⃣ 서버가 매 초마다 시간 전송하기

서버가 매 초마다 현재 시간을 Publish하여 클라이언트가 이를 그대로 렌더링하는 방식

단점

- 초 단위 Publish → 서버 CPU와 Redis 트래픽 지속적으로 소모
- TCP 특성상 지연이 쌓이면 큐가 밀릴 가능성 존재
- 모바일 환경에서 백그라운드 전환 시 타이머 동작 불안정

### 2️⃣ 서버가 이벤트가 발생할 시각을 알려주기

- 서버는 **~~“몇 초가 지났는지”~~**가 아닌 **“언제 발생하는지”**를 알림
- 이벤트가 발생할 절대 시각을 전송 → 카운트다운 UI는 클라이언트 자체 계산

장점

- 서버 Publish 횟수 최소화 → 부하 감소
- 네트워크 지연이 UI에 직접적인 영향을 주지 않음
- 클라이언트 타이머는 로컬에서 안정적으로 동작
- 이벤트 시점의 기준이 항상 서버 시간으로 고정됨

단점

- 클라이언트에서 시간 계산 로직이 필요
- 클라이언트–서버 시간 오차를 고려해야 함
  (→ 서버 timestamp 기준으로 보정 가능)

<aside>
💡

두 번째 방향이 서버 부하, 네트워크 안정성, 사용자 경험 측면에서 가장 합리적이라고 판단

</aside>

## 5. 작업 스케줄링 방식 검토

위에서 동기화 방식에 대한 고민을 했으니 이제 채택된 방식을 어케 구현할 건지에 대한 고민을 해봅시다

우선 기준을 두 가지 잡아봤는데,

1. 이벤트 시점이 서버 기준으로 정확하게 보장됨?
   - 제일 중요한 정확성! → 빼면 시체죠?
2. 게임 도중 동적으로 생성되거나 삭제되는 이벤트 처리 가능?
   - 우리 앱 특성상 체포, 탈옥 로직에서 필수적으로 요구

### 1️⃣ @Scheduled 기반 스케줄링 (탈락)

스프링에서 제공하는 어노테이션 기반 스케줄링 방식

고정된 주기 또는 corn 표현식을 통해 작업 실행

⊕ corn 표현식 : 정해진 시간 규칙을 문자열 한 줄로 표현한 것

장점

- 구현이 매우 간단하다 → 어노테이션 한 줄 띡!
- 설정이 적고 러닝 커브가 낮다
- 주기적인 배치 작업에 적합

단점

- 요청 유무와 관계없이 항상 실행됨
  - 게임이 진행 중이지 않아도 스케줄이 계속 돈다
    → 게임 수와 무관하게 서버 리소스를 지속적으로 소비
- 실행 주기가 정적으로 고정
- 게임별로 스케줄을 분리하기 어렵다

<aside>
💡

게임 수명 주기에 종속되는 이벤트를 다루기에는 구조적으로 맞지 않다고 판단했습니당

</aside>

### 2️⃣ **TaskScheduler 기반 스케줄링 (채택)**

Spring의 TaskScheduler를 사용하여 필요한 시점에만 작업을 등록하고 실행 후 제거

장점

- 이벤트 발생 시점에만 작업이 존재
- 특정 시각에 실행 가능 → 타겟 시간 기반 이벤트에 적합
- 동시에 여러 게임의 스케줄을 독립적으로 관리 가능
- Redis Pub/Sub과 결합하여 스케줄 실행 = 이벤트 발행 구조를 만들기 용이

단점

- @Scheduled 대비 구현 난이도가 높음
- 스레드 풀, 동시성 관리에 대한 고려가 필요
- 잘못 설계할 경우 Race Condition 등의 문제가 발생 가능

**가장 큰 문제**

**인메모리 방식으로 동작하므로 애플리케이션 종료 시 예약된 모든 스케줄이 소멸**

→ 게임 진행은 시간 기준으로 다시 계산할 수 있기 때문에, 예약이 사라져도 게임 흐름 자체는 복구 가능

<aside>
💡

정확한 타이밍 + 동적 이벤트 + 다중 게임이라는 요구사항을 만족하기 위해
→ TaskScheduler가 적합하다고 판단했습니당

추가로, 구현 방식에 따라 복구 가능성이 있는 것으로 보여서 채택!

</aside>

### 3️⃣ Quartz Scheduler (배제)

Spring에서 많이 쓰이는 전문 스케줄링 프레임워크

Job / Trigger / JobStore 구조

장점

- 분산 환경에서 안정적
- DB 기반 Job 영속화 가능
- 장애 발생 시 재실행, 미실행 보장 등 기능 풍부

단점

- 오버엔지니어링
- 설정과 러닝 커브가 매우 큼
- Job 관리 비용이 큼
- 게임 이벤트 단위로 쓰기엔 무겁다

배제 이유

- 현재 요구사항은 초 단위 정확도, 단기 생명주기 이벤트
  → Quartz의 영속 Job 관리, 장애 복구 기능까지는 필요하지 않음

## 6. 전체 아키텍처 개요

사실 원래 단방향 같은 경우는 일반적으로 SSE가 권장됨

하지만 우리는 이미 채팅 기능으로 양방향 Websocket + STOMP가 구축되어 있으니!
→ 고대로 사용하면 된다는 말씀 = 별도의 SSE 연결을 만들 필요가 없다

통신 방식

HTTP + WebSocket(STOMP)

서버 내부 처리

- Spring TaskScheduler + Redis Pub/Sub
- 서버는 시간 계산과 스케줄링만 담당하고 실제 알림은 Redis Topic을 통해 STOMP로 전달

## 7. 이제 구현하자

근데 시작부터 약간 헷갈려서 정리해봄

<aside>
💡

game 패키지: 게임 방 엔티티 관리

- 게임 생성, 참여자 추가/제거
- "방"의 존재 자체를 다룸

play/lobby 패키지: 대기실 상태 동기화

- 참여자의 상태 변경 (팀, 준비, 시작)
- "방 안에서" 일어나는 일들

play/system 패키지: 게임 중 시스템 이벤트

- 경찰 이동, 위치 공개, 체포, 탈옥, 게임 종료
- 게임 타이머 및 스케줄링
</aside>

→ 첨엔 시작이 어디에 들어가야 자연스러울까 생각했는데 lobby에 넣게 되었습니다

- Start를 대기실의 마지막 상태 변화라고 정의
- 의존성의 방향도 `lobby → system` 이렇게 되게끔!

### 스케줄러 구현 방식에 대한 고민

**1️⃣ 게임 시작 시 모든 이벤트 한 번에 예약 (채택)**

게임 시작 시 경찰 이동, 도둑 위치 공개, 정기 스케줄을 한꺼번에 등록

- **장점**
  - 서버 재시작 시 복구 용이
    → 시작 시간만 알면 우리가 DB에 저장해놓은 설정값으로 미래 이벤트 재등록 가능
  - 이벤트 간 의존성 없이 독립 실행
- **단점**
  - 동시 게임 많으면 메모리 부담
  - 게임 중도 종료 시 남은 스케줄 직접 취소해야 댐

**2️⃣ 연속적으로 다음 이벤트를 예약하는 방식**

이벤트 실행 시 다음 이벤트 하나만 예약

- **장점**
  - 메모리 사용 최소화
  - 게임 종료 시 자연스럽게 중단
- **단점**
  - 서버 재시작 시 복구 불가
    → 우리는 마지막 이벤트를 DB에 저장하고 있지 않기 때문
  - 체이닝 중 예외 발생 시 이후 이벤트 전체 중단

**결론**

<aside>
💡

첫 번째방식으로 하면 게임 설정이 시작 시 확정되고 DB에 정보가 있어 복구 가능

동시 게임 수가 많지 않은 환경에서는 메모리 부담도 크지 않음

ex) 30분 게임, 도둑 위치 공개 5분이라고 할 떄의 메모리 부담

| **동시 게임 수** | **ScheduledFuture 수** | **메모리 (Memory)** |
| ---------------- | ---------------------- | ------------------- |
| **100**          | ~700                   | ~200KB              |
| **1,000**        | ~7,000                 | ~2MB                |
| **10,000**       | ~70,000                | ~20MB               |
| **100,000**      | ~700,000               | ~200MB              |

</aside>

- **스케줄러 전체 코드**
  ```java
  package com.team.cops_and_robbers.play.system.application;

  import com.team.cops_and_robbers.common.util.TimestampUtil;
  import com.team.cops_and_robbers.game.game.domain.Game;
  import com.team.cops_and_robbers.game.game.domain.GameStatus;
  import com.team.cops_and_robbers.game.game.repository.GameRepository;
  import com.team.cops_and_robbers.play.location.application.RobberLocationService;
  import com.team.cops_and_robbers.play.system.domain.SystemEvent;
  import com.team.cops_and_robbers.play.system.domain.SystemEventData;
  import jakarta.annotation.PostConstruct;
  import lombok.RequiredArgsConstructor;
  import lombok.extern.slf4j.Slf4j;
  import org.springframework.scheduling.TaskScheduler;
  import org.springframework.stereotype.Service;

  import java.time.Instant;
  import java.time.LocalDateTime;
  import java.util.ArrayList;
  import java.util.List;
  import java.util.Map;
  import java.util.concurrent.ConcurrentHashMap;
  import java.util.concurrent.ScheduledFuture;

  @Slf4j
  @Service
  @RequiredArgsConstructor
  public class GameSchedulerService {

      private final Map<Long, List<ScheduledFuture>> gameSchedules = new ConcurrentHashMap<>();

      private final TaskScheduler taskScheduler;
      private final SystemPublisher systemPublisher;
      private final SystemEventFactory systemEventFactory;
      private final GameRepository gameRepository;
      private final RobberLocationService robberLocationService;

      /**
       * 게임 시작 시 모든 이벤트 예약
       */
      public void scheduleAllEvents(Long gameId) {
          Game game = gameRepository.getByGameId(gameId);
          scheduleGame(game);
      }

      /**
       * 서버 재시작 시 진행 중인 게임의 스케줄 복구
       */
      @PostConstruct
      public void recoverSchedules() {
          List<Game> inProgressGames = gameRepository.findByStatus(GameStatus.IN_PROGRESS);

          for (Game game : inProgressGames) {
              scheduleGame(game);
          }
      }

      private void scheduleGame(Game game) {
          Long gameId = game.getId();
          List<ScheduledFuture> scheduledTasks = new ArrayList<>();
          LocalDateTime now = TimestampUtil.nowKstLocal();

          schedulePoliceMoveStart(scheduledTasks, game, now);
          scheduleRobberLocationReveals(scheduledTasks, game, now);

          gameSchedules.put(gameId, scheduledTasks);
      }

      private void schedulePoliceMoveStart(
              List<ScheduledFuture> scheduledTasks,
              Game game,
              LocalDateTime now
      ) {
          LocalDateTime policeMoveStartTime = game.getStartedAt()
                  .plusMinutes(game.getPoliceWaitMinutes());

          register(scheduledTasks, policeMoveStartTime, now,
                  () -> publishPoliceMoveStart(game.getId()));
      }

      private void scheduleRobberLocationReveals(
              List<ScheduledFuture> scheduledTasks,
              Game game,
              LocalDateTime now
      ) {
          int policeWaitMinutes = game.getPoliceWaitMinutes();
          int roundDurationMinutes = game.getRoundDurationMinutes();
          int revealIntervalMinutes = game.getLocationRevealIntervalMinutes();

          LocalDateTime policeMoveStartTime = game.getStartedAt()
                  .plusMinutes(policeWaitMinutes);
          LocalDateTime gameOverTime = game.getStartedAt()
                  .plusMinutes(roundDurationMinutes);
          LocalDateTime revealTime = policeMoveStartTime.
                  plusMinutes(revealIntervalMinutes);

          while (revealTime.isBefore(gameOverTime)) {
              LocalDateTime finalRevealTime = revealTime;

              register(scheduledTasks, finalRevealTime, now,
                      () -> publishRobberLocationReveal(game.getId()));

              revealTime = revealTime.plusMinutes(revealIntervalMinutes);
          }
      }

      private void register(
              List<ScheduledFuture> scheduledTasks,
              LocalDateTime targetTime,
              LocalDateTime now,
              Runnable task
      ) {
          if (targetTime.isAfter(now)) {
              Instant instant = TimestampUtil.toInstant(targetTime);
              ScheduledFuture scheduledTask = taskScheduler.schedule(task, instant);
              scheduledTasks.add(scheduledTask);
          }
      }

      private void publishPoliceMoveStart(Long gameId) {
          SystemEvent event = systemEventFactory.createPoliceMoveStartEvent(gameId);
          systemPublisher.publish(event);
      }

      private void publishRobberLocationReveal(Long gameId) {
          List<SystemEventData.RobberLocation> locations = robberLocationService.getCurrentRobberLocations(gameId);

          SystemEvent event = systemEventFactory.createRobberLocationRevealEvent(gameId, locations);
          systemPublisher.publish(event);
      }
  }

  ```

### 스레드 개수 늘리기

![image.png](attachment:7606a063-e1c1-4d7f-b572-e581eabe6569:image.png)

→ 원래는 기본적으로 사이즈가 1

```java
@Configuration
public class SchedulerConfig {

    private static final String GAME_SCHEDULER_PREFIX = "game-scheduler-";

    @Bean
    public TaskScheduler taskScheduler() {
        ThreadPoolTaskScheduler scheduler = new ThreadPoolTaskScheduler();
        scheduler.setPoolSize(10);
        scheduler.setThreadNamePrefix(GAME_SCHEDULER_PREFIX);
        scheduler.setWaitForTasksToCompleteOnShutdown(true);
        scheduler.setAwaitTerminationSeconds(30);
        scheduler.initialize();
        return scheduler;
    }
}
```

→ 그래서 10으로 늘려줌 !

> 게임 이벤트가 같은 시각에 겹칠 수 있음
> → 기본 1개 스레드로는 순차 처리되며 지연이 생김
> → 여러 게임의 이벤트를 동시에 처리하기 위해 풀 사이즈를 늘림

### 도둑 위치 전송 서비스 작성하기 (클라이언트 → 서버)

도둑 역할의 클라이언트가 일정 주기로 자신의 GPS 좌표를 서버에 전송하는 엔드포인트

서버는 이 위치를 즉시 브로드캐스트하지 않고 RobberLocationService의 인메모리 캐시에 저장만!
→ 스케줄러가 위치 공개 시점이 되면 캐시에서 꺼내서 경찰 팀에게 한꺼번에 공개

엔드포인트 : publish/game/{gameId}/location

```json
{
  "latitude": 37.5665,
  "longitude": 126.978
}
```

이 서비스에서는 participantId가 존재하지 않거나, 도둑이 아니라 경찰이 잘못 보내는 등의
상황이 발생해도 로그만 찍고 예외는 던지지 않게끔 했습니당

→ 예외 발생 시 WebSocket 세션 전체가 끊길 수 있음

→ 위치는 고빈도 메시지라 하나 놓쳐도 데이터 손실 아님

→ 사용자에게 에러를 보여줄 필요 없음

## 6. 개선하면 좋은 것 (후순위)

`위치 업데이트마다 DB 조회 중!`

위치 전송은 엄청 많이 일어나느데 updateLocation() 호출할 때마다
findByIdWithUser()로 DB를 거치고 있음

→ 팀 정보는 게임 중 안 바뀌니까 세션이나 캐싱해도 댈 듯

## 6. 수동 테스트 🫨 🤸

tool: https://jiangxy.github.io/websocket-debug-tool/

### 테스트 환경 세팅

- 테스트 유저 3명 생성 후
- 모든 유저를 동일한 게임 방에 참가시킴
  - 빠.테를 위해 게임 시간 10분에
  - 경찰 대기 시간 : 5분
  - 도둑 위치 공개 주기 : 2분
  - 경찰 1, 도둑 2로 세팅
- 각 유저를 서로 다른 브라우저 탭에서 웹소켓 연결

각 탭에서

- URL: `ws://localhost:8080/game-connection`
- Connect Type: `STOMP`
- 구독: `/subscribe/game/1/system`
  (게임 시작은 `/subscribe/game/1/lobby` 로 테스트 해야 댐)
- STOMP connect header:

```json
{
  "Authorization": "Bearer <해당 유저 토큰>"
}
```

### POLICE_MOVE_START (5분)

![image.png](attachment:c83cf8bf-e15a-475f-976c-7715fe1b7515:image.png)

→ 21분에 발행 된 것을 확인 가능

### LOCATION_REVEAL (2분)

![image.png](attachment:5e69e52d-0bb6-48f9-8632-9c1fc4c8600e:image.png)

→ 경찰 출발 후 2분 뒤인 23분에 잘 도착하는 것을 확인!

![image.png](attachment:0549dc2f-fa4e-4b45-846b-c40014ae00cb:image.png)

→ 이후 2분 뒤인 25분

![image.png](attachment:96002e2f-b0be-43a5-8039-0eb7f0b2c47d:image.png)

→ 이후 2분 뒤인 27분

![image.png](attachment:dc9adfe5-6d3a-4bc2-9e50-2c1c2fa2ee68:image.png)

→ 중간에 도둑 한 명 더 위치 send
→ 리스트 형식으로 잘 도착함

### 재접속 후 schedule 복구

![image.png](attachment:96859942-a474-4eb3-abc1-d3606f432e06:image.png)

→ 재접속 후에도 33분에 메시지가 3개의 탭에 멀쩡히 오는 것을 확인
