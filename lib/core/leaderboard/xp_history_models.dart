import '../network/json_helpers.dart';
import 'leaderboard_models.dart';

class XpHistoryEntry {
  const XpHistoryEntry({
    required this.id,
    required this.source,
    required this.description,
    required this.xp,
    required this.earnedAt,
  });

  final String id;
  final String source;
  final String description;
  final int xp;
  final DateTime earnedAt;

  factory XpHistoryEntry.fromJson(Map<String, dynamic> json) {
    return XpHistoryEntry(
      id: json['id']?.toString() ?? '',
      source: json['source']?.toString() ?? 'XP',
      description: json['description']?.toString() ?? '',
      xp: _readInt(json['xp']) ?? 0,
      earnedAt:
          DateTime.tryParse(json['earnedAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}

class XpHistoryResponse {
  const XpHistoryResponse({
    required this.totalXP,
    required this.weeklyXP,
    required this.history,
    required this.page,
  });

  final int totalXP;
  final int weeklyXP;
  final List<XpHistoryEntry> history;
  final LeaderboardPageInfo<XpHistoryEntry> page;

  bool get hasMore => page.hasNextPage;

  XpHistoryResponse append(XpHistoryResponse next) {
    return XpHistoryResponse(
      totalXP: next.totalXP,
      weeklyXP: next.weeklyXP,
      history: <XpHistoryEntry>[...history, ...next.history],
      page: LeaderboardPageInfo<XpHistoryEntry>(
        page: next.page.page,
        size: next.page.size,
        totalElements: next.page.totalElements,
        totalPages: next.page.totalPages,
        items: <XpHistoryEntry>[...page.items, ...next.page.items],
      ),
    );
  }

  factory XpHistoryResponse.fromJson(Map<String, dynamic> json) {
    final rawHistory = json['history'];
    final parsedPage = json['page'] is Map
        ? LeaderboardPageInfo<XpHistoryEntry>.fromJson(
            jsonMap(json['page']),
            itemBuilder: XpHistoryEntry.fromJson,
          )
        : const LeaderboardPageInfo<XpHistoryEntry>(
            page: 0,
            size: 0,
            totalElements: 0,
            totalPages: 0,
            items: <XpHistoryEntry>[],
          );
    final history = rawHistory is List
        ? rawHistory
              .whereType<Object?>()
              .map((item) => XpHistoryEntry.fromJson(jsonMap(item)))
              .toList(growable: false)
        : parsedPage.items;
    return XpHistoryResponse(
      totalXP: _readInt(json['totalXP']) ?? 0,
      weeklyXP: _readInt(json['weeklyXP']) ?? 0,
      history: history,
      page: LeaderboardPageInfo<XpHistoryEntry>(
        page: parsedPage.page,
        size: parsedPage.size,
        totalElements: parsedPage.totalElements,
        totalPages: parsedPage.totalPages,
        items: history,
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
