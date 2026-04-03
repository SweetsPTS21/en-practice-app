import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/widgets/app_button.dart';
import '../../../core/design/widgets/app_card.dart';
import '../../../core/design/widgets/app_page_scaffold.dart';
import '../../../core/theme/page_palettes.dart';
import '../application/vocabulary_check_controller.dart';

class VocabularyCheckPage extends ConsumerWidget {
  const VocabularyCheckPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(vocabularyCheckControllerProvider);
    final controller = ref.read(vocabularyCheckControllerProvider.notifier);

    return AppPageScaffold(
      title: 'Vocabulary check',
      subtitle: 'Validate a word, test your Vietnamese meaning, then save the AI explanation back into your dictionary.',
      paletteKey: AppPagePaletteKey.vocabularyCheck,
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                decoration: const InputDecoration(
                  labelText: 'English word',
                  prefixIcon: Icon(Icons.translate_rounded),
                ),
                onChanged: controller.updateEnglishWord,
              ),
              const SizedBox(height: 12),
              AppButton(
                label: state.isValidating ? 'Validating...' : 'Validate word',
                icon: Icons.spellcheck_rounded,
                onPressed: state.isValidating ? null : controller.validateWord,
              ),
              if (state.validation != null) ...[
                const SizedBox(height: 12),
                Text(
                  state.validation!.valid
                      ? 'Valid word'
                      : 'This does not look like a valid English word.',
                ),
              ],
            ],
          ),
        ),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Your Vietnamese meaning',
                  prefixIcon: Icon(Icons.lightbulb_outline_rounded),
                ),
                onChanged: controller.updateVietnameseMeaning,
              ),
              const SizedBox(height: 12),
              AppButton(
                label: state.isChecking ? 'Checking...' : 'Check meaning',
                icon: Icons.fact_check_rounded,
                onPressed: state.isChecking ? null : controller.checkMeaning,
              ),
              if (state.result != null) ...[
                const SizedBox(height: 12),
                Text(
                  state.result!.isCorrect
                      ? 'Correct'
                      : 'Not quite. Correct meaning: ${state.result!.translation}',
                ),
                if (state.result!.alternatives.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text('Alternatives: ${state.result!.alternatives.join(', ')}'),
                ],
              ],
            ],
          ),
        ),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: state.isExplaining ? 'Loading AI...' : 'Ask AI for explanation',
                      icon: Icons.smart_toy_outlined,
                      onPressed: state.isExplaining ? null : controller.explainWord,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppButton(
                      label: 'Reset',
                      variant: AppButtonVariant.outline,
                      onPressed: controller.reset,
                    ),
                  ),
                ],
              ),
              if (state.explanation != null) ...[
                const SizedBox(height: 16),
                Text(
                  state.explanation!.word,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(state.explanation!.meaning),
                if (state.explanation!.examples.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  ...state.explanation!.examples.map((example) => Text('• $example')),
                ],
                const SizedBox(height: 12),
                AppButton(
                  label: state.savedWord == null ? 'Save to dictionary' : 'Saved',
                  icon: Icons.bookmark_add_outlined,
                  onPressed: state.savedWord == null ? controller.saveExplainedWord : null,
                ),
              ],
            ],
          ),
        ),
        if (state.errorMessage != null)
          AppCard(
            child: Text(state.errorMessage!),
          ),
      ],
    );
  }
}
