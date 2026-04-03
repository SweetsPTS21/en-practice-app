import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/analytics/learning_analytics_service.dart';
import '../../../core/design/widgets/app_button.dart';
import '../../../core/design/widgets/app_card.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/learning_journey/learning_journey_action_service.dart';
import '../../../core/navigation/learning_action_resolver.dart';
import '../../../core/navigation/learning_launch_store.dart';
import '../../../core/recommendation/recommendation_surface.dart';
import '../../../core/retention/flagship_retention_models.dart';
import '../../../core/theme/page_palettes.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../auth/auth_providers.dart';
import '../application/home_launchpad_state.dart';
import '../data/home_launchpad_models.dart';
import '../home_providers.dart';
import 'widgets/daily_plan_sheet.dart';
import 'widgets/flagship_retention_panel.dart';
import 'widgets/reminder_banner.dart';
import '../../recommendation/presentation/widgets/recommendation_surface_slot.dart';
import '../../leaderboard/presentation/widgets/leaderboard_summary_widget.dart';
import '../../notifications/application/push_entry_controller.dart';
import '../../notifications/presentation/widgets/push_permission_sheet.dart';
import '../../../core/push/push_providers.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  bool _trackedHomeOpen = false;
  bool _consumedFeedback = false;

  @override
  Widget build(BuildContext context) {
    final launchpad = ref.watch(homeLaunchpadControllerProvider);
    final auth = ref.watch(authControllerProvider);

    if (auth.isAuthenticated && launchpad.hasValue && !_trackedHomeOpen) {
      _trackedHomeOpen = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(learningAnalyticsServiceProvider)
            .trackEvent(
              const LearningEventPayload(
                eventName: LearningEventName.homeOpened,
                source: 'HOME_V2',
                module: 'HOME',
                route: '/home',
              ),
            );
      });
    }

    if (!_consumedFeedback && launchpad.hasValue) {
      _consumedFeedback = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final feedback = ref
            .read(learningLaunchStoreProvider)
            .consumeRecentLearningFeedback();
        if (!mounted || feedback == null) {
          return;
        }

        final message = feedback.xpEarned != null
            ? '${context.tr('home.feedback.completed')} ${feedback.taskTitle ?? context.tr('home.feedback.defaultTask')} · +${feedback.xpEarned} XP'
            : '${context.tr('home.feedback.completed')} ${feedback.taskTitle ?? context.tr('home.feedback.defaultTask')}';
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      });
    }

    return switch (launchpad) {
      AsyncData<HomeLaunchpadState>(:final value) => RefreshIndicator(
        onRefresh: () => ref
            .read(homeLaunchpadControllerProvider.notifier)
            .refreshLaunchpad(),
        child: _HomeContent(
          state: value,
          onContinueLearning: () =>
              _handleContinueLearning(value.continueLearning),
          onReminderBanner: value.reminderBanner == null
              ? null
              : () => _handleReminderBanner(value.reminderBanner!),
          onOpenDailyPlan: () => _openDailyPlanSheet(value.dailyPlan),
          onDailyTask: _handleDailyTask,
          onQuickPractice: _handleQuickPractice,
          onOpenSpeakingPrompt:
              value.flagshipRetention?.dailySpeakingPrompt == null
              ? null
              : () => _handleDailySpeakingPrompt(
                  value.flagshipRetention!.dailySpeakingPrompt!,
                ),
          onOpenVocabMicroLearning:
              value.flagshipRetention?.vocabMicroLearning == null
              ? null
              : () => _handleVocabMicroLearning(
                  value.flagshipRetention!.vocabMicroLearning!,
                ),
          onOpenChallenge: () => context.go('/challenges'),
        ),
      ),
      AsyncError() => _HomeErrorState(
        onRetry: () => ref
            .read(homeLaunchpadControllerProvider.notifier)
            .refreshLaunchpad(),
      ),
      _ => const _HomeLoadingState(),
    };
  }

  ContinueLearningItem _fallbackContinueItem(BuildContext context) {
    return ContinueLearningItem(
      source: 'GET_STARTED',
      title: context.tr('home.continueLearning.fallbackTitle'),
      description: context.tr('home.continueLearning.fallbackDescription'),
      resumeUrl: '/dictionary/review',
      estimatedMinutes: 5,
      reason: 'GET_STARTED',
      priority: 1,
      referenceType: 'GET_STARTED',
    );
  }

  Future<void> _handleContinueLearning(ContinueLearningItem? item) async {
    final effectiveItem = item ?? _fallbackContinueItem(context);
    final target = resolveLearningActionTarget(
      LearningActionInput(
        actionUrl: effectiveItem.resumeUrl,
        referenceType: effectiveItem.referenceType,
        referenceId: effectiveItem.referenceId,
        module: effectiveItem.source,
        metadata: effectiveItem.metadata,
      ),
    );

    await ref
        .read(learningAnalyticsServiceProvider)
        .trackEvent(
          LearningEventPayload(
            eventName: LearningEventName.continueLearningClicked,
            source: 'HOME_CONTINUE_CARD',
            module: effectiveItem.source,
            route: target.href,
            referenceType: effectiveItem.referenceType,
            referenceId: effectiveItem.referenceId,
            metadata: {
              'reason': effectiveItem.reason,
              'priority': effectiveItem.priority,
              'estimatedMinutes': effectiveItem.estimatedMinutes,
              'usedFallback': target.usedFallback,
            },
          ),
        );

    if (effectiveItem.reason == 'UNFINISHED_ATTEMPT') {
      await ref
          .read(learningAnalyticsServiceProvider)
          .trackEvent(
            LearningEventPayload(
              eventName: LearningEventName.resumeStarted,
              source: 'HOME_CONTINUE_CARD',
              module: effectiveItem.source,
              route: target.href,
              referenceType: effectiveItem.referenceType,
              referenceId: effectiveItem.referenceId,
              metadata: {'reason': effectiveItem.reason},
            ),
          );
    }

    await _navigateToLearningTarget(
      target: target,
      contextData: LearningLaunchContext(
        source: 'HOME_CONTINUE_CARD',
        module: effectiveItem.source,
        route: target.href,
        referenceType: effectiveItem.referenceType,
        referenceId: effectiveItem.referenceId,
        taskTitle: effectiveItem.title,
        reason: effectiveItem.reason,
        estimatedMinutes: effectiveItem.estimatedMinutes,
        metadata: effectiveItem.metadata,
        started: false,
        launchedAt: DateTime.now(),
      ),
    );
  }

  Future<void> _handleDailyTask(DailyLearningPlanItem item) async {
    final target = resolveLearningActionTarget(
      LearningActionInput(
        actionUrl: item.actionUrl,
        referenceType: 'DAILY_PLAN_ITEM',
        referenceId: item.id,
        module: item.type,
        metadata: item.metadata,
      ),
    );

    await ref
        .read(learningAnalyticsServiceProvider)
        .trackEvent(
          LearningEventPayload(
            eventName: LearningEventName.dailyTaskClicked,
            source: 'HOME_DAILY_PLAN',
            module: item.type,
            route: target.href,
            referenceType: 'DAILY_PLAN_ITEM',
            referenceId: item.id,
            metadata: {
              'taskId': item.id,
              'reason': item.reason,
              'priority': item.priority,
              'estimatedMinutes': item.estimatedMinutes,
              'usedFallback': target.usedFallback,
            },
          ),
        );

    await _navigateToLearningTarget(
      target: target,
      contextData: LearningLaunchContext(
        source: 'HOME_DAILY_PLAN',
        module: item.type,
        route: target.href,
        referenceType: 'DAILY_PLAN_ITEM',
        referenceId: item.id,
        taskId: item.id,
        taskTitle: item.title,
        reason: item.reason,
        estimatedMinutes: item.estimatedMinutes,
        metadata: item.metadata,
        started: false,
        launchedAt: DateTime.now(),
      ),
    );
  }

  Future<void> _handleQuickPractice(QuickPracticeItem item) async {
    final target = resolveLearningActionTarget(
      LearningActionInput(
        actionUrl: item.actionUrl,
        referenceType: item.type,
        referenceId: item.id,
        module: item.type,
        metadata: item.metadata,
      ),
    );

    await _navigateToLearningTarget(
      target: target,
      contextData: LearningLaunchContext(
        source: 'HOME_QUICK_PRACTICE',
        module: item.type,
        route: target.href,
        referenceType: item.type,
        referenceId: item.id,
        taskTitle: item.title,
        reason: item.reason,
        estimatedMinutes: item.estimatedMinutes,
        metadata: item.metadata,
        started: false,
        launchedAt: DateTime.now(),
      ),
    );
  }

  Future<void> _handleReminderBanner(ReminderBanner banner) async {
    final outcome = await ref
        .read(learningJourneyActionServiceProvider)
        .prepareAction(
          JourneyActionRequest(
            source: 'HOME_REMINDER_BANNER',
            analyticsEvents: const [LearningEventName.reminderBannerClicked],
            module: banner.type,
            actionUrl: banner.actionUrl,
            referenceType: banner.referenceType,
            referenceId: banner.referenceId,
            taskTitle: banner.title,
            reason: banner.reason,
            estimatedMinutes: banner.estimatedMinutes,
            priority: banner.priority,
            metadata: banner.metadata,
          ),
        );

    if (!mounted) {
      return;
    }

    if (outcome.target.kind == LearningActionKind.external) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr('home.common.externalRouteUnsupported')),
        ),
      );
      return;
    }

    context.go(outcome.target.href);
  }

  Future<void> _handleDailySpeakingPrompt(DailySpeakingPrompt prompt) async {
    final target = resolveLearningActionTarget(
      LearningActionInput(
        actionUrl: prompt.actionUrl,
        referenceType: 'DAILY_SPEAKING_PROMPT',
        referenceId: prompt.promptId,
        module: 'SPEAKING',
        metadata: const <String, dynamic>{},
      ),
    );

    await _navigateToLearningTarget(
      target: target,
      contextData: LearningLaunchContext(
        source: 'FLAGSHIP_RETENTION',
        module: 'SPEAKING',
        route: target.href,
        referenceType: 'DAILY_SPEAKING_PROMPT',
        referenceId: prompt.promptId,
        taskTitle: prompt.topic,
        reason: prompt.reason,
        estimatedMinutes: prompt.estimatedMinutes,
        metadata: {
          'specialEvent': 'SPEAKING_PROMPT',
          'resumeState': prompt.resumeState,
        },
        started: false,
        launchedAt: DateTime.now(),
      ),
    );
  }

  Future<void> _handleVocabMicroLearning(VocabMicroLearning item) async {
    final target = resolveLearningActionTarget(
      LearningActionInput(
        actionUrl: item.actionUrl,
        referenceType: 'VOCAB_MICRO_SESSION',
        module: 'VOCAB',
        metadata: const <String, dynamic>{},
      ),
    );

    await _navigateToLearningTarget(
      target: target,
      contextData: LearningLaunchContext(
        source: 'FLAGSHIP_RETENTION',
        module: 'VOCAB',
        route: target.href,
        referenceType: 'VOCAB_MICRO_SESSION',
        taskTitle: item.title,
        reason: item.reason,
        estimatedMinutes: item.estimatedMinutes,
        metadata: {
          'specialEvent': 'VOCAB_MICRO_SESSION',
          'targetWordCount': item.targetWordCount ?? item.dueWordCount,
        },
        started: false,
        launchedAt: DateTime.now(),
      ),
    );
  }

  Future<void> _navigateToLearningTarget({
    required LearningActionTarget target,
    required LearningLaunchContext contextData,
  }) async {
    if (target.kind == LearningActionKind.external) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.tr('home.common.externalRouteUnsupported')),
          ),
        );
      }
      return;
    }

    if (target.isLearningSession) {
      await ref
          .read(learningLaunchStoreProvider)
          .rememberLearningLaunch(contextData);
    }

    if (mounted) {
      context.go(target.href);
    }
  }

  Future<void> _openDailyPlanSheet(DailyLearningPlan? plan) async {
    if (plan == null || plan.items.isEmpty) {
      return;
    }

    final completedTaskIds = ref
        .read(learningLaunchStoreProvider)
        .getCompletedDailyTaskIds(date: plan.date)
        .toSet();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: false,
      backgroundColor: context.tokens.background.canvas,
      builder: (sheetContext) {
        return FractionallySizedBox(
          heightFactor: 0.88,
          child: DailyPlanSheet(
            plan: plan,
            completedTaskIds: completedTaskIds,
            onTaskPressed: (item) {
              Navigator.of(sheetContext).pop();
              _handleDailyTask(item);
            },
          ),
        );
      },
    );
  }
}

class _HomeContent extends ConsumerWidget {
  const _HomeContent({
    required this.state,
    required this.onContinueLearning,
    required this.onReminderBanner,
    required this.onOpenDailyPlan,
    required this.onDailyTask,
    required this.onQuickPractice,
    required this.onOpenSpeakingPrompt,
    required this.onOpenVocabMicroLearning,
    required this.onOpenChallenge,
  });

  final HomeLaunchpadState state;
  final VoidCallback onContinueLearning;
  final VoidCallback? onReminderBanner;
  final VoidCallback onOpenDailyPlan;
  final ValueChanged<DailyLearningPlanItem> onDailyTask;
  final ValueChanged<QuickPracticeItem> onQuickPractice;
  final VoidCallback? onOpenSpeakingPrompt;
  final VoidCallback? onOpenVocabMicroLearning;
  final VoidCallback onOpenChallenge;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plan = state.dailyPlan;
    final completedTaskIds = plan == null
        ? const <String>{}
        : ref
              .watch(learningLaunchStoreProvider)
              .getCompletedDailyTaskIds(date: plan.date)
              .toSet();
    final pushEntry = ref.watch(pushEntryControllerProvider);

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          sliver: SliverToBoxAdapter(
            child: _ContinueLearningCard(
              item: state.continueLearning,
              onPressed: onContinueLearning,
            ),
          ),
        ),
        const SliverPadding(
          padding: EdgeInsets.fromLTRB(20, 0, 20, 12),
          sliver: SliverToBoxAdapter(
            child: RecommendationSurfaceSlot(
              surface: RecommendationSurface.home,
              source: 'HOME_RECOMMENDATION',
              hero: true,
              showFeedbackActions: true,
            ),
          ),
        ),
        const SliverPadding(
          padding: EdgeInsets.fromLTRB(20, 0, 20, 12),
          sliver: SliverToBoxAdapter(child: LeaderboardSummaryWidget()),
        ),
        if (state.flagshipRetention?.hasAnyBlock == true)
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            sliver: SliverToBoxAdapter(
              child: FlagshipRetentionPanel(
                flagship: state.flagshipRetention!,
                onOpenSpeakingPrompt: onOpenSpeakingPrompt,
                onOpenVocabMicroLearning: onOpenVocabMicroLearning,
                onOpenChallenge: onOpenChallenge,
              ),
            ),
          ),
        if (state.reminderBanner != null && onReminderBanner != null)
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            sliver: SliverToBoxAdapter(
              child: ReminderBannerCard(
                banner: state.reminderBanner!,
                onPressed: onReminderBanner!,
              ),
            ),
          ),
        if (pushEntry.shouldShowHomePrompt(
          weeklyXp: state.progressSnapshot?.weeklyXp ?? 0,
        ))
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            sliver: SliverToBoxAdapter(
              child: _PushPermissionPromptCard(
                statusLabel:
                    pushEntry.permissionSnapshot?.label ?? 'Not requested yet',
                onEnable: () => PushPermissionSheet.show(context),
                onDismiss: () => ref
                    .read(pushLifecycleControllerProvider)
                    .dismissContextualPrompt(),
              ),
            ),
          ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          sliver: SliverToBoxAdapter(
            child: _DailyPlanPreviewCard(
              plan: plan,
              completedTaskIds: completedTaskIds,
              onOpenAll: onOpenDailyPlan,
              onTaskPressed: onDailyTask,
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          sliver: SliverToBoxAdapter(
            child: _QuickPracticeCard(
              items: state.quickPractice,
              onPressed: onQuickPractice,
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
          sliver: SliverToBoxAdapter(
            child: _ProgressSnapshotCard(snapshot: state.progressSnapshot),
          ),
        ),
      ],
    );
  }
}

class _ContinueLearningCard extends StatelessWidget {
  const _ContinueLearningCard({required this.item, required this.onPressed});

  final ContinueLearningItem? item;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final palette = context.pagePalette(AppPagePaletteKey.dashboard);
    final tokens = context.tokens;
    final title =
        item?.title ?? context.tr('home.continueLearning.fallbackTitle');
    final description =
        item?.description ??
        context.tr('home.continueLearning.fallbackDescription');

    return Container(
      padding: EdgeInsets.all(tokens.density.panelPadding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [palette.heroTop, palette.heroBottom],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(tokens.radius.hero),
        boxShadow: [
          BoxShadow(
            color: palette.accent.withValues(alpha: 0.18),
            blurRadius: tokens.motion.blurStrong + 12,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              context.tr('home.continueLearning.eyebrow'),
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(color: Colors.white),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.88),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _HeroMetaChip(
                icon: Icons.schedule_rounded,
                label:
                    '${item?.estimatedMinutes ?? 5} ${context.tr('home.common.minutes')}',
              ),
              _HeroMetaChip(
                icon: Icons.flag_rounded,
                label: (item?.reason ?? 'GET_STARTED').replaceAll('_', ' '),
              ),
            ],
          ),
          const SizedBox(height: 18),
          AppButton(
            label: item?.reason == 'UNFINISHED_ATTEMPT'
                ? context.tr('home.continueLearning.resume')
                : context.tr('home.continueLearning.start'),
            icon: Icons.play_circle_fill_rounded,
            onPressed: onPressed,
          ),
        ],
      ),
    );
  }
}

class _HeroMetaChip extends StatelessWidget {
  const _HeroMetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _DailyPlanPreviewCard extends StatelessWidget {
  const _DailyPlanPreviewCard({
    required this.plan,
    required this.completedTaskIds,
    required this.onOpenAll,
    required this.onTaskPressed,
  });

  final DailyLearningPlan? plan;
  final Set<String> completedTaskIds;
  final VoidCallback onOpenAll;
  final ValueChanged<DailyLearningPlanItem> onTaskPressed;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final items =
        plan?.items.take(3).toList(growable: false) ??
        const <DailyLearningPlanItem>[];

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
            title: context.tr('home.dailyPlan.title'),
            subtitle: context.tr('home.dailyPlan.subtitle'),
            actionLabel: items.isEmpty
                ? null
                : context.tr('home.dailyPlan.viewAll'),
            onAction: items.isEmpty ? null : onOpenAll,
          ),
          const SizedBox(height: 16),
          if (items.isEmpty)
            _EmptyState(
              icon: Icons.event_note_rounded,
              title: context.tr('home.dailyPlan.emptyTitle'),
              subtitle: context.tr('home.dailyPlan.emptyDescription'),
            )
          else
            ...items.map(
              (item) => Padding(
                padding: EdgeInsets.only(bottom: tokens.density.compactGap),
                child: _DailyTaskRow(
                  item: item,
                  isCompleted: completedTaskIds.contains(item.id),
                  onPressed: () => onTaskPressed(item),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _DailyTaskRow extends StatelessWidget {
  const _DailyTaskRow({
    required this.item,
    required this.isCompleted,
    required this.onPressed,
  });

  final DailyLearningPlanItem item;
  final bool isCompleted;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isCompleted
            ? tokens.background.panelStrong
            : tokens.background.elevated,
        borderRadius: BorderRadius.circular(tokens.radius.xl),
        border: Border.all(color: tokens.border.subtle),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isCompleted
                  ? tokens.success.withValues(alpha: 0.12)
                  : tokens.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(tokens.radius.lg),
            ),
            child: Icon(
              isCompleted ? Icons.check_rounded : Icons.bolt_rounded,
              color: isCompleted ? tokens.success : tokens.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  item.description,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: tokens.text.secondary),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          AppButton(
            label: isCompleted
                ? context.tr('home.dailyPlan.completed')
                : item.ctaLabel,
            variant: isCompleted
                ? AppButtonVariant.outline
                : AppButtonVariant.filled,
            onPressed: isCompleted ? null : onPressed,
          ),
        ],
      ),
    );
  }
}

class _QuickPracticeCard extends StatelessWidget {
  const _QuickPracticeCard({required this.items, required this.onPressed});

  final List<QuickPracticeItem> items;
  final ValueChanged<QuickPracticeItem> onPressed;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
            title: context.tr('home.quickPractice.title'),
            subtitle: context.tr('home.quickPractice.subtitle'),
          ),
          const SizedBox(height: 16),
          if (items.isEmpty)
            _EmptyState(
              icon: Icons.flash_on_rounded,
              title: context.tr('home.quickPractice.emptyTitle'),
              subtitle: context.tr('home.quickPractice.emptyDescription'),
            )
          else
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _QuickPracticeRow(
                  item: item,
                  onPressed: () => onPressed(item),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _QuickPracticeRow extends StatelessWidget {
  const _QuickPracticeRow({required this.item, required this.onPressed});

  final QuickPracticeItem item;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(tokens.radius.xl),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: tokens.background.panelStrong,
            borderRadius: BorderRadius.circular(tokens.radius.xl),
            border: Border.all(color: tokens.border.subtle),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: tokens.secondary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(tokens.radius.lg),
                ),
                child: Icon(Icons.bolt_rounded, color: tokens.secondary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: tokens.text.secondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    item.estimatedMinutes == null
                        ? context.tr('home.quickPractice.startNow')
                        : '${item.estimatedMinutes} ${context.tr('home.common.minutes')}',
                    style: Theme.of(
                      context,
                    ).textTheme.labelLarge?.copyWith(color: tokens.primary),
                  ),
                  const SizedBox(height: 6),
                  Icon(Icons.arrow_forward_rounded, color: tokens.primary),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PushPermissionPromptCard extends StatelessWidget {
  const _PushPermissionPromptCard({
    required this.statusLabel,
    required this.onEnable,
    required this.onDismiss,
  });

  final String statusLabel;
  final VoidCallback onEnable;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Stay in the loop',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Ask for push permission after the learner already has momentum. This prompt is gated by actual weekly XP, not by first app launch.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: tokens.text.secondary),
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: tokens.background.panelStrong,
              borderRadius: BorderRadius.circular(tokens.radius.xl),
              border: Border.all(color: tokens.border.subtle),
            ),
            child: Text('Device push status: $statusLabel'),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'Not now',
                  variant: AppButtonVariant.outline,
                  onPressed: onDismiss,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppButton(
                  label: 'Enable push',
                  icon: Icons.notifications_active_rounded,
                  onPressed: onEnable,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProgressSnapshotCard extends StatelessWidget {
  const _ProgressSnapshotCard({required this.snapshot});

  final ProgressSnapshot? snapshot;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final progress = snapshot?.todayProgressPercent?.clamp(0, 100) ?? 0;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
            title: context.tr('home.progress.title'),
            subtitle: context.tr('home.progress.subtitle'),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _MetricTile(
                  label: context.tr('home.progress.today'),
                  value:
                      '${snapshot?.studiedMinutes ?? 0}/${snapshot?.targetMinutes ?? 0} ${context.tr('home.common.minutes')}',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetricTile(
                  label: context.tr('home.progress.streak'),
                  value: '${snapshot?.currentStreak ?? 0}',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetricTile(
                  label: context.tr('home.progress.weeklyXp'),
                  value: '${snapshot?.weeklyXp ?? 0}',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress / 100,
              minHeight: 10,
              backgroundColor: tokens.border.subtle,
              valueColor: AlwaysStoppedAnimation<Color>(tokens.primary),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '$progress% ${context.tr('home.progress.progressLabel')}',
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(color: tokens.text.secondary),
          ),
          if ((snapshot?.latestImprovementText ?? '').isNotEmpty) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: tokens.background.panelStrong,
                borderRadius: BorderRadius.circular(tokens.radius.xl),
                border: Border.all(color: tokens.border.subtle),
              ),
              child: Text(snapshot!.latestImprovementText!),
            ),
          ],
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: tokens.background.panelStrong,
        borderRadius: BorderRadius.circular(tokens.radius.xl),
        border: Border.all(color: tokens.border.subtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: tokens.text.secondary),
          ),
          const SizedBox(height: 6),
          Text(value, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: tokens.text.secondary),
              ),
            ],
          ),
        ),
        if (actionLabel != null)
          TextButton(onPressed: onAction, child: Text(actionLabel!)),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: tokens.background.panelStrong,
        borderRadius: BorderRadius.circular(tokens.radius.xl),
        border: Border.all(color: tokens.border.subtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: tokens.primary),
          const SizedBox(height: 10),
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: tokens.text.secondary),
          ),
        ],
      ),
    );
  }
}

class _HomeLoadingState extends StatelessWidget {
  const _HomeLoadingState();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      children: const [
        _LoadingBlock(height: 240),
        SizedBox(height: 12),
        _LoadingBlock(height: 280),
        SizedBox(height: 12),
        _LoadingBlock(height: 220),
        SizedBox(height: 12),
        _LoadingBlock(height: 220),
      ],
    );
  }
}

class _HomeErrorState extends StatelessWidget {
  const _HomeErrorState({required this.onRetry});

  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: AppCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.cloud_off_rounded,
                size: 40,
                color: context.tokens.warning,
              ),
              const SizedBox(height: 12),
              Text(
                context.tr('home.common.errorTitle'),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                context.tr('home.common.errorDescription'),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              AppButton(
                label: context.tr('home.common.retry'),
                icon: Icons.refresh_rounded,
                onPressed: onRetry,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoadingBlock extends StatelessWidget {
  const _LoadingBlock({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: context.tokens.background.panelStrong,
        borderRadius: BorderRadius.circular(context.tokens.radius.hero),
        border: Border.all(color: context.tokens.border.subtle),
      ),
    );
  }
}
