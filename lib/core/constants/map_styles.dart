/// Google Maps 스타일 상수
///
/// 다크/라이트 모드 등 지도 스타일 JSON을 관리합니다.
abstract final class MapStyles {
  /// 도둑 팀 지도 스타일 — 야간 도시 컨셉, 공원 등 가독성 확보
  static const String dark = '''
[
  {"elementType":"geometry","stylers":[{"color":"#1a1a2e"}]},
  {"elementType":"labels.icon","stylers":[{"visibility":"off"}]},
  {"elementType":"labels.text.fill","stylers":[{"color":"#8a9ba8"}]},
  {"elementType":"labels.text.stroke","stylers":[{"color":"#1a1a2e"}]},
  {"featureType":"administrative","elementType":"geometry","stylers":[{"color":"#4a5568"}]},
  {"featureType":"administrative.locality","elementType":"labels.text.fill","stylers":[{"color":"#a0aec0"}]},
  {"featureType":"landscape.man_made","elementType":"geometry.fill","stylers":[{"color":"#2d2d44"}]},
  {"featureType":"landscape.natural","elementType":"geometry","stylers":[{"color":"#1a2d1a"}]},
  {"featureType":"poi","elementType":"geometry","stylers":[{"color":"#252540"}]},
  {"featureType":"poi.park","elementType":"geometry","stylers":[{"color":"#1a3320"}]},
  {"featureType":"poi.park","elementType":"labels.text.fill","stylers":[{"color":"#3d7a4f"}]},
  {"featureType":"road","elementType":"geometry.fill","stylers":[{"color":"#3a3a5c"}]},
  {"featureType":"road","elementType":"labels.text.fill","stylers":[{"color":"#8a9ba8"}]},
  {"featureType":"road.arterial","elementType":"geometry","stylers":[{"color":"#44445e"}]},
  {"featureType":"road.highway","elementType":"geometry","stylers":[{"color":"#4a4a70"}]},
  {"featureType":"road.highway","elementType":"geometry.stroke","stylers":[{"color":"#5a5a80"}]},
  {"featureType":"road.local","elementType":"labels.text.fill","stylers":[{"color":"#6a7a88"}]},
  {"featureType":"transit","elementType":"geometry","stylers":[{"color":"#2a3548"}]},
  {"featureType":"water","elementType":"geometry","stylers":[{"color":"#0d1b2a"}]},
  {"featureType":"water","elementType":"labels.text.fill","stylers":[{"color":"#3a5a78"}]}
]
''';
}
