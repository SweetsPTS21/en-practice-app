import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design/widgets/app_button.dart';
import '../../../core/design/widgets/app_card.dart';
import '../../../core/design/widgets/app_page_scaffold.dart';
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
      subtitle: 'Generate personalized tests from your own vocabulary history and review older attempts.',
      paletteKey: AppPagePaletteKey.vocabularyTest,
      trailing: AppButton(
        label: 'Attempt history',
        icon: Icons.history_rounded,
        variant: AppButtonVariant.outline,
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
                  Text('Create with AI', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    initialValue: value.questionCount,
                    decoration: const InputDecoration(labelText: 'Question count'),
                    items: const [5, 10, 15, 20]
                        .map((count) => DropdownMenuItem(value: count, child: Text('$count')))
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
                    label: value.isGenerating ? 'Generating...' : 'Generate test',
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
                  Text('Generated tests', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  if (value.tests.isEmpty)
                    const Text('No AI-generated tests yet.')
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
                        onTap: () => context.go('/vocabulary-tests/${test.testId}'),
                      ),
                    ),
                ],
              ),
            ),
          ],
          loading: () => const [
            AppCard(
              child: SizedBox(
                height: 160,
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
          ],
          error: (error, _) => [
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Vocabulary tests could not be loaded.'),
                  const SizedBox(height: 8),
                  Text(error.toString()),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
