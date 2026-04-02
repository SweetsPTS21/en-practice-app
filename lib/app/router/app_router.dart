import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/design/widgets/app_shell.dart';
import '../../core/navigation/app_route_contract.dart';
import '../../core/theme/page_palettes.dart';
import '../../features/auth/auth_providers.dart';
import '../../features/auth/models/auth_models.dart';
import '../../features/auth/view/auth_loading_page.dart';
import '../../features/auth/view/login_page.dart';
import '../../features/dictionary/dictionary_page.dart';
import '../../features/home/presentation/home_page.dart';
import '../../features/ielts/ielts_page.dart';
import '../../features/leaderboard/leaderboard_page.dart';
import '../../features/learning/learning_session_placeholder_page.dart';
import '../../features/profile/profile_page.dart';
import '../../features/settings/settings_page.dart';
import '../../features/shared/route_placeholder_page.dart';
import '../../features/speaking/speaking_page.dart';
import '../../features/theme_preview/theme_preview_page.dart';
import '../../features/writing/writing_page.dart';

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
          queryParameters: <String, String>{
            'redirect': redirectTarget,
          },
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
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/auth-loading',
        builder: (context, state) => const AuthLoadingPage(),
      ),
      ShellRoute(
        builder: (context, state, child) {
          return AppShell(
            location: state.uri.path,
            child: child,
          );
        },
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomePage(),
          ),
          GoRoute(
            path: '/dictionary',
            builder: (context, state) => const DictionaryPage(),
            routes: [
              GoRoute(
                path: 'review',
                builder: (context, state) => LearningSessionPlaceholderPage(
                  title: 'Dictionary Review',
                  subtitle: 'Quick review session placeholder for the daily loop.',
                  route: state.uri.toString(),
                  module: 'DICTIONARY',
                  paletteKey: AppPagePaletteKey.dictionary,
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
                  subtitle: 'Task detail and readiness view will land here.',
                  paletteKey: AppPagePaletteKey.ielts,
                  highlights: [
                    'Deep link compatible with web actionUrl.',
                    'Reserved for test entry and metadata.',
                  ],
                ),
              ),
              GoRoute(
                path: 'take/:attemptId',
                builder: (context, state) => LearningSessionPlaceholderPage(
                  title: 'IELTS Session',
                  subtitle: 'Resume and launch tracking are wired for this session route.',
                  route: state.uri.toString(),
                  module: 'IELTS',
                  paletteKey: AppPagePaletteKey.ielts,
                ),
              ),
              GoRoute(
                path: 'result/:attemptId',
                builder: (context, state) => const RoutePlaceholderPage(
                  title: 'IELTS Result',
                  subtitle: 'Result journey and next actions will connect here.',
                  paletteKey: AppPagePaletteKey.ielts,
                  highlights: [
                    'Review route kept for web parity.',
                    'Ready for result CTA and follow-up recommendations.',
                  ],
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
                builder: (context, state) => const RoutePlaceholderPage(
                  title: 'Writing History',
                  subtitle: 'Draft history and submission revisit flow will grow here.',
                  paletteKey: AppPagePaletteKey.writing,
                  highlights: [
                    'Reserved for submission list.',
                    'Route contract now stable for navigation resolver.',
                  ],
                ),
              ),
              GoRoute(
                path: 'task/:taskId',
                builder: (context, state) => const RoutePlaceholderPage(
                  title: 'Writing Task',
                  subtitle: 'Prompt detail and setup surface will live here.',
                  paletteKey: AppPagePaletteKey.writing,
                  highlights: [
                    'Supports direct actionUrl resolution.',
                    'Ready for task detail and preparation UI.',
                  ],
                ),
                routes: [
                  GoRoute(
                    path: 'take',
                    builder: (context, state) => LearningSessionPlaceholderPage(
                      title: 'Writing Session',
                      subtitle:
                          'Writing task session placeholder with launch analytics wired.',
                      route: state.uri.toString(),
                      module: 'WRITING',
                      paletteKey: AppPagePaletteKey.writing,
                    ),
                  ),
                ],
              ),
              GoRoute(
                path: 'submission/:submissionId',
                builder: (context, state) => const RoutePlaceholderPage(
                  title: 'Writing Submission',
                  subtitle: 'Submission review and feedback screen will land here.',
                  paletteKey: AppPagePaletteKey.writing,
                  highlights: [
                    'Review route aligned with web aliases.',
                    'Reserved for feedback actions and reattempt flow.',
                  ],
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/speaking',
            builder: (context, state) => const SpeakingPage(),
            routes: [
              GoRoute(
                path: 'practice/:id',
                builder: (context, state) => LearningSessionPlaceholderPage(
                  title: 'Speaking Practice',
                  subtitle: 'Speaking launch flow is ready for session started analytics.',
                  route: state.uri.toString(),
                  module: 'SPEAKING',
                  paletteKey: AppPagePaletteKey.speaking,
                ),
              ),
              GoRoute(
                path: 'result/:id',
                builder: (context, state) => const RoutePlaceholderPage(
                  title: 'Speaking Result',
                  subtitle: 'Result review and retry decisions will plug in here.',
                  paletteKey: AppPagePaletteKey.speaking,
                  highlights: [
                    'Review route kept for deep links.',
                    'Ready for result CTA and follow-up practice.',
                  ],
                ),
              ),
              GoRoute(
                path: 'history',
                builder: (context, state) => const RoutePlaceholderPage(
                  title: 'Speaking History',
                  subtitle: 'History of speaking attempts will show in this route.',
                  paletteKey: AppPagePaletteKey.speaking,
                  highlights: [
                    'Reserved for recent attempts.',
                    'Navigation contract fixed for future feature work.',
                  ],
                ),
              ),
              GoRoute(
                path: 'conversation/:topicId',
                builder: (context, state) => const RoutePlaceholderPage(
                  title: 'Speaking Conversation',
                  subtitle: 'Conversation setup and prompt context will appear here.',
                  paletteKey: AppPagePaletteKey.speaking,
                  highlights: [
                    'Ready for topic detail route.',
                    'Can receive deep links from recommendations later.',
                  ],
                ),
              ),
              GoRoute(
                path: 'conversation/result/:id',
                builder: (context, state) => const RoutePlaceholderPage(
                  title: 'Speaking Conversation Result',
                  subtitle: 'Conversation result surface is reserved for later phases.',
                  paletteKey: AppPagePaletteKey.speaking,
                  highlights: [
                    'Contract stabilized for result deep links.',
                    'Will host reflection and next action CTA.',
                  ],
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/custom-speaking',
            builder: (context, state) => const RoutePlaceholderPage(
              title: 'Custom Speaking',
              subtitle: 'Custom speaking launcher will expand from this module root.',
              paletteKey: AppPagePaletteKey.speaking,
              highlights: [
                'Reserved for custom conversation entry.',
                'Fallback route already available for resolver.',
              ],
            ),
            routes: [
              GoRoute(
                path: 'conversation/:id',
                builder: (context, state) => LearningSessionPlaceholderPage(
                  title: 'Custom Speaking Session',
                  subtitle:
                      'Custom conversation session placeholder for resume and start tracking.',
                  route: state.uri.toString(),
                  module: 'CUSTOM_SPEAKING',
                  paletteKey: AppPagePaletteKey.speaking,
                ),
              ),
              GoRoute(
                path: 'result/:id',
                builder: (context, state) => const RoutePlaceholderPage(
                  title: 'Custom Speaking Result',
                  subtitle: 'Conversation result review route is ready for later phases.',
                  paletteKey: AppPagePaletteKey.speaking,
                  highlights: [
                    'Web-compatible result route.',
                    'Fallback target available for recommendation flows.',
                  ],
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/weekly-report',
            builder: (context, state) => const RoutePlaceholderPage(
              title: 'Weekly Report',
              subtitle: 'Weekly learning summary will be connected in a later phase.',
              paletteKey: AppPagePaletteKey.dashboard,
              highlights: [
                'Route reserved for retention surfaces.',
                'Deep link ready from future recommendations.',
              ],
            ),
          ),
          GoRoute(
            path: '/challenges',
            builder: (context, state) => const RoutePlaceholderPage(
              title: 'Challenges',
              subtitle: 'Challenge and gamification loop will appear here.',
              paletteKey: AppPagePaletteKey.leaderboard,
              highlights: [
                'Placeholder keeps route contract stable.',
                'Ready for future reward systems.',
              ],
            ),
          ),
          GoRoute(
            path: '/notifications',
            builder: (context, state) => const RoutePlaceholderPage(
              title: 'Notifications',
              subtitle: 'Notification center is reserved for a later delivery slice.',
              paletteKey: AppPagePaletteKey.profile,
              highlights: [
                'Keeps future notification deep links stable.',
                'Pairs with notification-to-session analytics flow.',
              ],
            ),
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
      return const Scaffold(
        body: Center(
          child: Text('Page not found'),
        ),
      );
    },
  );
});
