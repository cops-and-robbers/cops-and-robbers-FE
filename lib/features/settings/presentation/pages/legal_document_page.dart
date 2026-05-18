import 'dart:convert';

import 'package:cops_and_robbers/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacing_and_radius.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/utils/url_launcher_util.dart';
import '../../../../core/widgets/buttons/previous_button.dart';

/// 이용약관/개인정보처리방침 등 법적 문서 열람 페이지
///
/// assets/legals/ 디렉토리의 JSON 파일을 로드하여 표시합니다.
/// [assetPath]로 JSON 파일 경로를, [title]로 앱바 제목을 지정합니다.
class LegalDocumentPage extends StatefulWidget {
  const LegalDocumentPage({
    super.key,
    required this.title,
    required this.assetPath,
    this.externalUrl,
  });

  /// 앱바에 표시할 제목
  final String title;

  /// JSON 파일 경로 (예: 'assets/legals/terms_of_service.json')
  final String assetPath;

  /// 외부 링크 URL (앱바 우측 버튼용, null이면 버튼 숨김)
  final String? externalUrl;

  @override
  State<LegalDocumentPage> createState() => _LegalDocumentPageState();
}

class _LegalDocumentPageState extends State<LegalDocumentPage> {
  Map<String, dynamic>? _document;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDocument();
  }

  Future<void> _loadDocument() async {
    try {
      final jsonString = await rootBundle.loadString(widget.assetPath);
      final data = jsonDecode(jsonString) as Map<String, dynamic>;
      if (mounted) {
        setState(() {
          _document = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('[LegalDocumentPage] JSON 로드 실패: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: PreviousButton(onPressed: () => Navigator.of(context).pop()),
        centerTitle: true,
        title: Text(
          widget.title,
          style: AppTextStyles.heading_20.copyWith(color: AppColors.black),
        ),
        actions: [
          if (widget.externalUrl != null)
            Padding(
              padding: EdgeInsets.only(right: 6.w),
              child: IconButton(
                onPressed: () => launchExternalUrl(widget.externalUrl!),
                icon: SvgPicture.asset(
                  'assets/icons/icon_link.svg',
                  width: 24.w,
                  height: 24.w,
                  colorFilter: ColorFilter.mode(
                    AppColors.black600,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _document == null
            ? Center(
                child: Text(
                  AppLocalizations.of(context).settings_legalDocumentPage_L105,
                  style: AppTextStyles.paragraph_14.copyWith(
                    color: AppColors.black600,
                  ),
                ),
              )
            : SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.horizontal24,
                  vertical: AppSpacing.vertical16,
                ),
                child: _buildSections(),
              ),
      ),
    );
  }

  Widget _buildSections() {
    final sections = (_document!['sections'] as List<dynamic>?) ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 비-ko 로케일 전용 고지문 배너 (ko에서는 빈 문자열 → 미표시)
        _buildKoreanOnlyNotice(),
        for (int i = 0; i < sections.length; i++) ...[
          if (i > 0) SizedBox(height: 24.h),
          _buildSection(sections[i] as Map<String, dynamic>),
        ],
        // 안드로이드 제스처 네비게이션 바와 마지막 본문이 겹치지 않도록 여백 확보
        SizedBox(height: AppSpacing.vertical64),
      ],
    );
  }

  /// 한국어 원본만 제공한다는 고지문 배너
  ///
  /// ARB의 [legalDocumentKoreanOnlyNotice]가 빈 문자열인 로케일(ko)은 미표시.
  /// en/ja 등 번역되지 않은 로케일 사용자에게 원본 언어와 법적 효력을 안내.
  Widget _buildKoreanOnlyNotice() {
    final notice = AppLocalizations.of(context).legalDocumentKoreanOnlyNotice;
    if (notice.isEmpty) return const SizedBox.shrink();
    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.vertical16),
      padding: AppPadding.all16,
      decoration: BoxDecoration(
        color: AppColors.black100,
        borderRadius: AppRadius.large,
      ),
      child: Text(
        notice,
        style: AppTextStyles.tag_12.copyWith(
          color: AppColors.black800,
          height: 1.4,
        ),
      ),
    );
  }

  Widget _buildSection(Map<String, dynamic> section) {
    final heading = section['heading'] as String? ?? '';
    final content = section['content'] as String? ?? '';
    final items = (section['items'] as List<dynamic>?) ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 조항 제목
        if (heading.isNotEmpty) ...[
          Text(
            heading,
            style: AppTextStyles.paragraph14Semibold.copyWith(
              color: AppColors.black,
            ),
          ),
          SizedBox(height: 8.h),
        ],

        // 본문
        if (content.isNotEmpty)
          Text(
            content,
            style: AppTextStyles.tag_12.copyWith(
              color: AppColors.black800,
              height: 1.4,
            ),
          ),

        // 항목 목록
        if (items.isNotEmpty) ...[
          if (content.isNotEmpty) SizedBox(height: 8.h),
          for (final item in items) _buildItem(item as Map<String, dynamic>),
        ],
      ],
    );
  }

  Widget _buildItem(Map<String, dynamic> item) {
    final text = item['text'] as String? ?? '';
    final subItems = (item['subItems'] as List<dynamic>?) ?? [];

    return Padding(
      padding: EdgeInsets.only(top: 4.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 항목 텍스트
          Text(
            text,
            style: AppTextStyles.tag_12.copyWith(
              color: AppColors.black800,
              height: 1.4,
            ),
          ),

          // 하위 항목
          if (subItems.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(left: 16.w, top: 4.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final subItem in subItems)
                    Padding(
                      padding: EdgeInsets.only(top: 2.h),
                      child: Text(
                        subItem.toString(),
                        style: AppTextStyles.tag_12.copyWith(
                          color: AppColors.black800,
                          height: 1.4,
                        ),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
