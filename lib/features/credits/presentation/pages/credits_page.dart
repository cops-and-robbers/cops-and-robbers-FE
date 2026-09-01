import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../core/constants/app_urls.dart';
import '../../../../core/utils/url_launcher_util.dart';
import '../../../../core/widgets/load_failure_view.dart';
import '../../../../core/widgets/navigation/app_top_bar.dart';

/// 크레딧(만든 사람들) 페이지
///
/// 설정 > 앱 버전 5탭으로 진입하는 히든 페이지. 본문을 공식 사이트에서
/// 웹뷰로 가져옵니다(#519). 예전에는 멤버·사진이 앱에 하드코딩돼 있어
/// 인원이 바뀔 때마다 심사를 다시 받아야 했는데, 이제 정본이 웹에 있어
/// 웹 배포만으로 갱신됩니다. 웹뷰 골격은 법적 문서(LegalDocumentPage)의
/// 검증된 방식을 따르되 크레딧에 맞게 둘이 다릅니다: 화면이 밤 지도라
/// 배경·앱바가 어둡고, 멤버 카드의 소셜 링크는 외부 브라우저로 엽니다.
class CreditsPage extends StatefulWidget {
  const CreditsPage({super.key});

  @override
  State<CreditsPage> createState() => _CreditsPageState();
}

class _CreditsPageState extends State<CreditsPage> {
  /// 웹 크레딧 화면의 지도 타일 색. 로딩 중 배경이 이 색이어야 웹 화면이
  /// 뜰 때 이음새 없이 이어집니다 (dongsim-web lib/credits/embed-html.ts).
  static const Color _nightMap = Color(0xFF22262B);

  static final Uri _uri = Uri.parse(AppUrls.credits);

  late final WebViewController _controller;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      // 웹 크레딧의 연출은 전부 CSS 다. 실행 권한을 주지 않는다.
      ..setJavaScriptMode(JavaScriptMode.disabled)
      ..setBackgroundColor(_nightMap)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) => _settle(),
          // 폰트·사진 하나가 실패한 것으로는 화면을 덮지 않는다.
          onWebResourceError: (error) {
            if (error.isForMainFrame ?? true) _fail();
          },
          // onHttpError 는 하위 리소스에도 온다. 실패한 주소가 문서 자체인지로 가른다.
          onHttpError: (error) {
            if (error.request?.uri == _uri) _fail();
          },
          onNavigationRequest: _decideNavigation,
        ),
      )
      ..loadRequest(_uri);
  }

  /// 소셜 링크는 외부 브라우저로, 그 밖의 이탈은 막는다
  ///
  /// 법적 문서와 달리 크레딧에는 멤버의 GitHub·인스타그램 링크가 있고,
  /// 그건 앱 안 웹뷰가 아니라 브라우저에서 열리는 게 맞다. 다만 로딩 중의
  /// 타 호스트 이동은 링크 탭이 아니라 공용 와이파이 포털 같은 가로채기라
  /// 실패로 처리해 재시도 화면을 보여준다.
  NavigationDecision _decideNavigation(NavigationRequest request) {
    final target = Uri.tryParse(request.url);
    if (target != null &&
        target.isScheme('https') &&
        target.host == _uri.host) {
      return NavigationDecision.navigate;
    }
    if (_isLoading) {
      _fail();
    } else if (target != null && target.isScheme('https')) {
      launchExternalUrl(request.url);
    }
    return NavigationDecision.prevent;
  }

  void _settle() {
    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  void _fail() {
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _hasError = true;
    });
  }

  void _retry() {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    _controller.loadRequest(_uri);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _nightMap,
      // 제목은 웹 화면이 로고로 그린다. 앱바는 뒤로가기만 어두운 톤으로 얹는다.
      appBar: AppTopBar(
        backgroundColor: _nightMap,
        isDarkMode: true,
        onBack: () => Navigator.of(context).pop(),
      ),
      body: SafeArea(child: _buildBody()),
    );
  }

  Widget _buildBody() {
    // 웹뷰를 트리에서 빼지 않고 위에 덮는다. 빼면 안드로이드에서 플랫폼 뷰가
    // 정리돼 재시도할 때 다시 만들어야 한다.
    return Stack(
      children: [
        WebViewWidget(controller: _controller),
        if (_isLoading)
          const Positioned.fill(
            child: ColoredBox(
              color: _nightMap,
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
        if (_hasError)
          Positioned.fill(
            child: ColoredBox(
              color: _nightMap,
              child: LoadFailureView(
                message: AppLocalizations.of(
                  context,
                ).errorLegalDocumentLoadFailed,
                onRetry: _retry,
              ),
            ),
          ),
      ],
    );
  }
}
