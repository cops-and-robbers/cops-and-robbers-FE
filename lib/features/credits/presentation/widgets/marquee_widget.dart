import 'package:flutter/material.dart';

/// 무한 우→좌 마키 스크롤 위젯
///
/// 자식 위젯을 두 벌 복제하여 이음새 없는 루프를 구현한다.
/// [speed]는 초당 이동 픽셀 수 (기본 30.0).
class MarqueeWidget extends StatefulWidget {
  const MarqueeWidget({super.key, required this.child, this.speed = 30.0});

  final Widget child;

  /// 초당 스크롤 픽셀 수
  final double speed;

  @override
  State<MarqueeWidget> createState() => _MarqueeWidgetState();
}

class _MarqueeWidgetState extends State<MarqueeWidget> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    // 레이아웃 완료 후 스크롤 루프 시작
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startScrollLoop();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// 한 카피 너비만큼 애니메이션 → jumpTo(0) 반복
  Future<void> _startScrollLoop() async {
    while (mounted) {
      final maxExtent = _scrollController.position.maxScrollExtent;
      if (maxExtent <= 0) {
        // 콘텐츠가 뷰포트보다 짧으면 대기 후 재시도
        await Future<void>.delayed(const Duration(milliseconds: 500));
        continue;
      }

      // 절반 지점 = 한 카피 너비 (Row에 두 벌 배치)
      final halfExtent = maxExtent / 2;
      final durationMs = (halfExtent / widget.speed * 1000).round();

      await _scrollController.animateTo(
        halfExtent,
        duration: Duration(milliseconds: durationMs),
        curve: Curves.linear,
      );

      if (!mounted) break;

      // 원점으로 점프하여 이음새 없는 루프
      _scrollController.jumpTo(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      // 사용자 수동 스크롤 방지
      physics: const NeverScrollableScrollPhysics(),
      child: Row(children: [widget.child, widget.child]),
    );
  }
}
