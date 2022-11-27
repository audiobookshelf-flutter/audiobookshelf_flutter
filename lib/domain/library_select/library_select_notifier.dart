import 'package:audiobookshelf/models/library.dart';
import 'package:audiobookshelf/repositories/media/media_repository.dart';
import 'package:audiobookshelf/domain/library_select/library_select_state.dart';
import 'package:audiobookshelf/providers.dart';
import 'package:collection/collection.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final libraryStateProvider =
    StateNotifierProvider<LibrarySelectNotifier, LibrarySelectState>((ref) {
  final repo = ref.watch(mediaRepositoryProvider);
  return LibrarySelectNotifier(ref, repo);
});

class LibrarySelectNotifier extends StateNotifier<LibrarySelectState> {
  final MediaRepository _repository;
  final Ref _ref;

  LibrarySelectNotifier(this._ref, this._repository)
      : super(const LibrarySelectState.initial()) {
    getLibraries();
  }

  Future<void> setLibrary(Library library) async {
    if (library.id == null) {
      return;
    }
    final prefsNotifier = _ref.read(preferencesProvider.notifier);
    final prefs = _ref.read(preferencesProvider);
    await prefsNotifier.save(prefs.copyWith(
      libraryId: library.id!,
    ));
    _repository.setLibraryId(library.id!);
    _repository.getServerAndLibrary();
    if (state is LibrarySelectStateLoaded) {
      state = (state as LibrarySelectStateLoaded).copyWith(
        selectedLibrary: library,
      );
    }
  }

  Future<void> getLibraries() async {
    try {
      state = const LibrarySelectState.loading();
      await _repository.getServerAndLibrary();
      final libs = await _repository.getLibraries();
      final selectedLibraryId = _ref.read(preferencesProvider).libraryId;
      var selectedLibrary =
          libs.firstWhereOrNull((element) => element.id == selectedLibraryId);
      if (selectedLibrary == null && libs.isNotEmpty) {
        selectedLibrary = libs.first;
        await setLibrary(selectedLibrary);
      }
      state = LibrarySelectState.loaded(
          libraries: libs, selectedLibrary: selectedLibrary);
    } on Exception {
      state = const LibrarySelectState.error(
          "Couldn't fetch libraries. Is the device online?");
    }
  }
}
