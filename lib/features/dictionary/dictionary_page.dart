import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/design/widgets/app_button.dart';
import '../../core/design/widgets/app_card.dart';
import '../../core/design/widgets/app_header_icon_action.dart';
import '../../core/design/widgets/app_page_scaffold.dart';
import '../../core/design/widgets/app_state_widgets.dart';
import '../../core/dictionary/dictionary_models.dart';
import '../../core/theme/page_palettes.dart';
import 'application/dictionary_controller.dart';

class DictionaryPage extends ConsumerStatefulWidget {
  const DictionaryPage({super.key});

  @override
  ConsumerState<DictionaryPage> createState() => _DictionaryPageState();
}

class _DictionaryPageState extends ConsumerState<DictionaryPage> {
  Timer? _searchDebounce;
  String _selectedFilter = 'ALL';

  @override
  void dispose() {
    _searchDebounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dictionary = ref.watch(dictionaryControllerProvider);

    return AppPageScaffold(
      title: 'Dictionary',
      subtitle:
          'Review saved words, clean up your list and jump back into practice.',
      paletteKey: AppPagePaletteKey.dictionary,
      onRefresh: () =>
          ref.read(dictionaryControllerProvider.notifier).refresh(),
      trailing: AppHeaderIconAction(
        tooltip: 'Review now',
        icon: Icons.auto_stories_rounded,
        onPressed: () => context.go('/dictionary/review'),
      ),
      children: [
        AppCard(
          strong: true,
          child: dictionary.when(
            data: (state) => LayoutBuilder(
              builder: (context, constraints) {
                final availableWidth =
                    constraints.hasBoundedWidth &&
                        constraints.maxWidth.isFinite &&
                        constraints.maxWidth > 0
                    ? constraints.maxWidth
                    : MediaQuery.sizeOf(context).width - 40;
                final compact = availableWidth < 360;
                final itemWidth = compact
                    ? availableWidth
                    : (availableWidth - 24) / 3;

                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    SizedBox(
                      width: itemWidth,
                      child: _MetricTile(
                        label: 'Saved words',
                        value: '${state.stats.totalWords}',
                      ),
                    ),
                    SizedBox(
                      width: itemWidth,
                      child: _MetricTile(
                        label: 'Mastered',
                        value: '${state.stats.masteredWords}',
                      ),
                    ),
                    SizedBox(
                      width: itemWidth,
                      child: _MetricTile(
                        label: 'Due now',
                        value: '${state.stats.dueReviews}',
                      ),
                    ),
                  ],
                );
              },
            ),
            loading: () => const SizedBox(
              height: 96,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (_, _) => Text(
              'Your saved totals could not be loaded right now.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppSectionHeader(
                title: 'Find and manage words',
                subtitle:
                    'Search quickly, narrow the list, then take the next useful action.',
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search_rounded),
                  labelText: 'Search words or meanings',
                ),
                onChanged: (value) {
                  _searchDebounce?.cancel();
                  _searchDebounce = Timer(
                    const Duration(milliseconds: 300),
                    () => ref
                        .read(dictionaryControllerProvider.notifier)
                        .updateKeyword(value),
                  );
                },
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _FilterChip(
                    label: 'All',
                    selected: _selectedFilter == 'ALL',
                    onSelected: () => _applyFilter('ALL'),
                  ),
                  _FilterChip(
                    label: 'Favorite',
                    selected: _selectedFilter == 'FAVORITE',
                    onSelected: () => _applyFilter('FAVORITE'),
                  ),
                  _FilterChip(
                    label: 'Verb',
                    selected: _selectedFilter == 'VERB',
                    onSelected: () => _applyFilter('VERB'),
                  ),
                  _FilterChip(
                    label: 'Noun',
                    selected: _selectedFilter == 'NOUN',
                    onSelected: () => _applyFilter('NOUN'),
                  ),
                  _FilterChip(
                    label: 'Adj',
                    selected: _selectedFilter == 'ADJ',
                    onSelected: () => _applyFilter('ADJ'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  AppButton(
                    label: 'Add word',
                    icon: Icons.add_rounded,
                    onPressed: () => _openAddWordSheet(context),
                  ),
                  AppButton(
                    label: 'Vocabulary check',
                    icon: Icons.fact_check_rounded,
                    variant: AppButtonVariant.outline,
                    onPressed: () => context.go('/vocabulary/check'),
                  ),
                  AppButton(
                    label: 'AI tests',
                    icon: Icons.quiz_rounded,
                    variant: AppButtonVariant.outline,
                    onPressed: () => context.go('/vocabulary-tests'),
                  ),
                ],
              ),
            ],
          ),
        ),
        ...dictionary.when(
          data: (state) {
            if (state.page.content.isEmpty) {
              return [
                AppCard(
                  child: AppEmptyState(
                    icon: Icons.menu_book_rounded,
                    title: 'No words found',
                    subtitle:
                        'Try a different filter or add a new word to start building your list.',
                    action: AppButton(
                      label: 'Add word',
                      icon: Icons.add_rounded,
                      onPressed: () => _openAddWordSheet(context),
                    ),
                  ),
                ),
              ];
            }

            return [
              ...state.page.content.map(
                (word) => AppCard(
                  child: Material(
                    type: MaterialType.transparency,
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(word.word),
                      subtitle: Text(
                        [
                          if (word.meaning.isNotEmpty) word.meaning,
                          if (word.wordType.isNotEmpty) word.wordType,
                        ].join(' • '),
                      ),
                      trailing: IconButton(
                        onPressed: () => ref
                            .read(dictionaryControllerProvider.notifier)
                            .toggleFavorite(word.id),
                        icon: Icon(
                          word.isFavorite
                              ? Icons.star_rounded
                              : Icons.star_border_rounded,
                        ),
                      ),
                      onTap: () => context.go('/dictionary/word/${word.id}'),
                    ),
                  ),
                ),
              ),
              if (state.page.totalPages > 1)
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Page ${state.query.page + 1} / ${state.page.totalPages}',
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: AppButton(
                              label: 'Previous',
                              variant: AppButtonVariant.outline,
                              onPressed: state.query.page == 0
                                  ? null
                                  : () => ref
                                        .read(
                                          dictionaryControllerProvider.notifier,
                                        )
                                        .updatePage(state.query.page - 1),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: AppButton(
                              label: 'Next',
                              onPressed:
                                  state.query.page >= state.page.totalPages - 1
                                  ? null
                                  : () => ref
                                        .read(
                                          dictionaryControllerProvider.notifier,
                                        )
                                        .updatePage(state.query.page + 1),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
            ];
          },
          loading: () => const [
            AppLoadingCard(height: 120, message: 'Loading your saved words...'),
          ],
          error: (_, _) => [
            AppErrorCard(
              title: 'Dictionary is unavailable',
              message: 'We could not load your saved words. Please try again.',
              onRetry: () =>
                  ref.read(dictionaryControllerProvider.notifier).refresh(),
            ),
          ],
        ),
      ],
    );
  }

  void _applyFilter(String filter) {
    setState(() => _selectedFilter = filter);
    switch (filter) {
      case 'FAVORITE':
        ref
            .read(dictionaryControllerProvider.notifier)
            .updateFilter(isFavorite: true);
        return;
      case 'VERB':
        ref
            .read(dictionaryControllerProvider.notifier)
            .updateFilter(wordType: 'VERB');
        return;
      case 'NOUN':
        ref
            .read(dictionaryControllerProvider.notifier)
            .updateFilter(wordType: 'NOUN');
        return;
      case 'ADJ':
        ref
            .read(dictionaryControllerProvider.notifier)
            .updateFilter(wordType: 'ADJ');
        return;
      default:
        ref
            .read(dictionaryControllerProvider.notifier)
            .updateFilter(wordType: null, isFavorite: null);
        return;
    }
  }

  Future<void> _openAddWordSheet(BuildContext context) async {
    final result = await showModalBottomSheet<DictionaryWord>(
      context: context,
      isScrollControlled: true,
      builder: (context) => const _AddWordSheet(),
    );
    if (result == null || !mounted) {
      return;
    }

    await ref.read(dictionaryControllerProvider.notifier).addWord(result);
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label),
        const SizedBox(height: 6),
        Text(value, style: Theme.of(context).textTheme.headlineSmall),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
    );
  }
}

class _AddWordSheet extends StatefulWidget {
  const _AddWordSheet();

  @override
  State<_AddWordSheet> createState() => _AddWordSheetState();
}

class _AddWordSheetState extends State<_AddWordSheet> {
  final _wordController = TextEditingController();
  final _meaningController = TextEditingController();
  final _typeController = TextEditingController();
  final _exampleController = TextEditingController();

  @override
  void dispose() {
    _wordController.dispose();
    _meaningController.dispose();
    _typeController.dispose();
    _exampleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _wordController,
            decoration: const InputDecoration(labelText: 'English word'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _meaningController,
            decoration: const InputDecoration(labelText: 'Meaning'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _typeController,
            decoration: const InputDecoration(labelText: 'Word type'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _exampleController,
            decoration: const InputDecoration(labelText: 'Example sentence'),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'Cancel',
                  variant: AppButtonVariant.outline,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppButton(
                  label: 'Save',
                  icon: Icons.check_rounded,
                  onPressed: () {
                    Navigator.of(context).pop(
                      DictionaryWord(
                        id: '',
                        word: _wordController.text.trim(),
                        meaning: _meaningController.text.trim(),
                        wordType: _typeController.text.trim().toUpperCase(),
                        ipa: '',
                        examples: _exampleController.text.trim().isEmpty
                            ? const <String>[]
                            : [_exampleController.text.trim()],
                        isFavorite: false,
                        masteryLevel: 0,
                        createdAt: null,
                        nextReviewDate: null,
                        sourceType: 'MANUAL',
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
