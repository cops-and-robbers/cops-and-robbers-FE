// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'community_notification_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CommunityNotificationResponseModelImpl
_$$CommunityNotificationResponseModelImplFromJson(Map<String, dynamic> json) =>
    _$CommunityNotificationResponseModelImpl(
      id: (json['id'] as num).toInt(),
      type: json['type'] as String,
      communityPostId: (json['communityPostId'] as num).toInt(),
      postTitle: json['postTitle'] as String,
      content: json['content'] as String,
      read: json['read'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$CommunityNotificationResponseModelImplToJson(
  _$CommunityNotificationResponseModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'type': instance.type,
  'communityPostId': instance.communityPostId,
  'postTitle': instance.postTitle,
  'content': instance.content,
  'read': instance.read,
  'createdAt': instance.createdAt.toIso8601String(),
};

_$CommunityNotificationListResponseModelImpl
_$$CommunityNotificationListResponseModelImplFromJson(
  Map<String, dynamic> json,
) => _$CommunityNotificationListResponseModelImpl(
  content: (json['content'] as List<dynamic>)
      .map(
        (e) => CommunityNotificationResponseModel.fromJson(
          e as Map<String, dynamic>,
        ),
      )
      .toList(),
  hasNext: json['hasNext'] as bool,
  nextCursor: (json['nextCursor'] as num?)?.toInt(),
);

Map<String, dynamic> _$$CommunityNotificationListResponseModelImplToJson(
  _$CommunityNotificationListResponseModelImpl instance,
) => <String, dynamic>{
  'content': instance.content.map((e) => e.toJson()).toList(),
  'hasNext': instance.hasNext,
  'nextCursor': instance.nextCursor,
};

_$CommunityNotificationUnreadCountResponseModelImpl
_$$CommunityNotificationUnreadCountResponseModelImplFromJson(
  Map<String, dynamic> json,
) => _$CommunityNotificationUnreadCountResponseModelImpl(
  unreadCount: (json['unreadCount'] as num).toInt(),
);

Map<String, dynamic> _$$CommunityNotificationUnreadCountResponseModelImplToJson(
  _$CommunityNotificationUnreadCountResponseModelImpl instance,
) => <String, dynamic>{'unreadCount': instance.unreadCount};
