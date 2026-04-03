import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design/widgets/app_card.dart';
import '../../../core/design/widgets/app_page_scaffold.dart';
import '../../../core/design/widgets/app_state_widgets.dart';
import '../../../core/theme/page_palettes.dart';
import '../application/speaking_controllers.dart';

class SpeakingHistoryPage extends ConsumerWidget {
  const SpeakingHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(speakingAttemptHistoryProvider);

    return AppPageScaffold(
      title: 'Speaking history',
      subtitle:
          'Reopen single-attempt speaking sessions and keep the async grading comeback loop visible.',
      paletteKey: AppPagePaletteKey.speaking,
      onRefresh: () async => ref.invalidate(speakingAttemptHistoryProvider),
      children: [
        switch (history) {
          AsyncData(:final value) when value.items.isEmpty =>
            const AppEmptyState(
              icon: Icons.mic_off_rounded,
              title: 'No speaking attempts yet',
              subtitle: 'Your submitted speaking attempts will appear here.',
            ),
          AsyncData(:final value) => AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recent attempts',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                ...value.items.map(
                  (item) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(item.topicQuestion),
                    subtitle: Text('${item.topicPart} • ${item.status}'),
                    trailing: Text(
                      item.isPending || item.overallBandScore == null
                          ? 'Pending'
                          : item.overallBandScore!.toStringAsFixed(1),
                    ),
                    onTap: () => context.go('/speaking/result/${item.id}'),
                  ),
                ),
              ],
            ),
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
        },
      ],
    );
  }
}
