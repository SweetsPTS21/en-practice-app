import '../navigation/app_route_contract.dart';
import 'recommendation_surface.dart';

enum RecommendationFeedbackAction {
  click('CLICK'),
  dismiss('DISMISS'),
  snooze('SNOOZE');

  const RecommendationFeedbackAction(this.value);

  final String value;
}

class RecommendationFeedbackRequest {
  const RecommendationFeedbackRequest({
    required this.action,
    required this.sourceSurface,
    this.snoozeUntil,
    this.route,
    this.metadata,
  });

  final RecommendationFeedbackAction action;
  final RecommendationSurface sourceSurface;
  final DateTime? snoozeUntil;
  final String? route;
  final Map<String, dynamic>? metadata;

  Map<String, dynamic> toJson() {
    return {
      'action': action.value,
      'sourceSurface': sourceSurface.value,
      'snoozeUntil': snoozeUntil?.toUtc().toIso8601String(),
      'route': route,
      'metadata': sanitizeMetadata(metadata),
    };
  }
}
