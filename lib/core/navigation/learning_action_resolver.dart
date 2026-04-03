import 'app_route_contract.dart';

enum LearningActionKind { internal, external }

class LearningActionInput {
  const LearningActionInput({
    this.actionUrl,
    this.referenceType,
    this.referenceId,
    this.module,
    this.metadata,
    this.defaultRoute = '/home',
  });

  final String? actionUrl;
  final String? referenceType;
  final String? referenceId;
  final String? module;
  final Map<String, dynamic>? metadata;
  final String defaultRoute;
}

class LearningActionTarget {
  const LearningActionTarget({
    required this.kind,
    required this.href,
    required this.usedFallback,
    required this.isLearningSession,
  });

  final LearningActionKind kind;
  final String href;
  final bool usedFallback;
  final bool isLearningSession;
}

const _referenceFallbacks = <String, String>{
  'WRITING_SUBMISSION': '/writing',
  'WRITING_TASK': '/writing',
  'SPEAKING_ATTEMPT': '/speaking',
  'SPEAKING_TOPIC': '/speaking',
  'SPEAKING_CONVERSATION': '/speaking',
  'DAILY_SPEAKING_PROMPT': '/speaking?mode=quick',
  'CUSTOM_SPEAKING_CONVERSATION': '/custom-speaking',
  'IELTS_ATTEMPT': '/ielts',
  'VOCAB_REVIEW': '/dictionary',
  'VOCAB_REVIEW_SESSION': '/dictionary',
  'VOCAB_MICRO_SESSION': '/dictionary/review?mode=micro',
  'VOCABULARY_TEST': '/vocabulary-tests',
  'VOCABULARY_CHECK': '/vocabulary/check',
  'READING_DRILL': '/ielts?mode=mini&skill=READING',
  'DAILY_PLAN_ITEM': '/home',
  'STREAK': '/home',
};

const _moduleFallbacks = <String, String>{
  'WRITING': '/writing',
  'SPEAKING': '/speaking',
  'CUSTOM_SPEAKING': '/custom-speaking',
  'IELTS': '/ielts',
  'VOCABULARY': '/dictionary',
  'DICTIONARY': '/dictionary',
  'VOCAB': '/dictionary',
  'VOCAB_TEST': '/vocabulary-tests',
};

LearningActionTarget resolveLearningActionTarget(LearningActionInput input) {
  final actionUrl = input.actionUrl?.trim();
  if (actionUrl != null &&
      actionUrl.isNotEmpty &&
      RegExp(r'^https?://', caseSensitive: false).hasMatch(actionUrl)) {
    return LearningActionTarget(
      kind: LearningActionKind.external,
      href: actionUrl,
      usedFallback: false,
      isLearningSession: false,
    );
  }

  final detailRoute = _normalizeInternalCandidate(
    _mapActionUrlToDetailRoute(actionUrl),
  );
  if (detailRoute != null) {
    return LearningActionTarget(
      kind: LearningActionKind.internal,
      href: detailRoute,
      usedFallback: false,
      isLearningSession: isLearningSessionRoute(detailRoute),
    );
  }

  final primaryRoute = _normalizeInternalCandidate(actionUrl);
  if (primaryRoute != null) {
    return LearningActionTarget(
      kind: LearningActionKind.internal,
      href: primaryRoute,
      usedFallback: false,
      isLearningSession: isLearningSessionRoute(primaryRoute),
    );
  }

  if (actionUrl != null &&
      RegExp(
        r'^/ielts/tests/[^/?#]+/resume',
        caseSensitive: false,
      ).hasMatch(actionUrl) &&
      input.referenceType == 'IELTS_ATTEMPT' &&
      input.referenceId != null &&
      input.referenceId!.isNotEmpty) {
    final href = '/ielts/take/${input.referenceId}';
    return LearningActionTarget(
      kind: LearningActionKind.internal,
      href: href,
      usedFallback: false,
      isLearningSession: true,
    );
  }

  final fallbackRoute = getFallbackRoute(
    referenceType: input.referenceType,
    module: input.module,
    metadata: input.metadata,
    defaultRoute: input.defaultRoute,
  );

  return LearningActionTarget(
    kind: LearningActionKind.internal,
    href: fallbackRoute,
    usedFallback: true,
    isLearningSession: isLearningSessionRoute(fallbackRoute),
  );
}

String getFallbackRoute({
  String? referenceType,
  String? module,
  Map<String, dynamic>? metadata,
  String defaultRoute = '/home',
}) {
  final metadataFallback = _normalizeInternalCandidate(
    metadata?['fallbackActionUrl']?.toString(),
  );
  if (metadataFallback != null) {
    return metadataFallback;
  }

  final referenceFallback = _normalizeInternalCandidate(
    _referenceFallbacks[referenceType],
  );
  if (referenceFallback != null) {
    return referenceFallback;
  }

  final moduleFallback = _normalizeInternalCandidate(
    _moduleFallbacks[module?.toUpperCase()],
  );
  if (moduleFallback != null) {
    return moduleFallback;
  }

  return _normalizeInternalCandidate(defaultRoute) ?? '/home';
}

String? _normalizeInternalCandidate(String? route) {
  final normalized = normalizeInternalRoute(route);
  if (normalized == null || !isSupportedAppRoute(normalized.href)) {
    return null;
  }

  return normalized.href;
}

String? _mapActionUrlToDetailRoute(String? actionUrl) {
  if (actionUrl == null || actionUrl.isEmpty) {
    return null;
  }

  try {
    final uri = Uri.parse(
      actionUrl.startsWith('http')
          ? actionUrl
          : 'https://en-practice.local$actionUrl',
    );
    final writingTaskMatch = RegExp(
      r'^/writing/tasks/([^/?#]+)(?:/.*)?$',
      caseSensitive: false,
    ).firstMatch(uri.path);
    if (writingTaskMatch != null) {
      return '/writing/task/${writingTaskMatch.group(1)}${_composeUriSuffix(uri)}';
    }

    final ieltsTestMatch = RegExp(
      r'^/ielts/tests/([^/?#]+)(?:/.*)?$',
      caseSensitive: false,
    ).firstMatch(uri.path);
    if (ieltsTestMatch != null) {
      return '/ielts/test/${ieltsTestMatch.group(1)}${_composeUriSuffix(uri)}';
    }

    final speakingTopicMatch = RegExp(
      r'^/speaking/topics/([^/?#]+)(?:/.*)?$',
      caseSensitive: false,
    ).firstMatch(uri.path);
    if (speakingTopicMatch != null) {
      return '/speaking/practice/${speakingTopicMatch.group(1)}${_composeUriSuffix(uri)}';
    }
  } catch (_) {
    return null;
  }

  return null;
}

String _composeUriSuffix(Uri uri) {
  final search = uri.hasQuery ? '?${uri.query}' : '';
  final fragment = uri.fragment.isEmpty ? '' : '#${uri.fragment}';
  return '$search$fragment';
}
