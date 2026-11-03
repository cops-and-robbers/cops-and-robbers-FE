/// 이벤트 증거 사진 한 장.
///
/// [url]이 없으면 앱에 든 [assetPath]를 보여 준다. 받지 못했을 때도 이 사진으로 대신한다.
class EventEvidencePhoto {
  const EventEvidencePhoto({required this.assetPath, this.url});

  final String assetPath;
  final String? url;

  EventEvidencePhoto get bundled => EventEvidencePhoto(assetPath: assetPath);
}

/// 한 판에서 쓰는 증거 사진 묶음.
class EventEvidence {
  const EventEvidence({required this.photos, required this.aspectRatio});

  static const double bundledAspectRatio = 9 / 16;

  /// 원격으로 쓸 수 있는 사진 수.
  static const int maxPhotos = 3;

  /// 앱에는 사진이 2장뿐이라 3번 칸을 못 받으면 2번 사진으로 대신한다.
  static const List<String> _assetPaths = [
    'assets/events/evidence1.png',
    'assets/events/evidence2.png',
    'assets/events/evidence2.png',
  ];

  /// 앱에 든 사진. 주소가 없거나 Remote Config를 못 읽었을 때 쓴다.
  static const EventEvidence bundled = EventEvidence(
    photos: [
      EventEvidencePhoto(assetPath: 'assets/events/evidence1.png'),
      EventEvidencePhoto(assetPath: 'assets/events/evidence2.png'),
    ],
    aspectRatio: bundledAspectRatio,
  );

  /// 주소 목록으로 묶음을 만든다. 비율은 사진을 받기 전까지 앱 사진의 비율을 쓴다.
  factory EventEvidence.fromUrls(List<String> urls) {
    if (urls.isEmpty) return bundled;
    return EventEvidence(
      photos: [
        for (var i = 0; i < urls.length && i < maxPhotos; i++)
          EventEvidencePhoto(assetPath: _assetPaths[i], url: urls[i]),
      ],
      aspectRatio: bundledAspectRatio,
    );
  }

  final List<EventEvidencePhoto> photos;

  /// 가로/세로. 사진들은 비율이 같다고 보고 1번 사진 값을 쓴다.
  final double aspectRatio;

  int get count => photos.length;

  /// 체포 순서(1부터)에 맞는 사진. 사진 수를 넘으면 마지막 사진을 보여 준다.
  EventEvidencePhoto photoFor(int order) =>
      photos[order.clamp(1, count).toInt() - 1];
}

/// Remote Config의 주소들을 사진 목록으로 바꾼다.
///
/// 앞에서부터 빈 값을 만나기 전까지가 사진이다. 1번이 비면 앱 사진을 쓴다(빈 목록).
List<String> eventEvidenceUrlsFrom(List<String> values) {
  final urls = <String>[];
  for (final value in values) {
    final url = value.trim();
    if (url.isEmpty) break;
    urls.add(url);
  }
  return urls;
}
