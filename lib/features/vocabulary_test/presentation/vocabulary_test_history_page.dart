import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design/widgets/app_card.dart';
import '../../../core/design/widgets/app_page_scaffold.dart';
import '../../../core/theme/page_palettes.dart';
import '../application/vocabulary_test_list_controller.dart';

class VocabularyTestHistoryPage extends ConsumerWidget {
  const VocabularyTestHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(vocabularyTestListControllerProvider);
    return AppPageScaffold(
      title: 'Attempt history',
      subtitle: 'Review completed vocabulary test attempts from the AI-generated loop.',
      paletteKey: AppPagePaletteKey.vocabularyTest,
      children: [
        ...state.when(
          data: (value) => [
            if (value.attempts.isEmpty)
              const AppCard(child: Text('No attempts yet.'))
            else
              ...value.attempts.map(
                (attempt) => AppCard(
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(attempt.testTitle),
                    subtitle: Text(
                      '${attempt.correctCount} / ${attempt.totalQuestions} • ${attempt.status.name}',
                    ),
                    trailing: Text(
                      attempt.accuracyPercent == null
                          ? '--'
                          : '${attempt.accuracyPercent!.round()}%',
                    ),
                    onTap: () => context.go('/vocabulary-tests/attempts/${attempt.attemptId}'),
                  ),
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
          error: (error, _) => [AppCard(child: Text(error.toString()))],
        ),
      ],
    );
  }
}
