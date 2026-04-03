import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/dictionary/dictionary_models.dart';
import '../../../core/dictionary/dictionary_providers.dart';
import '../../../core/dictionary/dictionary_query_params.dart';

class DictionaryScreenState {
  const DictionaryScreenState({
    required this.query,
    required this.stats,
    required this.page,
    this.isMutating = false,
  });

  final DictionaryQueryParams query;
  final DictionaryStats stats;
  final DictionaryWordPage page;
  final bool isMutating;

  DictionaryScreenState copyWith({
    DictionaryQueryParams? query,
    DictionaryStats? stats,
    DictionaryWordPage? page,
    bool? isMutating,
  }) {
    return DictionaryScreenState(
      query: query ?? this.query,
      stats: stats ?? this.stats,
      page: page ?? this.page,
      isMutating: isMutating ?? this.isMutating,
    );
  }
}

class DictionaryController
    extends AutoDisposeAsyncNotifier<DictionaryScreenState> {
  static const _defaultQuery = DictionaryQueryParams();

  @override
  Future<DictionaryScreenState> build() async {
    return _load(_defaultQuery);
  }

  Future<void> refresh() async {
    state = await AsyncValue.guard(() => _load(state.requireValue.query));
  }

  Future<void> updateKeyword(String keyword) async {
    final nextQuery = state.requireValue.query.copyWith(
      keyword: keyword,
      page: 0,
    );
    state = await AsyncValue.guard(() => _load(nextQuery));
  }

  Future<void> updateFilter({String? wordType, bool? isFavorite}) async {
    final nextQuery = state.requireValue.query.copyWith(
      page: 0,
      wordType: wordType,
      isFavorite: isFavorite,
    );
    state = await AsyncValue.guard(() => _load(nextQuery));
  }

  Future<void> updatePage(int page) async {
    final nextQuery = state.requireValue.query.copyWith(page: page);
    state = await AsyncValue.guard(() => _load(nextQuery));
  }

  Future<void> toggleFavorite(String id) async {
    final current = state.requireValue;
    state = AsyncData(current.copyWith(isMutating: true));
    try {
      await ref.read(dictionaryApiProvider).toggleFavorite(id);
      state = AsyncData(await _load(current.query));
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  Future<void> deleteWord(String id) async {
    final current = state.requireValue;
    state = AsyncData(current.copyWith(isMutating: true));
    try {
      await ref.read(dictionaryApiProvider).deleteWord(id);
      state = AsyncData(await _load(current.query));
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  Future<DictionaryWord> addWord(DictionaryWord draft) async {
    final word = await ref
        .read(dictionaryApiProvider)
        .addWord(draft.toAddPayload());
    state = await AsyncValue.guard(() => _load(state.requireValue.query));
    return word;
  }

  Future<DictionaryScreenState> _load(DictionaryQueryParams query) async {
    final api = ref.read(dictionaryApiProvider);
    final stats = await api.getStats();
    final page = await api.searchWords(query);
    return DictionaryScreenState(query: query, stats: stats, page: page);
  }
}

final dictionaryControllerProvider =
    AutoDisposeAsyncNotifierProvider<
      DictionaryController,
      DictionaryScreenState
    >(DictionaryController.new);

final dictionaryWordDetailProvider = FutureProvider.autoDispose
    .family<DictionaryWord, String>((ref, wordId) async {
      return ref.watch(dictionaryApiProvider).getWordById(wordId);
    });
