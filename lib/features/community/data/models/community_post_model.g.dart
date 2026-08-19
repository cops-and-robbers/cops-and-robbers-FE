// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'community_post_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CommunityLocationModelImpl _$$CommunityLocationModelImplFromJson(
  Map<String, dynamic> json,
) => _$CommunityLocationModelImpl(
  latitude: (json['latitude'] as num).toDouble(),
  longitude: (json['longitude'] as num).toDouble(),
  address: json['address'] as String?,
  roadAddress: json['roadAddress'] as String?,
  buildingName: json['buildingName'] as String?,
);

Map<String, dynamic> _$$CommunityLocationModelImplToJson(
  _$CommunityLocationModelImpl instance,
) => <String, dynamic>{
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'address': instance.address,
  'roadAddress': instance.roadAddress,
  'buildingName': instance.buildingName,
};

_$CursorInfoModelImpl _$$CursorInfoModelImplFromJson(
  Map<String, dynamic> json,
) => _$CursorInfoModelImpl(
  nextCursor: json['nextCursor'] as String?,
  hasNext: json['hasNext'] as bool,
);

Map<String, dynamic> _$$CursorInfoModelImplToJson(
  _$CursorInfoModelImpl instance,
) => <String, dynamic>{
  'nextCursor': instance.nextCursor,
  'hasNext': instance.hasNext,
};

_$CommunityPostResponseModelImpl _$$CommunityPostResponseModelImplFromJson(
  Map<String, dynamic> json,
) => _$CommunityPostResponseModelImpl(
  id: (json['id'] as num).toInt(),
  writerId: (json['writerId'] as num).toInt(),
  title: json['title'] as String,
  content: json['content'] as String,
  meetingAt: DateTime.parse(json['meetingAt'] as String),
  location: CommunityLocationModel.fromJson(
    json['location'] as Map<String, dynamic>,
  ),
  maxParticipants: (json['maxParticipants'] as num).toInt(),
  status: json['status'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  writerNickname: json['writerNickname'] as String?,
  currentParticipants: (json['currentParticipants'] as num?)?.toInt(),
  likeCount: (json['likeCount'] as num?)?.toInt(),
  bookmarkCount: (json['bookmarkCount'] as num?)?.toInt(),
);

Map<String, dynamic> _$$CommunityPostResponseModelImplToJson(
  _$CommunityPostResponseModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'writerId': instance.writerId,
  'title': instance.title,
  'content': instance.content,
  'meetingAt': instance.meetingAt.toIso8601String(),
  'location': instance.location.toJson(),
  'maxParticipants': instance.maxParticipants,
  'status': instance.status,
  'createdAt': instance.createdAt.toIso8601String(),
  'writerNickname': instance.writerNickname,
  'currentParticipants': instance.currentParticipants,
  'likeCount': instance.likeCount,
  'bookmarkCount': instance.bookmarkCount,
};

_$CommunityPostListResponseModelImpl
_$$CommunityPostListResponseModelImplFromJson(Map<String, dynamic> json) =>
    _$CommunityPostListResponseModelImpl(
      content: (json['content'] as List<dynamic>)
          .map(
            (e) =>
                CommunityPostResponseModel.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
      cursor: CursorInfoModel.fromJson(json['cursor'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$CommunityPostListResponseModelImplToJson(
  _$CommunityPostListResponseModelImpl instance,
) => <String, dynamic>{
  'content': instance.content.map((e) => e.toJson()).toList(),
  'cursor': instance.cursor.toJson(),
};
