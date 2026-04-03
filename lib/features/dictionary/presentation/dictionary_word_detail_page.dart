import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/widgets/app_button.dart';
import '../../../core/design/widgets/app_card.dart';
import '../../../core/design/widgets/app_page_scaffold.dart';
import '../../../core/theme/page_palettes.dart';
import '../application/dictionary_controller.dart';

class DictionaryWordDetailPage extends ConsumerWidget {
  const DictionaryWordDetailPage({
    super.key,
    required this.wordId,
  });

  final String wordId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final word = ref.watch(dictionaryWordDetailProvider(wordId));
    return AppPageScaffold(
      title: 'Word detail',
      subtitle: 'Inspect the saved word, its examples, and dictionary metadata.',
      paletteKey: AppPagePaletteKey.dictionary,
      children: [
        ...word.when(
          data: (value) => [
            AppCard(
              strong: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(value.word, style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  Text(value.meaning),
                  if (value.wordType.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text('Type: ${value.wordType}'),
                  ],
                  if (value.ipa.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text('IPA: ${value.ipa}'),
                  ],
                ],
              ),
            ),
            if (value.examples.isNotEmpty)
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Examples', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 12),
                    ...value.examples.map((example) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text('• $example'),
                        )),
                  ],
                ),
              ),
            AppCard(
              child: Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: value.isFavorite ? 'Unfavorite' : 'Favorite',
                      icon: value.isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
                      onPressed: () async {
                        await ref.read(dictionaryControllerProvider.notifier).toggleFavorite(value.id);
                        ref.invalidate(dictionaryWordDetailProvider(wordId));
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppButton(
                      label: 'Delete',
                      variant: AppButtonVariant.outline,
                      icon: Icons.delete_outline_rounded,
                      onPressed: () async {
                        await ref.read(dictionaryControllerProvider.notifier).deleteWord(value.id);
                        if (context.mounted) {
                          Navigator.of(context).pop();
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
          loading: () => const [
            AppCard(
              child: SizedBox(
                height: 120,
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
          ],
          error: (error, _) => [
            AppCard(child: Text(error.toString())),
          ],
        ),
      ],
    );
  }
}
