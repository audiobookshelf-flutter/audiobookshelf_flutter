import 'package:audiobookshelf/domain/offline/offline_state.dart';
import 'package:audiobookshelf/services/database/database_service.dart';
import 'package:audiobookshelf/singletons.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:audiobookshelf/utils/utils.dart';

final offlineStateProvider =
    StateNotifierProvider<OfflineNotifier, OfflineState>(
  (ref) => OfflineNotifier(),
);

class OfflineNotifier extends StateNotifier<OfflineState> {
  final DatabaseService _databaseService = getIt();

  OfflineNotifier() : super(OfflineState.initial()) {
    getBooks();
  }

  Future getBooks() async {
    try {
      state = OfflineState.loading();
      final books = (await _databaseService.getBooks().first)
          .map((book) => MediaHelpers.fromBook(book))
          .toList();
      state = OfflineState.loaded(
        books: books,
      );
    } on Exception {
      state = OfflineState.error("Something went wrong... :(");
    }
  }
}
