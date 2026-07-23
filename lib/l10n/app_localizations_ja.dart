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
  String get legalDocumentKoreanOnlyNotice =>
      '本書面は韓国語のみで提供されます。法的効力を持つのは韓国語版です';

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
  String get chatSystemGameStartReportTip =>
      'ゲーム中、チャットを長押しして迷惑なユーザーを通報およびブロックできます';

  @override
  String get chatSystemPoliceMoveWarning => '警察がまもなく出動します。泥棒は急いで移動してください！';

  @override
  String chatSystemRemainingRobbers(int count) {
    return '現在 $count人 逃走中！';
  }

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
  String get errorNotFound => '要求された情報が見つかりません';

  @override
  String get errorConflict => 'リクエストを処理できません。しばらくしてからもう一度お試しください';

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
  String get buttonGoogleSignIn => 'Googleで続ける';

  @override
  String get buttonAppleSignIn => 'Appleで続ける';

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
  String get areaTypeSetByDistance => '距離で設定';

  @override
  String get areaTypeSetByPin => 'ピンで設定';

  @override
  String get setupPlaygroundPinDescription => 'ゲームが進行されるエリア全体を選択します';

  @override
  String get setupPrisonPinDescription => '泥棒を拘束しておく牢屋エリアを選択します';

  @override
  String get zoneAreaLabel => '面積';

  @override
  String pinMaxCountMessage(int count) {
    return 'ピンは最大$count個まで置けます';
  }

  @override
  String get pinTooCloseMessage => 'ピン同士が近すぎます';

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
  String get asset_loading_sub_joinRoom => '今アプリを閉じると合流がキャンセルされます。少々お待ちください';

  @override
  String get asset_loading_sub_createRoom => '作戦本部を設営しています。少々お待ちください';

  @override
  String get asset_loading_sub_changeTeam => '新しい身分証を発行しています。少々お待ちください';

  @override
  String get asset_loading_sub_startGame => 'まもなく作戦が始まります。アプリを閉じないでください';

  @override
  String get asset_loading_sub_updateArea => '作戦区域を保存しています。少々お待ちください';

  @override
  String get asset_loading_sub_saveSettings => '設定を保存しています。少々お待ちください';

  @override
  String get asset_loading_sub_loadProfile => 'エージェント情報を読み込んでいます。少々お待ちください';

  @override
  String get asset_loading_sub_logout => '安全に撤収しています。少々お待ちください';

  @override
  String get asset_loading_sub_deleteAccount => '記録を削除しています。アプリを閉じないでください';

  @override
  String get asset_loading_sub_bugReport => '報告を受け付けています。少々お待ちください';

  @override
  String get asset_loading_joinRoom => '潜入の準備中です';

  @override
  String get asset_loading_joinRoomJoinOperation => '作戦に合流しているところです';

  @override
  String get asset_loading_joinRoomEnterSecretPassage => '秘密の通路から進入しています';

  @override
  String get asset_loading_joinRoomCheckDisguise => '変装を確認しています';

  @override
  String get asset_loading_joinRoomCheckDeployment => '作戦投入人員を確認しています';

  @override
  String get asset_loading_createRoom => '作戦本部を設置しています';

  @override
  String get asset_loading_createRoomPrepareHideout => '秘密のアジトを準備しています';

  @override
  String get asset_loading_createRoomSecureArea => 'ゲームエリアを確保しています';

  @override
  String get asset_loading_createRoomUnfoldMap => '秘密の地図を広げています';

  @override
  String get asset_loading_createRoomTuneRadio => 'トランシーバーの周波数を合わせています';

  @override
  String get asset_loading_changeTeam => '変装しています';

  @override
  String get asset_loading_changeTeamChangeCoverIdentity => '偽装身分を変更しています';

  @override
  String get asset_loading_changeTeamLaunderIdentity => '身分をロンダリングしています';

  @override
  String get asset_loading_changeTeamSwitchToDoubleSpy => '二重スパイに転換しています';

  @override
  String get asset_loading_changeTeamIssueNewId => '新しい身分証を発行しています';

  @override
  String get asset_loading_startGame => '作戦開始の準備をしています';

  @override
  String get asset_loading_startGamePrepareMoveOut => '出動の準備をしています';

  @override
  String get asset_loading_startGameCountdownStart => 'カウントダウン開始';

  @override
  String get asset_loading_startGameTurnOnRadio => 'トランシーバーの電源を入れています';

  @override
  String get asset_loading_startGameDeployAgents => '現場エージェントを配置しています';

  @override
  String get asset_loading_updateArea => 'ゲームエリアを設定しています';

  @override
  String get asset_loading_updateAreaDesignateZone => '管轄区域を指定しています';

  @override
  String get asset_loading_updateAreaPlotOnMap => '地図の上に点を打っています';

  @override
  String get asset_loading_updateAreaAnalyzeSatellite => '衛星写真を分析しています';

  @override
  String get asset_loading_updateAreaCalculateRange => '作戦範囲を計算しています';

  @override
  String get asset_loading_saveSettings => '作戦指針を編集しています';

  @override
  String get asset_loading_saveSettingsUpdateRules => 'ルールをアップデートしています';

  @override
  String get asset_loading_saveSettingsApplyNewRules => '新しいルールを適用しています';

  @override
  String get asset_loading_saveSettingsChangePasscode => '暗号を変更しています';

  @override
  String get asset_loading_saveSettingsApplyOperationCode => '新しい作戦コードを適用しています';

  @override
  String get asset_loading_loadProfile => '身元を確認しています';

  @override
  String get asset_loading_loadProfileCheckWantedPoster => '指名手配書を確認しています';

  @override
  String get asset_loading_loadProfileInspectId => '身分証を検査しています';

  @override
  String get asset_loading_loadProfileMatchFingerprints => '指紋を照合しています';

  @override
  String get asset_loading_loadProfileAnalyzeSuspect => '容疑者のプロフィールを分析しています';

  @override
  String get asset_loading_logout => '撤収しています';

  @override
  String get asset_loading_logoutGoIntoHiding => '潜伏しています';

  @override
  String get asset_loading_logoutEraseTraces => '足跡を消しています';

  @override
  String get asset_loading_logoutDestroyEvidence => '証拠を隠滅しています';

  @override
  String get asset_loading_logoutEscapeViaPassage => '秘密の通路から脱出しています';

  @override
  String get asset_loading_deleteAccount => '退会処理をしています';

  @override
  String get asset_loading_deleteAccountObliterateRecords => '記録を抹消しています';

  @override
  String get asset_loading_deleteAccountDeleteIdentity => '身元を削除しています';

  @override
  String get asset_loading_reconnect => '再び現場に復帰しています';

  @override
  String get asset_loading_reconnectRejoinOperation => '作戦に再合流しているところです';

  @override
  String get asset_loading_reconnectPrepareReturn => '現場復帰の準備をしています';

  @override
  String get asset_loading_reconnectRestoreRadio => '無線チャンネルを復旧しています';

  @override
  String get asset_loading_reconnectRescanFrequency => '秘密の周波数を再探索しています';

  @override
  String get asset_loading_bugReport => '報告書を作成しています';

  @override
  String get asset_loading_bugReportSubmitReport => '本部に報告書を提出しています';

  @override
  String get asset_loading_bugReportAttachPhotos => '現場写真を添付しています';

  @override
  String get asset_loading_bugReportAssignCaseNumber => '事件番号を付与しています';

  @override
  String get asset_loading_bugReportHandToInvestigation => '捜査班に引き継いでいます';

  @override
  String get asset_loading_easterEggCharacterRumor =>
      'ホーム画面のキャラを何度も押すと何か変わるという噂が...';

  @override
  String get asset_loading_easterEggCharacterTap =>
      'キャラを何度も叩くと新しい姿が現れるらしいですよ...？';

  @override
  String get asset_loading_easterEggCharacterSecret =>
      'ホーム画面のキャラに隠された秘密があるらしい...';

  @override
  String get asset_loading_easterEggSettingsTap => '設定のどこかを押し続けると秘密が開くらしいですよ';

  @override
  String get asset_loading_easterEggVersionTap =>
      'アプリのバージョンを何度もタップすると何かが出るかも...？';

  @override
  String get asset_loading_easterEggVersionSecret =>
      '誰かがバージョン番号に秘密を隠したという噂が...';

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
  String get errorGameRoomCreateUnexpected => '待機室の作成中に予期せぬエラーが発生しました';

  @override
  String get errorActiveGameFetchUnexpected => '参加中のゲームの照会中に予期せぬエラーが発生しました';

  @override
  String gameSettingMaxPlayers(String count) {
    return '$count人';
  }

  @override
  String gameSettingRoundMinutes(int minutes) {
    return '$minutes分';
  }

  @override
  String gameSettingLocationShareMinutes(int minutes) {
    return '$minutes分';
  }

  @override
  String gameSettingPoliceStartDelay(int minutes) {
    return '泥棒が逃げたあと $minutes分後';
  }

  @override
  String zoneRadiusMeters(String meters) {
    return '半径 ${meters}m';
  }

  @override
  String get errorSettingsSaveFailed => '設定の保存に失敗しました';

  @override
  String get pageGameSettingsEditTitle => '設定の編集';

  @override
  String get buttonSaving => '保存中...';

  @override
  String get buttonSave => '保存';

  @override
  String get errorAreaSaveFailed => 'エリアの保存に失敗しました';

  @override
  String get pageGameSettingsTitle => 'ゲーム設定';

  @override
  String get errorZoneInfoLoadFailed => 'エリア情報を読み込めません';

  @override
  String get errorSettingsLoadFailed => '設定情報を読み込めません';

  @override
  String get zonePlayground => 'プレイグラウンド';

  @override
  String get zoneJail => '牢屋';

  @override
  String get homePageGameButtonsHint => 'ゲームを作成したり、招待コードで参加したりできます';

  @override
  String get dialogSafetyWarningTitle => '周囲を確認しながらご利用ください';

  @override
  String get dialogSafetyWarningMessage =>
      'ゲーム中画面に集中しすぎると危険です\n道路や歩行環境を確認し、安全にご利用ください';

  @override
  String get buttonAcknowledgedSurroundings => '確認しました！';

  @override
  String get homePageDontShowToday => '今日はもう表示しない';

  @override
  String get errorAlreadyInGame => 'すでに参加中のゲームがあります';

  @override
  String get errorUnknownGameState => '不明なゲーム状態です';

  @override
  String get buttonGoToSettings => '設定へ移動';

  @override
  String get dialogBatteryGuideTitle => '途切れのないゲームのために';

  @override
  String get homePageBatteryGuideStep1 => 'アプリ設定 → バッテリー → 制限なし に変更してください\n';

  @override
  String get homePageBatteryGuideStep2 => 'そうすれば画面が消えてもゲームが途切れません';

  @override
  String get errorJoinFailedCheckCode => '参加に失敗しました。招待コードをご確認ください';

  @override
  String get errorJoinRetry => '参加に失敗しました。もう一度お試しください';

  @override
  String get dialogJoinRoomTitle => '待機室に参加する';

  @override
  String get fieldInviteCodeHint => '招待コードを入力してください';

  @override
  String get dialogScanInviteQrTitle => '招待コードQRをスキャンしてください';

  @override
  String get buttonJoin => '参加する';

  @override
  String get appBrandName => 'ケイドロ';

  @override
  String get messageComingSoon => '準備中です';

  @override
  String get homePageWelcomeMessage => '誰がぼくのチーズを\n盗んだの!!!!🧀';

  @override
  String get homePageWelcomeMessageClassic => 'とても楽しみです\n今回はどんな役割になるでしょうか';

  @override
  String get buttonCreateRoom => '待機室を作る';

  @override
  String get buttonJoinRoom => '待機室に参加する';

  @override
  String get sessionCreationStepZoneSubtitle =>
      'ゲームを行うゲームエリアを設定します\nまずプレイグラウンドを指定してください';

  @override
  String get sessionCreationStepRulesSubtitle =>
      'ゲームルールを決めます\n数字をタップすると直接入力できます';

  @override
  String get errorCreateRoomFailed => '待機室の作成に失敗しました。もう一度お試しください';

  @override
  String get sessionCreationZoneFirstQuestion => 'エリア選択を先に設定しましょうか';

  @override
  String get sessionCreationStepParticipantsTitle => '人数を設定します';

  @override
  String get sessionCreationStepBasicTitle => '基本情報を設定します';

  @override
  String get sessionCreationStepReviewTitle => '最終設定を確認します';

  @override
  String get sessionCreationStepZoneIntro => 'ゲームに必要なエリアを設定します';

  @override
  String get sessionCreationStepParticipantsHint => '最低2人からゲームの進行が可能です';

  @override
  String get sessionCreationStepBasicHint => 'ゲームを進行する際、必ず必要な情報です';

  @override
  String get sessionCreationStepReviewHint => '待機室を作る前に最後に設定を確認しましょうか';

  @override
  String get buttonNext => '次へ';

  @override
  String get errorZoneNotConfigured => 'エリア情報を先に設定してください';

  @override
  String get setupPlaygroundRadiusInputHint => 'ここをタップすると半径を直接入力できます';

  @override
  String get setupPlaygroundDescription => 'ゲームが進行されるエリア全体の大きさを設定します';

  @override
  String get buttonDone => '完了';

  @override
  String get setupPrisonDescription => '泥棒を拘束しておく牢屋の位置と大きさを設定します';

  @override
  String get errorPlaygroundFirst => 'プレイグラウンドを先に設定してください';

  @override
  String get errorJailOutsidePlayground => '牢屋がプレイグラウンドの範囲を超えています';

  @override
  String get dummyNicknameBear => 'ぽかぽかクマ...';

  @override
  String get errorCannotJoinRoom => '待機室に参加できません';

  @override
  String get errorNotInGame => '該当ゲームに参加していないユーザーです';

  @override
  String get waitingRoomTutorialTeamSwitch => 'このボタンを押して別のチームに移動できます';

  @override
  String get waitingRoomTutorialInvite => '友達に招待コードを共有できます';

  @override
  String get waitingRoomTutorialSettings => 'ゲーム設定を確認できます';

  @override
  String get waitingRoomTutorialReady => '準備ができたら押してください';

  @override
  String get dialogInGamePreviewTitle => 'インゲーム画面のプレビュー';

  @override
  String get dialogTutorialPromptMessage =>
      'ゲームが開始されたらどのように動作するか\n一度確認してから始めてみましょうか';

  @override
  String get buttonViewInGamePreview => '見に行く';

  @override
  String dialogKickConfirmTitle(String nickname) {
    return '$nicknameさんを退出させますか';
  }

  @override
  String get dialogKickConfirmMessage =>
      '追放されたユーザーは即座に待機室から退出させられます\n再び待機室に参加するには招待コードを入力する必要があります';

  @override
  String get buttonKick => '退出させる';

  @override
  String get errorKickFailed => '追放処理中にエラーが発生しました';

  @override
  String get dialogKickedFromRoomTitle => '待機室から退出させられました';

  @override
  String get dialogKickedFromRoomMessage => '再び参加するには招待コードを入力する必要があります';

  @override
  String messageMemberKicked(String kickedNickname) {
    return '$kickedNicknameさんが退出させられました';
  }

  @override
  String get errorTeamChangeFailed => 'チーム変更に失敗しました';

  @override
  String get errorReadyChangeFailed => '準備状態の変更に失敗しました';

  @override
  String get errorGameStartFailed => 'ゲーム開始に失敗しました';

  @override
  String get dialogLeaveRoomTitle => '待機室から退室しますか';

  @override
  String get dialogLeaveRoomMessage => '退室すると、再度招待コードを入力する必要があります';

  @override
  String get buttonLeave => '退室';

  @override
  String get errorLeaveRoomFailed => '退出処理中にエラーが発生しました';

  @override
  String get dialogInviteCodeCreatedTitle => '招待コードを作成しました';

  @override
  String get dialogInviteCodeShareMessage => '友達にコードを共有してゲームに参加してみましょう！';

  @override
  String get messageCodeCopied => 'コードがコピーされました';

  @override
  String get buttonShare => '共有する';

  @override
  String get buttonStartGame => 'ゲーム開始';

  @override
  String get buttonReadyDone => '準備完了';

  @override
  String get buttonReady => '準備完了';

  @override
  String get pageZonePreviewTitle => 'ゲームエリア';

  @override
  String get zonePreviewSubtitle => '現在設定されているゲームエリアです';

  @override
  String get dummyNicknameRaccoon => 'おてんばタヌキ';

  @override
  String get defaultNicknameLabel => 'ニックネーム';

  @override
  String get titleGameRules => 'ゲームルール';

  @override
  String get buttonViewInGame => 'インゲームを見る';

  @override
  String get gameRulesCopGoalPrefix => '警察はすべての泥棒を捕まえて';

  @override
  String get gameRulesCopGoalSuffix => '逮捕すれば、';

  @override
  String get gameRulesRobberGoalPrefix => '\n泥棒は';

  @override
  String get gameRulesRobberGoalCondition => '制限時間が終了するまで逃げ切れば';

  @override
  String get gameRulesWinSuffix => '勝利します';

  @override
  String get gameRulesLocationShareLine1 => '泥棒チームの位置は';

  @override
  String gameRulesLocationShareLine2(int minutes) {
    return '$minutes分ごとに警察チームに共有されます';
  }

  @override
  String get gameRulesLocationShareLine3 => '';

  @override
  String get gameRulesZoneRuleLine1 => '指定されたゲームエリアから外に出てはいけません';

  @override
  String get gameRulesZoneRuleLine2 => '\n→ エリア外に出ると画面がロックされます';

  @override
  String get dialogstep0SelectAreaContentTitle => 'プレイグラウンド';

  @override
  String get dialogstep0SelectAreaContentTitle5bc0 => '牢屋';

  @override
  String get fieldstep1ParticipantSettingsContentLabel => '最大参加者';

  @override
  String get unitPerson => '人';

  @override
  String get fieldstep2GameSettingsContentLabel => 'ラウンド制限時間';

  @override
  String get unitMinutes => '分';

  @override
  String get fieldstep2GameSettingsContentLabel5ab2 => '泥棒の位置公開間隔';

  @override
  String get gameSettingNoLocationShareWarning => '泥棒の位置が公開されません！';

  @override
  String get fieldstep2GameSettingsContentLabelCe3b => '警察出動時間';

  @override
  String get gameSettingPoliceStartPrefix => '泥棒が逃げたあと';

  @override
  String get gameSettingPoliceStartSuffix => '後';

  @override
  String get sectionTitleSettings => '設定';

  @override
  String get labelParticipantCount => '参加人数';

  @override
  String get fieldRoundTimeLimit => 'ラウンド制限時間';

  @override
  String get fieldLocationShareInterval => '位置公開間隔';

  @override
  String get fieldPoliceDispatchTime => '警察出動時間';

  @override
  String teamSectionCurrentCount(int count) {
    return '現在 $count人';
  }

  @override
  String get sectionTitleZone => 'エリア';

  @override
  String get errorLogoutGeneric => 'ログアウト中にエラーが発生しました';

  @override
  String get errorAuthUserNotFound => 'ログイン情報を取得できません。もう一度お試しください';

  @override
  String get errorAuthTokenIssueFailed => '認証に失敗しました。もう一度お試しください';

  @override
  String get errorAuthTokenValidationFailed => 'ログイン情報の有効期限が切れました。再度ログインしてください';

  @override
  String get errorAuthInvalidCredential => '不正な認証情報です';

  @override
  String get errorAuthAccountDisabled => '無効化されたアカウントです';

  @override
  String get errorAuthTooManyRequests => 'リクエストが多すぎます。しばらくしてからもう一度お試しください';

  @override
  String get errorAuthSignInMethodUnavailable => 'このログイン方法は現在ご利用いただけません';

  @override
  String get errorAuthFirebaseConfig => '一時的なエラーが発生しました。しばらくしてからもう一度お試しください';

  @override
  String get errorAuthFirebaseInternal => '一時的なエラーが発生しました。しばらくしてからもう一度お試しください';

  @override
  String errorAuthProviderLoginFailed(String provider) {
    return '$provider ログインに失敗しました。もう一度お試しください';
  }

  @override
  String get errorAuthLoginFailed => 'ログインに失敗しました。もう一度お試しください';

  @override
  String get linkMarketingConsent => 'マーケティング情報の受信';

  @override
  String get agreementPageAgreeButton => '同意して始める';

  @override
  String get agreementPageTitle => 'サービス利用のために\n規約に同意してください';

  @override
  String get agreementPageRequiredNotice => '必須規約にすべて同意する必要がサービスをご利用いただけます';

  @override
  String get errorNetworkNotConnected => 'まだネットワークに接続されていません';

  @override
  String get errorRequiredAgreementsMissing => '必須規約にすべて同意してください';

  @override
  String get messageAccountDeleted => '退会が完了しました';

  @override
  String get dialogAge14ConfirmTitle => '14歳以上ですか';

  @override
  String get dialogAge14ConfirmMessage =>
      'Cops and Robbersは14歳未満の会員登録ができません\n該当情報は登録禁止の確認目的のみに使用しています';

  @override
  String get errorLoginGeneric => 'ログイン中にエラーが発生しました';

  @override
  String get errorAppleLoginFailed => 'Appleログイン中にエラーが発生しました';

  @override
  String get errorAgeRestrictionUnder14 => '14歳未満はサービスを利用できません';

  @override
  String get loginPageTagline => 'リアルタイムGPS オフライン・チェイス・レース';

  @override
  String get loginPageAgreementPrefix => 'ログインすると、';

  @override
  String get linkPrivacyPolicy => '個人情報処理方針';

  @override
  String get linkTermsOfService => '利用規約';

  @override
  String get linkLocationTerms => '位置情報利用規約';

  @override
  String get loginPageAgreementSuffix => 'に同意したことになります';

  @override
  String get messageNicknameSaved => 'ニックネームが保存されました';

  @override
  String get nicknameSetupTitle => 'ニックネームを設定します';

  @override
  String get nicknameSetupSubtitle => 'サービス内で引き続き使用されるニックネームです\n1〜10文字で作成できます';

  @override
  String get fieldNicknameHint => 'ニックネームを入力してください';

  @override
  String get buttonCheckNicknameDuplicate => '重複確認';

  @override
  String get errorNicknameTooShort => '1文字未満のニックネームは使用できません';

  @override
  String get errorNicknameDuplicated => '重複したニックネームです。別のニックネームを入力してください';

  @override
  String get nicknameAvailable => '使用可能なニックネームです';

  @override
  String get splashReturningToScene => '再び現場に復帰しています';

  @override
  String get dialogNetworkConnectionFailedTitle => 'ネットワーク接続失敗';

  @override
  String get dialogSplashOfflineMessage => 'インターネット接続を確認したあと\nもう一度お試しください';

  @override
  String get splashPleaseWait => '少々お待ちください';

  @override
  String get splashCreditTag => 'by Innocare';

  @override
  String get splashOfflineTitle => 'インターネット接続が必要です';

  @override
  String get splashOfflineMessage => '接続状態を確認したあと\nもう一度お試しください';

  @override
  String get errorUnknown => '不明なエラーが発生しました';

  @override
  String get errorLogoutFailed => 'ログアウトに失敗しました';

  @override
  String get agreementAllCheckboxLabel => '全て同意';

  @override
  String get agreementItemRequiredTag => '[必須]';

  @override
  String get agreementItemOptionalTag => '[選択]';

  @override
  String get gameRobberOnTheRunBanner => '泥棒が逃走しています！';

  @override
  String get gameOverBannerTitle => 'ゲーム終了！';

  @override
  String get gameOverReasonAllArrested => '泥棒が全員逮捕されました！';

  @override
  String get gameOverReasonTimeUp => '制限時間が終了しました！';

  @override
  String get gameOverReasonPoliceForfeited => '警察が全員退場しました！';

  @override
  String get gameOverReasonRobberForfeited => '泥棒が全員退場しました！';

  @override
  String get gameOverFallbackMessage => 'ゲームが終了しました。';

  @override
  String get gameTeamCop => '警察チーム';

  @override
  String get gameTeamRobber => '泥棒チーム';

  @override
  String get gameResultWin => '勝利';

  @override
  String get gameResultLose => '敗北';

  @override
  String messageGameOverWinner(Object winnerTeamLabel) {
    return '$winnerTeamLabelの勝利です！';
  }

  @override
  String get gameRoleCopLabel => '警察';

  @override
  String get gameRoleRobberLabel => '泥棒';

  @override
  String get errorCannotArrestDuringWait => '警察の待機時間中は泥棒を逮捕できません';

  @override
  String get qrScannerWantedRobberTitle => '泥棒の指名手配QRをスキャンしてください';

  @override
  String get errorExpiredQr => '有効期限切れのQRです。QRの更新をリクエストしてください';

  @override
  String get errorAlreadyArrested => 'すでに逮捕された泥棒です';

  @override
  String get gameArrestOverlayTitle => '逮捕されました！';

  @override
  String get gameArrestOverlayMessage =>
      '逮捕されている間はゲームの状況を確認できません\n同じチームに救助要請をして素早く脱獄しましょう！';

  @override
  String get gameArrestOverlayEscapeCompleteButton => '脱獄完了';

  @override
  String get buttonEscape => '脱獄';

  @override
  String get buttonNo => 'いいえ';

  @override
  String get labelArrestCount => '逮捕回数';

  @override
  String gameResultArrestCount(int count) {
    return '$count回';
  }

  @override
  String get fieldRemainingRobbers => '残りの泥棒';

  @override
  String gameResultRemainingRobberCount(int count) {
    return '$count人';
  }

  @override
  String get fieldGamePlaytime => 'ゲーム進行時間';

  @override
  String get buttonGoHome => 'ホームへ';

  @override
  String get buttonPlayAgain => 'もう一度';

  @override
  String get buttonViewMyRecord => 'マイ記録を見る';

  @override
  String get labelMyRecord => 'マイ記録';

  @override
  String get labelTravelDistance => '移動した距離';

  @override
  String get labelMyArrestCount => '捕まえた泥棒';

  @override
  String get labelMyEscapeCount => '脱獄回数';

  @override
  String get labelResult => '結果';

  @override
  String get messageSaveFailed => '保存に失敗しました';

  @override
  String get messageShareComplete => '共有しました';

  @override
  String get labelNoRoute => '移動記録なし';

  @override
  String get legendArrestSpot => '捕獲地点';

  @override
  String get legendCaughtSpot => '逮捕地点';

  @override
  String gameLocationRevealCountdown(String formatted) {
    return '次の泥棒の位置公開まで $formatted';
  }

  @override
  String get dialogArrestConfirmTitle => '該当のプレイヤーを逮捕しましたか';

  @override
  String get buttonYes => 'はい';

  @override
  String get dialogEscapeAttemptMessage => '脱獄を試みますか';

  @override
  String get gameParticipantOverlayCurrent => '現在';

  @override
  String gameParticipantOverlayCount(int count) {
    return '$count人';
  }

  @override
  String get gameRobberStatusEscaping => '逃走中！';

  @override
  String gamePoliceStartCountdown(String formatted) {
    return '警察開始まで $formatted';
  }

  @override
  String get gameQrDisplayTitle => '指名手配QR';

  @override
  String get gameQrDisplayMessage => '警察にQRコードを見せてください';

  @override
  String get buttonClose => '閉じる';

  @override
  String get dialogCameraPermissionTitle => 'カメラの権限が必要です';

  @override
  String get dialogCameraPermissionMessage =>
      'QRコードをスキャンするにはカメラの権限が必要です\n設定でカメラの権限を許可してください';

  @override
  String get errorCameraUnavailable => 'カメラを使用できません';

  @override
  String get gameZoneExitBanner => 'プレイグラウンドを外れました';

  @override
  String get chatTeamPrefix => '[チーム]';

  @override
  String get chatSystemGameTimeLimit30Min => '制限時間は30分です';

  @override
  String get chatSystemGoodLuckRobber => '泥棒さん、うまく逃げてくださいね〜';

  @override
  String get chatSystemLetsWin => '勝ちましょう！';

  @override
  String get messageMessageCopied => 'メッセージがコピーされました';

  @override
  String get messageUserBlocked => '該当ユーザーをブロックしました';

  @override
  String get fieldReportContentLabel => '通報内容';

  @override
  String get fieldReportReasonHint => '通報の理由を詳しく記入してください\n(状況や会話内容を含めてください)';

  @override
  String get buttonReport => '通報';

  @override
  String get messageReportSubmitted => '通報が受け付けられました';

  @override
  String get errorReportFailed => '通報に失敗しました';

  @override
  String get dialogReportConfirmTitle => '該当ユーザーを通報しますか';

  @override
  String get chatReportSelectedCategoryLabel => '選択した通報理由:';

  @override
  String get chatReportSubmitNotice => '\n報告された内容は検討した上で対処いたします';

  @override
  String get buttonCopy => 'コピーする';

  @override
  String get buttonBlock => 'ブロック';

  @override
  String get chatReportCategoryTitle => '通報タイプの選択';

  @override
  String chatInputBarUnreadAll(String all) {
    return '全体 $all件';
  }

  @override
  String chatInputBarUnreadTeam(String team) {
    return 'チーム $team件';
  }

  @override
  String chatInputBarUnreadHint(String body) {
    return '未読メッセージ [$body]';
  }

  @override
  String get chatInputBarConnecting => '接続中...';

  @override
  String get chatInputBarHint => 'チャットを入力してください';

  @override
  String get chatMessageListEmpty => 'チャットを始めてみてください';

  @override
  String get buttonGoToLatestMessage => '最新のメッセージへ移動';

  @override
  String get chatWeekdayMon => '月';

  @override
  String get chatWeekdayTue => '火';

  @override
  String get chatWeekdayWed => '水';

  @override
  String get chatWeekdayThu => '木';

  @override
  String get chatWeekdayFri => '金';

  @override
  String get chatWeekdaySat => '土';

  @override
  String get chatWeekdaySun => '日';

  @override
  String chatDateSeparator(
    String year,
    String month,
    String day,
    String weekday,
  ) {
    return '$year年 $month月 $day日 $weekday曜日';
  }

  @override
  String get chatScopeAllTitle => '全体チャット';

  @override
  String get chatScopeTeamTitle => 'チームチャット';

  @override
  String get chatPreviewTagNotice => '告知';

  @override
  String get chatPreviewTagTeam => 'チーム';

  @override
  String get chatPreviewTagAll => '全体';

  @override
  String get messageChangesSaved => '変更事項が保存されました';

  @override
  String get errorTemporaryRetry => '一時的なエラーが発生しました。もう一度お試しください';

  @override
  String get pageAgreementSettingsTitle => '利用規約とポリシー';

  @override
  String get errorAgreementLoadFailed => '規約への同意状況を読み込めません';

  @override
  String get buttonRetry => 'もう一度試す';

  @override
  String get buttonSaveChanges => '変更事項を保存';

  @override
  String get errorLegalDocumentLoadFailed => '文書を読み込めません';

  @override
  String get pageSettingsTitle => '設定';

  @override
  String get settingsSectionAccount => 'アカウント';

  @override
  String get settingsAccountChangeNickname => 'ニックネーム変更';

  @override
  String get settingsSectionAppPreferences => 'アプリ設定';

  @override
  String get settingsAppGameNotification => 'ゲーム通知';

  @override
  String get settingsAppGameNotificationDescription =>
      'ゲーム進行中に発生するイベントの通知を設定します';

  @override
  String get settingsAppGeneralNotification => '通知';

  @override
  String get settingsAppGeneralNotificationHighlight => 'ゲーム中通知';

  @override
  String get settingsAppGeneralNotificationDetail =>
      'を含む、アプリから送信されるすべての通知を設定します';

  @override
  String get settingsAppLocationPermission => '位置情報の権限管理';

  @override
  String get settingsAppLocationPermissionDescription => '端末の設定で位置情報の権限を変更できます';

  @override
  String get settingsSectionGuide => '利用案内';

  @override
  String get settingsGuideBugReport => 'バグ報告';

  @override
  String get settingsGuideTutorialRewatch => 'チュートリアルをもう一度見る';

  @override
  String get settingsGuideTutorialReset => 'チュートリアル初期化';

  @override
  String get settingsGuideAgreements => '利用規約とポリシー';

  @override
  String get settingsSectionEtc => 'その他';

  @override
  String get settingsEtcDeleteAccount => '退会';

  @override
  String get settingsAppVersionLabel => 'アプリバージョン';

  @override
  String get settingsSnsPrompt => 'もっと最新情報が気になるなら 👀';

  @override
  String get errorGameNotificationToggleFailed => 'ゲーム通知の設定を変更できませんでした';

  @override
  String get titleBugReport => 'バグ報告';

  @override
  String get fieldBugReportLabel => 'バグ内容';

  @override
  String get fieldBugReportHint =>
      'どのような問題が発生しましたか\n発生状況を詳しく記入してください(時間、端末情報を含む)';

  @override
  String get buttonSubmitReport => '報告する';

  @override
  String get messageBugReportSubmitted => 'バグ報告が受け付けられました';

  @override
  String get dialogTutorialResetTitle => 'チュートリアル初期化';

  @override
  String get dialogTutorialResetMessage =>
      'すべての画面のチュートリアルを\nもう一度見られるように初期化しますか';

  @override
  String get buttonReset => '初期化';

  @override
  String get messageTutorialReset => 'チュートリアルが初期化されました';

  @override
  String get dialogLogoutTitle => 'ログアウト';

  @override
  String get dialogLogoutMessage => '本当にログアウトしますか';

  @override
  String get snackbarLogoutFailed => 'ログアウトに失敗しました';

  @override
  String get snackbarLogoutSuccess => 'ログアウトしました';

  @override
  String get dialogDeleteAccountTitle => '退会';

  @override
  String get dialogDeleteAccountMessage =>
      '退会するとすべてのデータが削除され\n元に戻すことはできません\n\n続けるには「delete」と入力してください';

  @override
  String get fieldDeleteAccountHint => 'delete';

  @override
  String get buttonDeleteAccount => '退会';

  @override
  String get tutorialDummyNicknameCop1 => 'Cop1';

  @override
  String get tutorialDummyNicknameRobberKing => 'RobberKing';

  @override
  String get tutorialDummyNicknameRobberOrNot => 'RobberOrNot';

  @override
  String get tutorialDummyNicknameCapturedRobber => 'CapturedRobber';

  @override
  String get titleTutorialComplete => 'チュートリアル完了！';

  @override
  String get messageTutorialComplete => '核心となる流れをマスターしました\n実際のゲームで活用してみましょう';

  @override
  String get buttonFinishTutorial => 'チュートリアルを終了する';

  @override
  String get tutorialInGameMyLocation => '自分の位置にカメラが移動しました';

  @override
  String get tutorialMapPreviewLabel => '地図のプレビュー';

  @override
  String get tutorialLocationRevealCountdown => '次の泥棒の位置公開まで 04:30';

  @override
  String get tutorialInGameRulesGuide => 'ゲームルールの案内が開きます';

  @override
  String get tutorialQrRobberHint => '自分の指名手配QRが画面に表示されます。警察に見せると逮捕されます';

  @override
  String get tutorialQrCopHint => 'カメラが起動し、泥棒のQRをスキャンして逮捕できます';

  @override
  String get tutorialMissionParticipantsButton => '参加者表示ボタンを押してみてください';

  @override
  String get tutorialMissionQrButton => 'QRボタンを押してみてください';

  @override
  String get tutorialMissionMapButton => '地図に戻ってみてください';

  @override
  String get tutorialMissionDropPing => '地図を長押ししてピンを置いてみてください';

  @override
  String get tutorialPingLongPressHint => '地図のどこでも長押し';

  @override
  String tutorialMissionProgress(String step) {
    return 'ミッション $step/4';
  }

  @override
  String get tutorialPerspectiveRobber => '泥棒視点で見ているところです';

  @override
  String get tutorialPerspectiveCop => '警察視点で見ているところです';

  @override
  String get tutorialInGameSelfEscape => '自分が収監された場合、カードタップで脱獄を試みることができます';

  @override
  String get tutorialInGameQrArrest => '実際のゲームでは、QRスキャンで泥棒を逮捕します';

  @override
  String get tutorialCurrentLabel => '現在';

  @override
  String tutorialPlayerCount(int count) {
    return '$count人';
  }

  @override
  String get tutorialOnTheRun => '逃走中！';

  @override
  String get tutorialInGameChatExpand => 'ハンドルを上にドラッグするとチャットが展開されます';

  @override
  String get tutorialInGameChatInput => 'ここにメッセージを入力すると、チーム/全体チャットに送信できます';

  @override
  String get tutorialChatHint => 'チャットを入力してください';

  @override
  String get tutorialCatalogAreaSubtitle => 'プレイグラウンド・牢屋の設定とスライダー操作';

  @override
  String get tutorialCatalogInviteSubtitle => '招待コードの入力とQRスキャン';

  @override
  String get tutorialCatalogWaitingRoomTitle => '待機室';

  @override
  String get tutorialCatalogLobbySubtitle => 'チーム変更、ゲーム設定、準備完了';

  @override
  String get tutorialCatalogInGameTitle => 'インゲーム';

  @override
  String get tutorialCatalogGameSubtitle => 'タイマー・地図・参加者・チャット・QR';

  @override
  String get pageTutorialCatalogTitle => 'チュートリアル';

  @override
  String get tutorialCatalogIntro => 'ゲームを初めてプレイする場合は、一度見てから始めてみてください';

  @override
  String get tutorialCatalogComingSoon => '準備中';

  @override
  String get creditMemberHongEuiMin => 'Hong Eui-min';

  @override
  String get creditMemberParkChanBin => 'Park Chan-bin';

  @override
  String get creditMemberLeeChangHee => 'Lee Chang-hee';

  @override
  String get creditMemberJeongSangHee => 'Jeong Sang-hee';

  @override
  String get creditMemberHwangHyeRim => 'Hwang Hye-rim';

  @override
  String get creditMemberYoonJiHee => 'Yoon Ji-hee';

  @override
  String get creditMemberKimDaim => 'Kim Da-im';

  @override
  String get creditMemberShinJiHoon => 'Shin Ji-hoon';

  @override
  String get creditMemberNamHaeYoon => 'Nam Hae-yoon';

  @override
  String get creditMemberSongHyeJung => 'Song Hye-jung';

  @override
  String get creditMemberLeeJin => 'Lee Jin';

  @override
  String get creditMemberAhnGeumSeo => 'Ahn Geum-seo';

  @override
  String get creditMemberSonGeonWoo => 'Son Geon-woo';

  @override
  String get creditMemberShinHyeBin => 'Shin Hye-bin';

  @override
  String get creditMemberJeongChangWoo => 'Jeong Chang-woo';

  @override
  String get creditMemberHeoSeokJun => 'Heo Seok-jun';

  @override
  String get creditMemberSeoHyunJin => 'Seo Hyun-jin';

  @override
  String get creditMemberOhDongHyun => 'Oh Dong-hyun';

  @override
  String get creditMemberChoiSeungHoon => 'Choi Seung-hoon';

  @override
  String get creditMemberKimMinWook => 'Kim Min-wook';

  @override
  String get creditMemberJeongMyeongJun => 'Jeong Myeong-jun';

  @override
  String get creditMemberKangDaeHyun => 'Kang Dae-hyun';

  @override
  String get creditMemberSimHyuk => 'Sim Hyuk';

  @override
  String get pageCreditsTitle => 'ケイドロを作った人々';

  @override
  String get errorReportGeneric => '通報処理中にエラーが発生しました';

  @override
  String get reportCategoryBait => '釣り/いやがらせ/連投';

  @override
  String get reportCategoryAbuse => '暴言/見下し';

  @override
  String get reportCategoryImpersonation => '詐称/詐欺';

  @override
  String get reportCategorySpam => '広告/スパム';

  @override
  String get reportCategoryExploit => '不正行為/バグ悪用';

  @override
  String get reportCategoryTeamSabotage => 'チーム士気低下行為';

  @override
  String get reportCategoryOther => 'その他(直接記入)';

  @override
  String get errorNicknameCheckUnexpected => 'ニックネームの確認中に予期せぬエラーが発生しました';

  @override
  String get errorNicknameUpdateUnexpected => 'ニックネームの変更中に予期せぬエラーが発生しました';

  @override
  String get errorUserInfoFetch => 'ユーザー情報の照会中にエラーが発生しました';

  @override
  String get errorDeleteAccountUnexpected => '退会処理中に予期せぬエラーが発生しました';

  @override
  String get errorAgreementFetchUnexpected => '規約同意状態の照会中に予期せぬエラーが発生しました';

  @override
  String get errorAgreementSaveUnexpected => '規約同意の保存中に予期せぬエラーが発生しました';

  @override
  String get errorGamePushFetchUnexpected => 'ゲームプッシュ通知同意の照会中に予期せぬエラーが発生しました';

  @override
  String get errorGamePushUpdateUnexpected => 'ゲームプッシュ通知の同意更新中に予期しないエラーが発生しました';

  @override
  String get errorAuthTokenMissing => 'ログイン情報を確認できません。再度ログインしてください';

  @override
  String get errorServerUnreachable => 'サーバーに接続できません。しばらくしてからもう一度お試しください';

  @override
  String get errorAuthExpired => '認証の有効期限が切れました。再ログインが必要です';

  @override
  String get errorNoticesLoadGeneric => '知らせを読み込む中にエラーが発生しました';

  @override
  String get messageLoadingNotices => '知らせを読み込んでいます...';

  @override
  String get errorNoticeLoadFailed => 'お知らせを読み込めませんでした';

  @override
  String get pageNoticesTitle => 'お知らせ';

  @override
  String get pageNoticesEmpty => '登録されたお知らせはありません';

  @override
  String get errorAreaLoadFailed => 'エリア情報を読み込めません';

  @override
  String get pageNotFoundTitle => 'ページが見つかりません';

  @override
  String get pageNotFoundMessage => 'お探しのページは存在しません';

  @override
  String pageNotFoundPath(String path) {
    return 'パス: $path';
  }

  @override
  String get buttonLogout => 'ログアウト';

  @override
  String get errorBugReportFailed => 'バグ報告の処理中にエラーが発生しました';

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
  String get gameEventPoliceMove => '警察出動!  泥棒は逃げて!';

  @override
  String get gameEventLocationReveal => '現在の泥棒の位置が公開されます!';

  @override
  String gameEventArrestNotice(String policeNickname, String robberNickname) {
    return '@icon_police [$policeNickname]が@icon_robber [$robberNickname]を逮捕しました!';
  }

  @override
  String get gameEventEscapeNotice => '泥棒が脱獄しました!今すぐ逮捕してください!';

  @override
  String gameEventPlayerLeftNotice(String nickname, String teamLabel) {
    return '[$nickname]($teamLabel)さんがゲームから退場しました';
  }

  @override
  String mapErrorLoadFailed(String mapName) {
    return '$mapNameの読み込みに失敗しました';
  }

  @override
  String get errorGameJoinUnexpected => 'ゲーム参加中に予期しないエラーが発生しました';

  @override
  String get errorAlreadyInAnotherRoom => '既に他の部屋に参加中です。今の部屋から退出してから再度お試しください';

  @override
  String get deeplinkAlreadyInRoom => '既に参加中の部屋があります';

  @override
  String get errorGameAlreadyStarted => '既に開始されたゲームのため入場できません';

  @override
  String get errorRoomSwitchFailed => '新しい部屋に入室できませんでした。前の部屋からは退出済みです';

  @override
  String get deeplinkSwitchRoomTitle => '部屋を移動しますか？';

  @override
  String get deeplinkSwitchRoomMessage => '現在参加中の部屋から退出し、新しい部屋に参加します';

  @override
  String get deeplinkSwitchRoomConfirm => '退出して参加';

  @override
  String get errorPendingInviteLoad => '保留中の招待コードを読み込めませんでした';

  @override
  String get errorPendingInviteSave => '招待コードの保存に失敗しました';

  @override
  String get errorPendingInviteClear => '招待コードの削除に失敗しました';

  @override
  String shareInviteMessage(String inviteCode) {
    return 'ケイドロの部屋に招待されました！招待コード: $inviteCode';
  }

  @override
  String get errorCodeMissingRequestPart => 'リクエストに必要なパートが不足しています';

  @override
  String get errorCodeInvalidRequestBody => 'リクエストボディの形式が正しくありません';

  @override
  String get errorCodeInvalidQueryParameter => 'クエリパラメータの形式が正しくありません';

  @override
  String get errorCodeQueryParameterTypeMismatch => 'リクエストパラメータの型が正しくありません';

  @override
  String get errorCodeInvalidInputValue => '入力値が検証を通過しませんでした';

  @override
  String get errorCodeInvalidDestination => '接続先が正しくありません';

  @override
  String get errorCodeUnsupportedMediaType => 'サポートされていない形式です';

  @override
  String get errorCodeMethodNotAllowed => '許可されていないリクエストです';

  @override
  String get errorCodeEndpointNotFound => 'リクエストパスが見つかりません';

  @override
  String get errorCodeInvalidSocketSession => 'セッション情報が見つかりません。再接続してください';

  @override
  String get errorCodeUnauthorizedSubscription => 'このチーム専用チャンネルを購読する権限がありません';

  @override
  String get errorCodeInternalServerError =>
      '一時的なエラーが発生しました。しばらくしてからもう一度お試しください';

  @override
  String get errorCodeFirebaseInitError => '一時的なエラーが発生しました。しばらくしてからもう一度お試しください';

  @override
  String get errorCodeFirebaseConfigNotFound =>
      '一時的なエラーが発生しました。しばらくしてからもう一度お試しください';

  @override
  String get errorCodeEncryptionFailed => '一時的なエラーが発生しました。しばらくしてからもう一度お試しください';

  @override
  String get errorCodeDecryptionFailed => '一時的なエラーが発生しました。しばらくしてからもう一度お試しください';

  @override
  String get errorCodeInvalidEncryptionKey =>
      '一時的なエラーが発生しました。しばらくしてからもう一度お試しください';

  @override
  String get errorCodeSocialLoginFailed => 'ソーシャルログインに失敗しました';

  @override
  String get errorCodeAccessTokenExpired => '認証の有効期限が切れました';

  @override
  String get errorCodeRefreshTokenExpired => 'ログインの有効期限が切れました。再度ログインしてください';

  @override
  String get errorCodeInvalidToken => '認証情報が正しくありません。再度ログインしてください';

  @override
  String get errorCodeUnauthenticatedRequest => 'ログインが必要です';

  @override
  String get errorCodeExpiredFirebaseToken => '認証の有効期限が切れました。もう一度お試しください';

  @override
  String get errorCodeInvalidFirebaseToken => '認証に失敗しました。もう一度お試しください';

  @override
  String get errorCodeUnsupportedSocialType => 'サポートされていないソーシャルログイン方法です';

  @override
  String get errorCodeForbiddenAdminOnly => '管理者権限が必要です';

  @override
  String get errorCodeNicknameGenerationFailed =>
      '会員登録に失敗しました。しばらくしてからもう一度お試しください';

  @override
  String get errorCodeFirebaseServerError =>
      '一時的なエラーが発生しました。しばらくしてからもう一度お試しください';

  @override
  String get errorCodeUserNotFound => 'ユーザーが見つかりません';

  @override
  String get errorCodeDuplicatedNickname =>
      'このニックネームはすでに使われています。別のニックネームを選択してください';

  @override
  String get errorCodeCannotWithdraw => '進行中のゲームセッションがあるため退会できません';

  @override
  String get errorCodeRequiredTermsNotAgreed => '必須規約にはすべて同意する必要があります';

  @override
  String get errorCodeGameNotFound => 'リクエストされたゲーム情報が存在しません';

  @override
  String get errorCodeGameNotInProgress => 'ゲームが進行中の状態ではありません';

  @override
  String get errorCodeGameNotActive => '待機中または進行中のゲームでのみ照会できます';

  @override
  String get errorCodeGameNotWaiting => '待機中のゲームのみ設定を変更できます';

  @override
  String get errorCodeInvalidLocationInterval => '位置公開間隔はラウンド時間より短くしてください';

  @override
  String get errorCodeInvalidPoliceWaitTime => '警察の待機時間はラウンド時間より短くしてください';

  @override
  String get errorCodeInviteCodeGenerationFailed =>
      '招待コードの生成に失敗しました。しばらくしてからもう一度お試しください';

  @override
  String get errorCodeInvalidJailRadius => '牢屋の半径はプレイグラウンドの半径以上にはできません';

  @override
  String get errorCodeJailOutsidePlayground => '牢屋はプレイグラウンド内に完全に含まれる必要があります';

  @override
  String get errorCodeGameAreaNotFound => 'ゲームエリアが見つかりません';

  @override
  String get errorCodeAlreadyParticipating => 'すでにこのゲームに参加しています';

  @override
  String get errorCodeGameAlreadyStarted => 'すでに開始されたゲームには参加できません';

  @override
  String get errorCodeGameFull => 'ゲームに参加できる最大人数を超えています';

  @override
  String get errorCodeInvalidInviteCode => '入力された招待コードが無効です';

  @override
  String get errorCodeParticipantNotFound => 'このユーザーはこのゲームに参加していません';

  @override
  String get errorCodeNotAParticipant => 'このゲームの参加者ではありません';

  @override
  String get errorCodeCannotLeaveDuringGame => 'ゲーム開始後は部屋を退出できません';

  @override
  String get errorCodeLobbyActionNotAllowed => 'ゲーム開始後はロビーの状態を変更できません';

  @override
  String get errorCodeNotHost => 'ホストのみ操作できます';

  @override
  String get errorCodeInvalidTeamComposition =>
      'ゲームを開始するには、警察と泥棒チームにそれぞれ1名以上の参加者が必要です';

  @override
  String get errorCodeNotAllReady => 'すべての参加者が準備完了状態でないとゲームを開始できません';

  @override
  String get errorCodeNotRobberTeam => '泥棒チームのみ位置を送信できます';

  @override
  String get errorCodeHostCannotUnready => 'ホストは常に準備完了状態でなければなりません';

  @override
  String get errorCodeParticipantGameMismatch => '警察と泥棒が異なるゲームに参加しています';

  @override
  String get errorCodeOnlyPoliceCanArrest => '警察チームのみ泥棒を逮捕できます';

  @override
  String get errorCodeOnlyRobberCanBeArrested => '泥棒チームのみ逮捕されます';

  @override
  String get errorCodeOnlyRobberCanEscape => '泥棒チームのみ脱獄できます';

  @override
  String get errorCodeAlreadyArrested => 'すでに収監されている泥棒です';

  @override
  String get errorCodeNotJailed => '収監中のみ脱獄できます';

  @override
  String get errorCodePoliceWaitingTime => '警察は待機時間中、泥棒を逮捕できません';

  @override
  String get errorCodeCannotKickYourself => 'ホストは自分自身を追放することはできません';

  @override
  String get errorCodeNoticeNotFound => 'お知らせが見つかりません';

  @override
  String get errorCodeGameResultNotFound => 'ゲーム結果が見つかりません';

  @override
  String get errorCodeEtcReasonRequired => '通報タイプがその他の場合は理由を入力してください';

  @override
  String get errorCodeSelfReport => '自分自身は通報できません';

  @override
  String get errorCodeDuplicateReport => 'このゲームですでにこのユーザーを通報しています';

  @override
  String get errorCodeReportNotFound => '該当する通報履歴が存在しません';

  @override
  String get errorCodeReportTargetNotFound => 'このゲームに存在しない参加者です';

  @override
  String get pingFound => '発見';

  @override
  String get pingSuspect => '疑い';

  @override
  String get pingCooldownNotice => 'しばらくしてからもう一度お試しください';

  @override
  String get gameLeaveConfirmTitle => 'ゲームから退場しますか';

  @override
  String get gameLeaveConfirmMessage => '進行中のゲームから退場します';

  @override
  String get gameLeaveFailedMessage => '退場できませんでした。しばらくしてからもう一度お試しください';

  @override
  String get gameEventArrestSuccessTitle => '確保';

  @override
  String gameEventArrestSuccessMessage(String nickname) {
    return '$nicknameを確保';
  }

  @override
  String get gameEventArrestSuccessConfirm => '確認';

  @override
  String get errorEventArrestRequestFailed => '逮捕リクエストの送信に失敗しました。もう一度お試しください';

  @override
  String get gameEventResultTitle => '捜査終了';

  @override
  String get gameEventProgressTitle => '確保状況';

  @override
  String gameEventResultArrestCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '運営$count名を確保',
    );
    return '$_temp0';
  }
}
