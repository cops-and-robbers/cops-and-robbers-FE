// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'community_chat_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CommunityChatLastMessageResponseModelImpl
_$$CommunityChatLastMessageResponseModelImplFromJson(
  Map<String, dynamic> json,
) => _$CommunityChatLastMessageResponseModelImpl(
  id: (json['id'] as num).toInt(),
  message: json['message'] as String?,
  messageType: json['messageType'] as String?,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  senderNickname: json['senderNickname'] as String?,
  senderProfileIcon: (json['senderProfileIcon'] as num?)?.toInt(),
);

Map<String, dynamic> _$$CommunityChatLastMessageResponseModelImplToJson(
  _$CommunityChatLastMessageResponseModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'message': instance.message,
  'messageType': instance.messageType,
  'createdAt': instance.createdAt?.toIso8601String(),
  'senderNickname': instance.senderNickname,
  'senderProfileIcon': instance.senderProfileIcon,
};

_$CommunityChatRoomResponseModelImpl
_$$CommunityChatRoomResponseModelImplFromJson(Map<String, dynamic> json) =>
    _$CommunityChatRoomResponseModelImpl(
      postId: (json['postId'] as num).toInt(),
      title: json['title'] as String?,
      status: json['status'] as String?,
      meetingAt: json['meetingAt'] == null
          ? null
          : DateTime.parse(json['meetingAt'] as String),
      memberCount: (json['memberCount'] as num?)?.toInt(),
      lastMessage: json['lastMessage'] == null
          ? null
          : CommunityChatLastMessageResponseModel.fromJson(
              json['lastMessage'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$$CommunityChatRoomResponseModelImplToJson(
  _$CommunityChatRoomResponseModelImpl instance,
) => <String, dynamic>{
  'postId': instance.postId,
  'title': instance.title,
  'status': instance.status,
  'meetingAt': instance.meetingAt?.toIso8601String(),
  'memberCount': instance.memberCount,
  'lastMessage': instance.lastMessage?.toJson(),
};

_$CommunityChatRoomListResponseModelImpl
_$$CommunityChatRoomListResponseModelImplFromJson(Map<String, dynamic> json) =>
    _$CommunityChatRoomListResponseModelImpl(
      chatRooms:
          (json['chatRooms'] as List<dynamic>?)
              ?.map(
                (e) => CommunityChatRoomResponseModel.fromJson(
                  e as Map<String, dynamic>,
                ),
              )
              .toList() ??
          const <CommunityChatRoomResponseModel>[],
    );

Map<String, dynamic> _$$CommunityChatRoomListResponseModelImplToJson(
  _$CommunityChatRoomListResponseModelImpl instance,
) => <String, dynamic>{
  'chatRooms': instance.chatRooms.map((e) => e.toJson()).toList(),
};

_$CommunityChatMessageResponseModelImpl
_$$CommunityChatMessageResponseModelImplFromJson(Map<String, dynamic> json) =>
    _$CommunityChatMessageResponseModelImpl(
      id: (json['id'] as num).toInt(),
      messageKey: json['messageKey'] as String?,
      senderId: (json['senderId'] as num?)?.toInt(),
      senderNickname: json['senderNickname'] as String?,
      senderProfileIcon: (json['senderProfileIcon'] as num?)?.toInt(),
      message: json['message'] as String?,
      messageType: json['messageType'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$CommunityChatMessageResponseModelImplToJson(
  _$CommunityChatMessageResponseModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'messageKey': instance.messageKey,
  'senderId': instance.senderId,
  'senderNickname': instance.senderNickname,
  'senderProfileIcon': instance.senderProfileIcon,
  'message': instance.message,
  'messageType': instance.messageType,
  'createdAt': instance.createdAt?.toIso8601String(),
};

_$CommunityChatHistoryResponseModelImpl
_$$CommunityChatHistoryResponseModelImplFromJson(Map<String, dynamic> json) =>
    _$CommunityChatHistoryResponseModelImpl(
      messages:
          (json['messages'] as List<dynamic>?)
              ?.map(
                (e) => CommunityChatMessageResponseModel.fromJson(
                  e as Map<String, dynamic>,
                ),
              )
              .toList() ??
          const <CommunityChatMessageResponseModel>[],
      nextCursor: (json['nextCursor'] as num?)?.toInt(),
      hasNext: json['hasNext'] as bool? ?? false,
    );

Map<String, dynamic> _$$CommunityChatHistoryResponseModelImplToJson(
  _$CommunityChatHistoryResponseModelImpl instance,
) => <String, dynamic>{
  'messages': instance.messages.map((e) => e.toJson()).toList(),
  'nextCursor': instance.nextCursor,
  'hasNext': instance.hasNext,
};

_$CommunityChatMemberResponseModelImpl
_$$CommunityChatMemberResponseModelImplFromJson(Map<String, dynamic> json) =>
    _$CommunityChatMemberResponseModelImpl(
      userId: (json['userId'] as num).toInt(),
      nickname: json['nickname'] as String?,
      profileIcon: (json['profileIcon'] as num?)?.toInt(),
      isAuthor: json['isAuthor'] as bool? ?? false,
    );

Map<String, dynamic> _$$CommunityChatMemberResponseModelImplToJson(
  _$CommunityChatMemberResponseModelImpl instance,
) => <String, dynamic>{
  'userId': instance.userId,
  'nickname': instance.nickname,
  'profileIcon': instance.profileIcon,
  'isAuthor': instance.isAuthor,
};

_$CommunityChatMemberListResponseModelImpl
_$$CommunityChatMemberListResponseModelImplFromJson(
  Map<String, dynamic> json,
) => _$CommunityChatMemberListResponseModelImpl(
  members:
      (json['members'] as List<dynamic>?)
          ?.map(
            (e) => CommunityChatMemberResponseModel.fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList() ??
      const <CommunityChatMemberResponseModel>[],
);

Map<String, dynamic> _$$CommunityChatMemberListResponseModelImplToJson(
  _$CommunityChatMemberListResponseModelImpl instance,
) => <String, dynamic>{
  'members': instance.members.map((e) => e.toJson()).toList(),
};
