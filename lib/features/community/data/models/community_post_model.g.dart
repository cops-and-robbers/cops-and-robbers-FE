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
  region: json['region'] as String?,
  address: json['address'] as String?,
  placeName: json['placeName'] as String?,
  countryCode: json['countryCode'] as String?,
);

Map<String, dynamic> _$$CommunityLocationModelImplToJson(
  _$CommunityLocationModelImpl instance,
) => <String, dynamic>{
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'region': instance.region,
  'address': instance.address,
  'placeName': instance.placeName,
  'countryCode': instance.countryCode,
};

_$CommunityAddressResponseModelImpl
_$$CommunityAddressResponseModelImplFromJson(Map<String, dynamic> json) =>
    _$CommunityAddressResponseModelImpl(
      region: json['region'] as String?,
      address: json['address'] as String?,
      countryCode: json['countryCode'] as String?,
    );

Map<String, dynamic> _$$CommunityAddressResponseModelImplToJson(
  _$CommunityAddressResponseModelImpl instance,
) => <String, dynamic>{
  'region': instance.region,
  'address': instance.address,
  'countryCode': instance.countryCode,
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

_$CommunityCountryResponseModelImpl
_$$CommunityCountryResponseModelImplFromJson(Map<String, dynamic> json) =>
    _$CommunityCountryResponseModelImpl(
      countryCode: json['countryCode'] as String?,
    );

Map<String, dynamic> _$$CommunityCountryResponseModelImplToJson(
  _$CommunityCountryResponseModelImpl instance,
) => <String, dynamic>{'countryCode': instance.countryCode};

_$CommunityLocationRequestModelImpl
_$$CommunityLocationRequestModelImplFromJson(Map<String, dynamic> json) =>
    _$CommunityLocationRequestModelImpl(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      placeName: json['placeName'] as String,
    );

Map<String, dynamic> _$$CommunityLocationRequestModelImplToJson(
  _$CommunityLocationRequestModelImpl instance,
) => <String, dynamic>{
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'placeName': instance.placeName,
};

_$CommunityPostWriteRequestModelImpl
_$$CommunityPostWriteRequestModelImplFromJson(Map<String, dynamic> json) =>
    _$CommunityPostWriteRequestModelImpl(
      title: json['title'] as String,
      content: json['content'] as String,
      meetingAt: DateTime.parse(json['meetingAt'] as String),
      location: CommunityLocationRequestModel.fromJson(
        json['location'] as Map<String, dynamic>,
      ),
      maxParticipants: (json['maxParticipants'] as num).toInt(),
    );

Map<String, dynamic> _$$CommunityPostWriteRequestModelImplToJson(
  _$CommunityPostWriteRequestModelImpl instance,
) => <String, dynamic>{
  'title': instance.title,
  'content': instance.content,
  'meetingAt': _dateTimeToIso(instance.meetingAt),
  'location': instance.location.toJson(),
  'maxParticipants': instance.maxParticipants,
};

_$CommunityPostStatusRequestModelImpl
_$$CommunityPostStatusRequestModelImplFromJson(Map<String, dynamic> json) =>
    _$CommunityPostStatusRequestModelImpl(status: json['status'] as String);

Map<String, dynamic> _$$CommunityPostStatusRequestModelImplToJson(
  _$CommunityPostStatusRequestModelImpl instance,
) => <String, dynamic>{'status': instance.status};
