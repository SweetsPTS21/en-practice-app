import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/design/widgets/app_shell.dart';
import '../../core/dictionary/review_models.dart';
import '../../core/navigation/app_route_contract.dart';
import '../../core/theme/page_palettes.dart';
import '../../core/vocabulary_test/vocabulary_test_models.dart';
import '../../features/auth/auth_providers.dart';
import '../../features/auth/models/auth_models.dart';
import '../../features/auth/view/auth_loading_page.dart';
import '../../features/challenges/presentation/weekly_challenge_page.dart';
import '../../features/auth/view/login_page.dart';
import '../../features/dictionary/dictionary_page.dart';
import '../../features/dictionary/presentation/dictionary_review_page.dart';
import '../../features/dictionary/presentation/dictionary_word_detail_page.dart';
import '../../features/home/presentation/home_page.dart';
import '../../features/ielts/ielts_page.dart';
import '../../features/leaderboard/leaderboard_page.dart';
import '../../features/leaderboard/xp_history_page.dart';
import '../../features/learning/learning_session_placeholder_page.dart';
import '../../features/notifications/presentation/notification_inbox_page.dart';
import '../../features/profile/profile_page.dart';
import '../../features/reports/presentation/weekly_report_page.dart';
import '../../features/results/data/result_snapshot_request.dart';
import '../../features/results/presentation/result_journey_page.dart';
import '../../features/settings/settings_page.dart';
import '../../features/shared/route_placeholder_page.dart';
import '../../features/custom_speaking/presentation/custom_speaking_chat_page.dart';
import '../../features/custom_speaking/presentation/custom_speaking_history_page.dart';
import '../../features/custom_speaking/presentation/custom_speaking_page.dart';
import '../../features/speaking/speaking_page.dart';
import '../../features/speaking/presentation/speaking_history_page.dart';
import '../../features/speaking/presentation/speaking_practice_page.dart';
import '../../features/speaking_conversation/presentation/speaking_conversation_history_page.dart';
import '../../features/speaking_conversation/presentation/speaking_conversation_page.dart';
import '../../features/speaking_conversation/presentation/speaking_conversation_result_page.dart';
import '../../features/theme_preview/theme_preview_page.dart';
import '../../features/vocabulary_check/presentation/vocabulary_check_page.dart';
import '../../features/vocabulary_test/presentation/vocabulary_test_attempt_page.dart';
import '../../features/vocabulary_test/presentation/vocabulary_test_history_page.dart';
import '../../features/vocabulary_test/presentation/vocabulary_test_list_page.dart';
import '../../features/vocabulary_test/presentation/vocabulary_test_preview_page.dart';
import '../../features/writing/presentation/writing_history_page.dart';
import '../../features/writing/presentation/writing_task_detail_page.dart';
import '../../features/writing/presentation/writing_task_page.dart';
import '../../features/writing/writing_page.dart';
import '../../core/custom_speaking/custom_speaking_models.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(authControllerProvider);

  return GoRouter(
    initialLocation: '/home',
    refreshListenable: auth,
    redirect: (context, state) {
      final rawLocation = state.uri.toString();
      final normalized = normalizeInternalRoute(rawLocation);
      final normalizedHref = normalized?.href;
      final isLoginRoute = state.matchedLocation == '/login';
      final isLoadingRoute = state.matchedLocation == '/auth-loading';

      if (!isLoginRoute &&
          !isLoadingRoute &&
          normalizedHref != null &&
          normalizedHref != rawLocation &&
          isSupportedAppRoute(normalizedHref)) {
        return normalizedHref;
      }

      if (auth.status == AuthStatus.loading) {
        return isLoadingRoute ? null : '/auth-loading';
      }

      if (!auth.isAuthenticated) {
        if (isLoginRoute) {
          return null;
        }

        final redirectTarget = normalizedHref ?? rawLocation;
        if (redirectTarget == '/' || redirectTarget == '/auth-loading') {
          return '/login';
        }

        return Uri(
          path: '/login',
          queryParameters: <String, String>{'redirect': redirectTarget},
        ).toString();
      }

      if (isLoadingRoute) {
        return '/home';
      }

      if (isLoginRoute) {
        final redirectTarget = state.uri.queryParameters['redirect'];
        return (redirectTarget != null && redirectTarget.isNotEmpty)
            ? redirectTarget
            : '/home';
      }

      if (rawLocation == '/') {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(
        path: '/auth-loading',
        builder: (context, state) => const AuthLoadingPage(),
      ),
      ShellRoute(
        builder: (context, state, child) {
          return AppShell(location: state.uri.path, child: child);
        },
        routes: [
          GoRoute(path: '/home', builder: (context, state) => const HomePage()),
          GoRoute(
            path: '/dictionary',
            builder: (context, state) => const DictionaryPage(),
            routes: [
              GoRoute(
                path: 'word/:wordId',
                builder: (context, state) => DictionaryWordDetailPage(
                  wordId: state.pathParameters['wordId'] ?? '',
                ),
              ),
              GoRoute(
                path: 'review',
                builder: (context, state) {
                  final filterName =
                      state.uri.queryParameters['filter']
                          ?.toLowerCase()
                          .trim() ??
                      'all';
                  final parsedLimit =
                      int.tryParse(state.uri.queryParameters['limit'] ?? '') ??
                      20;
                  final reviewFilter = switch (filterName) {
                    'today' => ReviewFilter.today,
                    'week' => ReviewFilter.week,
                    'month' => ReviewFilter.month,
                    'wrong' => ReviewFilter.wrong,
                    _ => ReviewFilter.all,
                  };
                  return DictionaryReviewPage(
                    filter: reviewFilter,
                    limit: parsedLimit,
                    route: state.uri.toString(),
                  );
                },
                redirect: (context, state) {
                  final normalized = normalizeInternalRoute(
                    state.uri.toString(),
                  );
                  final href = normalized?.href ?? state.uri.toString();
                  return href == state.uri.toString() ? null : href;
                },
                routes: [
                  GoRoute(
                    path: 'result/:sessionId',
                    builder: (context, state) => ResultJourneyPage(
                      request: ResultSnapshotRequest(
                        module: ResultSnapshotModule.vocabulary,
                        referenceId: state.pathParameters['sessionId'] ?? '',
                      ),
                      title: 'Dictionary Review Result',
                      subtitle:
                          'Review your latest dictionary session and choose the next step.',
                      paletteKey: AppPagePaletteKey.dictionary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: '/vocabulary/check',
            builder: (context, state) => const VocabularyCheckPage(),
          ),
          GoRoute(
            path: '/vocabulary-tests',
            builder: (context, state) => const VocabularyTestListPage(),
            routes: [
              GoRoute(
                path: 'history',
                builder: (context, state) => const VocabularyTestHistoryPage(),
              ),
              GoRoute(
                path: ':testId',
                builder: (context, state) => VocabularyTestPreviewPage(
                  testId: state.pathParameters['testId'] ?? '',
                ),
              ),
              GoRoute(
                path: 'attempts/:attemptId',
                builder: (context, state) => VocabularyTestAttemptPage(
                  attemptId: state.pathParameters['attemptId'] ?? '',
                  startResponse: state.extra as StartVocabularyTestResponse?,
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/ielts',
            builder: (context, state) => const IeltsPage(),
            routes: [
              GoRoute(
                path: 'test/:testId',
                builder: (context, state) => const RoutePlaceholderPage(
                  title: 'IELTS Test Detail',
                  subtitle: 'Review the test details before you begin.',
                  paletteKey: AppPagePaletteKey.ielts,
                  highlights: [
                    'Overview of the selected test.',
                    'Entry point before starting the session.',
                  ],
                ),
              ),
              GoRoute(
                path: 'take/:attemptId',
                builder: (context, state) => LearningSessionPlaceholderPage(
                  title: 'IELTS Session',
                  subtitle: 'Continue your IELTS practice session.',
                  route: state.uri.toString(),
                  module: 'IELTS',
                  paletteKey: AppPagePaletteKey.ielts,
                ),
              ),
              GoRoute(
                path: 'result/:attemptId',
                builder: (context, state) => ResultJourneyPage(
                  request: ResultSnapshotRequest(
                    module: ResultSnapshotModule.ielts,
                    referenceId: state.pathParameters['attemptId'] ?? '',
                  ),
                  title: 'IELTS Result',
                  subtitle: 'See your IELTS result and decide what to do next.',
                  paletteKey: AppPagePaletteKey.ielts,
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/writing',
            builder: (context, state) => const WritingPage(),
            routes: [
              GoRoute(
                path: 'history',
                builder: (context, state) => const WritingHistoryPage(),
              ),
              GoRoute(
                path: 'task/:taskId',
                builder: (context, state) => WritingTaskDetailPage(
                  taskId: state.pathParameters['taskId'] ?? '',
                ),
                routes: [
                  GoRoute(
                    path: 'take',
                    builder: (context, state) => WritingTaskPage(
                      taskId: state.pathParameters['taskId'] ?? '',
                    ),
                  ),
                ],
              ),
              GoRoute(
                path: 'submission/:submissionId',
                builder: (context, state) => ResultJourneyPage(
                  request: ResultSnapshotRequest(
                    module: ResultSnapshotModule.writing,
                    referenceId: state.pathParameters['submissionId'] ?? '',
                  ),
                  title: 'Writing Submission',
                  subtitle: 'Review your submission and choose the next step.',
                  paletteKey: AppPagePaletteKey.writing,
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/speaking',
            builder: (context, state) =>
                SpeakingPage(mode: state.uri.queryParameters['mode']),
            routes: [
              GoRoute(
                path: 'practice/:id',
                builder: (context, state) => SpeakingPracticePage(
                  topicId: state.pathParameters['id'] ?? '',
                ),
              ),
              GoRoute(
                path: 'result/:id',
                builder: (context, state) => ResultJourneyPage(
                  request: ResultSnapshotRequest(
                    module: ResultSnapshotModule.speaking,
                    referenceId: state.pathParameters['id'] ?? '',
                  ),
                  title: 'Speaking Result',
                  subtitle:
                      'Review your speaking result and decide what to do next.',
                  paletteKey: AppPagePaletteKey.speaking,
                ),
              ),
              GoRoute(
                path: 'history',
                builder: (context, state) => const SpeakingHistoryPage(),
              ),
              GoRoute(
                path: 'conversation/history',
                builder: (context, state) =>
                    const SpeakingConversationHistoryPage(),
              ),
              GoRoute(
                path: 'conversation/result/:id',
                builder: (context, state) => SpeakingConversationResultPage(
                  conversationId: state.pathParameters['id'] ?? '',
                ),
              ),
              GoRoute(
                path: 'conversation/:topicId',
                builder: (context, state) => SpeakingConversationPage(
                  topicId: state.pathParameters['topicId'] ?? '',
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/custom-speaking',
            builder: (context, state) => const CustomSpeakingPage(),
            routes: [
              GoRoute(
                path: 'history',
                builder: (context, state) => const CustomSpeakingHistoryPage(),
              ),
              GoRoute(
                path: 'conversation/:id',
                builder: (context, state) => CustomSpeakingChatPage(
                  conversationId: state.pathParameters['id'] ?? '',
                  bootstrap: state.extra as CustomSpeakingStep?,
                ),
              ),
              GoRoute(
                path: 'result/:id',
                builder: (context, state) => ResultJourneyPage(
                  request: ResultSnapshotRequest(
                    module: ResultSnapshotModule.customSpeaking,
                    referenceId: state.pathParameters['id'] ?? '',
                  ),
                  title: 'Custom Speaking Result',
                  subtitle:
                      'Review your custom speaking result and continue practicing.',
                  paletteKey: AppPagePaletteKey.speaking,
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/weekly-report',
            builder: (context, state) => const WeeklyReportPage(),
          ),
          GoRoute(
            path: '/challenges',
            builder: (context, state) => const WeeklyChallengePage(),
          ),
          GoRoute(
            path: '/notifications',
            builder: (context, state) => const NotificationInboxPage(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfilePage(),
          ),
          GoRoute(
            path: '/leaderboard',
            builder: (context, state) => const LeaderboardPage(),
          ),
          GoRoute(
            path: '/xp-history',
            builder: (context, state) => const XpHistoryPage(),
          ),
          GoRoute(
            path: '/preview',
            builder: (context, state) => const ThemePreviewPage(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsPage(),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) {
      return const Scaffold(body: Center(child: Text('Page not found')));
    },
  );
});
