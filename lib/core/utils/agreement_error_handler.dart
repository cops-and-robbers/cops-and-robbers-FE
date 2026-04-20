import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/presentation/providers/auth_provider.dart';
import '../constants/app_colors.dart';
import '../errors/app_exception.dart';
import '../network/api_error_response.dart';
import '../widgets/snackbars/app_snackbar.dart';

/// 백엔드가 RFC 7807 응답으로 내려주는 "필수 약관 미동의" 에러의 title 문자열.
///
/// `POST /api/games`, `POST /api/games/join` 등 필수 약관 동의가 선행되어야 하는
/// 엔드포인트에서 사용자가 미동의 상태로 호출했을 때 백엔드가 400과 함께 내려줍니다.
const String _requiredTermsErrorTitle = '필수 약관 미동의';

/// 에러에서 RFC 7807 응답을 추출합니다.
///
/// [AppException]의 `originalException`에서 DioException을 꺼내는 경우와
/// DioException을 직접 캐치한 경우(home_page `_joinRoom`) 모두 대응합니다.
ApiErrorResponse? _extractApiError(Object? error) {
  if (error is AppException && error.originalException is DioException) {
    return ApiErrorResponse.tryParse(
      (error.originalException as DioException).response?.data,
    );
  }
  if (error is DioException) {
    return ApiErrorResponse.tryParse(error.response?.data);
  }
  return null;
}

/// "필수 약관 미동의" 에러인지 판별합니다.
///
/// 백엔드의 RFC 7807 응답 `title`이 `"필수 약관 미동의"`인 경우 true를 반환합니다.
bool isRequiredTermsMissingError(Object? error) {
  final api = _extractApiError(error);
  return api?.title == _requiredTermsErrorTitle;
}

/// 에러가 "필수 약관 미동의"면 스낵바 + 상태 변경으로 `/agreement` 리디렉트를 수행합니다.
///
/// 처리한 경우 true, 아닌 경우 false를 반환합니다.
/// 호출부는 false일 때만 자신의 에러 처리(기본 스낵바 등)를 계속 진행하면 됩니다.
///
/// **동작**:
/// - 백엔드 `detail` 문구 그대로 스낵바 표시
/// - [AuthNotifier.markNeedsAgreement] 호출 → `requiresAgreement=true` 변경
/// - `_GoRouterRefreshNotifier`가 감지 → `app_router.dart` redirect step 2에서
///   `/agreement`로 자동 이동
bool handleRequiredTermsErrorIfNeeded({
  required BuildContext context,
  required WidgetRef ref,
  required Object? error,
}) {
  final api = _extractApiError(error);
  if (api?.title != _requiredTermsErrorTitle) return false;

  AppSnackbar.show(
    context,
    message: api!.detail,
    backgroundColor: AppColors.red,
  );
  ref.read(authNotifierProvider.notifier).markNeedsAgreement();
  return true;
}
