/// Google Maps 스타일 상수
///
/// 다크/라이트 모드 등 지도 스타일 JSON을 관리합니다.
abstract final class MapStyles {
  /// Google Maps 다크 스타일 JSON
  static const String dark = '''
[
  {"elementType":"geometry","stylers":[{"color":"#242424"}]},
  {"elementType":"labels.icon","stylers":[{"visibility":"off"}]},
  {"elementType":"labels.text.fill","stylers":[{"color":"#9a9a9a"}]},
  {"elementType":"labels.text.stroke","stylers":[{"color":"#242424"}]},
  {"featureType":"administrative","elementType":"geometry","stylers":[{"color":"#757575"}]},
  {"featureType":"landscape.man_made","elementType":"geometry.fill","stylers":[{"color":"#2e2e2e"}]},
  {"featureType":"poi","elementType":"geometry","stylers":[{"color":"#2e2e2e"}]},
  {"featureType":"poi.park","elementType":"geometry","stylers":[{"color":"#263c3f"}]},
  {"featureType":"road","elementType":"geometry.fill","stylers":[{"color":"#4a4a4a"}]},
  {"featureType":"road","elementType":"labels.text.fill","stylers":[{"color":"#9a9a9a"}]},
  {"featureType":"road.arterial","elementType":"geometry","stylers":[{"color":"#555555"}]},
  {"featureType":"road.highway","elementType":"geometry","stylers":[{"color":"#5a5a5a"}]},
  {"featureType":"road.highway","elementType":"geometry.stroke","stylers":[{"color":"#6a6a6a"}]},
  {"featureType":"road.local","elementType":"labels.text.fill","stylers":[{"color":"#7a7a7a"}]},
  {"featureType":"transit","elementType":"geometry","stylers":[{"color":"#354150"}]},
  {"featureType":"water","elementType":"geometry","stylers":[{"color":"#17263c"}]},
  {"featureType":"water","elementType":"labels.text.fill","stylers":[{"color":"#506a8a"}]}
]
''';
}
