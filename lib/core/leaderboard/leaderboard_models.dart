import '../network/json_helpers.dart';

enum LeaderboardPeriod {
  weekly('WEEKLY', 'This week'),
  monthly('MONTHLY', 'This month'),
  allTime('ALL_TIME', 'All time');

  const LeaderboardPeriod(this.apiValue, this.label);

  final String apiValue;
  final String label;

  static LeaderboardPeriod fromValue(String? value) {
    return values.firstWhere(
      (item) => item.apiValue == value,
      orElse: () => LeaderboardPeriod.weekly,
    );
  }
}

enum LeaderboardScope {
  global('GLOBAL', 'Global'),
  byTargetBand('BY_TARGET_BAND', 'Target band');

  const LeaderboardScope(this.apiValue, this.label);

  final String apiValue;
  final String label;

  static LeaderboardScope fromValue(String? value) {
    return values.firstWhere(
      (item) => item.apiValue == value,
      orElse: () => LeaderboardScope.global,
    );
  }
}

class LeaderboardEntry {
  const LeaderboardEntry({
    required this.rank,
    required this.userId,
    required this.displayName,
    required this.xp,
    required this.currentStreak,
    this.avatarUrl,
    this.targetBand,
    this.rankChange = 0,
    this.rankChangeDirection = 'STABLE',
  });

  final int rank;
  final String userId;
  final String displayName;
  final String? avatarUrl;
  final double? targetBand;
  final int xp;
  final int currentStreak;
  final int rankChange;
  final String rankChangeDirection;

  bool get isRising => rankChangeDirection.toUpperCase() == 'UP';
  bool get isFalling => rankChangeDirection.toUpperCase() == 'DOWN';

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      rank: _readInt(json['rank']) ?? 0,
      userId: json['userId']?.toString() ?? '',
      displayName: json['displayName']?.toString() ?? 'Learner',
      avatarUrl: _readString(json['avatarUrl']),
      targetBand: _readDouble(json['targetBand']),
      xp: _readInt(json['xp']) ?? 0,
      currentStreak: _readInt(json['currentStreak']) ?? 0,
      rankChange: _readInt(json['rankChange']) ?? 0,
      rankChangeDirection: json['rankChangeDirection']?.toString() ?? 'STABLE',
    );
  }
}

class MyRankSummary {
  const MyRankSummary({
    required this.rank,
    required this.totalParticipants,
    required this.xp,
    required this.xpToNextRank,
    this.rankChange = 0,
    this.rankChangeDirection = 'STABLE',
  });

  final int rank;
  final int totalParticipants;
  final int xp;
  final int xpToNextRank;
  final int rankChange;
  final String rankChangeDirection;

  bool get isRising => rankChangeDirection.toUpperCase() == 'UP';
  bool get isFalling => rankChangeDirection.toUpperCase() == 'DOWN';

  factory MyRankSummary.fromJson(Map<String, dynamic> json) {
    return MyRankSummary(
      rank: _readInt(json['rank']) ?? 0,
      totalParticipants: _readInt(json['totalParticipants']) ?? 0,
      xp: _readInt(json['xp']) ?? 0,
      xpToNextRank: _readInt(json['xpToNextRank']) ?? 0,
      rankChange: _readInt(json['rankChange']) ?? 0,
      rankChangeDirection: json['rankChangeDirection']?.toString() ?? 'STABLE',
    );
  }
}

class LeaderboardPageInfo<T> {
  const LeaderboardPageInfo({
    required this.page,
    required this.size,
    required this.totalElements,
    required this.totalPages,
    required this.items,
  });

  final int page;
  final int size;
  final int totalElements;
  final int totalPages;
  final List<T> items;

  bool get hasNextPage => page + 1 < totalPages;

  factory LeaderboardPageInfo.fromJson(
    Map<String, dynamic> json, {
    required T Function(Map<String, dynamic>) itemBuilder,
  }) {
    final rawItems = json['items'];
    return LeaderboardPageInfo<T>(
      page: _readInt(json['page']) ?? 0,
      size: _readInt(json['size']) ?? 0,
      totalElements: _readInt(json['totalElements']) ?? 0,
      totalPages: _readInt(json['totalPages']) ?? 0,
      items: rawItems is List
          ? rawItems
                .whereType<Object?>()
                .map((item) => itemBuilder(jsonMap(item)))
                .toList(growable: false)
          : <T>[],
    );
  }
}

class LeaderboardSummaryResponse {
  const LeaderboardSummaryResponse({
    required this.period,
    required this.topThree,
    this.myRank,
  });

  final LeaderboardPeriod period;
  final MyRankSummary? myRank;
  final List<LeaderboardEntry> topThree;

  factory LeaderboardSummaryResponse.fromJson(Map<String, dynamic> json) {
    final rawTopThree = json['topThree'];
    return LeaderboardSummaryResponse(
      period: LeaderboardPeriod.fromValue(json['period']?.toString()),
      myRank: json['myRank'] is Map
          ? MyRankSummary.fromJson(jsonMap(json['myRank']))
          : null,
      topThree: rawTopThree is List
          ? rawTopThree
                .whereType<Object?>()
                .map((item) => LeaderboardEntry.fromJson(jsonMap(item)))
                .toList(growable: false)
          : const <LeaderboardEntry>[],
    );
  }
}

class LeaderboardResponse {
  const LeaderboardResponse({
    required this.topUsers,
    required this.page,
    this.myRank,
  });

  final MyRankSummary? myRank;
  final List<LeaderboardEntry> topUsers;
  final LeaderboardPageInfo<LeaderboardEntry> page;

  bool get hasMore => page.hasNextPage;

  LeaderboardResponse append(LeaderboardResponse next) {
    return LeaderboardResponse(
      myRank: next.myRank ?? myRank,
      topUsers: <LeaderboardEntry>[...topUsers, ...next.topUsers],
      page: LeaderboardPageInfo<LeaderboardEntry>(
        page: next.page.page,
        size: next.page.size,
        totalElements: next.page.totalElements,
        totalPages: next.page.totalPages,
        items: <LeaderboardEntry>[...page.items, ...next.page.items],
      ),
    );
  }

  factory LeaderboardResponse.fromJson(Map<String, dynamic> json) {
    final parsedPage = json['page'] is Map
        ? LeaderboardPageInfo<LeaderboardEntry>.fromJson(
            jsonMap(json['page']),
            itemBuilder: LeaderboardEntry.fromJson,
          )
        : const LeaderboardPageInfo<LeaderboardEntry>(
            page: 0,
            size: 0,
            totalElements: 0,
            totalPages: 0,
            items: <LeaderboardEntry>[],
          );
    final rawTopUsers = json['topUsers'];
    final topUsers = rawTopUsers is List
        ? rawTopUsers
              .whereType<Object?>()
              .map((item) => LeaderboardEntry.fromJson(jsonMap(item)))
              .toList(growable: false)
        : parsedPage.items;

    return LeaderboardResponse(
      myRank: json['myRank'] is Map
          ? MyRankSummary.fromJson(jsonMap(json['myRank']))
          : null,
      topUsers: topUsers,
      page: LeaderboardPageInfo<LeaderboardEntry>(
        page: parsedPage.page,
        size: parsedPage.size,
        totalElements: parsedPage.totalElements,
        totalPages: parsedPage.totalPages,
        items: topUsers,
      ),
    );
  }
}

int? _readInt(Object? value) {
  return switch (value) {
    int value => value,
    num value => value.toInt(),
    String value => int.tryParse(value),
    _ => null,
  };
}

double? _readDouble(Object? value) {
  return switch (value) {
    double value => value,
    num value => value.toDouble(),
    String value => double.tryParse(value),
    _ => null,
  };
}

String? _readString(Object? value) {
  final trimmed = value?.toString().trim();
  if (trimmed == null || trimmed.isEmpty) {
    return null;
  }
  return trimmed;
}
