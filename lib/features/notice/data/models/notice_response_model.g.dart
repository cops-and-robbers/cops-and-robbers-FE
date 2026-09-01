// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notice_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$NoticeResponseModelImpl _$$NoticeResponseModelImplFromJson(
  Map<String, dynamic> json,
) => _$NoticeResponseModelImpl(
  id: (json['id'] as num).toInt(),
  title: json['title'] as String,
  content: json['content'] as String,
  language: json['language'] as String?,
  requestedLanguage: json['requestedLanguage'] as String?,
  pinned: json['pinned'] as bool,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$$NoticeResponseModelImplToJson(
  _$NoticeResponseModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'content': instance.content,
  'language': instance.language,
  'requestedLanguage': instance.requestedLanguage,
  'pinned': instance.pinned,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};

_$NoticeListResponseModelImpl _$$NoticeListResponseModelImplFromJson(
  Map<String, dynamic> json,
) => _$NoticeListResponseModelImpl(
  content: (json['content'] as List<dynamic>)
      .map((e) => NoticeResponseModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  page: PageInfoModel.fromJson(json['page'] as Map<String, dynamic>),
);

Map<String, dynamic> _$$NoticeListResponseModelImplToJson(
  _$NoticeListResponseModelImpl instance,
) => <String, dynamic>{
  'content': instance.content.map((e) => e.toJson()).toList(),
  'page': instance.page.toJson(),
};
