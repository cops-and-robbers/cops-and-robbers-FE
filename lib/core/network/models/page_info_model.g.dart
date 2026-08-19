// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'page_info_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PageInfoModelImpl _$$PageInfoModelImplFromJson(Map<String, dynamic> json) =>
    _$PageInfoModelImpl(
      size: (json['size'] as num).toInt(),
      number: (json['number'] as num).toInt(),
      totalElements: (json['totalElements'] as num).toInt(),
      totalPages: (json['totalPages'] as num).toInt(),
    );

Map<String, dynamic> _$$PageInfoModelImplToJson(_$PageInfoModelImpl instance) =>
    <String, dynamic>{
      'size': instance.size,
      'number': instance.number,
      'totalElements': instance.totalElements,
      'totalPages': instance.totalPages,
    };
