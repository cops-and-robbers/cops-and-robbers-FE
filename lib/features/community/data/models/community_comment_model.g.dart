// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'community_comment_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CommunityCommentResponseModelImpl
_$$CommunityCommentResponseModelImplFromJson(Map<String, dynamic> json) =>
    _$CommunityCommentResponseModelImpl(
      id: (json['id'] as num).toInt(),
      parentId: (json['parentId'] as num?)?.toInt(),
      writerId: (json['writerId'] as num?)?.toInt(),
      writerNickname: json['writerNickname'] as String?,
      writerProfileIcon: (json['writerProfileIcon'] as num?)?.toInt(),
      content: json['content'] as String?,
      deleted: json['deleted'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      replyNotificationsEnabled:
          json['replyNotificationsEnabled'] as bool? ?? true,
      replies:
          (json['replies'] as List<dynamic>?)
              ?.map(
                (e) => CommunityCommentResponseModel.fromJson(
                  e as Map<String, dynamic>,
                ),
              )
              .toList() ??
          const <CommunityCommentResponseModel>[],
    );

Map<String, dynamic> _$$CommunityCommentResponseModelImplToJson(
  _$CommunityCommentResponseModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'parentId': instance.parentId,
  'writerId': instance.writerId,
  'writerNickname': instance.writerNickname,
  'writerProfileIcon': instance.writerProfileIcon,
  'content': instance.content,
  'deleted': instance.deleted,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
  'replyNotificationsEnabled': instance.replyNotificationsEnabled,
  'replies': instance.replies.map((e) => e.toJson()).toList(),
};

_$CommunityCommentListResponseModelImpl
_$$CommunityCommentListResponseModelImplFromJson(Map<String, dynamic> json) =>
    _$CommunityCommentListResponseModelImpl(
      content:
          (json['content'] as List<dynamic>?)
              ?.map(
                (e) => CommunityCommentResponseModel.fromJson(
                  e as Map<String, dynamic>,
                ),
              )
              .toList() ??
          const <CommunityCommentResponseModel>[],
      nextCursor: (json['nextCursor'] as num?)?.toInt(),
      hasNext: json['hasNext'] as bool? ?? false,
    );

Map<String, dynamic> _$$CommunityCommentListResponseModelImplToJson(
  _$CommunityCommentListResponseModelImpl instance,
) => <String, dynamic>{
  'content': instance.content.map((e) => e.toJson()).toList(),
  'nextCursor': instance.nextCursor,
  'hasNext': instance.hasNext,
};

_$CommunityCommentCreateRequestModelImpl
_$$CommunityCommentCreateRequestModelImplFromJson(Map<String, dynamic> json) =>
    _$CommunityCommentCreateRequestModelImpl(
      parentId: (json['parentId'] as num?)?.toInt(),
      content: json['content'] as String,
    );

Map<String, dynamic> _$$CommunityCommentCreateRequestModelImplToJson(
  _$CommunityCommentCreateRequestModelImpl instance,
) => <String, dynamic>{
  'parentId': instance.parentId,
  'content': instance.content,
};

_$CommunityCommentNotificationRequestModelImpl
_$$CommunityCommentNotificationRequestModelImplFromJson(
  Map<String, dynamic> json,
) => _$CommunityCommentNotificationRequestModelImpl(
  replyNotificationsEnabled: json['replyNotificationsEnabled'] as bool,
);

Map<String, dynamic> _$$CommunityCommentNotificationRequestModelImplToJson(
  _$CommunityCommentNotificationRequestModelImpl instance,
) => <String, dynamic>{
  'replyNotificationsEnabled': instance.replyNotificationsEnabled,
};
