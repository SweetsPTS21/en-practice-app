import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/retention/retention_providers.dart';
import '../../../core/retention/weekly_report_models.dart';

final weeklyReportControllerProvider = FutureProvider.autoDispose<WeeklyReport?>((ref) async {
  final api = ref.watch(weeklyReportApiProvider);
  return api.getLatest();
});
