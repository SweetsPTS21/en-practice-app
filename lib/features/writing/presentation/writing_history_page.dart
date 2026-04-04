import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design/widgets/app_card.dart';
import '../../../core/design/widgets/app_page_scaffold.dart';
import '../../../core/design/widgets/app_state_widgets.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../core/theme/page_palettes.dart';
import '../../../core/writing/writing_models.dart';
import '../application/writing_controllers.dart';

class WritingHistoryPage extends ConsumerWidget {
  const WritingHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppPageScaffold(
      title: 'Writing history',
      subtitle:
          'Reopen previous submissions, check pending grading states, and jump back into improvement loops.',
      paletteKey: AppPagePaletteKey.writing,
      onRefresh: () async => ref.invalidate(writingSubmissionHistoryProvider),
      children: const [WritingHistoryContent()],
    );
  }
}

class WritingHistorySheet extends StatelessWidget {
  const WritingHistorySheet({super.key, this.onSelected});

  final ValueChanged<WritingSubmission>? onSelected;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FractionallySizedBox(
        heightFactor: 0.78,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Recent submissions',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 6),
              Text(
                'Open past writing results without leaving the list.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: context.tokens.text.secondary,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: WritingHistoryContent(
                  onSelected: onSelected,
                  includeSectionCard: false,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WritingHistoryContent extends ConsumerWidget {
  const WritingHistoryContent({
    super.key,
    this.onSelected,
    this.includeSectionCard = true,
  });

  final ValueChanged<WritingSubmission>? onSelected;
  final bool includeSectionCard;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(writingSubmissionHistoryProvider);

    return switch (history) {
      AsyncData(:final value) when value.items.isEmpty => const AppEmptyState(
        icon: Icons.history_toggle_off_rounded,
        title: 'No writing submissions yet',
        subtitle: 'Your completed drafts will show up here once you submit them.',
      ),
      AsyncData(:final value) => includeSectionCard
          ? AppCard(
              child: _WritingHistoryList(
                items: value.items,
                onSelected: onSelected,
                showHeader: true,
              ),
            )
          : _WritingHistoryList(
              items: value.items,
              onSelected: onSelected,
              showHeader: false,
              scrollable: true,
            ),
      AsyncError() => AppErrorCard(
        title: 'Writing history is unavailable',
        message: 'We could not load your writing submissions.',
        onRetry: () => ref.invalidate(writingSubmissionHistoryProvider),
      ),
      _ => const AppLoadingCard(
        height: 220,
        message: 'Loading writing history...',
      ),
    };
  }
}

class _WritingHistoryList extends StatelessWidget {
  const _WritingHistoryList({
    required this.items,
    required this.showHeader,
    this.scrollable = false,
    this.onSelected,
  });

  final List<WritingSubmission> items;
  final ValueChanged<WritingSubmission>? onSelected;
  final bool showHeader;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    if (scrollable) {
      return ListView.separated(
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          return _WritingHistoryTile(item: items[index], onSelected: onSelected);
        },
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showHeader) ...[
          Text(
            'Recent submissions',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
        ],
        for (var index = 0; index < items.length; index++) ...[
          _WritingHistoryTile(item: items[index], onSelected: onSelected),
          if (index != items.length - 1) const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _WritingHistoryTile extends StatelessWidget {
  const _WritingHistoryTile({required this.item, this.onSelected});

  final WritingSubmission item;
  final ValueChanged<WritingSubmission>? onSelected;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (onSelected != null) {
            onSelected!(item);
            return;
          }
          context.go('/writing/submission/${item.id}');
        },
        borderRadius: BorderRadius.circular(tokens.radius.xl),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: tokens.background.panelStrong,
            borderRadius: BorderRadius.circular(tokens.radius.xl),
            border: Border.all(color: tokens.border.subtle),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: tokens.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(tokens.radius.lg),
                ),
                child: Icon(Icons.history_rounded, color: tokens.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.taskTitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${item.taskType} • ${item.wordCount} words • ${item.status}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: tokens.text.secondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                item.isPending || item.overallBandScore == null
                    ? 'Pending'
                    : item.overallBandScore!.toStringAsFixed(1),
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: item.isPending ? tokens.warning : tokens.success,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
