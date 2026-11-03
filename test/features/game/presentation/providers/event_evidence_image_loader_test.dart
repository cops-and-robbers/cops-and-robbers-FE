import 'dart:io';

import 'package:cops_and_robbers/features/game/presentation/providers/event_evidence_provider.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// 실제 HTTP와 이미지 디코드를 거쳐 비율을 읽는지 본다. 네트워크 경계만 로컬 서버로 대신한다.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late HttpServer server;
  late List<int> photo;

  setUp(() async {
    // 테스트 바인딩은 모든 HTTP를 400으로 막는다. 실제 요청이 로컬 서버까지 가게 푼다
    HttpOverrides.global = null;
    photo = await File('assets/events/evidence1.png').readAsBytes();
  });

  Future<void> serve(WidgetTester tester, void Function(HttpRequest) handle) =>
      tester
          .runAsync(() async {
            server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
            server.listen(handle);
          })
          .then((_) {});

  String url(String path) => 'http://127.0.0.1:${server.port}/$path';

  Future<double?> load(WidgetTester tester, String target) async {
    final result = await tester.runAsync(
      () => const EventEvidenceImageLoader().aspectRatioOf(target),
    );
    await tester.runAsync(() => server.close(force: true));
    PaintingBinding.instance.imageCache.clear();
    return result;
  }

  testWidgets('reads_aspect_ratio_when_photo_downloads', (tester) async {
    await serve(tester, (request) {
      request.response.headers.contentType = ContentType('image', 'png');
      request.response.add(photo);
      request.response.close();
    });

    final ratio = await load(tester, url('a.png'));

    expect(ratio, closeTo(941 / 1672, 0.001));
    expect(tester.takeException(), isNull);
  });

  testWidgets('returns_null_without_error_report_when_server_rejects', (
    tester,
  ) async {
    await serve(tester, (request) {
      request.response.statusCode = HttpStatus.notFound;
      request.response.close();
    });

    final ratio = await load(tester, url('missing.png'));

    expect(ratio, isNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets('returns_null_without_error_report_when_file_is_not_an_image', (
    tester,
  ) async {
    await serve(tester, (request) {
      request.response.add(Uint8List.fromList([1, 2, 3, 4]));
      request.response.close();
    });

    final ratio = await load(tester, url('broken.png'));

    expect(ratio, isNull);
    expect(tester.takeException(), isNull);
  });
}
