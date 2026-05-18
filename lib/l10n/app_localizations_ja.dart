// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'Cops and Robbers';

  @override
  String get loadingDefault => '処理中...';

  @override
  String get permissionLocationFallbackTitle => '位置情報権限の案内';

  @override
  String get permissionLocationFallbackMessage => '位置情報の権限を許可してください';

  @override
  String get dialogUpdateOptionalTitle => '新バージョン案内';

  @override
  String get dialogUpdateOptionalMessage => 'さらに良くなった新バージョンがあります\nアップデートしますか';

  @override
  String get dialogUpdateOptionalConfirm => 'アップデート';

  @override
  String get dialogUpdateOptionalCancel => '後で';

  @override
  String get dialogUpdateMandatoryTitle => 'アップデート案内';

  @override
  String get dialogUpdateMandatoryMessage => '新しいバージョンがリリースされました\nアップデートしますか';

  @override
  String get dialogUpdateMandatoryConfirm => 'アップデート';

  @override
  String get dialogUpdateMandatoryCancel => '後で';

  @override
  String chatSystemGameStartTime(int minutes) {
    return '制限時間は $minutes分です';
  }

  @override
  String get chatSystemGameStartReady => 'まもなくゲームが開始されます。すべてのプレイヤーは準備してください！';

  @override
  String get chatSystemGameStartReportTip =>
      'ゲーム中、チャットを長押しして迷惑なユーザーを通報およびブロックできます';

  @override
  String get chatSystemGameStartGo => 'ゲーム開始！幸運を祈ります！';

  @override
  String get chatSystemPoliceMoveWarning => '警察がまもなく出動します。泥棒は急いで移動してください！';

  @override
  String get chatSystemPoliceMove => '警察出動！泥棒は逃げてください！';

  @override
  String get chatSystemLocationReveal => '現在の泥棒の位置が公開されます！';

  @override
  String chatSystemRemainingRobbers(int count) {
    return '現在 $count人 逃走中！';
  }

  @override
  String chatSystemArrest(String policeNickname, String robberNickname) {
    return '@icon_police [$policeNickname]さんが @icon_robber [$robberNickname]さんを逮捕しました！';
  }

  @override
  String get chatSystemEscapeNotice => '泥棒が脱獄しました！今すぐ逮捕してください！';

  @override
  String get chatSystemFiveMinutesLeft => 'ゲーム終了まで残り5分です。最後のチャンスを逃さないでください！';

  @override
  String get errorNetworkTimeout => 'サーバーへの接続時間がタイムアウトしました';

  @override
  String get errorNetworkOffline => 'ネットワーク接続をご確認ください';

  @override
  String get errorServerInternal => 'サーバーに問題が発生しました';

  @override
  String get errorBadRequest => '不正なリクエストです';

  @override
  String get errorUnauthorized => '認証に失敗しました';

  @override
  String get errorForbidden => 'アクセス権限がありません';

  @override
  String get errorNotFound => '要求されたリソースが見つかりません';

  @override
  String get errorConflict => 'リクエストが現在の状態と衝突しています';

  @override
  String get buttonConfirm => '確認';

  @override
  String get buttonCancel => 'キャンセル';

  @override
  String get dialogReconnectMessage => '接続が途切れました。再接続が必要です';

  @override
  String get dialogReconnectButtonConnecting => '接続中...';

  @override
  String get dialogReconnectButtonRetry => '再接続';

  @override
  String get pageForceUpdateTitle => 'アップデートが必要です';

  @override
  String get pageForceUpdateMessage => '新しいバージョンがリリースされました\nアップデート後にご利用ください！';

  @override
  String get pageForceUpdateButton => 'アップデート';

  @override
  String get pageMaintenanceTitle => 'サーバーメンテナンス中';

  @override
  String get pageMaintenanceMessage =>
      'より良いサービスのためにメンテナンス中です\nしばらくしてからもう一度お試しください！';

  @override
  String get buttonGoogleSignIn => 'Googleで始める';

  @override
  String get buttonAppleSignIn => 'Appleで始める';

  @override
  String zoneRadiusKm(String km) {
    return '半径 ${km}km';
  }

  @override
  String zoneRadiusMeter(String radiusMeters) {
    return '半径 ${radiusMeters}m';
  }

  @override
  String get zoneRadiusLabel => '半径';

  @override
  String get dialogAgreementRequiredTermsTitle => '必須規約未同意';

  @override
  String get errorAuthLoginCancelled => 'ログインがキャンセルされました';

  @override
  String get settingsLanguageLabel => '言語';

  @override
  String get settingsLanguageSubtitle => 'アプリの表示言語を変更できます';

  @override
  String get settingsLanguagePageTitle => '言語を選択';

  @override
  String get settingsLanguageOptionSystem => 'システム';

  @override
  String get settingsLanguageOptionKorean => '한국어';

  @override
  String get settingsLanguageOptionEnglish => 'English';

  @override
  String get settingsLanguageOptionJapanese => '日本語';

  @override
  String get asset_loading_joinRoom => '潜入の準備中です';

  @override
  String get asset_loading_joinRoom477c => '作戦に合流しているところです';

  @override
  String get asset_loading_joinRoom24a9 => '秘密の通路から進入しています';

  @override
  String get asset_loading_joinRoomCb98 => '変装を確認しています';

  @override
  String get asset_loading_joinRoomF964 => '作戦投入人員を確認しています';

  @override
  String get asset_loading_joinRoomB36a => '設定のどこかを押し続けると秘密が開くらしいですよ';

  @override
  String get asset_loading_joinRoomAaf8 => 'アプリのバージョンを何度もタップすると何かが出るかも...？';

  @override
  String get asset_loading_joinRoom25aa => '誰かがバージョン番号に秘密を隠したという噂が...';

  @override
  String get asset_loading_createRoom => '作戦本部を設置しています';

  @override
  String get asset_loading_createRoomF1fe => '秘密のアジトを準備しています';

  @override
  String get asset_loading_createRoom01f8 => 'ゲームエリアを確保しています';

  @override
  String get asset_loading_createRoom5076 => '秘密の地図を広げています';

  @override
  String get asset_loading_createRoomDd9e => 'トランシーバーの周波数を合わせています';

  @override
  String get asset_loading_createRoomB36a => '設定のどこかを押し続けると秘密が開くらしいですよ';

  @override
  String get asset_loading_createRoomAaf8 => 'アプリのバージョンを何度もタップすると何かが出るかも...？';

  @override
  String get asset_loading_createRoom25aa => '誰かがバージョン番号に秘密を隠したという噂が...';

  @override
  String get asset_loading_changeTeam => '変装しています';

  @override
  String get asset_loading_changeTeam681d => '偽装身分を変更しています';

  @override
  String get asset_loading_changeTeam1106 => '身分をロンダリングしています';

  @override
  String get asset_loading_changeTeam4d7a => '二重スパイに転換しています';

  @override
  String get asset_loading_changeTeam4cdc => '新しい身分証を発行しています';

  @override
  String get asset_loading_changeTeamB36a => '設定のどこかを押し続けると秘密が開くらしいですよ';

  @override
  String get asset_loading_changeTeamAaf8 => 'アプリのバージョンを何度もタップすると何かが出るかも...？';

  @override
  String get asset_loading_changeTeam25aa => '誰かがバージョン番号に秘密を隠したという噂が...';

  @override
  String get asset_loading_startGame => '作戦開始の準備をしています';

  @override
  String get asset_loading_startGameA35d => '出動の準備をしています';

  @override
  String get asset_loading_startGame64c3 => 'カウントダウン開始';

  @override
  String get asset_loading_startGame7a2f => 'トランシーバーの電源を入れています';

  @override
  String get asset_loading_startGame1b41 => '現場エージェントを配置しています';

  @override
  String get asset_loading_startGameB36a => '設定のどこかを押し続けると秘密が開くらしいですよ';

  @override
  String get asset_loading_startGameAaf8 => 'アプリのバージョンを何度もタップすると何かが出るかも...？';

  @override
  String get asset_loading_startGame25aa => '誰かがバージョン番号に秘密を隠したという噂が...';

  @override
  String get asset_loading_updateArea => 'ゲームエリアを設定しています';

  @override
  String get asset_loading_updateArea8c32 => '管轄区域を指定しています';

  @override
  String get asset_loading_updateArea0183 => '地図の上に点を打っています';

  @override
  String get asset_loading_updateArea2433 => '衛星写真を分析しています';

  @override
  String get asset_loading_updateAreaDc8b => '作戦範囲を計算しています';

  @override
  String get asset_loading_updateAreaB36a => '設定のどこかを押し続けると秘密が開くらしいですよ';

  @override
  String get asset_loading_updateAreaAaf8 => 'アプリのバージョンを何度もタップすると何かが出るかも...？';

  @override
  String get asset_loading_updateArea25aa => '誰かがバージョン番号に秘密を隠したという噂が...';

  @override
  String get asset_loading_saveSettings => '作戦指針を編集しています';

  @override
  String get asset_loading_saveSettingsFb58 => 'ルールをアップデートしています';

  @override
  String get asset_loading_saveSettings65dc => '新しいルールを適用しています';

  @override
  String get asset_loading_saveSettings5e80 => '暗号を変更しています';

  @override
  String get asset_loading_saveSettings128d => '新しい作戦コードを適用しています';

  @override
  String get asset_loading_saveSettingsB36a => '設定のどこかを押し続けると秘密が開くらしいですよ';

  @override
  String get asset_loading_saveSettingsAaf8 => 'アプリのバージョンを何度もタップすると何かが出るかも...？';

  @override
  String get asset_loading_saveSettings25aa => '誰かがバージョン番号に秘密を隠したという噂が...';

  @override
  String get asset_loading_loadProfile => '身元を確認しています';

  @override
  String get asset_loading_loadProfile27ee => '指名手配書を確認しています';

  @override
  String get asset_loading_loadProfile6dac => '身分証を検査しています';

  @override
  String get asset_loading_loadProfile23c6 => '指紋を照合しています';

  @override
  String get asset_loading_loadProfile221d => '容疑者のプロフィールを分析しています';

  @override
  String get asset_loading_loadProfileB36a => '設定のどこかを押し続けると秘密が開くらしいですよ';

  @override
  String get asset_loading_loadProfileAaf8 => 'アプリのバージョンを何度もタップすると何かが出るかも...？';

  @override
  String get asset_loading_loadProfile25aa => '誰かがバージョン番号に秘密を隠したという噂が...';

  @override
  String get asset_loading_logout => '撤収しています';

  @override
  String get asset_loading_logout3031 => '潜伏しています';

  @override
  String get asset_loading_logoutCe40 => '足跡を消しています';

  @override
  String get asset_loading_logout0ba9 => '証拠を隠滅しています';

  @override
  String get asset_loading_logoutFc0d => '秘密の通路から脱出しています';

  @override
  String get asset_loading_logoutB36a => '設定のどこかを押し続けると秘密が開くらしいですよ';

  @override
  String get asset_loading_logoutAaf8 => 'アプリのバージョンを何度もタップすると何かが出るかも...？';

  @override
  String get asset_loading_logout25aa => '誰かがバージョン番号に秘密を隠したという噂が...';

  @override
  String get asset_loading_deleteAccount => '退会処理をしています';

  @override
  String get asset_loading_deleteAccountC5fd => '記録を抹消しています';

  @override
  String get asset_loading_deleteAccount517f => '身元を削除しています';

  @override
  String get asset_loading_reconnect => '再び現場に復帰しています';

  @override
  String get asset_loading_reconnectBa5f => '作戦に再合流しているところです';

  @override
  String get asset_loading_reconnect098b => '現場復帰の準備をしています';

  @override
  String get asset_loading_reconnect429b => '無線チャンネルを復旧しています';

  @override
  String get asset_loading_reconnect6b88 => '秘密の周波数を再探索しています';

  @override
  String get asset_loading_reconnectB36a => '設定のどこかを押し続けると秘密が開くらしいですよ';

  @override
  String get asset_loading_reconnectAaf8 => 'アプリのバージョンを何度もタップすると何かが出るかも...？';

  @override
  String get asset_loading_reconnect25aa => '誰かがバージョン番号に秘密を隠したという噂が...';

  @override
  String get asset_loading_bugReport => '報告書を作成しています';

  @override
  String get asset_loading_bugReportDd4b => '本部に報告書を提出しています';

  @override
  String get asset_loading_bugReport5d70 => '現場写真を添付しています';

  @override
  String get asset_loading_bugReport3c49 => '事件番号を付与しています';

  @override
  String get asset_loading_bugReport83ca => '捜査班に引き継いでいます';

  @override
  String get asset_locationpermission_serviceDisabledTitle =>
      '位置情報サービスがオフになっています';

  @override
  String get asset_locationpermission_serviceDisabledHome =>
      'ゲーム中、泥棒の位置を警察チームに共有し、エリア離脱を検知するために位置情報を使用します\n端末の設定で位置情報サービスをオンにしてください';

  @override
  String get asset_locationpermission_serviceDisabledGame =>
      'ゲームに復帰するには位置情報サービスをオンにしてください\n設定で許可したあと、アプリを再起動してください';

  @override
  String get asset_locationpermission_serviceDisabledWaitingRoom =>
      'ゲームに参加するには位置情報サービスをオンにしてください\n設定で許可したあと、アプリを再起動してください';

  @override
  String get asset_locationpermission_permissionDeniedTitle => '位置情報の権限が必要です';

  @override
  String get asset_locationpermission_permissionDeniedHome =>
      'ゲーム中、泥棒の位置を警察チームに共有し、エリア離脱を検知するために位置情報を使用します\n位置情報はゲームの参加者にのみ共有され、ゲーム終了時に直ちに停止されます';

  @override
  String get asset_locationpermission_permissionDeniedGame =>
      'ゲームに復帰するには位置情報の権限を許可してください\n設定で許可したあとにアプリを再起動してください';

  @override
  String get asset_locationpermission_permissionDeniedWaitingRoom =>
      'ゲームに参加するには位置情報の権限を許可してください\n設定で許可したあとにアプリを再起動してください';

  @override
  String get dialogsessionRepositoryImplMessage => '待機室の作成中に予期せぬエラーが発生しました';

  @override
  String get dialogsessionRepositoryImplMessageAddf =>
      '参加中のゲームの照会中に予期せぬエラーが発生しました';

  @override
  String session_sessionSettings_L22(String maxPlayers) {
    return '$maxPlayers人';
  }

  @override
  String session_sessionSettings_L27(int roundTimeMinutes) {
    return '$roundTimeMinutes分';
  }

  @override
  String session_sessionSettings_L32(int locationShareMinutes) {
    return '$locationShareMinutes分';
  }

  @override
  String session_sessionSettings_L37(int policeStartDelayMinutes) {
    return '泥棒が逃げたあと $policeStartDelayMinutes分後';
  }

  @override
  String session_zoneInfo_L25(String km) {
    return '半径 ${km}km';
  }

  @override
  String session_zoneInfo_L27(String radiusMeters) {
    return '半径 ${radiusMeters}m';
  }

  @override
  String get session_gameSettingsEditPage_L110 => '設定の保存に失敗しました';

  @override
  String get session_gameSettingsEditPage_L146 => '設定の編集';

  @override
  String get session_gameSettingsEditPage_L197 => '保存中...';

  @override
  String get session_gameSettingsEditPage_L197_1 => '保存';

  @override
  String get session_gameSettingsPage_L140 => 'エリアの保存に失敗しました';

  @override
  String get session_gameSettingsPage_L190 => 'ゲーム設定';

  @override
  String get session_gameSettingsPage_L210 => 'エリア情報を読み込めません';

  @override
  String get session_gameSettingsPage_L228 => '設定情報を読み込めません';

  @override
  String get session_gameSettingsPage_L270 => 'プレイグラウンド';

  @override
  String get session_gameSettingsPage_L275 => '牢屋';

  @override
  String get session_homePage_L108 => '新しいゲームを作成できます';

  @override
  String get session_homePage_L113 => '招待コードを入力するとゲームに参加できます';

  @override
  String get dialoghomePageTitle => '周囲を確認しながらご利用ください';

  @override
  String get dialoghomePageMessage =>
      'ゲーム中画面に集中しすぎると危険です\n道路や歩行環境を確認し、安全にご利用ください';

  @override
  String get dialoghomePageConfirm => '確認しました！';

  @override
  String get session_homePage_L158 => '今日はもう表示しない';

  @override
  String get dialoghomePageMessage50b3 => 'すでに参加中のゲームがあります';

  @override
  String get dialoghomePageMessage89ff => '不明なゲーム状態です';

  @override
  String get dialoghomePageConfirm5435 => '設定へ移動';

  @override
  String get dialoghomePageCancel => 'キャンセル';

  @override
  String get dialoghomePageTitleEeea => '途切れのないゲームのために';

  @override
  String get session_homePage_L332 => 'アプリ設定 → バッテリー → 制限なし に変更してください\n';

  @override
  String get session_homePage_L333 => 'そうすれば画面が消えてもゲームが途切れません';

  @override
  String get session_homePage_L432 => '参加に失敗しました。招待コードをご確認ください';

  @override
  String get dialoghomePageMessage8155 => '参加に失敗しました。もう一度お試しください';

  @override
  String get dialoghomePageTitle879f => '待機室に参加する';

  @override
  String get fieldhomePageHint => '招待コードを入力してください';

  @override
  String get dialoghomePageTitle86c1 => '招待コードQRをスキャンしてください';

  @override
  String get dialoghomePageCancel218e => '閉じる';

  @override
  String get dialoghomePageConfirm665b => '参加する';

  @override
  String get session_homePage_L601 => 'Cops and Robbers';

  @override
  String get dialoghomePageMessage9e36 => '準備中です';

  @override
  String get session_homePage_L661 => 'とても楽しみです\n今回はどんな役割になるでしょうか';

  @override
  String get session_homePage_L677 => '待機室を作る';

  @override
  String get session_homePage_L684 => '待機室に参加する';

  @override
  String get session_sessionCreationFlowPage_L160 =>
      'ゲームを行うゲームエリアを設定します\nまずプレイグラウンドを指定してください';

  @override
  String get session_sessionCreationFlowPage_L167 =>
      'ゲームルールを決めます\n数字をタップすると直接入力できます';

  @override
  String get session_sessionCreationFlowPage_L374 =>
      '待機室の作成に失敗しました。もう一度お試しください';

  @override
  String get dialogsessionCreationFlowPageMessage => 'すでに参加中のゲームがあります';

  @override
  String get dialogsessionCreationFlowPageMessage89ff => '不明なゲーム状態です';

  @override
  String get session_sessionCreationFlowPage_L483 => 'エリア選択を先に設定しましょうか';

  @override
  String get session_sessionCreationFlowPage_L484 => '人数を設定します';

  @override
  String get session_sessionCreationFlowPage_L485 => '基本情報を設定します';

  @override
  String get session_sessionCreationFlowPage_L486 => '最終設定を確認します';

  @override
  String get session_sessionCreationFlowPage_L491 => 'ゲームに必要なエリアを設定します';

  @override
  String get session_sessionCreationFlowPage_L492 => '最低2人からゲームの進行が可能です';

  @override
  String get session_sessionCreationFlowPage_L493 => 'ゲームを進行する際、必ず必要な情報です';

  @override
  String get session_sessionCreationFlowPage_L494 => '待機室を作る前に最後に設定を確認しましょうか';

  @override
  String get session_sessionCreationFlowPage_L503 => '次へ';

  @override
  String get session_sessionCreationFlowPage_L505 => '待機室を作る';

  @override
  String get session_sessionCreationFlowPage_L507 => '次へ';

  @override
  String get session_sessionCreationFlowPage_L660 => 'プレイグラウンド';

  @override
  String get session_sessionCreationFlowPage_L665 => '牢屋';

  @override
  String get session_sessionCreationFlowPage_L676 => 'エリア情報を先に設定してください';

  @override
  String get session_setupPlaygroundPage_L135 => 'ここをタップすると半径を直接入力できます';

  @override
  String get session_setupPlaygroundPage_L195 => 'プレイグラウンド';

  @override
  String get session_setupPlaygroundPage_L212 => 'プレイグラウンド';

  @override
  String get session_setupPlaygroundPage_L233 => 'ゲームが進行されるエリア全体の大きさを設定します';

  @override
  String get session_setupPlaygroundPage_L267 => '完了';

  @override
  String get session_setupPrisonPage_L210 => '牢屋';

  @override
  String get session_setupPrisonPage_L227 => '牢屋';

  @override
  String get session_setupPrisonPage_L248 => '泥棒を拘束しておく牢屋の位置と大きさを設定します';

  @override
  String get session_setupPrisonPage_L286 => 'プレイグラウンドを先に設定してください';

  @override
  String get session_setupPrisonPage_L287 => '牢屋がプレイグラウンドの範囲を超えています';

  @override
  String get session_setupPrisonPage_L299 => '完了';

  @override
  String get dialogwaitingRoomPageConfirm => '設定へ移動';

  @override
  String get dialogwaitingRoomPageCancel => '退室';

  @override
  String get session_waitingRoomPage_L364 => 'ぽかぽかクマ...';

  @override
  String get dialogwaitingRoomPageTitle => '待機室に参加できません';

  @override
  String get session_waitingRoomPage_L545 => '該当ゲームに参加していないユーザーです';

  @override
  String get dialogwaitingRoomPageConfirm3ce8 => '確認';

  @override
  String get session_waitingRoomPage_L631 => 'このボタンを押して別のチームに移動できます';

  @override
  String get session_waitingRoomPage_L637 => '友達に招待コードを共有できます';

  @override
  String get session_waitingRoomPage_L642 => 'ゲーム設定を確認できます';

  @override
  String get session_waitingRoomPage_L647 => '準備ができたら押してください';

  @override
  String get dialogwaitingRoomPageTitle1946 => 'インゲーム画面のプレビュー';

  @override
  String get dialogwaitingRoomPageMessage =>
      'ゲームが開始されたらどのように動作するか\n一度確認してから始めてみましょうか';

  @override
  String get dialogwaitingRoomPageConfirmA2d8 => '見に行く';

  @override
  String dialogwaitingRoomPageTitleBc54(String nickname) {
    return '$nicknameさんを退出させますか';
  }

  @override
  String get dialogwaitingRoomPageMessageB302 =>
      '追放されたユーザーは即座に待機室から退出させられます\n再び待機室に参加するには招待コードを入力する必要があります';

  @override
  String get dialogwaitingRoomPageCancelD9de => 'キャンセル';

  @override
  String get dialogwaitingRoomPageConfirmC08c => '退出させる';

  @override
  String get dialogwaitingRoomPageMessageE87b => '追放処理中にエラーが発生しました';

  @override
  String get dialogwaitingRoomPageTitle8208 => '待機室から退出させられました';

  @override
  String get dialogwaitingRoomPageMessage64a2 => '再び参加するには招待コードを入力する必要があります';

  @override
  String dialogwaitingRoomPageMessage36a5(String kickedNickname) {
    return '$kickedNicknameさんが退出させられました';
  }

  @override
  String get session_waitingRoomPage_L1030 => 'チーム変更に失敗しました';

  @override
  String get session_waitingRoomPage_L1062 => '準備状態の変更に失敗しました';

  @override
  String get session_waitingRoomPage_L1099 => 'ゲーム開始に失敗しました';

  @override
  String get dialogwaitingRoomPageTitleFfec => '待機室から退室しますか';

  @override
  String get dialogwaitingRoomPageMessage3930 => '退室すると、再度招待コードを入力する必要があります';

  @override
  String get dialogwaitingRoomPageConfirmC0a3 => '退室';

  @override
  String get session_waitingRoomPage_L1130 => '退出処理中にエラーが発生しました';

  @override
  String get dialogwaitingRoomPageTitleA5bb => '招待コードを作成しました';

  @override
  String get dialogwaitingRoomPageMessage06a6 => '友達にコードを共有してゲームに参加してみましょう！';

  @override
  String get dialogwaitingRoomPageMessage4785 => 'コードがコピーされました';

  @override
  String get dialogwaitingRoomPageCancel218e => '閉じる';

  @override
  String get dialogwaitingRoomPageConfirm27f8 => '共有する';

  @override
  String get session_waitingRoomPage_L1511 => 'ゲーム開始';

  @override
  String get session_waitingRoomPage_L1526 => '準備完了';

  @override
  String get session_waitingRoomPage_L1537 => '準備完了';

  @override
  String get session_zonePreviewPage_L122 => 'ゲームエリア';

  @override
  String get session_zonePreviewPage_L145 => '現在設定されているゲームエリアです';

  @override
  String get session_waitingRoomParticipantsProvider_L81 => 'ぽかぽかクマ...';

  @override
  String get session_waitingRoomParticipantsProvider_L87 => 'おてんばタヌキ';

  @override
  String get session_waitingRoomParticipantsProvider_L93 => 'ニックネーム';

  @override
  String get session_waitingRoomParticipantsProvider_L99 => 'ニックネーム';

  @override
  String get dialoggameRulesContentTitle => 'ゲームルール';

  @override
  String get dialoggameRulesContentCancel => '確認';

  @override
  String get dialoggameRulesContentConfirm => 'インゲームを見る';

  @override
  String get session_gameRulesContent_L95 => '警察はすべての泥棒を捕まえて';

  @override
  String get session_gameRulesContent_L96 => '逮捕すれば、';

  @override
  String get session_gameRulesContent_L97 => '\n泥棒は';

  @override
  String get session_gameRulesContent_L98 => '制限時間が終了するまで逃げ切れば';

  @override
  String get session_gameRulesContent_L99 => '勝利します';

  @override
  String get session_gameRulesContent_L108 => '泥棒チームの位置は';

  @override
  String session_gameRulesContent_L109(int minutes) {
    return '$minutes分ごとに警察チームに共有されます';
  }

  @override
  String get session_gameRulesContent_L110 => '';

  @override
  String get session_gameRulesContent_L118 => '指定されたゲームエリアから外に出てはいけません';

  @override
  String get session_gameRulesContent_L119 => '\n→ エリア外に出ると画面がロックされます';

  @override
  String get dialogsessionCodeCardMessage => 'コードがコピーされました';

  @override
  String get dialogstep0SelectAreaContentTitle => 'プレイグラウンド';

  @override
  String get dialogstep0SelectAreaContentTitle5bc0 => '牢屋';

  @override
  String get fieldstep1ParticipantSettingsContentLabel => '最大参加者';

  @override
  String get session_step1ParticipantSettingsContent_L52 => '人';

  @override
  String get fieldstep2GameSettingsContentLabel => 'ラウンド制限時間';

  @override
  String get session_step2GameSettingsContent_L79 => '分';

  @override
  String get fieldstep2GameSettingsContentLabel5ab2 => '泥棒の位置公開間隔';

  @override
  String get session_step2GameSettingsContent_L97 => '分';

  @override
  String get session_step2GameSettingsContent_L104 => '泥棒の位置が公開されません！';

  @override
  String get fieldstep2GameSettingsContentLabelCe3b => '警察出動時間';

  @override
  String get session_step2GameSettingsContent_L115 => '分';

  @override
  String get session_step2GameSettingsContent_L117 => '泥棒が逃げたあと';

  @override
  String get session_step2GameSettingsContent_L118 => '後';

  @override
  String get session_sessionStepLayout_L42 => '次へ';

  @override
  String get dialogsettingListCardTitle => '設定';

  @override
  String get fieldsettingListCardLabel => '参加人数';

  @override
  String get fieldsettingListCardLabelEc5e => 'ラウンド制限時間';

  @override
  String get fieldsettingListCardLabelA1b3 => '位置公開間隔';

  @override
  String get fieldsettingListCardLabelCe3b => '警察出動時間';

  @override
  String get session_teamSection_L116 => '警察チーム';

  @override
  String get session_teamSection_L116_1 => '泥棒チーム';

  @override
  String session_teamSection_L178(int length) {
    return '現在 $length人';
  }

  @override
  String get dialogzoneListCardTitle => 'エリア';

  @override
  String get dialogauthRepositoryImplMessage => 'ログイン中にエラーが発生しました';

  @override
  String get dialogauthRepositoryImplMessage993d => 'ログアウト中にエラーが発生しました';

  @override
  String get auth_firebaseAuthErrorHandler_L31 => 'ログイン情報を取得できません。もう一度お試しください';

  @override
  String get auth_firebaseAuthErrorHandler_L33 =>
      '認証トークンの発行に失敗しました。もう一度お試しください';

  @override
  String get auth_firebaseAuthErrorHandler_L35 =>
      'Firebase認証トークンの検証に失敗しました。再度ログインしてください';

  @override
  String get auth_firebaseAuthErrorHandler_L37 => 'ログインがキャンセルされました';

  @override
  String get auth_firebaseAuthErrorHandler_L39 => 'ネットワーク接続をご確認ください';

  @override
  String get auth_firebaseAuthErrorHandler_L41 => '不正な認証情報です';

  @override
  String get auth_firebaseAuthErrorHandler_L43 => '無効化されたアカウントです';

  @override
  String get auth_firebaseAuthErrorHandler_L45 =>
      'リクエストが多すぎます。しばらくしてからもう一度お試しください';

  @override
  String get auth_firebaseAuthErrorHandler_L47 => 'このログイン方法は現在ご利用いただけません';

  @override
  String get auth_firebaseAuthErrorHandler_L49 =>
      'Firebase設定に問題があります。しばらくしてからもう一度お試しください';

  @override
  String get auth_firebaseAuthErrorHandler_L51 =>
      'Firebase内部エラーが発生しました。しばらくしてからもう一度お試しください';

  @override
  String auth_firebaseAuthErrorHandler_L55(int provider) {
    return '$provider ログインに失敗しました。もう一度お試しください';
  }

  @override
  String get auth_firebaseAuthErrorHandler_L57 => 'ログインに失敗しました。もう一度お試しください';

  @override
  String get dialogagreementPageTitle => '利用規約';

  @override
  String get dialogagreementPageTitleBe29 => '個人情報処理方針';

  @override
  String get dialogagreementPageTitle6dcc => '位置情報利用規約';

  @override
  String get dialogagreementPageTitle76b8 => 'マーケティング情報の受信';

  @override
  String get auth_agreementPage_L107 => '同意して始める';

  @override
  String get auth_agreementPage_L127 => 'サービス利用のために\n規約に同意してください';

  @override
  String get auth_agreementPage_L135 => '必須規約にすべて同意する必要がサービスをご利用いただけます';

  @override
  String get dialogagreementPageMessage => 'まだネットワークに接続されていません';

  @override
  String get dialogagreementPageMessage24a8 => '必須規約にすべて同意してください';

  @override
  String get auth_agreementPage_L184 => '一時的なエラーが発生しました。もう一度お試しください';

  @override
  String get dialogloginPageTitle => '個人情報処理方針';

  @override
  String get dialogloginPageTitle2aa8 => '利用規約';

  @override
  String get dialogloginPageTitle6dcc => '位置情報利用規約';

  @override
  String get dialogloginPageMessage => '退会が完了しました';

  @override
  String get dialogloginPageTitleA40f => '14歳以上ですか';

  @override
  String get dialogloginPageMessageBa5d =>
      'Cops and Robbersは14歳未満の会員登録ができません\n該当情報は登録禁止の確認目的のみに使用しています';

  @override
  String get dialogloginPageConfirm => 'はい';

  @override
  String get dialogloginPageCancel => 'いいえ';

  @override
  String get dialogloginPageMessageFe9d => 'ログインがキャンセルされました';

  @override
  String get auth_loginPage_L166 => 'ログイン中にエラーが発生しました';

  @override
  String get auth_loginPage_L191 => 'Appleログイン中にエラーが発生しました';

  @override
  String get auth_loginPage_L260 => '14歳未満はサービスを利用できません';

  @override
  String get auth_loginPage_L284 => 'ログインすると、';

  @override
  String get auth_loginPage_L286 => '個人情報処理方針';

  @override
  String get auth_loginPage_L295 => '利用規約';

  @override
  String get auth_loginPage_L304 => '位置情報利用規約';

  @override
  String get auth_loginPage_L311 => 'に同意したことになります';

  @override
  String get dialognicknameSetupPageMessage => 'ニックネームが保存されました';

  @override
  String get auth_nicknameSetupPage_L248 => 'ニックネームを設定します';

  @override
  String get auth_nicknameSetupPage_L257 =>
      'サービス内で引き続き使用されるニックネームです\n1〜10文字で作成できます';

  @override
  String get auth_nicknameSetupPage_L281 => '確認';

  @override
  String get auth_nicknameSetupPage_L308 => 'ニックネームを入力してください';

  @override
  String get auth_nicknameSetupPage_L336 => '重複確認';

  @override
  String get auth_nicknameSetupPage_L354 => '1文字未満のニックネームは使用できません';

  @override
  String get auth_nicknameSetupPage_L359 => '重複したニックネームです。別のニックネームを入力してください';

  @override
  String get auth_nicknameSetupPage_L364 => '使用可能なニックネームです';

  @override
  String get auth_nicknameSetupPage_L369 => 'エラーが発生しました。もう一度お試しください';

  @override
  String get auth_splashPage_L48 => '再び現場に復帰しています';

  @override
  String get auth_splashPage_L208 => '再び現場に復帰しています';

  @override
  String get dialogsplashPageMessage => 'まだネットワークに接続されていません';

  @override
  String get dialogsplashPageTitle => 'ネットワーク接続失敗';

  @override
  String get dialogsplashPageMessage665f => 'インターネット接続を確認したあと\nもう一度お試しください';

  @override
  String get dialogsplashPageConfirm => '再試行';

  @override
  String get auth_splashPage_L395 => '少々お待ちください';

  @override
  String get auth_splashPage_L412 => 'by 童心守り隊';

  @override
  String get auth_splashPage_L444 => 'インターネット接続が必要です';

  @override
  String get auth_splashPage_L450 => '接続状態を確認したあと\nもう一度お試しください';

  @override
  String get auth_splashPage_L461 => 'もう一度試す';

  @override
  String get dialogagreementProviderMessage => '一時的なエラーが発生しました。もう一度お試しください';

  @override
  String auth_authProvider_L129(String message) {
    return '事由: $message';
  }

  @override
  String get dialogauthProviderMessage => '不明なエラーが発生しました';

  @override
  String get dialogauthProviderMessage222f => 'ログアウトに失敗しました';

  @override
  String get auth_agreementAllCheckbox_L35 => '全て同意';

  @override
  String get auth_agreementItem_L39 => '[必須]';

  @override
  String get auth_agreementItem_L39_1 => '[選択]';

  @override
  String get dialoggamePageConfirm => '設定へ移動';

  @override
  String get game_gamePage_L379 => '泥棒が逃走しています！';

  @override
  String get game_gamePage_L1026 => 'ゲーム終了！';

  @override
  String get game_gamePage_L1034 => '泥棒が全員逮捕されました！';

  @override
  String get game_gamePage_L1034_1 => '制限時間が終了しました！';

  @override
  String get game_gamePage_L1086 => '警察チーム';

  @override
  String get game_gamePage_L1086_1 => '泥棒チーム';

  @override
  String get game_gamePage_L1090 => '勝利';

  @override
  String get game_gamePage_L1090_1 => '敗北';

  @override
  String dialoggamePageMessage(String winnerTeamLabel) {
    return '$winnerTeamLabelの勝利です！';
  }

  @override
  String get dialoggamePageCancel => 'ホームへ';

  @override
  String get dialoggamePageConfirm5863 => 'もう一度';

  @override
  String get game_gamePage_L1289 => '警察';

  @override
  String get game_gamePage_L1290 => '泥棒';

  @override
  String get dialoggamePageMessage5e97 => '警察の待機時間中は泥棒を逮捕できません';

  @override
  String get dialoggamePageTitle => '泥棒の指名手配QRをスキャンしてください';

  @override
  String get dialoggamePageMessage6487 => '有効期限切れのQRです。QRの更新をリクエストしてください';

  @override
  String get dialoggamePageMessage4b5f => 'すでに逮捕された泥棒です';

  @override
  String get game_gameEventProvider_L337 => '認証トークンを取得できません。再ログインが必要です';

  @override
  String get game_gameEventProvider_L452 => '逮捕リクエスト失敗';

  @override
  String get game_gameEventProvider_L492 => '脱獄リクエスト失敗';

  @override
  String get game_gameEventProvider_L520 => 'サーバーに接続できません。しばらくしてからもう一度お試しください';

  @override
  String get game_gameEventProvider_L702 => '警察';

  @override
  String get game_gameEventProvider_L703 => '泥棒';

  @override
  String get game_gameEventProvider_L866 => 'サーバーに接続できません。しばらくしてからもう一度お試しください';

  @override
  String get game_gameEventProvider_L937 => '認証の有効期限が切れました。再ログインが必要です';

  @override
  String get game_gameEventProvider_L951 => '認証の有効期限が切れました。再ログインが必要です';

  @override
  String get game_arrestLockOverlay_L71 => '逮捕されました！';

  @override
  String get game_arrestLockOverlay_L78 =>
      '逮捕されている間はゲームの状況を確認できません\n同じチームに救助要請をして素早く脱獄しましょう！';

  @override
  String get game_arrestLockOverlay_L89 => '脱獄完了';

  @override
  String get dialogarrestLockOverlayTitle => '脱獄';

  @override
  String get dialogarrestLockOverlayMessage => '脱獄しますか';

  @override
  String get game_arrestLockOverlay_L102 => '脱獄';

  @override
  String get game_gameActionModal_L63 => 'いいえ';

  @override
  String get game_gameActionModal_L63_1 => 'キャンセル';

  @override
  String get game_gameOverResultDialog_L324 => '勝利';

  @override
  String get game_gameOverResultDialog_L324_1 => '敗北';

  @override
  String get fieldgameOverResultDialogLabel => '逮捕回数';

  @override
  String game_gameOverResultDialog_L345(int totalArrestCount) {
    return '$totalArrestCount回';
  }

  @override
  String get fieldgameOverResultDialogLabelD8df => '残りの泥棒';

  @override
  String game_gameOverResultDialog_L351(int remainingRobberCount) {
    return '$remainingRobberCount人';
  }

  @override
  String get fieldgameOverResultDialogLabelAb0c => 'ゲーム進行時間';

  @override
  String get game_gameOverResultDialog_L438 => 'ホームへ';

  @override
  String get game_gameOverResultDialog_L452 => 'もう一度';

  @override
  String game_locationRevealCountdown_L109(String _formatted) {
    return '次の泥棒の位置公開まで $_formatted';
  }

  @override
  String get dialogparticipantOverlayMessage => '警察の待機時間中は泥棒を逮捕できません';

  @override
  String get dialogparticipantOverlayTitle => '該当のプレイヤーを逮捕しましたか';

  @override
  String get game_participantOverlay_L139 => 'はい';

  @override
  String get dialogparticipantOverlayTitle4167 => '脱獄';

  @override
  String get dialogparticipantOverlayMessage9497 => '脱獄を試みますか';

  @override
  String get game_participantOverlay_L166 => '脱獄';

  @override
  String get game_participantOverlay_L297 => '現在';

  @override
  String game_participantOverlay_L299(int count) {
    return '$count人';
  }

  @override
  String get game_participantOverlay_L305 => '逃走中！';

  @override
  String game_policeStartCountdown_L79(String _formatted) {
    return '警察開始まで $_formatted';
  }

  @override
  String get game_qrDisplayDialog_L62 => '指名手配QR';

  @override
  String get game_qrDisplayDialog_L86 => '警察にQRコードを見せてください';

  @override
  String get game_qrDisplayDialog_L97 => '閉じる';

  @override
  String get dialogqrScannerPageTitle => 'カメラの権限が必要です';

  @override
  String get dialogqrScannerPageMessage =>
      'QRコードをスキャンするにはカメラの権限が必要です\n設定でカメラの権限を許可してください';

  @override
  String get dialogqrScannerPageConfirm => '設定へ移動';

  @override
  String get dialogqrScannerPageCancel => '閉じる';

  @override
  String get game_qrScannerPage_L90 => 'カメラを使用できません';

  @override
  String get game_zoneExitBanner_L66 => 'プレイグラウンドを外れました';

  @override
  String get chat_chatProvider_L190 => '認証トークンを取得できません。再ログインが必要です';

  @override
  String get chat_chatProvider_L254 => '自分';

  @override
  String get dialogchatProviderMessage => '[チーム]';

  @override
  String get chat_chatProvider_L265 => 'チームメイトのニックネーム';

  @override
  String get chat_chatProvider_L265_1 => '相手のニックネーム';

  @override
  String get chat_chatProvider_L286 => 'システム';

  @override
  String get dialogchatProviderMessageDfca => '制限時間は30分です';

  @override
  String get chat_chatProvider_L381 => 'システム';

  @override
  String get dialogchatProviderMessage2119 =>
      '間もなくゲームが開始されます。すべてのプレイヤーは準備してください！';

  @override
  String get chat_chatProvider_L388 => 'システム';

  @override
  String get dialogchatProviderMessageC357 => '泥棒さん、うまく逃げてくださいね〜';

  @override
  String get chat_chatProvider_L395 => 'ニックネーム';

  @override
  String get dialogchatProviderMessageEa9a => '勝ちましょう！';

  @override
  String get chat_chatProvider_L402 => 'ニックネーム';

  @override
  String get chat_chatProvider_L564 => 'サーバーに接続できません。しばらくしてからもう一度お試しください';

  @override
  String get chat_chatProvider_L655 => '認証の有効期限が切れました。再ログインが必要です';

  @override
  String get chat_chatProvider_L676 => '認証の有効期限が切れました。再ログインが必要です';

  @override
  String get dialogchatContextMenuMessage => 'メッセージがコピーされました';

  @override
  String get dialogchatContextMenuMessage2c60 => '該当ユーザーをブロックしました';

  @override
  String get dialogchatContextMenuTitle => '通報';

  @override
  String get fieldchatContextMenuLabel => '通報内容';

  @override
  String get fieldchatContextMenuHint => '通報の理由を詳しく記入してください\n(状況や会話内容を含めてください)';

  @override
  String get chat_chatContextMenu_L140 => '通報';

  @override
  String get dialogchatContextMenuMessageDf78 => '通報が受け付けられました';

  @override
  String get dialogchatContextMenuMessage9d41 => '通報に失敗しました';

  @override
  String get dialogchatContextMenuTitle5ccb => '該当ユーザーを通報しますか';

  @override
  String get dialogchatContextMenuCancel => 'キャンセル';

  @override
  String get dialogchatContextMenuConfirm => '通報';

  @override
  String get chat_chatContextMenu_L190 => '選択した通報理由:';

  @override
  String get chat_chatContextMenu_L202 => '\n報告された内容は検討した上で対処いたします';

  @override
  String get fieldchatContextMenuLabelA83e => 'コピーする';

  @override
  String get fieldchatContextMenuLabel7812 => '通報';

  @override
  String get fieldchatContextMenuLabel2f14 => 'ブロック';

  @override
  String get chat_chatContextMenu_L478 => '通報タイプの選択';

  @override
  String chat_chatInputBar_L98(String all) {
    return '全体 $all件';
  }

  @override
  String chat_chatInputBar_L99(String team) {
    return 'チーム $team件';
  }

  @override
  String get chat_chatInputBar_L158 => '接続中...';

  @override
  String get chat_chatInputBar_L159 => 'チャットを入力してください';

  @override
  String get chat_chatMessageList_L152 => 'チャットを始めてみてください';

  @override
  String get fieldchatMessageListLabel => '最新のメッセージへ移動';

  @override
  String get chat_chatMessageList_L276 => '月';

  @override
  String get chat_chatMessageList_L276_1 => '火';

  @override
  String get chat_chatMessageList_L276_2 => '水';

  @override
  String get chat_chatMessageList_L276_3 => '木';

  @override
  String get chat_chatMessageList_L276_4 => '金';

  @override
  String get chat_chatMessageList_L276_5 => '土';

  @override
  String get chat_chatMessageList_L276_6 => '日';

  @override
  String chat_chatMessageList_L278(
    String year,
    String month,
    String day,
    String weekday,
  ) {
    return '$year年 $month月 $day日 $weekday曜日';
  }

  @override
  String get chat_chatOverlay_L428 => '全体チャット';

  @override
  String get chat_chatOverlay_L428_1 => 'チームチャット';

  @override
  String get chat_chatPreviewCard_L116 => '告知';

  @override
  String get chat_chatPreviewCard_L120 => 'チーム';

  @override
  String get chat_chatPreviewCard_L124 => '全体';

  @override
  String get dialogagreementSettingsPageMessage => 'まだネットワークに接続されていません';

  @override
  String get dialogagreementSettingsPageMessageEfc5 => '変更事項が保存されました';

  @override
  String get settings_agreementSettingsPage_L102 =>
      '一時的なエラーが発生しました。もう一度お試しください';

  @override
  String get settings_agreementSettingsPage_L142 => '利用規約とポリシー';

  @override
  String get settings_agreementSettingsPage_L159 => '規約への同意状況を読み込めません';

  @override
  String get settings_agreementSettingsPage_L176 => 'もう一度試す';

  @override
  String get dialogagreementSettingsPageTitle => '利用規約';

  @override
  String get dialogagreementSettingsPageTitleBe29 => '個人情報処理方針';

  @override
  String get dialogagreementSettingsPageTitle6dcc => '位置情報利用規約';

  @override
  String get dialogagreementSettingsPageTitle76b8 => 'マーケティング情報の受信';

  @override
  String get settings_agreementSettingsPage_L261 => '変更事項を保存';

  @override
  String get settings_legalDocumentPage_L105 => '文書を読み込めません';

  @override
  String get settings_settingsPage_L104 => '設定';

  @override
  String get settings_settingsPage_L115 => 'アカウント';

  @override
  String get settings_settingsPage_L117 => 'ニックネーム変更';

  @override
  String get settings_settingsPage_L128 => 'アプリ設定';

  @override
  String get settings_settingsPage_L130 => 'ゲーム通知';

  @override
  String get settings_settingsPage_L131 => 'ゲーム進行中に発生するイベントの通知を設定します';

  @override
  String get settings_settingsPage_L137 => '通知';

  @override
  String get settings_settingsPage_L143 => 'ゲーム中通知';

  @override
  String get settings_settingsPage_L149 => 'を含む、アプリから送信されるすべての通知を設定します';

  @override
  String get settings_settingsPage_L164 => '位置情報の権限管理';

  @override
  String get settings_settingsPage_L165 => '端末の設定で位置情報の権限を変更できます';

  @override
  String get settings_settingsPage_L176 => '利用案内';

  @override
  String get settings_settingsPage_L179 => 'バグ報告';

  @override
  String get settings_settingsPage_L182 => 'チュートリアルをもう一度見る';

  @override
  String get settings_settingsPage_L186 => 'チュートリアル初期化';

  @override
  String get settings_settingsPage_L189 => '利用規約とポリシー';

  @override
  String get settings_settingsPage_L202 => 'その他';

  @override
  String get settings_settingsPage_L204 => 'ログアウト';

  @override
  String get settings_settingsPage_L210 => '退会';

  @override
  String get settings_settingsPage_L292 => 'アプリバージョン';

  @override
  String get dialogsettingsPageMessage => 'ゲーム通知の設定を変更できませんでした';

  @override
  String get dialogsettingsPageTitle => 'バグ報告';

  @override
  String get fieldsettingsPageLabel => 'バグ内容';

  @override
  String get fieldsettingsPageHint =>
      'どのような問題が発生しましたか\n発生状況を詳しく記入してください(時間、端末情報を含む)';

  @override
  String get settings_settingsPage_L498 => '報告する';

  @override
  String get dialogsettingsPageMessage1b8e => 'バグ報告が受け付けられました';

  @override
  String get dialogsettingsPageTitleD4a4 => 'チュートリアル初期化';

  @override
  String get dialogsettingsPageMessageA4c9 =>
      'すべての画面のチュートリアルを\nもう一度見られるように初期化しますか';

  @override
  String get dialogsettingsPageConfirm => '初期化';

  @override
  String get dialogsettingsPageMessageC8cb => 'チュートリアルが初期化されました';

  @override
  String get dialogsettingsPageTitle9ab1 => 'ログアウト';

  @override
  String get dialogsettingsPageMessageE675 => '本当にログアウトしますか';

  @override
  String get dialogsettingsPageConfirm9ab1 => 'ログアウト';

  @override
  String get settings_settingsPage_L590 => 'ログアウトに失敗しました';

  @override
  String get settings_settingsPage_L590_1 => 'ログアウトしました';

  @override
  String get dialogsettingsPageTitle5e0d => '退会';

  @override
  String get settings_settingsPage_L603 =>
      '退会するとすべてのデータが削除され\n元に戻すことはできません\n\n続けるには「delete」と入力してください';

  @override
  String get fieldsettingsPageHint2960 => 'delete';

  @override
  String get dialogsettingsPageCancel => 'キャンセル';

  @override
  String get dialogsettingsPageConfirm9140 => '退会';

  @override
  String get settings_settingsPage_L613 => '退会する';

  @override
  String get tutorial_inGameTutorialPage_L62 => 'Cop1';

  @override
  String get tutorial_inGameTutorialPage_L72 => 'RobberKing';

  @override
  String get tutorial_inGameTutorialPage_L78 => 'RobberOrNot';

  @override
  String get tutorial_inGameTutorialPage_L84 => 'CapturedRobber';

  @override
  String get dialoginGameTutorialPageTitle => 'チュートリアル完了！';

  @override
  String get dialoginGameTutorialPageMessage =>
      '核心となる流れをマスターしました\n実際のゲームで活用してみましょう';

  @override
  String get dialoginGameTutorialPageConfirm => 'チュートリアルを終了する';

  @override
  String get dialoginGameTutorialPageMessage8372 => '自分の位置にカメラが移動しました';

  @override
  String get tutorial_inGameTutorialPage_L391 => '地図のプレビュー';

  @override
  String get tutorial_inGameTutorialPage_L434 => '次の泥棒の位置公開まで 04:30';

  @override
  String get dialoginGameTutorialPageMessage9b3f => 'ゲームルールの案内が開きます';

  @override
  String get tutorial_inGameTutorialPage_L491 =>
      '自分の指名手配QRが画面に表示されます。警察に見せると逮捕されます';

  @override
  String get tutorial_inGameTutorialPage_L492 => 'カメラが起動し、泥棒のQRをスキャンして逮捕できます';

  @override
  String get tutorial_inGameTutorialPage_L509 => '参加者表示ボタンを押してみてください';

  @override
  String get tutorial_inGameTutorialPage_L509_1 => 'QRボタンを押してみてください';

  @override
  String get tutorial_inGameTutorialPage_L509_2 => '地図に戻ってみてください';

  @override
  String tutorial_inGameTutorialPage_L525(String _missionStep) {
    return 'ミッション $_missionStep/3';
  }

  @override
  String get tutorial_inGameTutorialPage_L608 => '泥棒視点で見ているところです';

  @override
  String get tutorial_inGameTutorialPage_L608_1 => '警察視点で見ているところです';

  @override
  String get dialoginGameTutorialPageMessageA1c5 =>
      '自分が収監された場合、カードタップで脱獄を試みることができます';

  @override
  String get dialoginGameTutorialPageMessage9331 => '実際のゲームでは、QRスキャンで泥棒を逮捕します';

  @override
  String get tutorial_inGameTutorialPage_L688 => '現在';

  @override
  String tutorial_inGameTutorialPage_L690(int count) {
    return '$count人';
  }

  @override
  String get tutorial_inGameTutorialPage_L696 => '逃走中！';

  @override
  String get dialoginGameTutorialPageMessage7650 => 'ハンドルを上にドラッグするとチャットが展開されます';

  @override
  String get dialoginGameTutorialPageMessageDb39 =>
      'ここにメッセージを入力すると、チーム/全体チャットに送信できます';

  @override
  String get tutorial_inGameTutorialPage_L806 => 'チャットを入力してください';

  @override
  String get dialogtutorialCatalogPageTitle => '待機室を作る';

  @override
  String get tutorial_tutorialCatalogPage_L20 => 'プレイグラウンド・牢屋の設定とスライダー操作';

  @override
  String get dialogtutorialCatalogPageTitle879f => '待機室に参加する';

  @override
  String get tutorial_tutorialCatalogPage_L25 => '招待コードの入力とQRスキャン';

  @override
  String get dialogtutorialCatalogPageTitle2421 => '待機室';

  @override
  String get tutorial_tutorialCatalogPage_L30 => 'チーム変更、ゲーム設定、準備完了';

  @override
  String get dialogtutorialCatalogPageTitle8700 => 'インゲーム';

  @override
  String get tutorial_tutorialCatalogPage_L35 => 'タイマー・地図・参加者・チャット・QR';

  @override
  String get tutorial_tutorialCatalogPage_L62 => 'チュートリアル';

  @override
  String get tutorial_tutorialCatalogPage_L69 =>
      'ゲームを初めてプレイする場合は、一度見てから始めてみてください';

  @override
  String get tutorial_tutorialCatalogPage_L200 => '準備中';

  @override
  String get credits_creditMember_L78 => 'Hong Eui-min';

  @override
  String get credits_creditMember_L97 => 'Park Chan-bin';

  @override
  String get credits_creditMember_L110 => 'Lee Chang-hee';

  @override
  String get credits_creditMember_L122 => 'Jeong Sang-hee';

  @override
  String get credits_creditMember_L137 => 'Hwang Hye-rim';

  @override
  String get credits_creditMember_L149 => 'Yoon Ji-hee';

  @override
  String get credits_creditMember_L220 => 'Shin Ji-hoon';

  @override
  String get credits_creditMember_L227 => 'Nam Hae-yoon';

  @override
  String get credits_creditMember_L233 => 'Song Hye-jung';

  @override
  String get credits_creditMember_L239 => 'Lee Jin';

  @override
  String get credits_creditMember_L246 => 'Ahn Geum-seo';

  @override
  String get credits_creditMember_L252 => 'Son Geon-woo';

  @override
  String get credits_creditMember_L258 => 'Shin Hye-bin';

  @override
  String get credits_creditMember_L264 => 'Jeong Chang-woo';

  @override
  String get credits_creditMember_L270 => 'Heo Seok-jun';

  @override
  String get credits_creditMember_L276 => 'Seo Hyun-jin';

  @override
  String get credits_creditMember_L282 => 'Oh Dong-hyun';

  @override
  String get credits_creditMember_L288 => 'Choi Seung-hoon';

  @override
  String get credits_creditMember_L294 => 'Kim Min-wook';

  @override
  String get credits_creditMember_L300 => 'Jeong Myeong-jun';

  @override
  String get credits_creditMember_L306 => 'Kang Dae-hyun';

  @override
  String get credits_creditMember_L312 => 'Sim Hyuk';

  @override
  String get credits_creditsPage_L45 => 'Cops and Robbersを作った人々';

  @override
  String get dialogreportRepositoryImplMessage => '通報処理中にエラーが発生しました';

  @override
  String get report_reportCategories_L7 => '釣り/いやがらせ/連投';

  @override
  String get report_reportCategories_L8 => '暴言/見下し';

  @override
  String get report_reportCategories_L9 => '詐称/詐欺';

  @override
  String get report_reportCategories_L10 => '広告/スパム';

  @override
  String get report_reportCategories_L11 => '不正行為/バグ悪用';

  @override
  String get report_reportCategories_L12 => 'チーム士気低下行為';

  @override
  String get report_reportCategories_L13 => 'その他(直接記入)';

  @override
  String get dialoguserRepositoryImplMessage => 'ニックネームの確認中に予期せぬエラーが発生しました';

  @override
  String get dialoguserRepositoryImplMessageAc72 => 'ニックネームの変更中に予期せぬエラーが発生しました';

  @override
  String get dialoguserRepositoryImplMessage243c => 'ユーザー情報の照会中にエラーが発生しました';

  @override
  String get dialoguserRepositoryImplMessage220e => '退会処理中に予期せぬエラーが発生しました';

  @override
  String get dialoguserRepositoryImplMessage05b0 => '規約同意状態の照会中に予期せぬエラーが発生しました';

  @override
  String get dialoguserRepositoryImplMessage2357 => '規約同意の保存中に予期せぬエラーが発生しました';

  @override
  String get dialoguserRepositoryImplMessage3d3a =>
      'ゲームプッシュ通知同意の照会中に予期せぬエラーが発生しました';

  @override
  String get dialoguserRepositoryImplMessage5fe2 => '';

  @override
  String get lobby_lobbyProvider_L139 => '認証トークンを取得できません。再ログインが必要です';

  @override
  String get lobby_lobbyProvider_L187 => 'サーバーに接続できません。しばらくしてからもう一度お試しください';

  @override
  String get lobby_lobbyProvider_L319 => 'サーバーに接続できません。しばらくしてからもう一度お試しください';

  @override
  String get lobby_lobbyProvider_L381 => '認証の有効期限が切れました。再ログインが必要です';

  @override
  String get lobby_lobbyProvider_L399 => '認証の有効期限が切れました。再ログインが必要です';

  @override
  String get dialognoticeRepositoryImplMessage => '知らせを読み込む中にエラーが発生しました';

  @override
  String get dialognoticesPageMessage => '知らせを読み込んでいます...';

  @override
  String get dialognoticesPageMessage4982 => 'お知らせを読み込めませんでした';

  @override
  String get notice_noticesPage_L131 => 'お知らせ';

  @override
  String get notice_noticesPage_L152 => '登録されたお知らせはありません';

  @override
  String get router_appRouter_L477 => 'エリア情報を読み込めません';

  @override
  String get router_appRouter_L575 => 'ページが見つかりません';

  @override
  String get router_appRouter_L586 => 'お探しのページは存在しません';

  @override
  String router_appRouter_L589(String path) {
    return 'パス: $path';
  }

  @override
  String get router_appRouter_L600 => 'ログアウト';

  @override
  String get dialogbugRepositoryImplMessage => 'バグ報告の処理中にエラーが発生しました';

  @override
  String get dialogmainTitle => 'Cops and Robbers';

  @override
  String gameEventStartTime(int minutes) {
    return '制限時間は$minutes分です。';
  }

  @override
  String get gameEventStartReady => 'まもなくゲームが始まります。  全プレイヤーは準備してください!';

  @override
  String get gameEventStartReportTip => 'ゲーム中、チャットを長押しすると不快なユーザーを通報・ブロックできます。';

  @override
  String get gameEventStartGo => 'ゲーム開始!  幸運を!';

  @override
  String get gameEventPoliceMoveWarning => '警察がまもなく出動します。  泥棒は急いで移動してください!';

  @override
  String get gameEventPoliceMove => '警察出動!  泥棒は逃げて!';

  @override
  String get gameEventLocationReveal => '現在の泥棒の位置が公開されます!';

  @override
  String gameEventRemainingRobbers(int count) {
    return '現在$count人が逃走中!';
  }

  @override
  String gameEventArrestNotice(String policeNickname, String robberNickname) {
    return '@icon_police [$policeNickname]が@icon_robber [$robberNickname]を逮捕しました!';
  }

  @override
  String get gameEventEscapeNotice => '泥棒が脱獄しました!今すぐ逮捕してください!';

  @override
  String get gameEventFiveMinutesLeft => 'ゲーム終了まで5分です。最後のチャンスを逃さないで!';

  @override
  String mapErrorLoadFailed(String mapName) {
    return '$mapNameの読み込みに失敗しました';
  }
}
