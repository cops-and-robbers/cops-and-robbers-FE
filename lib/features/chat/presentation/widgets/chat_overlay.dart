import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../providers/chat_provider.dart';
import 'chat_input_bar.dart';
import 'chat_message_list.dart';

/// 채팅 오버레이 위젯
///
/// 게임 화면 하단에 표시되는 채팅 UI입니다.
/// DraggableScrollableSheet로 드래그하여 높이 조절 가능하고,
/// PageView로 전체 채팅 ↔ 팀 채팅을 스와이프 전환합니다.
/// 입력바는 항상 화면 하단 고정 위치에 표시됩니다.
class ChatOverlay extends ConsumerStatefulWidget {
  const ChatOverlay({
    required this.gameId,
    required this.myParticipantId,
    required this.myTeam,
    this.isDarkMode = false,
    super.key,
  });

  final int gameId;
  final int myParticipantId;
  final String myTeam;

  /// 다크 모드 여부 (도둑팀)
  final bool isDarkMode;

  @override
  ConsumerState<ChatOverlay> createState() => _ChatOverlayState();
}

class _ChatOverlayState extends ConsumerState<ChatOverlay> {
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();
  final PageController _pageController = PageController();
  final GlobalKey _inputBarKey = GlobalKey();
  int _currentPage = 0;

  bool _isExpanded = false;
  bool _isCollapsingFromKeyboard = false;
  bool _collapseScheduled = false;
  double _sheetSize = 0;
  double _pointerDy = 0; // 포인터 누적 이동량 (아래 = 양수)
  double _prevKeyboardHeight = 0;

  /// 사용자가 입력바 영역을 실제로 터치했는지 여부.
  /// 다이얼로그 닫힘 등으로 포커스가 프로그래매틱하게 복원될 때
  /// 시트가 올라오는 현상을 방지합니다.
  bool _inputBarTouched = false;

  static const double _snap50 = 0.5;
  static const double _snap75 = 0.75;

  @override
  void initState() {
    super.initState();
    _sheetController.addListener(_onSheetChanged);
  }

  double _minSize = 0.18;
  double _expandedThreshold = 0.25;

  void _onSheetChanged() {
    final size = _sheetController.size;
    _sheetSize = size;
    final expanded = size > _expandedThreshold;
    if (expanded != _isExpanded) {
      setState(() {
        _isExpanded = expanded;
      });
      if (expanded) {
        // 펼쳐질 때: PageView 재생성 후 이전 페이지 복원
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_pageController.hasClients && _currentPage != 0) {
            _pageController.jumpToPage(_currentPage);
          }
        });
      } else {
        FocusScope.of(context).unfocus();
      }
    }
  }

  void _handleSend(String message) {
    final scope = _currentPage == 0 ? 'ALL' : 'TEAM';
    ref
        .read(chatNotifierProvider.notifier)
        .sendMessage(gameId: widget.gameId, message: message, scope: scope);
  }

  void _onInputFocused() {
    // 사용자가 실제로 입력바를 터치한 경우에만 시트 확장.
    // 다이얼로그 닫힘 등으로 포커스가 프로그래매틱하게 복원되면 무시.
    if (!_inputBarTouched) return;
    _inputBarTouched = false;
    if (_sheetController.isAttached && _sheetController.size < _snap50) {
      _sheetController.animateTo(
        _snap50,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  /// 시트 접기 (키보드 닫기 + 시트 최소화)
  ///
  /// 드래그·오버스크롤 등에서 매 프레임 호출될 수 있으므로
  /// [_collapseScheduled] 플래그로 중복 호출을 방지합니다.
  void _collapseSheet() {
    if (_collapseScheduled) return;
    _collapseScheduled = true;
    FocusScope.of(context).unfocus();
    if (_sheetController.isAttached) {
      _sheetController.animateTo(
        _minSize,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
    Future.delayed(
      const Duration(milliseconds: 350),
      () => _collapseScheduled = false,
    );
  }

  @override
  void dispose() {
    _sheetController.removeListener(_onSheetChanged);
    _sheetController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatNotifierProvider);
    final isConnected =
        chatState.connectionState == StompConnectionState.connected;

    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final isKeyboardOpen = keyboardHeight > 0;
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;
    final safeBottomMargin = (bottomPadding > 0 ? bottomPadding : 37.h) + 12.h;
    final isKeyboardClosing =
        _prevKeyboardHeight > 0 && keyboardHeight < _prevKeyboardHeight;
    final bottomMargin = (isKeyboardOpen && !isKeyboardClosing)
        ? keyboardHeight
        : safeBottomMargin;
    final collapsedHeight = 20.h + 8.h + 64.h + safeBottomMargin;
    final expandedMinHeight = 20.h + 42.h + 18.h + 64.h + safeBottomMargin;

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableHeight = constraints.maxHeight;
        _minSize = (collapsedHeight / availableHeight).clamp(0.1, 0.25);
        _expandedThreshold = (expandedMinHeight / availableHeight).clamp(
          0.15,
          0.35,
        );

        // 키보드가 줄어들기 시작하면 시트를 50%로 내리기 시작
        if (isKeyboardClosing && !_isCollapsingFromKeyboard) {
          _isCollapsingFromKeyboard = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_sheetController.isAttached &&
                _sheetController.size > _snap50) {
              _sheetController.animateTo(
                _snap50,
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOut,
              );
            }
          });
        }
        if (!isKeyboardOpen) {
          _isCollapsingFromKeyboard = false;

          // 키보드가 열려있다가 완전히 닫힌 경우 → 시트를 _minSize로 복귀
          // (다이얼로그 등으로 포커스를 잃어 키보드가 닫힌 경우 대응)
          if (_prevKeyboardHeight > 0) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (_sheetController.isAttached &&
                  _sheetController.size > _minSize + 0.01) {
                _sheetController.animateTo(
                  _minSize,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                );
              }
            });
          }
        }
        _prevKeyboardHeight = keyboardHeight;

        // 키보드 열림: 시트 75% 고정, 닫히는 중/후: 기본 minSize
        final effectiveMinSize = (isKeyboardOpen && !_isCollapsingFromKeyboard)
            ? _snap75
            : _minSize;
        final effectiveSnap50 = _snap50;
        final effectiveSnap75 = _snap75;

        return Stack(
          children: [
            if (_isExpanded)
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    FocusScope.of(context).unfocus();
                    if (_sheetController.isAttached) {
                      _sheetController.animateTo(
                        _minSize,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      );
                    }
                  },
                  child: const SizedBox.expand(),
                ),
              ),
            DraggableScrollableSheet(
              controller: _sheetController,
              initialChildSize: effectiveMinSize,
              minChildSize: effectiveMinSize,
              maxChildSize: effectiveSnap75,
              snap: true,
              snapSizes: [
                if (effectiveSnap50 > effectiveMinSize &&
                    effectiveSnap50 < effectiveSnap75)
                  effectiveSnap50,
              ],
              builder: (context, scrollController) {
                return Listener(
                  onPointerDown: (_) => _pointerDy = 0,
                  onPointerMove: (event) {
                    _pointerDy += event.delta.dy;
                    if (!_isExpanded || _pointerDy < 40) return;
                    // 포인터가 입력바 영역에 있는지 확인
                    final box =
                        _inputBarKey.currentContext?.findRenderObject()
                            as RenderBox?;
                    if (box == null) return;
                    final inputBarTop = box.localToGlobal(Offset.zero).dy;
                    if (event.position.dy >= inputBarTop) {
                      _pointerDy = 0; // 중복 호출 방지
                      _collapseSheet();
                    }
                  },
                  child: Container(
                    clipBehavior: Clip.hardEdge,
                    decoration: BoxDecoration(
                      color: widget.isDarkMode
                          ? AppColors.black900
                          : AppColors.black100,
                      borderRadius: BorderRadius.only(
                        topLeft: AppRadius.xl20.topLeft,
                        topRight: AppRadius.xl20.topRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          offset: const Offset(0, -2),
                          blurRadius: 10,
                          color: AppColors.black.withValues(alpha: 0.1),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        SingleChildScrollView(
                          controller: scrollController,
                          physics: const ClampingScrollPhysics(),
                          child: _buildDragHandle(),
                        ),
                        if (_isExpanded)
                          Expanded(
                            child: Column(
                              children: [
                                _buildTitle(),
                                Expanded(
                                  child: PageView(
                                    controller: _pageController,
                                    onPageChanged: (page) {
                                      setState(() => _currentPage = page);
                                    },
                                    children: [
                                      ChatMessageList(
                                        messages: chatState.allScopeMessages,
                                        myParticipantId: widget.myParticipantId,
                                        myTeam: widget.myTeam,
                                        isDarkMode: widget.isDarkMode,
                                        onOverscrollDown: _collapseSheet,
                                      ),
                                      ChatMessageList(
                                        messages: chatState.teamScopeMessages,
                                        myParticipantId: widget.myParticipantId,
                                        myTeam: widget.myTeam,
                                        isDarkMode: widget.isDarkMode,
                                        onOverscrollDown: _collapseSheet,
                                      ),
                                    ],
                                  ),
                                ),
                                _buildPageIndicator(),
                              ],
                            ),
                          )
                        else
                          const Expanded(child: SizedBox.shrink()),
                        Listener(
                          onPointerDown: (_) => _inputBarTouched = true,
                          child: GestureDetector(
                            key: _inputBarKey,
                            child: ChatInputBar(
                              onSend: _handleSend,
                              enabled: isConnected,
                              onFocusGain: _onInputFocused,
                              isDarkMode: widget.isDarkMode,
                            ),
                          ),
                        ),
                        SizedBox(height: bottomMargin),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildDragHandle() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (!_sheetController.isAttached) return;
        final target = _sheetSize > _minSize + 0.01 ? _minSize : _snap50;
        _sheetController.animateTo(
          target,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      },
      child: Padding(
        padding: EdgeInsets.only(top: 12.h, bottom: 4.h),
        child: Center(
          child: Container(
            width: 48.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: widget.isDarkMode
                  ? AppColors.black600
                  : AppColors.black200,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    final title = _currentPage == 0 ? '전체 채팅' : '팀 채팅';
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.horizontal24,
        right: AppSpacing.horizontal24,
        top: AppSpacing.vertical16,
        bottom: AppSpacing.vertical8,
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: widget.isDarkMode
              ? AppTextStyles.robberSubHeading.copyWith(color: AppColors.white)
              : AppTextStyles.subHeading_18.copyWith(color: AppColors.black),
        ),
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(2, (index) {
          final isActive = index == _currentPage;
          return Container(
            width: 6.w,
            height: 6.w,
            margin: EdgeInsets.symmetric(horizontal: 3.w),
            decoration: BoxDecoration(
              color: isActive
                  ? (widget.isDarkMode ? AppColors.green : AppColors.blue)
                  : (widget.isDarkMode
                        ? AppColors.black600
                        : AppColors.black200),
              shape: BoxShape.circle,
            ),
          );
        }),
      ),
    );
  }
}
