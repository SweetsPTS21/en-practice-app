import 'dart:convert';

class AppResolvedRoute {
  const AppResolvedRoute({
    required this.href,
    required this.pathname,
    required this.search,
    required this.fragment,
  });

  final String href;
  final String pathname;
  final String search;
  final String fragment;
}

const supportedAppRoutePatterns = <String>[
  '/home',
  '/dictionary',
  '/dictionary/word/:wordId',
  '/dictionary/review',
  '/dictionary/review/result/:sessionId',
  '/vocabulary/check',
  '/vocabulary-tests',
  '/vocabulary-tests/:testId',
  '/vocabulary-tests/attempts/:attemptId',
  '/vocabulary-tests/history',
  '/ielts',
  '/ielts/test/:testId',
  '/ielts/take/:attemptId',
  '/ielts/result/:attemptId',
  '/writing',
  '/writing/history',
  '/writing/task/:taskId',
  '/writing/task/:taskId/take',
  '/writing/submission/:submissionId',
  '/speaking',
  '/speaking/practice/:id',
  '/speaking/result/:id',
  '/speaking/history',
  '/speaking/conversation/history',
  '/speaking/conversation/:topicId',
  '/speaking/conversation/result/:id',
  '/custom-speaking',
  '/custom-speaking/conversation/:id',
  '/custom-speaking/history',
  '/custom-speaking/result/:id',
  '/weekly-report',
  '/challenges',
  '/notifications',
  '/profile',
  '/leaderboard',
  '/xp-history',
  '/preview',
  '/settings',
];

const learningSessionRoutePatterns = <String>[
  '/dictionary/review',
  '/vocabulary-tests/attempts/:attemptId',
  '/ielts/take/:attemptId',
  '/writing/task/:taskId/take',
  '/speaking/practice/:id',
  '/speaking/conversation/:topicId',
  '/custom-speaking/conversation/:id',
];

const reviewRoutePatterns = <String>[
  '/dictionary/review/result/:sessionId',
  '/ielts/result/:attemptId',
  '/writing/submission/:submissionId',
  '/speaking/result/:id',
  '/speaking/conversation/result/:id',
  '/custom-speaking/result/:id',
];

final _routeAliases = <MapEntry<RegExp, String>>[
  MapEntry(RegExp(r'^/dashboard(?=/|$)', caseSensitive: false), '/home'),
  MapEntry(RegExp(r'^/vocabulary$', caseSensitive: false), '/vocabulary-tests'),
  MapEntry(
    RegExp(r'^/history(?=/|$)', caseSensitive: false),
    '/vocabulary-tests/history',
  ),
  MapEntry(
    RegExp(r'^/review(?=/|$)', caseSensitive: false),
    '/dictionary/review',
  ),
  MapEntry(
    RegExp(r'^/writing/submissions/([^/?#]+)', caseSensitive: false),
    r'/writing/submission/$1',
  ),
  MapEntry(
    RegExp(r'^/writing/tasks/([^/?#]+)$', caseSensitive: false),
    r'/writing/task/$1',
  ),
  MapEntry(
    RegExp(r'^/ielts/attempts/([^/?#]+)', caseSensitive: false),
    r'/ielts/result/$1',
  ),
  MapEntry(
    RegExp(r'^/speaking/attempts/([^/?#]+)', caseSensitive: false),
    r'/speaking/result/$1',
  ),
  MapEntry(
    RegExp(r'^/ielts/tests/([^/?#]+)/resume', caseSensitive: false),
    r'/ielts/test/$1',
  ),
  MapEntry(
    RegExp(r'^/practice/reading/matching-headings', caseSensitive: false),
    '/ielts?mode=mini&skill=READING',
  ),
  MapEntry(
    RegExp(r'^/speaking/daily-prompt/([^/?#]+)', caseSensitive: false),
    '/speaking?mode=quick',
  ),
  MapEntry(
    RegExp(r'^/custom-speaking-conversations/([^/?#]+)', caseSensitive: false),
    r'/custom-speaking/result/$1',
  ),
  MapEntry(
    RegExp(r'^/speaking/conversations/([^/?#]+)', caseSensitive: false),
    r'/speaking/conversation/result/$1',
  ),
  MapEntry(
    RegExp(r'^/speaking/custom/([^/?#]+)', caseSensitive: false),
    r'/custom-speaking/conversation/$1',
  ),
  MapEntry(
    RegExp(r'^/speaking/custom(?=/|$)', caseSensitive: false),
    '/custom-speaking',
  ),
  MapEntry(
    RegExp(r'^/reports/weekly/latest(?=/|$)', caseSensitive: false),
    '/weekly-report',
  ),
  MapEntry(RegExp(r'^/xp/history(?=/|$)', caseSensitive: false), '/xp-history'),
];

AppResolvedRoute? normalizeInternalRoute(String? route) {
  if (route == null) {
    return null;
  }

  final raw = route.trim();
  if (raw.isEmpty) {
    return null;
  }

  final rawUri = Uri.tryParse(raw);
  if (rawUri != null && rawUri.hasScheme) {
    final scheme = rawUri.scheme.toLowerCase();
    if (scheme == 'http' || scheme == 'https') {
      return null;
    }
  }

  final normalizedInput = raw.startsWith('/') ? raw : '/$raw';
  final uri = Uri.parse('https://en-practice.local$normalizedInput');

  var normalizedPathname = uri.path.isEmpty ? '/' : uri.path;
  for (final alias in _routeAliases) {
    normalizedPathname = normalizedPathname.replaceFirstMapped(
      alias.key,
      (match) => _expandRouteAlias(alias.value, match),
    );
  }

  final questionIndex = normalizedPathname.indexOf('?');
  final normalizedSearch = questionIndex >= 0
      ? normalizedPathname.substring(questionIndex)
      : (uri.hasQuery ? '?${uri.query}' : '');
  if (questionIndex >= 0) {
    normalizedPathname = normalizedPathname.substring(0, questionIndex);
  }

  final normalizedFragment = uri.fragment.isEmpty ? '' : '#${uri.fragment}';

  return AppResolvedRoute(
    href: '$normalizedPathname$normalizedSearch$normalizedFragment',
    pathname: normalizedPathname,
    search: normalizedSearch,
    fragment: normalizedFragment,
  );
}

bool isSupportedAppRoute(String? route) {
  final normalized = normalizeInternalRoute(route);
  if (normalized == null) {
    return false;
  }

  return supportedAppRoutePatterns.any(
    (pattern) => matchRoutePattern(normalized.pathname, pattern),
  );
}

bool isLearningSessionRoute(String? route) {
  final normalized = normalizeInternalRoute(route);
  if (normalized == null) {
    return false;
  }

  return learningSessionRoutePatterns.any(
    (pattern) => matchRoutePattern(normalized.pathname, pattern),
  );
}

bool isReviewRoute(String? route) {
  final normalized = normalizeInternalRoute(route);
  if (normalized == null) {
    return false;
  }

  return reviewRoutePatterns.any(
    (pattern) => matchRoutePattern(normalized.pathname, pattern),
  );
}

bool routesMatch(String? routeA, String? routeB) {
  final normalizedA = normalizeInternalRoute(routeA);
  final normalizedB = normalizeInternalRoute(routeB);

  if (normalizedA == null || normalizedB == null) {
    return false;
  }

  return normalizedA.pathname == normalizedB.pathname ||
      normalizedB.pathname.startsWith('${normalizedA.pathname}/');
}

String _expandRouteAlias(String template, Match match) {
  var result = template;
  for (var index = 1; index <= match.groupCount; index += 1) {
    result = result.replaceAll('\$$index', match.group(index) ?? '');
  }
  return result;
}

bool matchRoutePattern(String path, String pattern) {
  final normalizedPath = _normalizeSegments(path);
  final normalizedPattern = _normalizeSegments(pattern);

  if (normalizedPath.length != normalizedPattern.length) {
    return false;
  }

  for (var index = 0; index < normalizedPattern.length; index += 1) {
    final patternSegment = normalizedPattern[index];
    if (patternSegment.startsWith(':')) {
      continue;
    }

    if (patternSegment.toLowerCase() != normalizedPath[index].toLowerCase()) {
      return false;
    }
  }

  return true;
}

List<String> _normalizeSegments(String value) {
  return value
      .split('/')
      .where((segment) => segment.trim().isNotEmpty)
      .map((segment) => Uri.decodeComponent(segment))
      .toList(growable: false);
}

Map<String, dynamic>? sanitizeMetadata(Map<String, dynamic>? metadata) {
  if (metadata == null || metadata.isEmpty) {
    return null;
  }

  final sanitized = <String, dynamic>{};
  for (final entry in metadata.entries) {
    final value = entry.value;
    if (value == null ||
        value is num ||
        value is bool ||
        value is String ||
        value is List ||
        value is Map) {
      sanitized[entry.key] = value;
      continue;
    }

    sanitized[entry.key] = json.decode(json.encode(value.toString()));
  }

  return sanitized.isEmpty ? null : sanitized;
}
