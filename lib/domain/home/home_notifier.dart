import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:audiobookshelf/constants/app_constants.dart';
import 'package:audiobookshelf/models/book.dart';
import 'package:audiobookshelf/repositories/media/media_repository.dart';
import 'package:audiobookshelf/domain/home/home_state.dart';
import 'package:audiobookshelf/providers.dart';
import 'package:audiobookshelf/services/database/database_service.dart';
import 'package:get_it/get_it.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rxdart/rxdart.dart';

final homeStateProvider = StateNotifierProvider<HomeNotifier, HomeState>((ref) {
  return HomeNotifier(ref.watch(mediaRepositoryProvider));
});

class HomeNotifier extends StateNotifier<HomeState> {
  final MediaRepository? _repository;
  StreamSubscription<List<Book>>? booksSub;

  HomeNotifier(this._repository) : super(const HomeState.initial()) {
    getBooks();
  }

  Future refresh() async {
    List<MediaItem>? recentlyPlayed;
    List<MediaItem>? recentlyAdded;

    try {
      recentlyPlayed = await _repository!.getChildren(MediaIds.recentlyPlayed);
    } catch (e) {
      print(e);
    }
    try {
      recentlyAdded = await _repository!.getChildren(MediaIds.recentlyAdded);
    } catch (e) {
      print(e);
    }
    final downloaded = await _repository!.getChildren(MediaIds.downloads);
    booksSub ??= GetIt.I<DatabaseService>()
        .getBooks()
        .debounceTime(const Duration(milliseconds: 200))
        .listen((books) async {
      if (state is HomeStateLoaded) {
        final stateAsLoaded = (state as HomeStateLoaded);
        state = stateAsLoaded.copyWith(
            downloaded: await _repository!.getChildren(MediaIds.downloads));
      }
    });
    state = HomeState.loaded(
      recentlyPlayed: recentlyPlayed,
      recentlyAdded: recentlyAdded,
      downloaded: downloaded,
    );
  }

  Future<void> getBooks() async {
    try {
      state = const HomeState.loading();
      await refresh();
    } on Exception {
      state =
          const HomeState.error("Couldn't fetch books. Is the device online?");
    }
  }
}
