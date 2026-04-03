import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design/widgets/app_button.dart';
import '../../../core/design/widgets/app_card.dart';
import '../../../core/design/widgets/app_header_icon_action.dart';
import '../../../core/design/widgets/app_page_scaffold.dart';
import '../../../core/design/widgets/app_state_widgets.dart';
import '../../../core/theme/page_palettes.dart';
import '../../../core/vocabulary_test/vocabulary_test_models.dart';
import '../application/vocabulary_test_list_controller.dart';

class VocabularyTestListPage extends ConsumerWidget {
  const VocabularyTestListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(vocabularyTestListControllerProvider);
    final controller = ref.read(vocabularyTestListControllerProvider.notifier);

    return AppPageScaffold(
      title: 'AI vocabulary tests',
      subtitle:
          'Generate personalized tests from your own vocabulary history and review older attempts.',
      paletteKey: AppPagePaletteKey.vocabularyTest,
      onRefresh: controller.refresh,
      trailing: AppHeaderIconAction(
        tooltip: 'Attempt history',
        icon: Icons.history_rounded,
        onPressed: () => context.go('/vocabulary-tests/history'),
      ),
      children: [
        ...state.when(
          data: (value) => [
            AppCard(
              strong: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppSectionHeader(
                    title: 'Create with AI',
                    subtitle:
                        'Choose a test size, select the sources you want and generate one focused practice set.',
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    initialValue: value.questionCount,
                    decoration: const InputDecoration(
                      labelText: 'Question count',
                    ),
                    items: const [5, 10, 15, 20]
                        .map(
                          (count) => DropdownMenuItem(
                            value: count,
                            child: Text('$count'),
                          ),
                        )
                        .toList(growable: false),
                    onChanged: (next) {
                      if (next != null) {
                        controller.updateQuestionCount(next);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: VocabularyTestSource.values
                        .where((source) => source != VocabularyTestSource.all)
                        .map(
                          (source) => FilterChip(
                            label: Text(source.label),
                            selected: value.selectedSources.contains(source),
                            onSelected: (_) => controller.toggleSource(source),
                          ),
                        )
                        .toList(growable: false),
                  ),
                  const SizedBox(height: 16),
                  AppButton(
                    label: value.isGenerating
                        ? 'Generating...'
                        : 'Generate test',
                    icon: Icons.auto_awesome_rounded,
                    onPressed: value.isGenerating
                        ? null
                        : () async {
                            final detail = await controller.generate();
                            if (context.mounted) {
                              context.go('/vocabulary-tests/${detail.testId}');
                            }
                          },
                  ),
                ],
              ),
            ),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppSectionHeader(
                    title: 'Generated tests',
                    subtitle:
                        'Open a recent test or start a new one when you need fresh practice.',
                  ),
                  const SizedBox(height: 16),
                  if (value.tests.isEmpty)
                    const AppEmptyState(
                      icon: Icons.quiz_outlined,
                      title: 'No AI-generated tests yet',
                      subtitle:
                          'Generate your first test to see it listed here.',
                    )
                  else
                    ...value.tests.map(
                      (test) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(test.title),
                        subtitle: Text(
                          '${test.questionCount} questions • ${test.estimatedMinutes} min',
                        ),
                        trailing: Text(
                          test.latestAccuracyPercent == null
                              ? test.latestStatus.name
                              : '${test.latestAccuracyPercent!.round()}%',
                        ),
                        onTap: () =>
                            context.go('/vocabulary-tests/${test.testId}'),
                      ),
                    ),
                ],
              ),
            ),
          ],
          loading: () => const [
            AppLoadingCard(height: 160, message: 'Loading vocabulary tests...'),
          ],
          error: (_, _) => const [
            AppErrorCard(
              title: 'Vocabulary tests are unavailable',
              message: 'We could not load your generated tests right now.',
            ),
          ],
        ),
      ],
    );
  }
}
