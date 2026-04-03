import 'leaderboard_models.dart';

class LeaderboardQueryParams {
  const LeaderboardQueryParams({
    this.period = LeaderboardPeriod.weekly,
    this.scope = LeaderboardScope.global,
    this.targetBand,
    this.page = 0,
    this.size = 20,
  });

  final LeaderboardPeriod period;
  final LeaderboardScope scope;
  final double? targetBand;
  final int page;
  final int size;

  Map<String, dynamic> toQueryParameters() {
    return {
      'period': period.apiValue,
      'scope': scope.apiValue,
      'targetBand': targetBand,
      'page': page,
      'size': size,
    }..removeWhere((key, value) => value == null);
  }

  LeaderboardQueryParams copyWith({
    LeaderboardPeriod? period,
    LeaderboardScope? scope,
    double? targetBand,
    bool clearTargetBand = false,
    int? page,
    int? size,
  }) {
    return LeaderboardQueryParams(
      period: period ?? this.period,
      scope: scope ?? this.scope,
      targetBand: clearTargetBand ? null : (targetBand ?? this.targetBand),
      page: page ?? this.page,
      size: size ?? this.size,
    );
  }
}
