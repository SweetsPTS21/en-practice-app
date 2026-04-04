import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design/widgets/app_card.dart';
import '../../../core/design/widgets/app_page_scaffold.dart';
import '../../../core/design/widgets/app_state_widgets.dart';
import '../../../core/theme/page_palettes.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../core/speaking/speaking_models.dart';
import '../application/speaking_controllers.dart';

class SpeakingHistoryPage extends ConsumerWidget {
  const SpeakingHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppPageScaffold(
      title: 'Speaking history',
      subtitle:
          'Reopen single-attempt speaking sessions and keep the async grading comeback loop visible.',
      paletteKey: AppPagePaletteKey.speaking,
      onRefresh: () async => ref.invalidate(speakingAttemptHistoryProvider),
      children: const [SpeakingHistoryContent()],
    );
  }
}

class SpeakingHistorySheet extends StatelessWidget {
  const SpeakingHistorySheet({super.key, this.onSelected});

  final ValueChanged<SpeakingAttempt>? onSelected;

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
                'Recent attempts',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 6),
              Text(
                'Open previous speaking results without leaving the list.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: context.tokens.text.secondary,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SpeakingHistoryContent(
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

class SpeakingHistoryContent extends ConsumerWidget {
  const SpeakingHistoryContent({
    super.key,
    this.onSelected,
    this.includeSectionCard = true,
  });

  final ValueChanged<SpeakingAttempt>? onSelected;
  final bool includeSectionCard;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(speakingAttemptHistoryProvider);

    return switch (history) {
      AsyncData(:final value) when value.items.isEmpty => const AppEmptyState(
        icon: Icons.mic_off_rounded,
        title: 'No speaking attempts yet',
        subtitle: 'Your submitted speaking attempts will appear here.',
      ),
      AsyncData(:final value) => includeSectionCard
          ? AppCard(
              child: _SpeakingHistoryList(
                items: value.items,
                onSelected: onSelected,
                showHeader: true,
              ),
            )
          : _SpeakingHistoryList(
              items: value.items,
              onSelected: onSelected,
              showHeader: false,
              scrollable: true,
            ),
      AsyncError() => AppErrorCard(
        title: 'Speaking history is unavailable',
        message: 'We could not load your speaking attempts.',
        onRetry: () => ref.invalidate(speakingAttemptHistoryProvider),
      ),
      _ => const AppLoadingCard(
        height: 220,
        message: 'Loading speaking history...',
      ),
    };
  }
}

class _SpeakingHistoryList extends StatelessWidget {
  const _SpeakingHistoryList({
    required this.items,
    required this.showHeader,
    this.scrollable = false,
    this.onSelected,
  });

  final List<SpeakingAttempt> items;
  final ValueChanged<SpeakingAttempt>? onSelected;
  final bool showHeader;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    if (scrollable) {
      return ListView.separated(
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          return _SpeakingHistoryTile(
            item: items[index],
            onSelected: onSelected,
          );
        },
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showHeader) ...[
          Text(
            'Recent attempts',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
        ],
        for (var index = 0; index < items.length; index++) ...[
          _SpeakingHistoryTile(item: items[index], onSelected: onSelected),
          if (index != items.length - 1) const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _SpeakingHistoryTile extends StatelessWidget {
  const _SpeakingHistoryTile({required this.item, this.onSelected});

  final SpeakingAttempt item;
  final ValueChanged<SpeakingAttempt>? onSelected;

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
          context.go('/speaking/result/${item.id}');
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
                child: Icon(Icons.mic_rounded, color: tokens.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.topicQuestion,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${item.topicPart} • ${item.status}',
                      maxLines: 1,
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
