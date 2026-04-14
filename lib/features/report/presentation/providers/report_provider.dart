import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/dio_client.dart';
import '../../data/datasources/report_remote_datasource.dart';
import '../../data/repositories/report_repository_impl.dart';
import '../../domain/repositories/report_repository.dart';

part 'report_provider.g.dart';

// ============================================================================
// Data Layer Providers
// ============================================================================

/// ReportRemoteDataSource Provider (Retrofit)
@riverpod
ReportRemoteDataSource reportRemoteDataSource(Ref ref) {
  final dio = ref.watch(dioProvider);
  return ReportRemoteDataSource(dio);
}

// ============================================================================
// Domain Layer Providers
// ============================================================================

/// ReportRepository Provider
@riverpod
ReportRepository reportRepository(Ref ref) {
  return ReportRepositoryImpl(ref.watch(reportRemoteDataSourceProvider));
}
