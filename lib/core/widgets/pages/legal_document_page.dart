import 'package:cops_and_robbers/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_urls.dart';
import '../../constants/legal_doc.dart';
import '../load_failure_view.dart';
import '../navigation/app_top_bar.dart';

/// 이용약관·개인정보 처리방침 등 법적 문서 열람 페이지
///
/// 본문을 공식 사이트에서 웹뷰로 가져옵니다. 예전에는 `assets/legals/` 의 JSON 을 읽어
/// 위젯으로 그렸는데, 같은 문서가 앱과 웹 두 곳에 있어 사람이 손으로 맞춰야 했고
/// 문구 하나 고치려면 앱 심사를 다시 받아야 했습니다. 일본 사용자가 한국어 약관을
/// 보고 있던 것도 앱에 한국어 JSON 만 들어 있었기 때문입니다.
///
/// 웹 화면은 이 파일이 예전에 그리던 방식을 그대로 재현해 두었습니다. 색·타이포·여백이
/// 같고 기기 폭에 따른 배율도 맞춰 두어서, 앱바까지 합치면 예전 화면과 구분되지 않습니다.
/// 오히려 텍스트 선택과 확대가 되는 만큼 나아진 부분이 있습니다.
///
/// 앱바는 여전히 Flutter 가 그립니다. 웹은 본문만 냅니다.
class LegalDocumentPage extends StatefulWidget {
  const LegalDocumentPage({super.key, required this.title, required this.doc});

  /// 앱바에 표시할 제목
  final String title;

  /// 열어 볼 문서
  ///
  /// 주소는 이 값과 현재 로케일에서 만듭니다. 예전에는 JSON 경로와 외부 링크 주소를
  /// 따로 받아서, 짝이 어긋나도 아무도 못 잡았습니다.
  final LegalDoc doc;

  @override
  State<LegalDocumentPage> createState() => _LegalDocumentPageState();
}

class _LegalDocumentPageState extends State<LegalDocumentPage> {
  WebViewController? _controller;
  late Uri _uri;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Localizations.localeOf 는 initState 에서 못 쓴다. 그래서 여기서 만든다.
    //
    // 앱 안에서 언어를 바꾸면 앱 전체가 다시 그려지면서 이 메서드가 또 불린다.
    // 그때 주소가 달라지므로 같은 화면에서 다시 불러온다.
    final language = Localizations.localeOf(context).languageCode;
    final next = Uri.parse(AppUrls.legalDocument(widget.doc, language));
    if (_controller != null) {
      if (next != _uri) {
        // 곧 build 가 이어지므로 setState 를 부르지 않는다. 여기서 부르면 빌드 도중
        // markNeedsBuild 가 돼서 터진다.
        _uri = next;
        _isLoading = true;
        _hasError = false;
        _controller!.loadRequest(next);
      }
      return;
    }
    _uri = next;

    _controller = WebViewController()
      // 우리 문서에는 스크립트가 한 줄도 없다. 법적 문서 뷰어에 실행 권한을 주지 않는다.
      ..setJavaScriptMode(JavaScriptMode.disabled)
      // 로딩 중 기본 배경이 비쳐 검게 깜빡이는 것을 막는다.
      ..setBackgroundColor(AppColors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) => _settle(),
          // 폰트 같은 하위 리소스 하나가 실패한 것으로는 화면을 덮지 않는다.
          onWebResourceError: (error) {
            if (error.isForMainFrame ?? true) _fail();
          },
          // onHttpError 는 하위 리소스에도 온다. WebResourceRequest 에 프레임 정보가
          // 없어서, 실패한 주소가 문서 자체인지로 가른다. 폰트가 404 나는 것으로
          // 약관 전체를 못 읽게 만들면 안 된다.
          onHttpError: (error) {
            if (error.request?.uri == _uri) _fail();
          },
          onNavigationRequest: _decideNavigation,
        ),
      )
      ..loadRequest(_uri);
  }

  /// 문서 밖으로 나가는 이동을 막는다
  ///
  /// 본문은 우리가 만든 HTML 이고 링크가 없다. 그래도 웹뷰가 다른 곳으로 옮겨 갈 수
  /// 있으면 앱 안에 통제되지 않는 브라우저를 하나 두는 셈이라, 같은 호스트만 허용한다.
  NavigationDecision _decideNavigation(NavigationRequest request) {
    final target = Uri.tryParse(request.url);
    final allowed =
        target != null && target.isScheme('https') && target.host == _uri.host;
    if (allowed) return NavigationDecision.navigate;

    // 막기만 하면 스피너가 영원히 돈다. 공용 와이파이 로그인 페이지로 가로채이는
    // 경우가 여기 걸리는데, 그때 사용자에게는 다시 시도할 방법이 있어야 한다.
    _fail();
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
    _controller?.loadRequest(_uri);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppTopBar(
        title: widget.title,
        onBack: () => Navigator.of(context).pop(),
      ),
      body: SafeArea(child: _buildBody()),
    );
  }

  Widget _buildBody() {
    final controller = _controller;
    if (controller == null) {
      return const Center(child: CircularProgressIndicator());
    }

    // 웹뷰를 트리에서 빼지 않고 위에 덮는다. 빼면 안드로이드에서 플랫폼 뷰가 정리돼
    // 재시도할 때 다시 만들어야 한다.
    return Stack(
      children: [
        WebViewWidget(controller: controller),
        if (_isLoading)
          const Positioned.fill(
            child: ColoredBox(
              color: AppColors.white,
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
        if (_hasError)
          Positioned.fill(
            child: ColoredBox(
              color: AppColors.white,
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
