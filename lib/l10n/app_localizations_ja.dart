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
  String get buttonCancel => '閉じる';

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
  String get zoneRadiusLabel => '半径';

  @override
  String zoneRadiusValue(String value) {
    return '半径 $value';
  }

  @override
  String zoneAreaValue(String value) {
    return '面積 $value';
  }

  @override
  String get areaTypeSetByDistance => '距離で設定';

  @override
  String get areaTypeSetByPin => 'ピンで設定';

  @override
  String get setupPlaygroundPinDescription => 'ゲームを行うエリア全体を選択します';

  @override
  String get setupPrisonPinDescription => '泥棒を拘束しておく牢屋エリアを選択します';

  @override
  String get zoneAreaLabel => '面積';

  @override
  String get zoneClearAllPins => 'すべて解除';

  @override
  String pinMaxCountMessage(int count) {
    return 'ピンは最大$count個まで置けます';
  }

  @override
  String get pinTooCloseMessage => 'ピン同士が近すぎます';

  @override
  String get errorAuthLoginCancelled => 'ログインがキャンセルされました';

  @override
  String get settingsLanguageLabel => '言語';

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
    return '泥棒スタートから $minutes分後';
  }

  @override
  String get pageGameSettingsEditTitle => '設定の編集';

  @override
  String get buttonSaving => '保存中...';

  @override
  String get buttonSave => '保存';

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
  String get mypageProfileIconLabel => 'プロフィールアイコン';

  @override
  String get bottomNavHome => 'ホーム';

  @override
  String get bottomNavCommunity => 'コミュニティ';

  @override
  String get pageCommunityDetailTitle => '募集';

  @override
  String get communityDetailJoinChat => 'チャットに参加する';

  @override
  String get communityDetailShare => '共有';

  @override
  String get communityChatRoomsEmpty => '参加中のチャットルームはありません';

  @override
  String get communityChatRoomsLoginRequired => 'ログインすると参加中の集まりが見られます';

  @override
  String communityChatSystemJoined(String nickname) {
    return '$nicknameさんが参加しました';
  }

  @override
  String communityChatSystemLeft(String nickname) {
    return '$nicknameさんが退出しました';
  }

  @override
  String get communityChatPreviewJoined => '新しいメンバーが参加しました';

  @override
  String get communityChatPreviewLeft => 'メンバーが退出しました';

  @override
  String communityChatSystemKicked(String nickname) {
    return '$nicknameさんが退出させられました';
  }

  @override
  String get communityChatPreviewKicked => 'メンバーが退出させられました';

  @override
  String get communityChatPreviewInvite => 'ゲーム招待';

  @override
  String get communityChatPreviewUnsupported => '新しいメッセージ';

  @override
  String get communityChatInviteOpened => 'ゲームが始まりました!';

  @override
  String communityChatInviteTitle(String nickname, String roomTitle) {
    return '$nicknameさんが[$roomTitle]部屋に招待しました';
  }

  @override
  String communityChatInviteCode(String inviteCode) {
    return '招待コード $inviteCode';
  }

  @override
  String get communityChatInviteJoin => 'ゲームに参加';

  @override
  String get communityChatInputHint => 'メッセージを送る';

  @override
  String get communityChatEnterRoom => 'チャットに入る';

  @override
  String communityChatMeetingMembers(String current, int max) {
    return '現在 $current/$max名';
  }

  @override
  String get communityChatViewLocation => '場所を見る';

  @override
  String get communityChatStartGame => 'ゲーム開始';

  @override
  String get communityChatInviteSendFailed => 'チャットに招待を送れませんでした';

  @override
  String get communityChatInviteDialogTitle => 'ゲーム招待状';

  @override
  String communityChatInviteDialogBody(String nickname) {
    return '$nicknameさんが\nゲームに招待しました';
  }

  @override
  String get communityChatInviteDialogCodeLabel => 'ルームコード';

  @override
  String get communityChatInviteDialogDecline => '拒否';

  @override
  String get communityChatInviteDialogEnter => '入場';

  @override
  String communityChatMemberCount(int count) {
    return '参加者 $count名';
  }

  @override
  String get communityChatAuthorBadge => 'ホスト';

  @override
  String get communityChatViewPost => '募集を見る';

  @override
  String get communityChatLeave => 'チャットを退出';

  @override
  String get communityChatLeaveConfirmTitle => 'チャットを退出しますか？';

  @override
  String get communityChatLeaveConfirmMessage => '退出すると会話を再び見ることはできません';

  @override
  String get communityChatMeetingInfoTitle => '集まりの情報';

  @override
  String get communityChatConnectionLost => '接続が切れました';

  @override
  String get communityChatReconnect => '再接続';

  @override
  String get communityChatReconnecting => '接続中...';

  @override
  String get communityChatSendFailed => '送信失敗・タップで再送';

  @override
  String get communityChatEvicted => 'このチャットのメンバーではなくなりました';

  @override
  String get timePeriodAm => '午前';

  @override
  String get timePeriodPm => '午後';

  @override
  String communityChatTime(String period, String hour, String minute) {
    return '$period $hour:$minute';
  }

  @override
  String communityChatDateShort(String month, String day) {
    return '$month/$day';
  }

  @override
  String get buttonLogin => 'ログイン';

  @override
  String get errorCodeInvalidMessageType => '送信できないメッセージです';

  @override
  String get errorCodeEmptyMessage => 'メッセージを入力してください';

  @override
  String get errorCodeMessageTooLong => 'メッセージは500文字まで送れます';

  @override
  String get errorCodeInvalidGameInvite => '招待情報が正しくありません';

  @override
  String get errorCodeInvalidMessageKey => 'メッセージを送れませんでした。もう一度お試しください';

  @override
  String communityDetailCommentCount(int count) {
    return 'コメント $count';
  }

  @override
  String get communityCommentHint => 'コメントを残してみましょう';

  @override
  String get communityCommentReplyHint => '返信を残してみましょう';

  @override
  String get communityCommentDeleted => '削除されたコメントです';

  @override
  String get communityCommentEmpty => '最初のコメントを残してみましょう';

  @override
  String get communityCommentJustNow => 'たった今';

  @override
  String communityCommentMinutesAgo(int minutes) {
    return '$minutes分前';
  }

  @override
  String communityCommentHoursAgo(int hours) {
    return '$hours時間前';
  }

  @override
  String get communityDeleteConfirmTitle => '募集を削除しますか';

  @override
  String get communityDeleteConfirmMessage => '削除すると元に戻せません';

  @override
  String get communityLoginRequiredMessage => 'ログインが必要な機能です';

  @override
  String get communityMenuEdit => '修正する';

  @override
  String get communityMenuDelete => '削除する';

  @override
  String get communityMenuMarkCompleted => '締め切る';

  @override
  String get communityMenuMarkRecruiting => '再募集する';

  @override
  String get communityMenuLoginRequired => 'ログインして利用する';

  @override
  String get communityMenuNotificationOn => '通知をオンにする';

  @override
  String get communityMenuNotificationOff => '通知をオフにする';

  @override
  String get communityMenuReplyNotificationOn => '返信通知をオンにする';

  @override
  String get communityMenuReplyNotificationOff => '返信通知をオフにする';

  @override
  String get communityStatusRecruiting => '募集中';

  @override
  String get communityStatusCompleted => '締切';

  @override
  String get communityStatusEnded => '終了';

  @override
  String communityHeadcount(int current, int max) {
    return '$current/$max人';
  }

  @override
  String communityHeadcountMaxOnly(int max) {
    return '定員$max人';
  }

  @override
  String communityMeetingAt(
    String month,
    String day,
    String weekday,
    String time,
  ) {
    return '$month/$day ($weekday) $time';
  }

  @override
  String get pageCommunityTitle => 'コミュニティ';

  @override
  String get pageCommunityEmpty => '募集がまだありません';

  @override
  String get pageCommunityScrapTitle => 'スクラップ';

  @override
  String get communityScrapEmpty => 'スクラップした投稿がありません';

  @override
  String get pageCommunityNotificationTitle => '通知';

  @override
  String get communityNotificationEmpty => '届いた通知がありません';

  @override
  String communityNotificationNewComment(String content) {
    return '新しいコメント: $content';
  }

  @override
  String communityNotificationNewReply(String content) {
    return '新しい返信: $content';
  }

  @override
  String get communityScopeAll => 'すべて';

  @override
  String get communityScopeNearby => '近所';

  @override
  String get communityScopeMine => 'マイ募集';

  @override
  String get communitySortLatest => '新着順';

  @override
  String get communitySortPopular => '人気順';

  @override
  String get communitySortDistance => '近い順';

  @override
  String get communitySortDeadline => '締切間近順';

  @override
  String get communitySortNeedsLocation => '距離順で見るには位置情報の許可が必要です';

  @override
  String get communitySortLocationDenied => '設定で位置情報をオンにしてください';

  @override
  String get communitySearchHint => 'タイトル・場所で検索';

  @override
  String get communitySearchRecent => '最近の検索';

  @override
  String get communitySearchClearAll => 'すべて削除';

  @override
  String get communitySearchEmpty => '検索結果がありません';

  @override
  String get communitySearchTooShort => '2文字以上入力してください';

  @override
  String get communityCreatePost => '募集を作成';

  @override
  String get communityEditPost => '募集を修正';

  @override
  String get communityBackToList => '一覧に戻る';

  @override
  String get communityCreateLabelTitle => 'タイトル';

  @override
  String get communityCreateHintTitle => '仕事帰りに一戦！初心者歓迎';

  @override
  String get communityCreateLabelContent => '説明';

  @override
  String get communityCreateHintContent => 'ルール、持ち物、打ち上げの有無などを書いてください';

  @override
  String get communityCreateLabelDate => '日時';

  @override
  String get communityCreateHintDate => '集合日時を選んでください';

  @override
  String communityCreateDateValue(
    String year,
    String month,
    String day,
    String weekday,
    String time,
  ) {
    return '$year.$month.$day ($weekday) $time';
  }

  @override
  String get communityDateSheetTitle => '集合日時';

  @override
  String get communityDateSheetRowTime => '時間';

  @override
  String communityDateSheetRowDateValue(
    String year,
    String month,
    String day,
    String weekday,
  ) {
    return '$year.$month.$day $weekday';
  }

  @override
  String get communityCreateLabelLocation => '場所';

  @override
  String get communityCreateHintLocation => '詳細な集合場所を入力してください 例) 正門';

  @override
  String get communityCreateHintAddress => '地図で位置を選ぶと入力されます';

  @override
  String get communityCreateHintPickLocation => '地図で位置を選んでください';

  @override
  String get communityLocationCopied => '場所をコピーしました';

  @override
  String get communityLocationPickerTitle => '場所の選択';

  @override
  String get communityLocationPickerConfirm => 'この位置にする';

  @override
  String get communityLocationPickerLoading => '住所を確認しています';

  @override
  String get communityLocationPickerHint => '地図をタップして集合場所を決めます';

  @override
  String get communityLocationPickerNotFound => '住所が見つかりません。別の場所を選んでください';

  @override
  String get communityCreateLoading => '募集を投稿しています';

  @override
  String get communityCreateLoadingSub => '募集を登録しています。少々お待ちください';

  @override
  String get communityEditLoading => '募集を修正しています';

  @override
  String get communityEditLoadingSub => '募集を修正しています。少々お待ちください';

  @override
  String get communityCreateLabelHeadcount => '募集人数';

  @override
  String communityHeadcountValue(int count) {
    return '$count人';
  }

  @override
  String communityHeadcountQuickAdd(int count) {
    return '+ $count人';
  }

  @override
  String get communityHeadcountDecrease => '人数を減らす';

  @override
  String get communityHeadcountIncrease => '人数を増やす';

  @override
  String get weekdayMon => '月';

  @override
  String get weekdayTue => '火';

  @override
  String get weekdayWed => '水';

  @override
  String get weekdayThu => '木';

  @override
  String get weekdayFri => '金';

  @override
  String get weekdaySat => '土';

  @override
  String get weekdaySun => '日';

  @override
  String get bottomNavMyPage => 'マイページ';

  @override
  String get comingSoonMessage => '準備中です';

  @override
  String get homeBannerSemanticsLabel => 'イベントバナー';

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
  String get homePageWelcomeMessage => '誰がぼくのチーズを\n盗んだの!!!!🧀';

  @override
  String get buttonCreateRoom => 'ゲーム作成';

  @override
  String get buttonJoinRoom => 'ゲーム参加';

  @override
  String get errorCreateRoomFailed => '待機室の作成に失敗しました。もう一度お試しください';

  @override
  String get sessionCreationStepBasicTitle => '基本情報を設定します';

  @override
  String get sessionCreationStepReviewTitle => '最終設定を確認します';

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
  String get setupPlaygroundDescription => 'ゲームを行うエリア全体の大きさを設定します';

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
  String get dialogLeaveRoomTitle => '待機室から退室しますか';

  @override
  String get dialogLeaveRoomMessage => '退室すると、再度招待コードを入力する必要があります';

  @override
  String get buttonLeave => '退室';

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
  String get titleGameRules => 'ゲームルール';

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
  String get unitPerson => '人';

  @override
  String get unitMinutes => '分';

  @override
  String get gameSettingNoLocationShareWarning => '泥棒の位置が公開されません！';

  @override
  String get gameSettingPoliceStartPrefix => '泥棒スタートから';

  @override
  String get gameSettingPoliceStartSuffix => '後';

  @override
  String get buttonCompleteSetup => '完了する';

  @override
  String warnMaxReached(String max) {
    return '最大$maxまで設定できます';
  }

  @override
  String get warnRoundDurationRange => 'ゲーム時間は10分から180分まで設定できます';

  @override
  String get warnShorterThanRoundDuration => 'ゲーム時間より短く設定してください';

  @override
  String get warnPoliceWaitMin => '警察スタート時間は1分から設定できます';

  @override
  String get dialogQuitCreationTitle => 'ルーム作成をやめますか？';

  @override
  String get dialogQuitCreationMessage => '描いていたエリアは消えます';

  @override
  String get buttonKeepCreating => '作成を続ける';

  @override
  String get buttonQuitCreation => 'やめる';

  @override
  String get sectionTitleSettings => '設定';

  @override
  String get labelParticipantCount => '参加人数';

  @override
  String get fieldRoundTimeLimit => 'ゲーム時間';

  @override
  String get fieldLocationShareInterval => '泥棒の位置公開間隔';

  @override
  String get fieldPoliceDispatchTime => '警察スタート時間';

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
  String get gameOverFallbackMessage => 'ゲームが終了しました';

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
  String get fieldRemainingRobbers => '残りの泥棒';

  @override
  String get fieldGamePlaytime => 'ゲーム進行時間';

  @override
  String get buttonGoHome => 'ホームへ';

  @override
  String get buttonPlayAgain => 'もう一度';

  @override
  String get messageSaveFailed => '保存に失敗しました';

  @override
  String get dialogImageActionTitle => '画像をどうしますか？';

  @override
  String get buttonSaveImage => '画像を保存';

  @override
  String get messageImageSaved => '画像を保存しました';

  @override
  String get messageShareComplete => '共有しました';

  @override
  String get labelNoRoute => '移動記録なし';

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
  String get buttonCopy => 'コピーする';

  @override
  String get buttonBlock => 'ブロック';

  @override
  String get reportCategoryLabel => '通報の種類';

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
  String get settingsAccountMyScraps => 'マイスクラップ';

  @override
  String get settingsSectionAppPreferences => 'アプリ設定';

  @override
  String get settingsAppGameNotification => 'ゲーム通知';

  @override
  String get settingsAppGameNotificationDescription =>
      'ゲーム進行中に発生するイベントの通知を設定します';

  @override
  String get settingsAppCommunityNotification => 'コミュニティ通知';

  @override
  String get settingsAppCommunityNotificationDescription =>
      'コメント・返信・チャットのプッシュ通知を受け取ります。オフにしても通知ボックスには残ります';

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
  String get settingsGuideAgreements => '利用規約とポリシー';

  @override
  String get settingsGuideOpenSourceLicenses => 'オープンソースライセンス';

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
  String get errorProfileIconUpdateFailed => 'プロフィールアイコンを変更できませんでした';

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
  String get errorCommunityPushFetchUnexpected =>
      'コミュニティプッシュ通知の同意取得中に予期しないエラーが発生しました';

  @override
  String get errorCommunityPushUpdateUnexpected => 'コミュニティ通知の設定を変更できませんでした';

  @override
  String get errorAuthTokenMissing => 'ログイン情報を確認できません。再度ログインしてください';

  @override
  String get errorServerUnreachable => 'サーバーに接続できません。しばらくしてからもう一度お試しください';

  @override
  String get errorAuthExpired => '認証の有効期限が切れました。再ログインが必要です';

  @override
  String get errorNoticesLoadGeneric => '知らせを読み込む中にエラーが発生しました';

  @override
  String get errorCommunityPostsLoadGeneric => '募集の読み込み中にエラーが発生しました';

  @override
  String get errorCommunityPostsLoadFailed => '募集を読み込めませんでした';

  @override
  String get errorCommunityPostUpdateGeneric => '募集の修正中にエラーが発生しました';

  @override
  String get errorCommunityPostDeleteGeneric => '募集の削除中にエラーが発生しました';

  @override
  String get errorCommunityPostStatusGeneric => '募集状態の変更中にエラーが発生しました';

  @override
  String get errorCommunityPostCreateGeneric => '募集の登録中にエラーが発生しました';

  @override
  String get errorCommunityCommentsLoadGeneric => 'コメントの読み込み中にエラーが発生しました';

  @override
  String get errorCommunityCommentCreateGeneric => 'コメントの投稿中にエラーが発生しました';

  @override
  String get errorCommunityCommentDeleteGeneric => 'コメントの削除中にエラーが発生しました';

  @override
  String get errorCommunityReactionGeneric => '処理できませんでした。しばらくしてからもう一度お試しください';

  @override
  String get errorCommunityScrapsLoadGeneric =>
      'スクラップ一覧を読み込めませんでした。しばらくしてからもう一度お試しください';

  @override
  String get errorCommunityNotificationsLoadGeneric =>
      '通知一覧を読み込めませんでした。しばらくしてからもう一度お試しください';

  @override
  String get errorCommunityNotificationUnreadCountLoadGeneric =>
      '未読通知件数を読み込めませんでした';

  @override
  String get errorCommunityNotificationReadGeneric => '通知の既読処理に失敗しました';

  @override
  String get errorCommunityPostNotificationUpdateGeneric =>
      'この投稿の通知設定を変更できませんでした';

  @override
  String get errorCommunityCommentNotificationUpdateGeneric =>
      '返信通知の設定を変更できませんでした';

  @override
  String get errorCommunityAddressLoadGeneric => '住所の読み込み中にエラーが発生しました';

  @override
  String get errorNoticeLoadFailed => 'お知らせを読み込めませんでした';

  @override
  String get pageNoticesTitle => 'お知らせ';

  @override
  String get pageNoticesEmpty => '登録されたお知らせはありません';

  @override
  String get noticeCategoryAll => 'すべて';

  @override
  String get noticeCategoryNotice => 'お知らせ';

  @override
  String get noticeCategoryMaintenance => 'メンテナンス';

  @override
  String get noticeCategoryEvent => 'イベント';

  @override
  String get noticeCategoryUpdate => 'アップデート';

  @override
  String get noticeTranslationFallback => '翻訳を準備中のため、原文のまま表示しています';

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
    return '制限時間は$minutes分です';
  }

  @override
  String get gameEventStartReady => 'まもなくゲームが始まります。  全プレイヤーは準備してください!';

  @override
  String get gameEventStartReportTip => 'ゲーム中、チャットを長押しすると不快なユーザーを通報・ブロックできます';

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
  String get deeplinkAlreadyInRoom => '既に参加中の部屋があります';

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
  String get errorCodeInvalidInputValue => '入力値が条件に合いません';

  @override
  String get errorCodeAddressNotFound => '住所が見つかりません。別の場所を選んでください';

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
  String get errorCodeNoticeTranslationInvalid => 'お知らせの翻訳情報が正しくありません';

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
  String get errorCodeChatMessageNotFound => 'このメッセージが見つかりません';

  @override
  String get errorCodeReportTargetNotFound => 'このゲームに存在しない参加者です';

  @override
  String get errorCodeInvalidMeetingDate => '集まる時間は現在より後を選んでください';

  @override
  String get errorCodeCommentNotFound => 'すでに削除されたコメントです';

  @override
  String get errorCodeForbiddenNotCommentAuthor => '自分が書いたコメントのみ削除できます';

  @override
  String get errorCodeReplyTargetGone =>
      '返信しようとしたコメントがなくなりました。更新してからもう一度お試しください';

  @override
  String get errorCodeInvalidCommentDepth => '返信に返信はできません';

  @override
  String get errorCodePostNotFound => 'この募集はすでに削除されました';

  @override
  String get errorCodeForbiddenNotAuthor => 'ホストのみ編集・削除できます';

  @override
  String get errorCodeCountryNotSpecified => '国を確認できない場所です。別の場所で試してください';

  @override
  String get errorCodeAddressLookupFailed => '住所の取得に失敗しました。しばらくしてからもう一度お試しください';

  @override
  String get errorCodeRecruitmentClosed => 'この募集はすでに締め切られました';

  @override
  String get errorCodeUnsupportedListScope => 'サポートされていない一覧の範囲です';

  @override
  String get errorCodeUnsupportedListSort => 'サポートされていない並び替え方法です';

  @override
  String get errorCodeAlreadyJoined => '既にこのチャットに参加しています';

  @override
  String get errorCodeAuthorCannotLeave => 'ホストはこのチャットから退出できません';

  @override
  String get errorCodeChatRoomFull => 'このチャットの定員に達しました';

  @override
  String get errorCodeJoinedChatRoomLimitExceeded =>
      '参加できるチャット数の上限を超えました。他のチャットから退出してからもう一度お試しください';

  @override
  String get errorCodeNotAChatMember => 'このチャットの参加者ではありません';

  @override
  String get errorCodeForbiddenNotChatHost => 'ホストのみメンバーを追放できます';

  @override
  String get errorCodeChatMemberNotFound => 'このメンバーはすでにチャットから退出しています';

  @override
  String get errorCodeConflictingCountryFilter => '国の条件が競合しています';

  @override
  String get errorCodeReactionAlreadyApplied => 'すでに反映されています';

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

  @override
  String get onboardingOutdoorTitle => '外で本当に走る鬼ごっこです';

  @override
  String get onboardingOutdoorBody => '昔ながらのルールそのままです。進行はアプリにおまかせします';

  @override
  String get onboardingWinTitle => '全員逮捕したら警察、逃げ切れば泥棒の勝ちです';

  @override
  String get onboardingWinBody => '泥棒を全員逮捕したら警察の勝ち。時間切れまでひとりでも逃げ切れば泥棒の勝ちです';

  @override
  String get onboardingRefereeTitle => 'アプリが審判をします';

  @override
  String get onboardingRefereeBody =>
      'エリアは地図に描いて、泥棒の位置は一定間隔で足跡として公開されます。逮捕はQRスキャンなので、判定はいつも明確です';

  @override
  String get onboardingCommunityTitle => '一緒に遊ぶ人もここで探せます';

  @override
  String get onboardingCommunityBody =>
      '近くで一緒に走る人をコミュニティで探してみてください。場所と時間を見て、そのまま参加できます';

  @override
  String get buttonSkip => 'スキップ';

  @override
  String get settingsGuideAppIntro => 'アプリ紹介をもう一度見る';

  @override
  String get onboardingStartButton => '始める';
}
