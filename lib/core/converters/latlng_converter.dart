import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:json_annotation/json_annotation.dart';

/// LatLng <-> JSON 변환을 위한 JsonConverter
///
/// Freezed 모델에서 LatLng 타입을 JSON으로 직렬화/역직렬화하기 위해 사용합니다.
///
/// **사용 예시**:
/// ```dart
/// @freezed
/// class MyModel with _$MyModel {
///   const factory MyModel({
///     @LatLngConverter() LatLng? location,
///   }) = _MyModel;
///
///   factory MyModel.fromJson(Map<String, dynamic> json) =>
///       _$MyModelFromJson(json);
/// }
/// ```
class LatLngConverter implements JsonConverter<LatLng?, Map<String, dynamic>?> {
  const LatLngConverter();

  @override
  LatLng? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    return LatLng(
      (json['latitude'] as num).toDouble(),
      (json['longitude'] as num).toDouble(),
    );
  }

  @override
  Map<String, dynamic>? toJson(LatLng? latLng) {
    if (latLng == null) return null;
    return {'latitude': latLng.latitude, 'longitude': latLng.longitude};
  }
}

/// List&lt;LatLng&gt; <-> JSON 변환 (핀 목록 draft 저장용)
class LatLngListConverter
    implements JsonConverter<List<LatLng>?, List<dynamic>?> {
  const LatLngListConverter();

  @override
  List<LatLng>? fromJson(List<dynamic>? json) {
    if (json == null) return null;
    return [
      for (final item in json.cast<Map<String, dynamic>>())
        LatLng(
          (item['latitude'] as num).toDouble(),
          (item['longitude'] as num).toDouble(),
        ),
    ];
  }

  @override
  List<dynamic>? toJson(List<LatLng>? points) {
    if (points == null) return null;
    return [
      for (final p in points)
        {'latitude': p.latitude, 'longitude': p.longitude},
    ];
  }
}
